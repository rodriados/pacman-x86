; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "debug.inc"
%include "opengl.inc"

global game.TickCallback:function

section .rodata
  frames:         equ 50
  second:         equ 1000
  tick:           dd (second / frames)

section .text
  ; The game's tick event handler.
  ; Updates the game state whenever a time tick has passed.
  ; @param edi The game's tick count since start-up.
  game.TickCallback:
    push  rbp
    mov   rbp, rsp

    call _.game.ScheduleNextTick
    ;call _.game.UpdateState

    debug call getFrameRate

    call  glutPostRedisplay

    pop   rbp
    ret


  ; Schedules the next game tick event.
  ; @param edi The current game tick being handled.
  _.game.ScheduleNextTick:
    mov   edx, edi
    mov   edi, [tick]
    mov   esi, game.TickCallback
    inc   edx
    call  glutTimerFunc
    ret
