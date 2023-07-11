; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of OpenGL functions and values declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira

; Declaring OpenGL functions.
; This is the list of all OpenGL functions needed throughout the game's codebase.
; @see https://docs.gl/
extern glClear
extern glClearColor
extern glViewport
extern glMatrixMode
extern glLoadIdentity
extern glOrtho

; Declaring OpenGL macro values.
; This is the list of all OpenGL macro values needed throughout the game's codebase.
GL_QUADS:                   equ 0x0007
GL_PROJECTION:              equ 0x1701
GL_COLOR_BUFFER_BIT:        equ 0x4000
