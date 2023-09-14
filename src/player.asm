; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's player logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2022-present Rodrigo Siqueira
bits 64

%include "debug.inc"

extern logArrowUpPress
extern logArrowDownPress
extern logArrowLeftPress
extern logArrowRightPress
extern logSpacePress

global player.KeyArrowUpCallback:function
global player.KeyArrowDownCallback:function
global player.KeyArrowLeftCallback:function
global player.KeyArrowRightCallback:function
global player.KeySpaceCallback:function

section .text
  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowUpCallback:
    debug call logArrowUpPress
    ret

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowDownCallback:
    debug call logArrowDownPress
    ret

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowLeftCallback:
    debug call logArrowLeftPress
    ret

  ; The player controller's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  player.KeyArrowRightCallback:
    debug call logArrowRightPress
    ret

  ; The player controller's callback for a space key press event.
  ; @param (none) The event has no parameters.
  player.KeySpaceCallback:
    debug call logSpacePress
    ret
