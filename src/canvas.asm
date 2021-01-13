; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's canvas renderer and manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.inc"

global canvas.Render:function

section .rodata
  align 8
  windowBgColor:    dq  0.0,  0.0,  0.0,  1.0

section .data
  ; Manages the game's canvas rendering.
  ; @preserve (none)
  canvas.Render:
    push  rbp
    mov   rbp, rsp

    movss xmm0, [windowBgColor +  0]
    movss xmm1, [windowBgColor +  8]
    movss xmm2, [windowBgColor + 16]
    movss xmm3, [windowBgColor + 24]
    call  glClearColor

    ; Clearing the window canvas.
    ; Clears the color buffers in the whole game's window canvas, and sets it to
    ; the clear color previously defined. 
    mov   edi, GL_COLOR_BUFFER_BIT
    call  glClear

    mov   edi, GL_QUADS
    call  glBegin     

    call  glEnd
    call  glFlush

    pop   rbp
    ret
