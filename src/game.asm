; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's main logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%use fp

%include "thirdparty/glfw.inc"

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
  .paused:                resd 1
  .lastTime:              resq 1
endstruc

section .data
  state: istruc gameT
      at gameT.counter,   dd 0
      at gameT.paused,    dd 0
      at gameT.lastTime,  dq 0
    iend

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

  ; Updates the game state logic and triggers changes to object's positions.
  ; @param (none) The game's state is retrieved from memory.
  game.UpdateCallback:
    push  rbp
    mov   rbp, rsp

    call  glfwGetTime
    movq  xmm1, xmm0

    subsd xmm0, [state + gameT.lastTime]
    movq  qword [state + gameT.lastTime], xmm1

    call  _.game.TickCallback

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
    xor  dword [state + gameT.paused], 0x01
    ret

  ; The game logic's finalize callback.
  ; This callback should only be called when the game's being closed and finalized.
  ; @param (none) The event has no parameters.
  game.FinalizeCallback:
    ret

  ; The game's tick event handler.
  ; Updates the game state for a tick that has passed. It is mostly assumed that
  ; the time between two consecutive ticks are constant.
  ; @param xmm0 The real time since the last tick update.
  _.game.TickCallback:
      push  rbp
      mov   rbp, rsp
      sub   rsp, 0x10

      cmp   dword [state + gameT.paused], 0x01
      je    .game.paused

    .game.running:
      movq  qword [rbp - 0x08], xmm0

      ; Triggering game logic updates.
      ; Advances the current game state that will guide the game's objects positions
      ; update that follow next. The logic is provided with the current tick counter.
      mov   edi, dword [state + gameT.counter]
      call  _.game.TickGameLogicCallback

      ; Triggering game objects position updates.
      ; After the global game logic has been updated and each object behaviour has
      ; been already configured for the next tick, we must update their positions.
      movq  xmm0, qword [rbp - 0x08]
      call  _.game.TickGameObjectsPositionCallback

    .game.paused:
      leave
      ret

  ; Advances one tick of the game's logic.
  ; A tick is the game's internal time tracker. The game's logic mostly considers
  ; that two consecutive ticks will always have a constant real-time difference
  ; in between them. Also, although it might not be a good practice in bigger games'
  ; projects, here the game tick is directly related to the canvas refresh rate.
  ; @param edi The game's internal tick counter.
  _.game.TickGameLogicCallback:
    push rbp
    mov  rbp, rsp

    inc  dword [state + gameT.counter]

    leave
    ret

  ; Advances the game's objects position.
  ; After the game logic has executed and a new game state has been produced, we
  ; can then sequentially update the positions of every game object for a new frame.
  ; @param xmm0 The real time since the last tick update.
  _.game.TickGameObjectsPositionCallback:
    push rbp
    mov  rbp, rsp
    sub  rsp, 0x10

    movq  qword [rbp - 0x08], xmm0
    call  player.UpdatePositionCallback

    leave
    ret
