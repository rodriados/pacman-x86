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

section .bss
  aspect:         resd 1
  newW:           resd 1
  newH:           resd 1

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

      cmp   esi, 0x00
      mov   eax, 0x01
      cmove esi, eax

      mov   dword [newW], edi
      mov   dword [newH], esi

      mov   dword [window + (windowT.shape + 0)], edi
      mov   dword [window + (windowT.shape + 4)], esi

      mov   edi, 0x00
      mov   esi, 0x00
      mov   edx, dword [newW]
      mov   ecx, dword [newH]
      call  glViewport

      mov   edi, GL_PROJECTION
      call  glMatrixMode
      call  glLoadIdentity

      call  canvas.GetAspectRatio
      call  canvas._SetCanvasOrthographicMatrix

      pop   rbp
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

    cvtsi2ss  xmm0, dword [window + (windowT.shape + 0)]
    cvtsi2ss  xmm1, dword [window + (windowT.shape + 4)]
    divss     xmm0, xmm1

    movss     dword [aspect], xmm0
    ret

  ; Multiplies the current clipping matrix with an orthographic matrix.
  ; @param xmm0 The window's new aspect ratio.
  canvas._SetCanvasOrthographicMatrix:
      movss   xmm8, xmm0

      movss   xmm0, dword [neg1f]
      movss   xmm1, dword [pos1f]
      movss   xmm2, dword [neg1f]
      movss   xmm3, dword [pos1f]
      movss   xmm4, dword [neg1f]
      movss   xmm5, dword [pos1f]

      comiss  xmm8, [pos1f]
      jnb     .widerWindow

    .tallerWindow:
      divss xmm2, xmm8
      divss xmm3, xmm8
      jmp   .callOrtho

    .widerWindow:
      mulss xmm0, xmm8
      mulss xmm1, xmm8

    .callOrtho:
      call  glOrtho
      ret
    
section .rodata
  neg1f:          dd __float32__(-1.0)
  pos1f:          dd __float32__(+1.0)
