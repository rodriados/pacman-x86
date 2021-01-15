; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's window structure type declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
%pragma once

; Represents the game's window properties.
; This structure declares window properties that are globally relevant and should
; be kept up-to-date with the game's window current properties.
struc windowT
  .shape:       resw 2      ; The window's width and height.
  .position:    resw 2      ; The window's position on screen.
  .aspect:      resq 1      ; The window's aspect ratio.
  .title:       resb 20     ; The window's title string.
endstruc
