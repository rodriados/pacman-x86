; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's renderer and auxiliary rendering functions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2024-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"
%include "thirdparty/opengl.inc"

extern drawDummyPlayer
extern sprite.board

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
    call  _.render.DrawBoard
    call  drawDummyPlayer

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

  ; Renders the game board.
  ; Draws the game board from sprite that's previously loaded into memory.
  ; @param (none) The game board texture is retrieved from memory.
  _.render.DrawBoard:
    push  rbp
    mov   rbp, rsp

    mov   edi, GL_TEXTURE_2D
    call  glEnable

    movsd xmm5, [number.zero]
    movsd xmm6, [number.pOne]
    movsd xmm7, [number.p28]
    movsd xmm8, [number.p31]

    movsd xmm0, xmm6
    movsd xmm1, xmm6
    movsd xmm2, xmm6
    movsd xmm3, xmm6
    call  glColor4d

    mov   edi, GL_TEXTURE_2D
    mov   esi, [sprite.board]
    call  glBindTexture

    mov   edi, GL_POLYGON
    call  glBegin

    movsd xmm0, xmm5
    movsd xmm1, xmm5
    call  glTexCoord2d
    call  glVertex2d

    movsd xmm0, xmm6
    call  glTexCoord2d
    movsd xmm0, xmm7
    call  glVertex2d

    movsd xmm0, xmm6
    movsd xmm1, xmm6
    call  glTexCoord2d
    movsd xmm0, xmm7
    movsd xmm1, xmm8
    call  glVertex2d

    movsd xmm0, xmm5
    movsd xmm1, xmm6
    call glTexCoord2d
    movsd xmm1, xmm8
    call  glVertex2d

    call  glEnd

    mov   edi, GL_TEXTURE_2D
    call  glDisable

    pop   rbp
    ret

section .rodata
  number.zero:    dq float64(+0.0)
  number.pOne:    dq float64(+1.0)
  number.p28:     dq float64(+28.)
  number.p31:     dq float64(+31.)
