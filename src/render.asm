; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's renderer and auxiliary rendering functions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2024-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"
%include "logic/character.inc"
%include "thirdparty/opengl.inc"

extern pacman.entity
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
    call  _.render.DrawPlayer

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

    push  r12
    push  r13
    push  r14
    push  r15

    mov   edi, GL_TEXTURE_2D
    call  glEnable

    mov   r12, qword [number.zero]
    mov   r13, qword [number.pOne]
    mov   r14, qword [number.p28]
    mov   r15, qword [number.p31]

    movq  xmm0, r13
    movq  xmm1, r13
    movq  xmm2, r13
    movq  xmm3, r13
    call  glColor4d

    mov   edi, GL_TEXTURE_2D
    mov   esi, dword [sprite.board]
    call  glBindTexture

    mov   edi, GL_POLYGON
    call  glBegin

    movq  xmm0, r12
    movq  xmm1, r12
    call  glTexCoord2d

    movq  xmm0, r12
    movq  xmm1, r12
    call  glVertex2d

    movq  xmm0, r13
    movq  xmm1, r12
    call  glTexCoord2d

    movq  xmm0, r14
    movq  xmm1, r12
    call  glVertex2d

    movq  xmm0, r13
    movq  xmm1, r13
    call  glTexCoord2d

    movq  xmm0, r14
    movq  xmm1, r15
    call  glVertex2d

    movq  xmm0, r12
    movq  xmm1, r13
    call  glTexCoord2d

    movq  xmm0, r12
    movq  xmm1, r15
    call  glVertex2d

    call  glEnd

    mov   edi, GL_TEXTURE_2D
    call  glDisable

    pop   r15
    pop   r14
    pop   r13
    pop   r12

    pop   rbp
    ret

  ; Renders the player character.
  ; Draws the player by querying its current position.
  ; @param (none) The player position is queried with a function call.
  _.render.DrawPlayer:
    push  rbp
    mov   rbp, rsp

    push  r12
    push  r13
    push  r14
    push  r15

    mov   r12, qword [number.zero]
    mov   r13, qword [number.pOne]

    lea   rax, [pacman.entity + characterT.position]
    mov   r14, qword [rax + 0x00]
    mov   r15, qword [rax + 0x08]

    movq  xmm0, r13
    movq  xmm1, r12
    movq  xmm2, r12
    movq  xmm3, r13
    call  glColor4d

    mov   edi, GL_POLYGON
    call  glBegin

    movq  xmm0, r14
    movq  xmm1, r15
    call  glVertex2d

    movq  xmm0, r14
    movq  xmm1, r15
    movq  xmm2, r13
    addsd xmm0, xmm2
    call  glVertex2d

    movq  xmm0, r14
    movq  xmm1, r15
    movq  xmm2, r13
    addsd xmm0, xmm2
    addsd xmm1, xmm2
    call  glVertex2d

    movq  xmm0, r14
    movq  xmm1, r15
    movq  xmm2, r13
    addsd xmm1, xmm2
    call  glVertex2d

    call  glEnd

    pop   r15
    pop   r14
    pop   r13
    pop   r12

    pop   rbp
    ret

section .rodata
  number.zero:    dq float64(+0.0)
  number.pOne:    dq float64(+1.0)
  number.p28:     dq float64(+28.)
  number.p31:     dq float64(+31.)
