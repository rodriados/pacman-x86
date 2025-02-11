; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%use fp

%include "debug.inc"
%include "thirdparty/glfw.inc"

extern player.PauseCallback
extern player.ResetCallback
extern player.SetDirectionUpCallback
extern player.SetDirectionDownCallback
extern player.SetDirectionLeftCallback
extern player.SetDirectionRightCallback
extern player.UpdatePositionCallback
extern sprite.LoadGameSpritesCallback

global game.InitializeCallback:function
global game.UpdateCallback:function
global game.KeyArrowUpCallback:function
global game.KeyArrowDownCallback:function
global game.KeyArrowLeftCallback:function
global game.KeyArrowRightCallback:function
global game.KeySpaceCallback:function
global game.FinalizeCallback:function

; Represents the game's logic state values.
; This structure is responsible for holding the game's global state, which will
; be persisted through ticks and control the game's behavior.
struc gameT
  .counter:               resd 1          ; The game's internal tick counter.
  .lastTime:              resq 1
endstruc

section .data
  state: istruc gameT
      at gameT.counter,   dd 0
      at gameT.lastTime,  dq 0
    iend

section .rodata
  frequency:      dq float64(0.03)        ; The game logic tick frequency.

section .text
  ; Initializes the game state, loads assets and sets game logic to initial condition.
  ; @param (none) The game's state, assets and logic are retrieved from memory.
  game.InitializeCallback:
    push  rbp
    mov   rbp, rsp

    call  sprite.LoadGameSpritesCallback
    call  player.ResetCallback

    xorpd xmm0, xmm0
    call  glfwSetTime         ; Resets the window timer.

    leave
    ret

  ; Checks whether the game state must be updated. As the game assumes a constant
  ; time between updates, we must skip if the update frequency is too high.
  ; @param (none) The game's state is retrieved from memory.
  game.UpdateCallback:
      push  rbp
      mov   rbp, rsp

      call  glfwGetTime
      movq  xmm1, xmm0

      subsd   xmm0, [state + gameT.lastTime]
      comisd  xmm0, [frequency]
      jb      .skip

    .continue:
      movq  qword [state + gameT.lastTime], xmm1
      call  _.game.TickCallback

    .skip:
      leave
      ret

  ; The game's callback for a key arrow-up press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowUpCallback:
    call player.SetDirectionUpCallback
    ret

  ; The game's callback for a key arrow-down press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowDownCallback:
    call player.SetDirectionDownCallback
    ret

  ; The game's callback for a key arrow-left press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowLeftCallback:
    call player.SetDirectionLeftCallback
    ret

  ; The game's callback for a key arrow-right press event.
  ; @param (none) The event has no parameters.
  game.KeyArrowRightCallback:
    call player.SetDirectionRightCallback
    ret

  ; The game's callback for a space key press event.
  ; @param (none) The event has no parameters.
  game.KeySpaceCallback:
    call player.PauseCallback
    ret

  ; The game logic's finalize callback.
  ; This callback should only be called when the game's being closed and finalized.
  ; @param (none) The event has no parameters.
  game.FinalizeCallback:
    ret

  ; The game's tick event handler.
  ; Updates the game state whenever a time tick has passed. It is assumed that two
  ; consecutive ticks happen in constant times between each other.
  ; @param (none) The game's internal tick counter is retrieved from memory.
  _.game.TickCallback:
    push  rbp
    mov   rbp, rsp

    ; Retrieving the current game tick counter.
    ; The tick defines the rate changes should be performed on the game's state.
    ; We do not advance the tick here in order to allow the game logic to have total
    ; control whether the tick should be incremented or not.
    mov   edi, dword [state + gameT.counter]
    call  _.game.TickGameLogicCallback

    ; Triggering game objects updates after the global game logic has been updated
    ; and each object behaviour has been already configured for the next tick.
    call  player.UpdatePositionCallback

    pop   rbp
    ret

; Advances one tick of the game's logic.
  ; A tick is the game's internal time tracker. The game's logic considers that
  ; two consecutive ticks will always have a constant real-time difference in between
  ; them. Also, although it might not be a good practice in bigger games' projects,
  ; here the game tick is directly related to the canvas refresh rate.
  ; @param edi The game's internal tick counter.
  _.game.TickGameLogicCallback:
      push rbp
      mov  rbp, rsp

    .advante.tick:
      inc   dword [state + gameT.counter]

      leave
      ret
