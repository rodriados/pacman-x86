; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's keyboard handler.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.inc"

extern game.KeyArrowUpCallback
extern game.KeyArrowDownCallback
extern game.KeyArrowLeftCallback
extern game.KeyArrowRightCallback
extern fullscreen.ToggleCallback

global keyboard.SpecialCallback:function

; Maps a key value to a callback and executes it if is the current event.
; @param %1 The identifier of key to be mapped to a callback.
; @param %2 The callback to be executed if the current event matches.
; @param edi The event to be executed.
%macro mapCallback 2
    cmp   edi, %{1}
    jne   %%fallthrough
    call  %{2}
    jmp   .quit
  %%fallthrough:
%endmacro

section .text
  ; Handler for the special key pressing event.
  ; Calls the function bound to the requested key.
  ; @param edi The identifier of the key pressed by the player.
  ; @param esi The mouse's x-position on the game's window.
  ; @param edx The mouse's y-position on the game's window.
  keyboard.SpecialCallback:
      mapCallback GLUT_KEY_UP,    game.KeyArrowUpCallback
      mapCallback GLUT_KEY_DOWN,  game.KeyArrowDownCallback
      mapCallback GLUT_KEY_LEFT,  game.KeyArrowLeftCallback
      mapCallback GLUT_KEY_RIGHT, game.KeyArrowRightCallback
      mapCallback GLUT_KEY_F11,   fullscreen.ToggleCallback

    .quit:
      ret
