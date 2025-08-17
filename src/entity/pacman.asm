; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's Pacman entity logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira
bits 64

%use fp

%include "logic/character.inc"

extern character.UpdatePositionCallback

global pacman.entity:data
global pacman.ResetCallback:function
global pacman.UpdatePositionCallback:function

section .data
  align 16
  pacman.entity: istruc characterT
      at characterT.position,        times 2 dq 0
      at characterT.direction,       times 2 dq 0
      at characterT.direction.queue, times 2 dq 0
      at characterT.track,           times 4 dq 0
      at characterT.speed,           dq 0
      at characterT.warping,         db 0
    iend

section .rodata
  align 16
  position.init:  dq float64(13.5), float64(23.0)
  speed.default:  dq float64( 9.5)

section .text
  ; Resets Pacman to its expected state at game start.
  ; @param (none) The event has no parameters.
  pacman.ResetCallback:
    xor rax, rax
    mov rdi, pacman.entity
    mov rcx, characterT_size
    rep stosb

    movapd xmm0, oword [position.init]
    movapd oword [pacman.entity + characterT.position], xmm0

    mov rax, qword [speed.default]
    mov qword [pacman.entity + characterT.speed], rax
    ret

  ; Ticks Pacman position update.
  ; @param xmm0 The real time since the last logic tick.
  pacman.UpdatePositionCallback:
    lea  rdi, [pacman.entity]
    call character.UpdatePositionCallback
    ret
