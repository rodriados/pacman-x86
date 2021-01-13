; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's entry point file.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.inc"

extern canvas.Render

global main:function

section .rodata
  align 8
  windowHeight:     dw 320
  windowWidth:      dw 320
  windowPositionX:  dw 50
  windowPositionY:  dw 50
  windowTitle:      db "Pacman-x86", 0

section .text
  ; The game's entry point.
  ; @param edi The number of command line arguments.
  ; @param rsi A memory pointer to the list of command line arguments.
  main:
    push  rbp
    mov   rbp, rsp

    sub   rsp, 0x10

    ; Initializing the GLUT library.
    ; Here, the GLUT library is initialized and window session is negotiated with
    ; the window system. No rendering can occur before this call.
    mov   [rsp - 0x04], edi
    lea   rdi, [rsp - 0x04]
    call  glutInit

    ; Creating a GLUT window with the given title.
    ; Implicitly creates a new top-level window, provides the window's name to the
    ; window system and associates an OpenGL context to the new window.
    mov   edi, windowTitle
    call  glutCreateWindow

    ; Setting the window's size.
    ; The window's size is just a suggestion to the window system for the window's
    ; initial size. The window system is not obligated to use this information.
    ; The reshape callback should be used to determine the window's true dimensions.
    ; @see https://www.opengl.org/resources/libraries/glut/spec3/node11.html
    mov   edi, dword [windowWidth]
    mov   esi, dword [windowHeight]
    call  glutInitWindowSize

    ; Setting the window's position.
    ; Similarly to when the window's size, its initial position is just a suggestion
    ; that the window system is not obligated to follow.
    mov   edi, dword [windowPositionX]
    mov   esi, dword [windowPositionY]
    call  glutInitWindowPosition

    ; Setting the function for rendering game's canvas on the window.
    ; This function will be run repeatedly in order to render each frame.
    mov   edi, canvas.Render
    call  glutDisplayFunc

    call  glutMainLoop

    leave
    ret
