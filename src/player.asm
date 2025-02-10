; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's player logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2022-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"

extern logArrowUpPress
extern logArrowDownPress
extern logArrowLeftPress
extern logArrowRightPress
extern logSpacePress

global player.ResetState:function
global player.QueryPosition:function
global player.KeyArrowUpCallback:function
global player.KeyArrowDownCallback:function
global player.KeyArrowLeftCallback:function
global player.KeyArrowRightCallback:function
global player.KeySpaceCallback:function
global player.UpdatePosition

; Represents the player's state.
; This structure is responsible for managing the player's global state, which will
; be manipulated during gameplay.
struc playerT
  .position:              resq 2
  .direction:             resq 2
endstruc

section .data
  align 8
  state: istruc playerT
      at playerT.position,    dq 0, 0
      at playerT.direction,   dd 0, 0
    iend

; Defining macros to help inquiring the player's position.
; @param (none) Gets the requested position dimension by its name.
%define playerT.positionX   (playerT.position + 0)
%define playerT.positionY   (playerT.position + 8)

; Defining macros to help inquiring the player's direction.
; @param (none) Gets the requested direction dimension by its name.
%define playerT.directionX  (playerT.direction + 0)
%define playerT.directionY  (playerT.direction + 8)

section .text
  ; Resets the player to its expected state at game start.
  ; @param (none) The event has no parameters.
  player.ResetState:
    push  rbp
    mov   rbp, rsp

    mov   rcx, qword [initial.positionX]
    mov   rdx, qword [initial.positionY]

    mov   qword [state + playerT.positionX], rcx
    mov   qword [state + playerT.positionY], rdx
    mov   dword [state + playerT.direction], 0

    leave
    ret

  ; Updates the player position according to the direction currently set.
  ; @param (none) The event has no parameters.
  player.UpdatePosition:
    push  rbp
    mov   rbp, rsp

    movq  xmm0, qword [state + playerT.positionX]
    movq  xmm1, qword [state + playerT.positionY]
    movq  xmm2, qword [state + playerT.directionX]
    movq  xmm3, qword [state + playerT.directionY]
    movq  xmm4, qword [movement.delta]

    mulsd xmm2, xmm4
    mulsd xmm3, xmm4

    addsd xmm0, xmm2
    addsd xmm1, xmm3

    movq  qword [state + playerT.positionX], xmm0
    movq  qword [state + playerT.positionY], xmm1

    leave
    ret

  ; Queries the player's current position.
  ; @return Pointer to the player's current position.
  player.QueryPosition:
    lea   rax, [state + playerT.position]
    ret

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowUpCallback:
    mov   rax, qword [number.zero]
    mov   rcx, qword [number.nOne]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowDownCallback:
    mov   rax, qword [number.zero]
    mov   rcx, qword [number.pOne]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowLeftCallback:
    mov   rax, qword [number.nOne]
    mov   rcx, qword [number.zero]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowRightCallback:
    mov   rax, qword [number.pOne]
    mov   rcx, qword [number.zero]
    jmp   _.player.CommitDirectionChange

  ; Commits a previously configured direction change.
  ; @param rax The new X-axis speed.
  ; @param rcx The new Y-axis speed.
  _.player.CommitDirectionChange:
    mov   qword [state + playerT.directionX], rax
    mov   qword [state + playerT.directionY], rcx
    ret

  ; The player controller's callback for a space key press event.
  ; @param (none) The event has no parameters.
  player.KeySpaceCallback:
    mov   qword [state + playerT.directionX], 0
    mov   qword [state + playerT.directionY], 0
    ret

section .rodata
  initial.positionX:      dq float64(+13.5)
  initial.positionY:      dq float64(+17.0)

  movement.delta:         dq float64(+0.2)

  number.pOne:            dq float64(+1.0)
  number.nOne:            dq float64(-1.0)
  number.zero:            dq float64(+0.0)
