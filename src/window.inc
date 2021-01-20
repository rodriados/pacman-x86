; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's window structure type declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira

; Represents the game's window properties.
; This structure declares window properties that are globally relevant and should
; be kept up-to-date with the game's window current properties.
struc windowT
  .shape:       resd 2      ; The window's width and height.
  .position:    resd 2      ; The window's position on screen.
  .aspect:      resq 1      ; The window's aspect ratio.
  .fullscreen:  resb 1      ; The window's fullscreen toggle state.
  .title:       resb 20     ; The window's title string.
endstruc

; Defining macros to help inquiring the window's shape.
; @param (none) Gets the requested shape dimension by its name.
%define windowT.shapeX      (windowT.shape + 0)
%define windowT.shapeY      (windowT.shape + 4)

; Defining macros to help inquiring the window's position.
; @param (none) Gets the requested position dimension by its name.
%define windowT.positionX   (windowT.position + 0)
%define windowT.positionY   (windowT.position + 4)
