; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's canvas renderer and manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%use fp

%include "color.inc"
%include "window.inc"

%include "thirdparty/glfw.inc"
%include "thirdparty/opengl.inc"

global canvas.RenderCallback:function
global canvas.ReshapeCallback:function
global canvas.MoveCallback:function
global canvas.GetAspectRatio:function
global canvas.SetBackgroundColor:function

extern window
extern render.DrawFrameCallback

section .text
  ; The game's window re-paint event handler.
  ; Manages the game's canvas rendering.
  ; @param rdi The window's context pointer.
  canvas.RenderCallback:
    push  rbp
    mov   rbp, rsp

    mov   rbx, rdi            ; Preserving the window context pointer.

    ; Clearing the window canvas.
    ; Clears the color buffers in the whole game's window canvas, and sets it to
    ; the clear color previously defined.
    mov   edi, GL_COLOR_BUFFER_BIT
    call  glClear

    ; Delegates frame redering to the game logic.
    ; Calls the game logic module to draw a frame when it is time to perform a window
    ; repaint. This delegation achieves centralizing all logic related to the game's
    ; controls, progress and drawing in a single module.
    call  render.DrawFrameCallback

    ; Shows the newly drawn frame in the window canvas.
    ; Once a new frame has been thoroughly drawn in the back buffer, we must bring
    ; it to the front so it is displayed by the window and a new can be drawn.
    mov   rdi, rbx
    call  glfwSwapBuffers

    pop   rbp
    ret

  ; The game's window reshape event handler.
  ; Adjusts the window's properties whenever it is resized.
  ; @param rdi The window's context pointer.
  ; @param esi The window's new width.
  ; @param edx The window's new height.
  canvas.ReshapeCallback:
    push  rbp
    mov   rbp, rsp

    cmp   edx, 0x00
    mov   eax, 0x01
    cmove edx, eax

    mov   dword [window + windowT.shapeX], esi
    mov   dword [window + windowT.shapeY], edx

    ; Configuring the game's window viewport.
    ; The viewport refers to the display area on the screen.
    mov   ecx, edx
    mov   edx, esi
    mov   edi, 0x00
    mov   esi, 0x00
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

  ; The game's window move event handler.
  ; Adjusts the window's properties whenever it is moved.
  ; @param rdi The window's context pointer.
  ; @param esi The window's new width.
  ; @param edx The window's new height.
  canvas.MoveCallback:
    mov   dword [window + windowT.positionX], esi
    mov   dword [window + windowT.positionY], edx
    ret

  ; Informs the window's current aspect ratio.
  ; @return xmm0 The window's aspect ratio.
  ; @return xmm1 The window's length.
  ; @return xmm2 The window's height.
  canvas.GetAspectRatio:
    pxor      xmm0, xmm0
    pxor      xmm1, xmm1
    pxor      xmm2, xmm2

    cvtsi2sd  xmm1, dword [window + windowT.shapeX]
    cvtsi2sd  xmm2, dword [window + windowT.shapeY]
    movsd     xmm0, xmm1
    divsd     xmm0, xmm2

    movsd     qword [window + windowT.aspect], xmm0
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

  ; Multiplies the current clipping matrix with an orthographic matrix. This function
  ; effectively determines the window coordinate system used by the game.
  ; @param xmm0 The window's new aspect ratio.
  ; @param xmm1 The window's new length.
  ; @param xmm2 The window's new height.
  _.canvas.SetCanvasOrthographicMatrix:
      push    rbp
      mov     rbp, rsp

      movsd   xmm9, xmm0              ; Preserving the window's aspect ratio.

      movsd   xmm0, [coords.minX]
      movsd   xmm1, [coords.maxX]
      movsd   xmm2, [coords.maxY]
      movsd   xmm3, [coords.minY]
      movsd   xmm4, [number.mOne]
      movsd   xmm5, [number.pOne]

      movsd   xmm6, [coords.scaleX]
      movsd   xmm7, [coords.scaleY]

      movsd   xmm8, xmm6
      divsd   xmm8, xmm7
      comisd  xmm9, xmm8
      jb      .window.taller

    ; The game window is wider than the aspect ratio used internally by the game.
    ; Therefore, we must draw vertical stripes on the right and left of our canvas
    ; so that the game is horizontally centered on the window.
    .window.wider:
      movsd   xmm8, xmm9
      mulsd   xmm8, xmm7
      subsd   xmm8, xmm1
      divsd   xmm8, [number.pTwo]

      subsd   xmm0, xmm8
      addsd   xmm1, xmm8
      jmp     .ready

    ; The game window is taller than the aspect ratio used internally by the game.
    ; In this scenario, horizontal stripes must be inserted above and below of the
    ; the canvas, so the game is vertically centered on the window.
    .window.taller:
      movsd   xmm8, xmm6
      divsd   xmm8, xmm9
      subsd   xmm8, xmm7
      divsd   xmm8, [number.pTwo]

      subsd   xmm3, xmm8
      addsd   xmm2, xmm8

    .ready:
      call  glOrtho
      leave
      ret

section .rodata
  number.mOne:    dq float64(-1.0)
  number.pOne:    dq float64(+1.0)
  number.pTwo:    dq float64(+2.0)

  coords.minX:    dq float64(+00.0)
  coords.maxX:    dq float64(+28.0)
  coords.minY:    dq float64(-03.0)
  coords.maxY:    dq float64(+33.0)
  coords.scaleX:  dq float64(+28.0)
  coords.scaleY:  dq float64(+36.0)
