; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The list of GLFW functions and values declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2023-present Rodrigo Siqueira

; Declaring GLFW functions.
; This is the list of all GLFW functions needed throughout the game's codebase.
; @see https://www.glfw.org/docs/3.3/
extern glfwInit
extern glfwTerminate
extern glfwCreateWindow
extern glfwMakeContextCurrent
extern glfwSetWindowPos
extern glfwSetWindowSize
extern glfwSetWindowCloseCallback
extern glfwSetWindowRefreshCallback
extern glfwSetWindowSizeCallback
extern glfwSetKeyCallback
extern glfwWindowShouldClose
extern glfwSwapBuffers
extern glfwPollEvents

; Declaring GLFW macro values.
; This is the list of all GLFW macro values needed throughout the game's codebase.
GLFW_KEY_RIGHT:      	equ 262
GLFW_KEY_LEFT:       	equ 263
GLFW_KEY_DOWN:       	equ 264
GLFW_KEY_UP:         	equ 265
GLFW_KEY_F11:           equ 300

GLFW_PRESS:				equ 1
