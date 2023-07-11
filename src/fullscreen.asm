; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's fullscreen mode manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "window.inc"

%include "thirdparty/glfw.inc"

extern window

global fullscreen.ToggleCallback:function

; Preserves the game's canvas state before a fullscreen request.
; This is needed because when a fullscreen operation triggers the canvas' reshape
; callback, the window's global state is updated.
struc preserveT
  .shape:         resd 2      ; The preserved window's width and height.
  .position:      resd 2      ; The preserved window's position on screen.
endstruc

section .bss
  preserve:       resb preserveT_size

section .text
  ; Toggles the game's window fullscreen mode.
  ; When toggled off of the fullscreen mode, the screen must come back and be redrawn
  ; to its previous size and position.
  ; @param (none) The goggle state is queried from memory.
  fullscreen.ToggleCallback:
      xor   byte [window + windowT.fullscreen], 0x01
      jz    .toggleOff

    .toggleOn:
      glutGetState GLUT_WINDOW_X
      mov   dword [preserve + preserveT.position + 0], eax

      glutGetState GLUT_WINDOW_Y
      mov   dword [preserve + preserveT.position + 4], eax

      mov   ecx, dword [window + windowT.shapeX]
      mov   edx, dword [window + windowT.shapeY]
      mov   dword [preserve + preserveT.shape + 0], ecx
      mov   dword [preserve + preserveT.shape + 4], edx

      call  glutFullScreen
      ret

    .toggleOff:
      mov   edi, dword [preserve + preserveT.shape + 0]
      mov   esi, dword [preserve + preserveT.shape + 4]
      mov   dword [window + windowT.shapeX], edi
      mov   dword [window + windowT.shapeY], esi
      call  glutReshapeWindow

      mov   edi, dword [preserve + preserveT.position + 0]
      mov   esi, dword [preserve + preserveT.position + 4]
      mov   dword [window + windowT.positionX], edi
      mov   dword [window + windowT.positionY], esi
      call  glutPositionWindow
      ret
