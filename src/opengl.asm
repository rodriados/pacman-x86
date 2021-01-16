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

%assign GL_QUADS            0x0007
%assign GL_PROJECTION       0x1701
%assign GL_COLOR_BUFFER_BIT 0x4000

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
extern glutIdleFunc
extern glutMainLoop
extern glutFullScreen

%assign GLUT_DOUBLE         0x0002

%assign GLUT_KEY_F1         0x0001
%assign GLUT_KEY_F2         0x0002
%assign GLUT_KEY_F3         0x0003
%assign GLUT_KEY_F4         0x0004
%assign GLUT_KEY_F5         0x0005
%assign GLUT_KEY_F6         0x0006
%assign GLUT_KEY_F7         0x0007
%assign GLUT_KEY_F8         0x0008
%assign GLUT_KEY_F9         0x0009
%assign GLUT_KEY_F10        0x000A
%assign GLUT_KEY_F11        0x000B
%assign GLUT_KEY_F12        0x000C
%assign GLUT_KEY_LEFT       0x0064
%assign GLUT_KEY_UP         0x0065
%assign GLUT_KEY_RIGHT      0x0066
%assign GLUT_KEY_DOWN       0x0067

%assign GLUT_WINDOW_X       0x0064
%assign GLUT_WINDOW_Y       0x0065
%assign GLUT_WINDOW_WIDTH   0x0066
%assign GLUT_WINDOW_HEIGHT  0x0067

; Aliases the call for getting a state value from the current window.
; @param %1 The identifier of the state value being requested.
; @return %2 The requested window state's current value.
%macro glutGetState 1-2 eax
  mov   edi, %1
  call  glutGet
  %ifnidni %2, eax
    mov   %2, eax
  %endif
%endmacro
