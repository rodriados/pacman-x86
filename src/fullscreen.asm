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

; Defining macros to help inquiring the window's preserved shape.
; @param (none) Gets the requested shape dimension by its name.
%define preserveT.shapeX      (preserveT.shape + 0)
%define preserveT.shapeY      (preserveT.shape + 4)

; Defining macros to help inquiring the window's preserved position.
; @param (none) Gets the requested position dimension by its name.
%define preserveT.positionX   (preserveT.position + 0)
%define preserveT.positionY   (preserveT.position + 4)

section .text
  ; Toggles the game's window fullscreen mode.
  ; When toggled off of the fullscreen mode, the window is expected to come back
  ; and be redrawn to its previous size and position.
  ; @param rdi The window's context pointer.
  fullscreen.ToggleCallback:
      xor   byte [window + windowT.fullscreen], 0x01
      jz    .toggle.off

    ; If the game is currently running in windowed mode, then we want it to go into
    ; fullscreen mode. Ideally, if the system has more than one single screen, the
    ; targeted screen for fullscreen mode is the one that draws the largest area
    ; of the game's window.
    .toggle.on:
      call  _.fullscreen.ToggleOn
      ret

    ; Whereas, if the game is currently running in fullscreen mode, then we want
    ; it to go back to windowed mode in the same size and position that it was before.
    .toggle.off:
      call  _.fullscreen.ToggleOff
      ret

  ; Toggles the game's window fullscreen mode on.
  ; @param rdi The window's context pointer.
  _.fullscreen.ToggleOn:
    %push _.context.ToggleOn
    %stacksize flat64
    %assign %$localsize 0x00

    %local .window:qword
    %local .screen:qword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      mov   qword [.window], rdi

      ; Retrieving the current window size and preserving it, so that the window
      ; can return to current size when fullscreen mode is turned off.
      mov   rdi, qword [.window]
      lea   rsi, [preserve + preserveT.shapeX]
      lea   rdx, [preserve + preserveT.shapeY]
      call  glfwGetWindowSize

      ; Similarly, the current window position must be preserved, so that the window
      ; can be redrawn in the same position when fullscreen mode is turned off.
      mov   rdi, qword [.window]
      lea   rsi, [preserve + preserveT.positionX]
      lea   rdx, [preserve + preserveT.positionY]
      call  glfwGetWindowPos

      ; Selects the screen in which the game must be drawn as fullscreen. It might
      ; be tricky to determine in which monitor screen to use if more than one is
      ; currently present in the system.
      mov   rdi, qword [.window]
      call  _.fullscreen.GetMonitorFromWindow
      mov   qword [.screen], rax

      ; Redraws the game canvas in fullscreen mode on the selected screen. When
      ; in fullscreen mode, the game canvas must be drawn in the whole screen.
      mov   rdi, rax
      call  glfwGetVideoMode
      xor   edx, edx
      xor   ecx, ecx
      mov   rdi, qword [.window]
      mov   rsi, qword [.screen]
      mov   r8d, dword [rax + 0x00]
      mov   r9d, dword [rax + 0x04]
      mov   eax, dword [rax + 0x14]
      sub   rsp, 0x08
      push  rax
      call  glfwSetWindowMonitor

      leave
      ret
    %pop

  ; Toggles the fullscreen mode off, and redraws the game window in the same size
  ; and position that it was before turning fullscreen on.
  ; @param rdi The window's context pointer.
  _.fullscreen.ToggleOff:
      push  rbp
      mov   rbp, rsp
      sub   rsp, 0x08

      xor   esi, esi
      mov   edx, dword [preserve + preserveT.positionX]
      mov   ecx, dword [preserve + preserveT.positionY]
      mov   r8d, dword [preserve + preserveT.shapeX]
      mov   r9d, dword [preserve + preserveT.shapeY]
      push  GLFW_DONT_CARE
      call  glfwSetWindowMonitor

      leave
      ret

  ; Retrieves the context pointer for the monitor screen in which the window is
  ; currently being drawn.
  ; @param rdi The window's context pointer.
  ; @return rax The window's monitor context pointer.
  _.fullscreen.GetMonitorFromWindow:
    %push _.context.GetMonitorFromWindow
    %stacksize flat64
    %assign %$localsize 0x00

    %local .window:qword
    %local .screenList:qword
    %local .screenCount:dword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      mov   qword [.window], rdi

      ; Retrieves the total number and a reference to the list of monitor screens
      ; currently present in the system.
      lea   rdi, [.screenCount]
      call  glfwGetMonitors
      mov   qword [.screenList], rax

      ; Checks whether there is more than one screen in the system. If only screen
      ; is found, than it is the screen in which the game window is drawn.
      cmp   dword [.screenCount], 0x01
      je    .monitors.one

    .monitors.many:
      ; TODO: Implement logic for detecting the screen in which the window is currently
      ;       located in, and set fullscreen to this specific screen.

    .monitors.one:
      mov   rax, qword [.screenList]
      mov   rax, qword [rax]

      leave
      ret
    %pop
