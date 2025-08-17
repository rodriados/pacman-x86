; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The board global constants and definitions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira

; The board dimensions.
; Identifies how many blocks of width and height the playable game board has. These
; values are directly used to determine the drawable canvas area of the game window.
board.width:            equ 28
board.height:           equ 31

; The board map legend.
; Identifies the meaning of each value within an instance of a board map. Excluding
; the border, a square has all states greater-or-equal to the value it stores.
board.square.border:    equ  0
board.square.ghost:     equ  1
board.square.walkable:  equ  2
board.square.food:      equ  3
board.square.powerup:   equ  4
board.square.warp:      equ  5
