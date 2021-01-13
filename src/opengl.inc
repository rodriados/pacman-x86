; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of OpenGL and GLUT functions declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
%pragma once

extern glClear
extern glClearColor
extern glBegin
extern glEnd
extern glColor3f
extern glVertex2f
extern glFlush

extern glutInit
extern glutCreateWindow
extern glutInitWindowSize
extern glutInitWindowPosition
extern glutDisplayFunc
extern glutMainLoop

%define GL_COLOR_BUFFER_BIT 0x4000
%define GL_QUADS            0x0007
