; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of OpenGL and GLUT functions declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
%pragma once

; Declaring OpenGL functions.
; This is the list of all OpenGL functions needed throughout the game's codebase.
; @see https://docs.gl/
extern glClear
extern glClearColor
extern glViewport
extern glMatrixMode
extern glLoadIdentity
extern glOrtho

%define GL_QUADS            0x0007
%define GL_PROJECTION       0x1701
%define GL_COLOR_BUFFER_BIT 0x4000

; Declaring GLUT functions.
; This is the list of all GLUT functions needed throughout the game's codebase.
; @see https://www.opengl.org/resources/libraries/glut/spec3/spec3.html
extern glutInit
extern glutCreateWindow
extern glutInitWindowSize
extern glutInitWindowPosition
extern glutInitDisplayMode
extern glutPostRedisplay
extern glutDisplayFunc
extern glutReshapeFunc
extern glutIdleFunc
extern glutMainLoop

%define GLUT_DOUBLE         0x0002
