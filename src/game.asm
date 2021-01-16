; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "opengl.inc"

global game.TickCallback:function

section .text
  ; The game's idle event handler.
  ; Updates the game state whenever the game is idling.
  ; @param (none)
  game.TickCallback:
    call  glutPostRedisplay
    ret
