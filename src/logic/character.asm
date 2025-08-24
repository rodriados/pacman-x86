; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's generic character logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"
%include "board.inc"
%include "logic/character.inc"

extern board.GetState

global character.QueueDirection:function
global character.UpdatePositionCallback:function

section .data
  floor:  equ 0x01
  ceil:   equ 0x02

section .text
  ; Queues a direction change for a character.
  ; @param rdi The character to queue a direction change for.
  ; @param rsi The direction to queue for the given character.
  character.QueueDirection:
    sal    rsi, 0x04
    movapd xmm0, oword [directions + rsi]
    movapd oword [rdi + characterT.direction.queue], xmm0
    ret

  ; Updates the position of a character according to its current state.
  ; @param rdi The pointer to the character to have its position updated.
  ; @param xmm0 The real time since the last position update.
  character.UpdatePositionCallback:
      push rbp
      mov  rbp, rsp
      sub  rsp, 0x08

      push rbx
      mov  rbx, rdi

    %ifdef PACMAN_DEBUG_USE_STEADY_TICK
      movq  xmm0, qword [steadytick]
    %endif

      ; In order to avoid repetitively requesting data from the memory throughout
      ; the execution of this function, we retrieve all the data initially needed
      ; into designated registers that must be preserved until the end.
      movapd xmm1, oword [rbx + characterT.position]
      movapd xmm2, oword [rbx + characterT.direction]
      movapd xmm3, oword [rbx + characterT.direction.queue]
      vmulsd xmm4, xmm0, qword [rbx + characterT.speed]
      movapd xmm5, xmm1

      ; Here, we validate whether the character is stopped or generally moving on
      ; a north-west or south-east direction. Similarly, we check and flag whether
      ; there is any direction change request in queue.
      vhaddpd   xmm0, xmm2, xmm3
      cvttpd2dq xmm0, xmm0
      pextrd    r10d, xmm0, 0x00
      pextrd    r11d, xmm0, 0x01

      ; To calculate the character's next movement, we first create a reference
      ; point that is located at the edge of the square that the character is currently
      ; moving torwards. This point will be the reference for any directional change.
      cmp r10d, 0x00
      jg  .reference.southeast
      je  .reference.ready          ; character has not moved yet

    .reference.northwest:
      roundpd xmm5, xmm5, floor
      jmp     .reference.ready

    .reference.southeast:
      roundpd xmm5, xmm5, ceil

      ; A distance between the current character position and the reference point
      ; is calculated to validate whether an orthogonal turn is possible.
    .reference.ready:
      vsubpd  xmm6, xmm5, xmm1      ; xmm6: distanceToReferencePoint
      andpd   xmm6, [fabsmask]
      haddpd  xmm6, xmm6

      ; Check whether an orthogonal turn is queued. If not, then we can skip and
      ; try performing a parallel go-around or keep going the same direction.
    .turn.orthogonal.try:
      vcmpeqpd  xmm8, xmm2, [zero]
      vcmpneqpd xmm9, xmm3, [zero]
      andpd     xmm8, xmm9
      movmskpd  eax,  xmm8
      test      eax,  11b
      jz        .turn.parallel.try

      ; If the character has not yet moved, then a turn is always allowed. Otherwise,
      ; we must validate if it is close enough to a square border to allow a turn.
      cmp r10d, 0x00
      je  .turn.orthogonal.allowed

      comisd  xmm6, xmm4
      jnb     .position.update

      ; Once the character is in a position that allows an orthogonal turn, we must
      ; validate if the board allows it to occupy the requested position.
    .turn.orthogonal.allowed:
      vaddpd    xmm8, xmm5, xmm3
      cvttpd2dq xmm8, xmm8

      pextrd edi, xmm8, 0x00
      pextrd esi, xmm8, 0x01
      call   board.GetState

      cmp al, board.square.walkable
      jl  .position.update

      ; If all conditions are met and an orthogonal turn is possible, then we perform
      ; the turn by discovering the new track and updating the character's direction.
    .turn.orthogonal.confirmed:
      subsd   xmm4, xmm6
      movapd  xmm1, xmm5

      call  _.character.DiscoverTrack
      jmp   .direction.update

      ; If no orthogonal turn is queued, then we check if a go-around or a keep-going
      ; is in queue. If not, we skip the character's direction update.
    .turn.parallel.try:
      cmp r11d, 0x00
      je  .position.update

      ; Update the character's position according to the queued direction. To get
      ; here, all turn validations must have already been performed.
    .direction.update:
      movapd  xmm2, xmm3
      xorpd   xmm3, xmm3

      movapd  oword [rbx + characterT.direction], xmm2
      movapd  oword [rbx + characterT.direction.queue], xmm3

      ; Moves the character by the needed time-offset displacement, in the direction
      ; previously set and within its track bounds. If the character has not moved
      ; before the current frame, then the position update is skipped until a frame
      ; after a direction has been set. This delays response by one frame but guarantees
      ; that all direction values are correctly set here before any movement.
    .position.update:
      cmp   r10d, 0x00
      je    .skip

      shufpd  xmm4, xmm4, 0x00
      mulpd   xmm4, xmm2
      addpd   xmm1, xmm4

      maxpd   xmm1, oword [rbx + characterT.track.begin]
      minpd   xmm1, oword [rbx + characterT.track.end]

      movapd  oword [rbx + characterT.position], xmm1

    .skip:
      pop   rbx

      leave
      ret

  ; Discovers a track in the board that a character may traverse.
  ; Characters are confined to tracks to simply their position update logic and
  ; guaranteeing that they do not move to squares they are not allowed to occupy.
  ; @param rbx The pointer to the character to be have its track updated.
  ; @param xmm1 The reference point to discover a track that passes through.
  ; @param xmm3 The direction to which the track must be discovered.
  _.character.DiscoverTrack:
      movapd    xmm7, xmm3

      ; Checks whether the track to be discovered is oriented vertically or horizontally,
      ; and determines the directions that need to be traversed.
      cmpeqpd   xmm7, [zero]
      movmskpd  eax,  xmm7

      cmp eax, 01b
      je  .track.vertical

      cmp eax, 10b
      je  .track.horizontal
      jmp .skip

      ; Defines the directions that the track must strech to from the given reference
      ; point. The opposite orientation to character movement must also be searched.
    .track.vertical:
      cvttpd2dq xmm10, oword [north]
      cvttpd2dq xmm11, oword [south]
      jmp .search.extremity

    .track.horizontal:
      cvttpd2dq xmm10, oword [west]
      cvttpd2dq xmm11, oword [east]

      ; Search for each extremity of the new track and save in the given character
      ; pointer. Each extremity corresponds to the furthermost points that the character
      ; can move in the given direction from the reference point.
    .search.extremity:
      movapd  xmm0, xmm10
      call    _.character.FindTrackExtremity
      movapd  oword [rbx + characterT.track.begin], xmm8

      movapd  xmm0, xmm11
      call    _.character.FindTrackExtremity
      movapd  oword [rbx + characterT.track.end], xmm8

    .skip:
      ret

  ; Finds the extremity of a track that passes through the given reference point
  ; by traversing the board in the given direction.
  ; @param xmm0 The direction to which the track extremity must be found.
  ; @param xmm1 The reference point that the track streches from.
  ; @return xmm8 The extremity point for the given track in the direction.
  _.character.FindTrackExtremity:
      cvttpd2dq xmm8, xmm1

    .continue:
      paddd   xmm8, xmm0
      pextrd  edi,  xmm8, 0x00
      pextrd  esi,  xmm8, 0x01
      call    board.GetState

      cmp al, board.square.walkable
      jge .continue

    .found:
      psubd     xmm8, xmm0
      cvtdq2pd  xmm8, xmm8

      ret

section .rodata
  align 16
  directions:
    zero:   dq float64(+0.0), float64(+0.0)
    north:  dq float64(+0.0), float64(-1.0)
    south:  dq float64(+0.0), float64(+1.0)
    west:   dq float64(-1.0), float64(+0.0)
    east:   dq float64(+1.0), float64(+0.0)
  fabsmask: times 2 dq 0x7FFFFFFFFFFFFFFF
  steadytick: dq float64(0.015)
