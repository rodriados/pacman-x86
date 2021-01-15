; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's canvas renderer and manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.asm"

%include "color.asm"
%include "window.asm"

extern window

global canvas.GetAspectRatio:function
global canvas.RenderCallback:function
global canvas.ReshapeCallback:function
global canvas.SetBackgroundColor:function

extern testScene

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

    mov   dword [window + (windowT.shape + 0)], edi
    mov   dword [window + (windowT.shape + 4)], esi

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
    call  canvas._SetCanvasOrthographicMatrix

    leave
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

    cvtsi2sd  xmm0, dword [window + (windowT.shape + 0)]
    cvtsi2sd  xmm1, dword [window + (windowT.shape + 4)]
    divsd     xmm0, xmm1

    movsd     qword [window + windowT.aspect], xmm0
    ret

  ; Multiplies the current clipping matrix with an orthographic matrix.
  ; @param xmm0 The window's new aspect ratio.
  canvas._SetCanvasOrthographicMatrix:
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
    
section .rodata
  neg1f:          dq __float64__(-1.0)
  pos1f:          dq __float64__(+1.0)
