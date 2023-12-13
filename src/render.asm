; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's renderer and auxiliary rendering functions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2024-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"
%include "thirdparty/opengl.inc"

extern drawBoard

global render.DrawFrameCallback:function

section .text
  ; The frame drawing callback.
  ; Draws a new game frame to be displayed at the user's window.
  ; @param (none) The current game state is retrieved from memory.
  render.DrawFrameCallback:
    push  rbp
    mov   rbp, rsp

    mov   edi, GL_MODELVIEW
    call  glMatrixMode
    call  glLoadIdentity

    mov   edi, GL_BLEND
    call  glEnable

    mov   edi, GL_SRC_ALPHA
    mov   esi, GL_ONE_MINUS_SRC_ALPHA
    call  glBlendFunc

    debug call drawCheckboard
    call  drawBoard

    movss xmm0, [number.pOne]
    movss xmm1, xmm0
    movss xmm2, xmm0
    movss xmm3, xmm0
    call  glColor4d

    mov   esi, 0x00
    mov   edi, GL_TEXTURE_2D
    call  glBindTexture

    pop   rbp
    ret

section .rodata
  number.pOne:    dq float64(+1.0)
