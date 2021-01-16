; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's keyboard handler.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.asm"

extern canvas.ToggleFullscreen

global keyboard.SpecialCallback:function

section .text
  ; Handler for the special key pressing event.
  ; Calls the function bound to the requested key.
  ; @param edi The identifier of the key pressed by the player.
  ; @param esi The mouse's x-position on the game's window.
  ; @param edx The mouse's y-position on the game's window.
  keyboard.SpecialCallback:
      cmp   edi, GLUT_KEY_F11
      jne   .quit

      call  canvas.ToggleFullscreen

    .quit:
      ret
