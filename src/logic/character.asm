; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's generic character logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira
bits 64

%use fp

%include "logic/character.inc"

global character.QueueDirection:function
global character.UpdatePositionCallback:function

section .text
  ; Queues a direction change for a character.
  ; @param rdi The character to queue a direction change for.
  ; @param rsi The direction to queue for the given character.
  character.QueueDirection:
    sal    rsi, 4
    movapd xmm0, oword [directions + rsi]
    movapd oword [rdi + characterT.direction.queue], xmm0
    ret

  ; Updates the position of a character according to its current state.
  ; @param rdi The pointer to the character to have its position updated.
  ; @param xmm0 The real time since the last position update.
  character.UpdatePositionCallback:
    movapd        xmm1, [rdi + characterT.position]
    movapd        xmm2, [rdi + characterT.direction.queue]
    mulsd         xmm0, [rdi + characterT.speed]

    vbroadcastsd  ymm0, xmm0
    vfmadd231pd   xmm1, xmm2, xmm0

    movapd        oword [rdi + characterT.position], xmm1
    ret

section .rodata
  align 16
  directions:
    dq float64( +0.0), float64( +0.0)
    dq float64( +0.0), float64( -1.0)
    dq float64( +0.0), float64( +1.0)
    dq float64( -1.0), float64( +0.0)
    dq float64( +1.0), float64( +0.0)
