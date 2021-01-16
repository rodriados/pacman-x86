; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's canvas renderer and manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%use fp

%include "opengl.asm"

%include "color.asm"
%include "window.asm"

extern window

global canvas.GetAspectRatio:function
global canvas.RenderCallback:function
global canvas.ReshapeCallback:function
global canvas.SetBackgroundColor:function
global canvas.ToggleFullscreen:function

extern testScene

; Preserves the game's canvas state before a fullscreen request.
; This is needed because when a fullscreen operation triggers the canvas' reshape
; callback, the window's global state is updated.
struc preserveT
  .shape:         resd 2      ; The preserved window's width and height.
  .position:      resd 2      ; The preserved window's position on screen.
endstruc

section .text
  ; The game's window re-paint event handler.
  ; Manages the game's canvas rendering.
  ; @param (none)
  canvas.RenderCallback:
    push  rbp
    mov   rbp, rsp

    ; Clearing the window canvas.
    ; Clears the color buffers in the whole game's window canvas, and sets it
    ; to the clear color previously defined. 
    mov   edi, GL_COLOR_BUFFER_BIT
    call  glClear

    call  testScene

    pop   rbp
    ret


  ; The game's window reshape event handler.
  ; Adjusts the window's properties whenever it is resized.
  ; @param rdi The window's new width.
  ; @param rsi The window's new height.
  canvas.ReshapeCallback:
    push  rbp
    mov   rbp, rsp
    sub   rsp, 0x10

    cmp   esi, 0x00
    mov   eax, 0x01
    cmove esi, eax

    mov   dword [rbp - 4], edi
    mov   dword [rbp - 8], esi

    mov   dword [windowT.shapeX(window)], edi
    mov   dword [windowT.shapeY(window)], esi

    ; Configuring the game's window viewport.
    ; The viewport refers to the display area on the screen.
    mov   edi, 0x00
    mov   esi, 0x00
    mov   edx, dword [rbp - 4]
    mov   ecx, dword [rbp - 8]
    call  glViewport

    ; Configuring the window's clipping area.
    ; The clipping area refers to the area that is captured by the camera and, therefore
    ; it is the area that can be seen on the window.
    mov   edi, GL_PROJECTION
    call  glMatrixMode
    call  glLoadIdentity

    ; Mapping the clipping area to the viewport.
    ; Calculates the window's new aspect ratio and adjusts the mapping between the
    ; window's clipping area and its viewport.
    call  canvas.GetAspectRatio
    call  _.canvas.SetCanvasOrthographicMatrix

    leave
    ret


  ; Toggles the game's window fullscreen mode.
  ; When toggled off of the fullscreen mode, the screen must come back and be redrawn
  ; to its previous size and position.
  ; @param (none)
  canvas.ToggleFullscreen:
    xor   byte [window + windowT.fullscreen], 0x01
    jnz   _.fullscreen.ToggleOn
    jmp   _.fullscreen.ToggleOff
    ret


  ; Defines the game's background color.
  ; @param rdi The color to paint the background with.
  canvas.SetBackgroundColor:
    movss xmm0, [rdi + colorT.r]
    movss xmm1, [rdi + colorT.g]
    movss xmm2, [rdi + colorT.b]
    movss xmm3, [rdi + colorT.a]
    call  glClearColor
    ret


  ; Informs the window's current aspect ratio.
  ; @return xmm0 The window's aspect ratio.
  canvas.GetAspectRatio:
    pxor      xmm0, xmm0
    pxor      xmm1, xmm1

    cvtsi2sd  xmm0, dword [windowT.shapeX(window)]
    cvtsi2sd  xmm1, dword [windowT.shapeY(window)]
    divsd     xmm0, xmm1

    movsd     qword [window + windowT.aspect], xmm0
    ret


  ; Multiplies the current clipping matrix with an orthographic matrix.
  ; @param xmm0 The window's new aspect ratio.
  _.canvas.SetCanvasOrthographicMatrix:
      movsd   xmm2, qword [neg1f]
      movsd   xmm3, qword [pos1f]
      movsd   xmm4, xmm2
      movsd   xmm5, xmm3
      movsd   xmm6, xmm0

      comisd  xmm0, xmm3
      jb      .taller

    ; If the window's width is bigger than its height, as usually, then we must
    ; control the viewport's area accordingly.
    .wider:
      mulsd   xmm0, xmm2
      movsd   xmm1, xmm6
      jmp     .ready

    ; If the window's height is bigger than its width, then we must control the
    ; viewport's area accordingly, leaving blank vertical spaces if needed.
    .taller:
      movsd   xmm0, xmm2
      movsd   xmm1, xmm3
      divsd   xmm2, xmm6
      divsd   xmm3, xmm6

    .ready:
      call  glOrtho
      ret


section .bss
  preserve:       resb preserveT_size

section .text
  ; Copies the current window's state and toggles the fullscreen mode on.
  ; @param (none)
  _.fullscreen.ToggleOn:
    glutGetState GLUT_WINDOW_X
    mov   dword [preserve + preserveT.position + 0], eax

    glutGetState GLUT_WINDOW_Y
    mov   dword [preserve + preserveT.position + 4], eax

    mov   ecx, dword [windowT.shapeX(window)]
    mov   edx, dword [windowT.shapeY(window)]
    mov   dword [preserve + preserveT.shape + 0], ecx
    mov   dword [preserve + preserveT.shape + 4], edx

    call  glutFullScreen
    ret


  ; Restores the current window's previous state and leaves fullscreen mode.
  ; @param (none)
  _.fullscreen.ToggleOff:
    mov   edi, dword [preserve + preserveT.shape + 0]
    mov   esi, dword [preserve + preserveT.shape + 4]
    mov   dword [windowT.shapeX(window)], edi
    mov   dword [windowT.shapeY(window)], esi
    call  glutReshapeWindow

    mov   edi, dword [preserve + preserveT.position + 0]
    mov   esi, dword [preserve + preserveT.position + 4]
    mov   dword [windowT.positionX(window)], edi
    mov   dword [windowT.positionY(window)], esi
    call  glutPositionWindow
    ret


section .rodata
  neg1f:          dq float64(-1.0)
  pos1f:          dq float64(+1.0)
