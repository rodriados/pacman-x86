; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's player logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2022-present Rodrigo Siqueira
bits 64

%use fp

global player.QueryPosition:function

global player.ResetCallback:function
global player.SetDirectionUpCallback:function
global player.SetDirectionDownCallback:function
global player.SetDirectionLeftCallback:function
global player.SetDirectionRightCallback:function
global player.UpdatePositionCallback:function

; Represents the player's state.
; This structure is responsible for managing the player's global state, which will
; be manipulated during gameplay.
struc playerT
  .position:              resq 2
  .direction:             resq 2
endstruc

section .data
  align 16
  state: istruc playerT
      at playerT.position,    dq 0, 0
      at playerT.direction,   dq 0, 0
    iend

section .rodata
  align 16
  direction.up:           dq float64( +0.0), float64( -1.0)
  direction.down:         dq float64( +0.0), float64( +1.0)
  direction.left:         dq float64( -1.0), float64( +0.0)
  direction.right:        dq float64( +1.0), float64( +0.0)
  position.init:          dq float64(+13.5), float64(+23.0)
  movement.speed:         dq float64( +9.5)

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
  player.ResetCallback:
    movapd  xmm0, oword [position.init]
    movapd  oword [state + playerT.position], xmm0

    mov     qword [state + playerT.directionX], 0x00
    mov     qword [state + playerT.directionY], 0x00
    ret

  ; Updates the player position according to the direction currently set.
  ; @param xmm0 The real time since the last position update.
  player.UpdatePositionCallback:
    movapd        xmm1, [state + playerT.position]
    movapd        xmm2, [state + playerT.direction]
    mulsd         xmm0, [movement.speed]

    vbroadcastsd  ymm0, xmm0
    vfmadd231pd   xmm1, xmm2, xmm0

    movapd        oword [state + playerT.position], xmm1
    ret

  ; Queries the player's current position.
  ; @return Pointer to the player's current position.
  player.QueryPosition:
    lea   rax, [state + playerT.position]
    ret

  ; The callback for changing player movement direction upwards.
  ; @param (none) The event has no parameters.
  player.SetDirectionUpCallback:
    movapd  xmm0, oword [direction.up]
    movapd  oword [state + playerT.direction], xmm0
    ret

  ; The callback for changing player movement direction downwards.
  ; @param (none) The event has no parameters.
  player.SetDirectionDownCallback:
    movapd  xmm0, oword [direction.down]
    movapd  oword [state + playerT.direction], xmm0
    ret

  ; The callback for changing player movement direction backwards.
  ; @param (none) The event has no parameters.
  player.SetDirectionLeftCallback:
    movapd  xmm0, oword [direction.left]
    movapd  oword [state + playerT.direction], xmm0
    ret

  ; The callback for changing player movement direction forwards.
  ; @param (none) The event has no parameters.
  player.SetDirectionRightCallback:
    movapd  xmm0, oword [direction.right]
    movapd  oword [state + playerT.direction], xmm0
    ret
