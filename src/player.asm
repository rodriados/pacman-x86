; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's player input controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2022-present Rodrigo Siqueira
bits 64

%include "logic/character.inc"

extern pacman.entity
extern character.QueueDirection

global player.EnqueueDirectionUpCallback:function
global player.EnqueueDirectionDownCallback:function
global player.EnqueueDirectionLeftCallback:function
global player.EnqueueDirectionRightCallback:function
global player.DequeueDirectionCallback:function

section .text
  ; The callback for changing player movement direction upwards.
  ; @param (none) The event has no parameters.
  player.EnqueueDirectionUpCallback:
    lea  rdi, [pacman.entity]
    mov  rsi, character.direction.up
    call character.QueueDirection
    ret

  ; The callback for changing player movement direction downwards.
  ; @param (none) The event has no parameters.
  player.EnqueueDirectionDownCallback:
    lea  rdi, [pacman.entity]
    mov  rsi, character.direction.down
    call character.QueueDirection
    ret

  ; The callback for changing player movement direction backwards.
  ; @param (none) The event has no parameters.
  player.EnqueueDirectionLeftCallback:
    lea  rdi, [pacman.entity]
    mov  rsi, character.direction.left
    call character.QueueDirection
    ret

  ; The callback for changing player movement direction forwards.
  ; @param (none) The event has no parameters.
  player.EnqueueDirectionRightCallback:
    lea  rdi, [pacman.entity]
    mov  rsi, character.direction.right
    call character.QueueDirection
    ret

  ; The callback for clearing the player direction queue.
  ; @param (none) The event has no parameters.
  player.DequeueDirectionCallback:
    lea  rdi, [pacman.entity]
    mov  rsi, character.direction.clear
    call character.QueueDirection
    ret
