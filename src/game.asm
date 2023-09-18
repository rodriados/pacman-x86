; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "debug.inc"

extern testScene

global game.TickCallback:function
global game.DrawFrameCallback:function
global game.KeyArrowUpCallback:function
global game.KeyArrowDownCallback:function
global game.KeyArrowLeftCallback:function
global game.KeyArrowRightCallback:function
global game.KeySpaceCallback:function
global game.InitializeCallback:function
global game.FinalizeCallback:function

extern player.KeyArrowUpCallback
extern player.KeyArrowDownCallback
extern player.KeyArrowLeftCallback
extern player.KeyArrowRightCallback
extern player.KeySpaceCallback
extern sprite.LoadGameSprites

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
  ; Initializes the game state, loads assets and sets game logic to initial condition.
  ; @param (none) The game's state, assets and logic are retrieved from memory.
  game.InitializeCallback:
    push  rbp
    mov   rbp, rsp

    call  sprite.LoadGameSprites

    leave
    ret

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

    call  _.game.AdvanceGameState
    debug call getFrameRate

    pop   rbp
    ret

  ; The frame drawing callback.
  ; Draws a new game frame to be displayed at the user's window.
  ; @param (none) The current game state is retrieved from memory.
  game.DrawFrameCallback:
    push  rbp
    mov   rbp, rsp

    call  testScene

    pop   rbp
    ret

  ; The game's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowUpCallback:
    call player.KeyArrowUpCallback
    ret

  ; The game's callback for a key arrow-down press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowDownCallback:
    call player.KeyArrowDownCallback
    ret

  ; The game's callback for a key arrow-left press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowLeftCallback:
    call player.KeyArrowLeftCallback
    ret

  ; The game's callback for a key arrow-right press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowRightCallback:
    call player.KeyArrowRightCallback
    ret

  ; The game's callback for a space key press event.
  ; @param (none) The event has no parameters.
  game.KeySpaceCallback:
    call player.KeySpaceCallback
    ret

  ; The game logic's finalize callback.
  ; This callback should only be called when the game's being closed and finalized.
  ; @param (none) The event has no parameters.
  game.FinalizeCallback:
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
