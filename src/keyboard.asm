; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's keyboard handler.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "thirdparty/glfw.inc"

extern game.KeyArrowUpCallback
extern game.KeyArrowDownCallback
extern game.KeyArrowLeftCallback
extern game.KeyArrowRightCallback
extern game.KeySpaceCallback
extern game.RelaseKeyArrowCallback
extern fullscreen.ToggleCallback

global keyboard.KeyCallback:function

section .text
  ; Handler for the special key pressing event.
  ; Calls the function bound to the requested key.
  ; @param rdi The window's context pointer.
  ; @param esi The identifier of the key pressed by the player.
  ; @param edx The event key's scan code, that may be platform-specific.
  ; @param ecx The event key's action, that may be press, release or repeat.
  keyboard.KeyCallback:
      ; Maps a key value to a callback and executes it if is the current event.
      ; @param %1 The key action to map to a callback.
      ; @param %2 The identifier of key to be mapped to a callback.
      ; @param %3 The callback to be executed if the current event matches.
      ; @param edi The event to be executed.
      %macro mapCallback 3
          cmp   ecx, %{1}
          jne   %%fallthrough
          cmp   esi, %{2}
          jne   %%fallthrough
          call  %{3}
          jmp   .quit
        %%fallthrough:
      %endmacro

      mapCallback GLFW_PRESS, GLFW_KEY_UP,    game.KeyArrowUpCallback
      mapCallback GLFW_PRESS, GLFW_KEY_DOWN,  game.KeyArrowDownCallback
      mapCallback GLFW_PRESS, GLFW_KEY_LEFT,  game.KeyArrowLeftCallback
      mapCallback GLFW_PRESS, GLFW_KEY_RIGHT, game.KeyArrowRightCallback
      mapCallback GLFW_PRESS, GLFW_KEY_SPACE, game.KeySpaceCallback
      mapCallback GLFW_PRESS, GLFW_KEY_F11,   fullscreen.ToggleCallback

    .quit:
      ret
