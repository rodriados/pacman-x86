; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "debug.inc"
%include "opengl.inc"

extern testScene

global game.TickCallback:function
global game.DrawFrameCallback:function

time.fps:                 equ 50          ; The game's ideal frame per second rate.
time.second:              equ 1000        ; The number of milliseconds in a second.
time.tick:                equ (time.second / time.fps)

; Represents the game's logic state values.
; This structure is responsible for holding the game's global state, which will
; be persisted through ticks and control the game's behavior.
struc gameT
  .counter:               resd 1          ; The game's internal tick counter.
endstruc

section .data
  state: istruc gameT
      at gameT.counter,   dd 0
    iend

section .text
  ; The game's tick event handler.
  ; Updates the game state whenever a time tick has passed.
  ; @param (none) The game's internal tick counter is retrieved from memory.
  game.TickCallback:
    push  rbp
    mov   rbp, rsp

    ; Retrieving the current game tick counter.
    ; The tick defines the rate changes should be performed on the game's state.
    ; We do not advance the tick here in order to allow the game logic to have total
    ; control whether the tick should be incremented or not.
    mov   edi, dword [state + gameT.counter]

    call  _.game.ScheduleNextTick
    call  _.game.AdvanceGameState

    debug call getFrameRate

    call  glutPostRedisplay

    pop   rbp
    ret

  ; The frame drawing callback.
  ; Draws a new game frame to be displayed at the user's window.
  ; @param (none) The current game state is retrieved from memory.
  game.DrawFrameCallback:
    push  rbp
    mov   rbp, rsp

    call  testScene
    call  glutSwapBuffers

    pop   rbp
    ret

  ; Advances one tick of the game's logic.
  ; A tick is the game's internal time tracker. The game's logic considers that
  ; two consecutive ticks will always have a constant real-time difference in between
  ; them. Also, although it might not be a good practice in bigger games' projects,
  ; here the game tick is directly related to the canvas refresh rate.
  ; @param edi The game's internal tick counter.
  _.game.AdvanceGameState:
    inc   dword [state + gameT.counter]
    ret

  ; Schedules the next game tick event.
  ; @param edi The current game tick being handled.
  ; @preserve rdi The game's internal tick counter.
  _.game.ScheduleNextTick:
    push  rdi

    mov   edx, edi
    mov   edi, time.tick
    mov   esi, game.TickCallback
    call  glutTimerFunc

    pop   rdi
    ret
