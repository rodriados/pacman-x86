; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of OpenGL and GLUT functions declaration.
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

GL_QUADS:                   equ 0x0007
GL_PROJECTION:              equ 0x1701
GL_COLOR_BUFFER_BIT:        equ 0x4000

; Declaring GLUT functions.
; This is the list of all GLUT functions needed throughout the game's codebase.
; @see https://www.opengl.org/resources/libraries/glut/spec3/spec3.html
extern glutGet
extern glutInit
extern glutCreateWindow
extern glutInitWindowSize
extern glutInitWindowPosition
extern glutReshapeWindow
extern glutPositionWindow
extern glutInitDisplayMode
extern glutPostRedisplay
extern glutDisplayFunc
extern glutReshapeFunc
extern glutSpecialFunc
extern glutTimerFunc
extern glutMainLoop
extern glutFullScreen
extern glutSwapBuffers

GLUT_DOUBLE:                equ 0x0002

GLUT_KEY_F1:                equ 0x0001
GLUT_KEY_F2:                equ 0x0002
GLUT_KEY_F3:                equ 0x0003
GLUT_KEY_F4:                equ 0x0004
GLUT_KEY_F5:                equ 0x0005
GLUT_KEY_F6:                equ 0x0006
GLUT_KEY_F7:                equ 0x0007
GLUT_KEY_F8:                equ 0x0008
GLUT_KEY_F9:                equ 0x0009
GLUT_KEY_F10:               equ 0x000A
GLUT_KEY_F11:               equ 0x000B
GLUT_KEY_F12:               equ 0x000C
GLUT_KEY_LEFT:              equ 0x0064
GLUT_KEY_UP:                equ 0x0065
GLUT_KEY_RIGHT:             equ 0x0066
GLUT_KEY_DOWN:              equ 0x0067

GLUT_WINDOW_X:              equ 0x0064
GLUT_WINDOW_Y:              equ 0x0065
GLUT_WINDOW_WIDTH:          equ 0x0066
GLUT_WINDOW_HEIGHT:         equ 0x0067

; Aliases the call for getting a state value from the current window.
; @param %1 The identifier of the state value being requested.
; @return %2 The requested window state's current value.
%macro glutGetState 1-2 eax
  mov   edi, %{1}
  call  glutGet
  %ifnidni %{2}, eax
    mov   %{2}, eax
  %endif
%endmacro
