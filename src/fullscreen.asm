; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's fullscreen mode manager.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "window.inc"
%include "thirdparty/glfw.inc"

extern window

global fullscreen.ToggleCallback:function

; Preserves the game's canvas state before a fullscreen request.
; This is needed because when a fullscreen operation triggers the canvas' reshape
; callback, the window's global state is updated.
struc preserveT
  .shape:         resd 2      ; The preserved window's width and height.
  .position:      resd 2      ; The preserved window's position on screen.
endstruc

section .bss
  preserve:       resb preserveT_size

section .text
  ; Toggles the game's window fullscreen mode.
  ; When toggled off of the fullscreen mode, the window is expected to come back
  ; and be redrawn to its previous size and position.
  ; @param rdi The window's context pointer.
  fullscreen.ToggleCallback:
      xor   byte [window + windowT.fullscreen], 0x01
      jz    .toggle.off

    .toggle.on:
      call  _.fullscreen.ToggleOn
      ret

    .toggle.off:
      call  _.fullscreen.ToggleOff
      ret

  ; Toggles the game's window fullscreen mode on.
  ; @param rdi The window's context pointer.
  _.fullscreen.ToggleOn:
    %push _.context.ToggleOn
    %stacksize flat64
    %assign %$localsize 0x00

    %local _1.local.windowPtr:qword
    %local _1.local.monitorPtr:qword

      enter %$localsize, 0x00

      mov   qword [_1.local.windowPtr], rdi

      lea   rsi, [preserve + preserveT.shape + 0x00]
      lea   rdx, [preserve + preserveT.shape + 0x04]
      mov   rdi, qword [_1.local.windowPtr]
      call  glfwGetWindowSize

      lea   rsi, [preserve + preserveT.position + 0x00]
      lea   rdx, [preserve + preserveT.position + 0x04]
      mov   rdi, qword [_1.local.windowPtr]
      call  glfwGetWindowPos

      mov   rdi, qword [_1.local.windowPtr]
      call  _.fullscreen.GetMonitorFromWindow
      mov   qword [_1.local.monitorPtr], rax

      mov   rdi, qword [_1.local.monitorPtr]
      call  glfwGetVideoMode

      xor   edx, edx
      xor   ecx, ecx
      mov   rdi, qword [_1.local.windowPtr]
      mov   rsi, qword [_1.local.monitorPtr]
      mov   r8d, dword [rax + 0x00]
      mov   r9d, dword [rax + 0x04]
      ; push  GLFW_DONT_CARE
      call  glfwSetWindowMonitor

      leave
      ret
    %pop

  ; Toggles the game's window fullscreen mode off.
  ; @param rdi The window's context pointer.
  _.fullscreen.ToggleOff:
      enter 0x00, 0x01

      xor   esi, esi
      mov   edx, dword [preserve + preserveT.position + 0x00]
      mov   ecx, dword [preserve + preserveT.position + 0x04]
      mov   r8d, dword [preserve + preserveT.shape + 0x00]
      mov   r9d, dword [preserve + preserveT.shape + 0x04]
      push  GLFW_DONT_CARE
      call  glfwSetWindowMonitor

      leave
      ret

  ; Retrieves the context pointer for the monitor in which the window is currently.
  ; @param rdi The window's context pointer.
  ; @return rax The window's monitor context pointer.
  _.fullscreen.GetMonitorFromWindow:
    %push _.context.GetMonitorFromWindow
    %stacksize flat64
    %assign %$localsize 0x00

    %local _2.local.windowPtr:qword
    %local _2.local.monitorsCount:dword

      enter %$localsize, 0x00

      mov   [_2.local.windowPtr], rdi

      lea   rdi, [_2.local.monitorsCount]
      call  glfwGetMonitors

      ; cmp   dword [_2.local.monitorsCount], 0x01
      ; je    .monitors.one

      jmp   .monitors.one

    .monitors.many:
      ; TODO: Implement logic for detecting monitor in which the window is currently
      ;       located in, and set fullscreen to this monitor.

    .monitors.one:
      mov   rdx, qword [rax]
      mov   rax, rdx

      leave
      ret
    %pop
