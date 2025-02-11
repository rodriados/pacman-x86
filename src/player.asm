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

global player.PauseCallback:function
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
  align 8
  state: istruc playerT
      at playerT.position,    dq 0, 0
      at playerT.direction,   dq 0, 0
    iend

section .rodata
  align 8
  position.start:         dq float64(+13.5), float64(+17.0)
  movement.speed:         dq float64( +0.3)

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
    movapd  xmm0, oword [position.start]
    movapd  oword [state + playerT.position], xmm0

    mov     qword [state + playerT.directionX], 0x00
    mov     qword [state + playerT.directionY], 0x00
    ret

  ; Updates the player position according to the direction currently set.
  ; @param (none) The event has no parameters.
  player.UpdatePositionCallback:
    movapd        xmm0, oword [state + playerT.position]
    movapd        xmm1, oword [state + playerT.direction]
    vbroadcastsd  ymm2, qword [movement.speed]

    vfmadd231pd   xmm0, xmm1, xmm2

    movapd        oword [state + playerT.position], xmm0
    ret

  ; Queries the player's current position.
  ; @return Pointer to the player's current position.
  player.QueryPosition:
    lea   rax, [state + playerT.position]
    ret

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.SetDirectionUpCallback:
    mov   rax, qword [number.zero]
    mov   rcx, qword [number.nOne]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.SetDirectionDownCallback:
    mov   rax, qword [number.zero]
    mov   rcx, qword [number.pOne]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.SetDirectionLeftCallback:
    mov   rax, qword [number.nOne]
    mov   rcx, qword [number.zero]
    jmp   _.player.CommitDirectionChange

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.SetDirectionRightCallback:
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
  player.PauseCallback:
    mov   qword [state + playerT.directionX], 0
    mov   qword [state + playerT.directionY], 0
    ret

section .rodata
  number.pOne:            dq float64(+1.0)
  number.nOne:            dq float64(-1.0)
  number.zero:            dq float64(+0.0)
