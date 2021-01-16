; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's color structure type declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira

; Represents an OpenGL color structure.
; This structure declares the individual values of a 4-channel color.
struc colorT
  .r:         resd 1        ; The color's R-channel value.
  .g:         resd 1        ; The color's G-channel value.
  .b:         resd 1        ; The color's B-channel value.
  .a:         resd 1        ; The color's A-channel value.
endstruc
