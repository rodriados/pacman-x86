; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of OpenGL functions and values declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira

; Declaring OpenGL functions.
; This is the list of all OpenGL functions needed throughout the game's codebase.
; @see https://docs.gl/
extern glClear
extern glClearColor
extern glBegin, glEnd
extern glEnable, glDisable
extern glViewport
extern glMatrixMode
extern glLoadIdentity
extern glOrtho

extern glGenTextures
extern glBindTexture
extern glPixelStorei
extern glTexImage2D
extern glTexParameteri
extern glBlendFunc
extern glColor4d
extern glTexCoord2d
extern glVertex2d

; Declaring OpenGL macro values.
; This is the list of all OpenGL macro values needed throughout the game's codebase.
GL_QUADS:                   equ 0x0007
GL_POLYGON:                 equ 0x0009

GL_PROJECTION:              equ 0x1701
GL_COLOR_BUFFER_BIT:        equ 0x4000
GL_UNPACK_ALIGNMENT:        equ 0x0cf5
GL_RGBA                     equ 0x1908
GL_UNSIGNED_BYTE            equ 0x1401
GL_LINEAR                   equ 0x2601
GL_CLAMP                    equ 0x2900

GL_TEXTURE_2D:              equ 0x0de1
GL_TEXTURE_WRAP_S:          equ 0x2802
GL_TEXTURE_WRAP_T:          equ 0x2803
GL_TEXTURE_MAG_FILTER:      equ 0x2800
GL_TEXTURE_MIN_FILTER:      equ 0x2801

GL_MODELVIEW:               equ 0x1700
GL_BLEND:                   equ 0x0be2
GL_SRC_ALPHA:               equ 0x0302
GL_ONE_MINUS_SRC_ALPHA:     equ 0x0303
