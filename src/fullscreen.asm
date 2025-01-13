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
    %assign %$localsize 0x08

    %local .screen:qword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      ; Retrieving the current window size and preserving it, so that the window
      ; can return to current size when fullscreen mode is turned off.
      mov   rdi, qword [window + windowT.ref]
      lea   rsi, [preserve + preserveT.shapeX]
      lea   rdx, [preserve + preserveT.shapeY]
      call  glfwGetWindowSize

      ; Similarly, the current window position must be preserved, so that the window
      ; can be redrawn in the same position when fullscreen mode is turned off.
      mov   rdi, qword [window + windowT.ref]
      lea   rsi, [preserve + preserveT.positionX]
      lea   rdx, [preserve + preserveT.positionY]
      call  glfwGetWindowPos

      ; Selects the screen in which the game must be drawn as fullscreen. It might
      ; be tricky to determine in which monitor screen to use if more than one is
      ; currently present in the system.
      call  _.fullscreen.GetMonitorFromWindow
      mov   qword [.screen], rax

      ; Redraws the game canvas in fullscreen mode on the selected screen. When
      ; in fullscreen mode, the game canvas must be drawn in the whole screen.
      mov   rdi, rax
      call  glfwGetVideoMode
      xor   edx, edx
      xor   ecx, ecx
      mov   rsi, qword [.screen]
      mov   r8d, dword [rax + 0x00]
      mov   r9d, dword [rax + 0x04]
      mov   eax, dword [rax + 0x14]
      mov   rdi, qword [window + windowT.ref]
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
  ; @param (none) The window's context is retrieved from memory.
  ; @return rax The window's monitor context pointer.
  _.fullscreen.GetMonitorFromWindow:
    %push _.context.GetMonitorFromWindow
    %stacksize flat64
    %assign %$localsize 0x00

    %local .screen.list:qword
    %local .screen.count:dword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      ; Retrieves the total number and a reference to the list of monitor screens
      ; currently present in the system.
      lea   rdi, [.screen.count]
      call  glfwGetMonitors
      mov   qword [.screen.list], rax

      ; Checks whether there is more than one screen in the system. If only screen
      ; is found, than it is the screen in which the game window is drawn.
      cmp   dword [.screen.count], 0x01
      je    .monitors.one

    .monitors.many:
      ; TODO: Implement logic for detecting the screen in which the window is currently
      ;       located in, and set fullscreen to this specific screen.
      mov   rdi, qword [.screen.list]
      mov   esi, dword [.screen.count]
      call  _.fullscreen.SelectMonitor

      leave
      ret

    .monitors.one:
      mov   rax, qword [.screen.list]
      mov   rax, qword [rax]

      leave
      ret
    %pop

  ; Picks the monitor the window must be fullscreen in.
  ; @param rdi A pointer to the list of all available monitor contexts.
  ; @param esi The total number of currently available monitors.
  ; @return rax The window's monitor context pointer.
  _.fullscreen.SelectMonitor:
    %push _.context.SelectMonitor
    %stacksize flat64
    %assign %$localsize 0x08

    %local .screen.shapeX:dword
    %local .screen.shapeY:dword
    %local .screen.positionX:dword
    %local .screen.positionY:dword
    %local .screen.list:qword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      push  rbx
      push  r12
      push  r13

      xor   rbx, rbx
      mov   ebx, esi
      mov   qword [.screen.list], rdi

      call  _.fullscreen.IncludeFrameToWindow

      xor   r12, r12
      xor   r13, r13
    .next:
      dec   rbx
      mov   rdi, qword [.screen.list]
      mov   rdi, qword [rdi + rbx * 0x08]
      call  _.fullscreen.GetWindowAreaInScreen

      cmp   eax, r13d
      jle   .continue

      mov   r12,  rbx
      mov   r13d, eax

    .continue:
      cmp   rbx, 0x00
      jg    .next

      mov   rax, qword [.screen.list]
      mov   rax, qword [rax + r12 * 0x08]

      pop   r13
      pop   r12
      pop   rbx

      leave
      ret
    %pop

  ; Adds to the window's frame size to its coordinates and shape values.
  ; @param (none) The window's context is retrieved from memory.
  ; @return (none) The window's properties are modified in-place.
  _.fullscreen.IncludeFrameToWindow:
    %push _.context.IncludeFrameToWindow
    %stacksize flat64
    %assign %$localsize 0x08

    %local .frame.shapeX:dword
    %local .frame.shapeY:dword
    %local .frame.positionX:dword
    %local .frame.positionY:dword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      lea   rcx, [.frame.shapeX]
      lea   r8,  [.frame.shapeY]
      lea   rsi, [.frame.positionX]
      lea   rdx, [.frame.positionY]
      mov   rdi, qword [window + windowT.ref]
      call  glfwGetWindowFrameSize

      mov   eax, dword [.frame.shapeX]
      mov   ecx, dword [.frame.shapeY]
      mov   r8d, dword [.frame.positionX]
      mov   r9d, dword [.frame.positionY]

      add   dword [window + windowT.shapeX], r8d
      add   dword [window + windowT.shapeX], eax
      add   dword [window + windowT.shapeY], r9d
      add   dword [window + windowT.shapeY], ecx

      sub   dword [window + windowT.positionX], r8d
      sub   dword [window + windowT.positionY], r9d

      leave
      ret
    %pop

  ; Calculates the area of intersection between the window and a monitor screen.
  ; @param rdi The monitor context pointer to calculate intersection with.
  ; @return eax The intersection area between window and given monitor.
  _.fullscreen.GetWindowAreaInScreen:
    %push _.context.GetWindowAreaInScreen
    %stacksize flat64
    %assign %$localsize 0x00

    %local .screen.shape:qword
    %local .screen.position:qword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      push  rbx
      mov   rbx, rdi

      mov   rdi, rbx
      lea   rsi, [.screen.position + 0x00]
      lea   rdx, [.screen.position + 0x04]
      call  glfwGetMonitorPos

      mov   rdi, rbx
      call  glfwGetVideoMode

      mov   rdx, qword [rax + 0x00]
      mov   qword [.screen.shape], rdx

      movq    xmm1, qword [window + windowT.shape]
      movq    xmm2, qword [window + windowT.position]
      movq    xmm3, qword [.screen.shape]
      movq    xmm4, qword [.screen.position]

      vpmaxud xmm0, xmm2, xmm4
      paddd   xmm1, xmm2
      paddd   xmm3, xmm4
      pminsd  xmm1, xmm3
      psubd   xmm1, xmm0

      movq  rdx, xmm1
      xor   eax, eax
      xor   ebx, ebx

      cmp   edx, 0x00
      cmovg eax, edx
      shr   rdx, 32
      cmp   edx, 0x00
      cmovg ebx, edx
      mul   ebx

      pop   rbx

      leave
      ret
    %pop
