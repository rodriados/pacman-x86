; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's board logic controller.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira
bits 64

%include "board.inc"

global board.state:data
global board.ResetCallback:function

section .rodata
  ; The initial board state.
  ; This is a map to every walkable path by the player, and the ghosts. Also, it
  ; shows where every food and powerups are initially located. This map should be
  ; copied to a modifiable board whenever a new game or level starts.
  board.init:
    %define _ board.square.border
    db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_
    db _,3,3,3,3,3,3,3,3,3,3,3,3,_,_,3,3,3,3,3,3,3,3,3,3,3,3,_
    db _,3,_,_,_,_,3,_,_,_,_,_,3,_,_,3,_,_,_,_,_,3,_,_,_,_,3,_
    db _,4,_,_,_,_,3,_,_,_,_,_,3,_,_,3,_,_,_,_,_,3,_,_,_,_,4,_
    db _,3,_,_,_,_,3,_,_,_,_,_,3,_,_,3,_,_,_,_,_,3,_,_,_,_,3,_
    db _,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,_
    db _,3,_,_,_,_,3,_,_,3,_,_,_,_,_,_,_,_,3,_,_,3,_,_,_,_,3,_
    db _,3,_,_,_,_,3,_,_,3,_,_,_,_,_,_,_,_,3,_,_,3,_,_,_,_,3,_
    db _,3,3,3,3,3,3,_,_,3,3,3,3,_,_,3,3,3,3,_,_,3,3,3,3,3,3,_
    db _,_,_,_,_,_,3,_,_,_,_,_,2,_,_,2,_,_,_,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,_,_,_,2,_,_,2,_,_,_,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,2,2,2,2,2,2,2,2,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,_,_,_,1,1,_,_,_,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,_,1,1,1,1,1,1,_,2,_,_,3,_,_,_,_,_,_
    db 2,2,2,2,2,2,3,2,2,2,_,1,1,1,1,1,1,_,2,2,2,3,2,2,2,2,2,2
    db _,_,_,_,_,_,3,_,_,2,_,1,1,1,1,1,1,_,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,_,_,_,_,_,_,_,_,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,2,2,2,2,2,2,2,2,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,_,_,_,_,_,_,_,_,2,_,_,3,_,_,_,_,_,_
    db _,_,_,_,_,_,3,_,_,2,_,_,_,_,_,_,_,_,2,_,_,3,_,_,_,_,_,_
    db _,3,3,3,3,3,3,3,3,3,3,3,3,_,_,3,3,3,3,3,3,3,3,3,3,3,3,_
    db _,3,_,_,_,_,3,_,_,_,_,_,3,_,_,3,_,_,_,_,_,3,_,_,_,_,3,_
    db _,3,_,_,_,_,3,_,_,_,_,_,3,_,_,3,_,_,_,_,_,3,_,_,_,_,3,_
    db _,4,3,3,_,_,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,_,_,3,3,4,_
    db _,_,_,3,_,_,3,_,_,3,_,_,_,_,_,_,_,_,3,_,_,3,_,_,3,_,_,_
    db _,_,_,3,_,_,3,_,_,3,_,_,_,_,_,_,_,_,3,_,_,3,_,_,3,_,_,_
    db _,3,3,3,3,3,3,_,_,3,3,3,3,_,_,3,3,3,3,_,_,3,3,3,3,3,3,_
    db _,3,_,_,_,_,_,_,_,_,_,_,3,_,_,3,_,_,_,_,_,_,_,_,_,_,3,_
    db _,3,_,_,_,_,_,_,_,_,_,_,3,_,_,3,_,_,_,_,_,_,_,_,_,_,3,_
    db _,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,_
    db _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_
    %undef _
  board.size:         equ $ - board.init

section .bss
  board.state:        resb board.size

section .text
  ; Resets the game board state.
  ; The board is reset by simply copying the initial state into the live board.
  ; As suggested by the name, all state changes to the board will erased.
  ; @param (none) The board state is retrieved from memory.
  board.ResetCallback:
    mov rcx, board.size
    mov rsi, board.init
    mov rdi, board.state
    rep movsb
    ret
