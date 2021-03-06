; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's entry point file.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "debug.inc"
%include "color.inc"
%include "opengl.inc"
%include "window.inc"

extern canvas.RenderCallback
extern canvas.ReshapeCallback
extern keyboard.SpecialCallback
extern game.TickCallback

extern canvas.SetBackgroundColor

global window:data
global main:function

section .data
  align 8
  window: istruc windowT
      at windowT.shape,       dd 640, 480
      at windowT.position,    dd 100, 100
      at windowT.aspect,      dq 0
      at windowT.fullscreen,  db 0
      at windowT.title,       db "Pacman-x86", 0
    iend

section .rodata
  align 8
  bgcolor: istruc colorT
      at colorT.r,          dd 0.0
      at colorT.g,          dd 0.0
      at colorT.b,          dd 0.0
      at colorT.a,          dd 1.0
    iend

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

    ; Setting the game's window to use double buffering.
    ; A double buffering uses two display buffers to smoothen animations. The next
    ; screen frame is prepared in a back buffer, while the current screen is held
    ; in a front buffer. Once preparation is done, the buffers must be swapped.
    ; @see https://www.opengl.org/resources/libraries/glut/spec3/node12.html
    mov   edi, GLUT_DOUBLE
    call  glutInitDisplayMode

    ; Setting the window's size.
    ; The window's size is just a suggestion to the window system for the window's
    ; initial size. The window system is not obligated to use this information.
    ; The reshape callback should be used to determine the window's true dimensions.
    ; @see https://www.opengl.org/resources/libraries/glut/spec3/node11.html
    mov   edi, dword [window + windowT.shapeX]
    mov   esi, dword [window + windowT.shapeY]
    call  glutInitWindowSize

    ; Setting the window's position.
    ; Similarly to when the window's size, its initial position is just a suggestion
    ; that the window system is not obligated to follow.
    mov   edi, dword [window + windowT.positionX]
    mov   esi, dword [window + windowT.positionY]
    call  glutInitWindowPosition

    ; Creating a GLUT window with the given title.
    ; Implicitly creates a new top-level window, provides the window's name to the
    ; window system and associates an OpenGL context to the new window.
    mov   edi, window + windowT.title
    call  glutCreateWindow

    ; Setting the game's window background color.
    ; Configures the game canvas to show a colored background if needed.
    mov   edi, bgcolor
    call  canvas.SetBackgroundColor

    ; Setting the callback for window re-paint event.
    ; This callback will be called repeatedly in order to render each frame.
    mov   edi, canvas.RenderCallback
    call  glutDisplayFunc

    ; Setting the callback for the window reshape event.
    ; This callback will be called whenever the window be resized.
    mov   edi, canvas.ReshapeCallback
    call  glutReshapeFunc

    ; Setting the callback for the keyboard's special buttons event.
    ; This callback will be called whenever a special key is pressed.
    mov   edi, keyboard.SpecialCallback
    call  glutSpecialFunc

    ; Setting the callback for the game's tick event.
    ; This callback will be called in regular periods to indicate that a game tick
    ; time has passed and thus the game state must be updated. The tick timing is
    ; directly determined by the game's frame rate.
    xor   edi, edi
    xor   edx, edx
    mov   esi, game.TickCallback
    call  glutTimerFunc

    ; Entering the event-processing infinite loop.
    ; Puts the OpenGL system to wait for events and trigger their handlers.
    call  glutMainLoop

    leave
    ret
