; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's entry point file.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira
bits 64

%include "debug.inc"
%include "color.inc"
%include "window.inc"

%include "thirdparty/glfw.inc"
%include "thirdparty/opengl.inc"

extern canvas.RenderCallback
extern canvas.ReshapeCallback
extern canvas.MoveCallback
extern canvas.SetBackgroundColor
extern keyboard.KeyCallback
extern game.InitializeCallback
extern game.UpdateCallback
extern game.FinalizeCallback

global window:data
global main:function

section .data
  align 8
  window: istruc windowT
      at windowT.ref,         dq 0
      at windowT.shape,       dd 640, 480
      at windowT.position,    dd 100, 100
      at windowT.aspect,      dq 0
      at windowT.fullscreen,  db 0
      at windowT.title,       db "Pacman-x86", 0
    iend

section .rodata
  align 8
  bgcolor: istruc colorT
      at colorT.r,          dd 0.0
      at colorT.g,          dd 0.0
      at colorT.b,          dd 0.0
      at colorT.a,          dd 1.0
    iend

section .text
  ; The game's entry point.
  ; @param edi The number of command line arguments.
  ; @param rsi A memory pointer to the list of command line arguments.
  main:
      push  rbp
      mov   rbp, rsp

      ; Initialization of the GLFW library.
      ; Here, the GLFW library is initialized and all resources needed are allocated
      ; by the library. If GLFW could not be initialized, then we bail out.
      call  glfwInit

      cmp   eax, 0x00
      je    .exit

      ; Inform the player whether the game has been compiled in debug mode.
      ; The debug mode may affect the game's performance as some extra validations
      ; and even visual elements may be added to the game.
      debug call showDebugMessage

      ; Creation of a window.
      ; A window must be created as a canvas for the game. Also, the OpenGL context
      ; is attached to the newly window, which shall be unique. The window's size
      ; parameters are just a suggestion to the window system for the window's initial
      ; size, as it is not obligated to use this information.
      mov   edi, dword [window + windowT.shapeX]
      mov   esi, dword [window + windowT.shapeY]
      mov   rdx, window + windowT.title
      xor   ecx, ecx
      xor   r8d, r8d
      call  glfwCreateWindow
      mov   qword [window + windowT.ref], rax

      cmp   rax, 0x00
      je    .terminate.fail

      ; Set the created window as the current context.
      ; As no other windows should be created during the execution of the game,
      ; we can permanently set the one recently created as the current context.
      mov   rdi, qword [window + windowT.ref]
      call  glfwMakeContextCurrent

      ; Enables vertical-synchronization.
      ; Our window should only render as fast as the screen can refresh.
      mov   edi, 0x01
      call  glfwSwapInterval

      ; Setting the game's window background color.
      ; Configures the game canvas to show a colored background if needed.
      mov   edi, bgcolor
      call  canvas.SetBackgroundColor

      ; Setting the callback for the window resize event.
      ; This callback will be called whenever the window is resized.
      mov   rdi, qword [window + windowT.ref]
      mov   esi, canvas.ReshapeCallback
      call  glfwSetWindowSizeCallback

      ; Setting the callback for updating the window position when moved.
      ; This callback will be called whenever the window is moved.
      mov   rdi, qword [window + windowT.ref]
      mov   esi, canvas.MoveCallback
      call  glfwSetWindowPosCallback

      ; Setting the callback for the keyboard's input event.
      ; This callback will be called whenever a there's a keyboard input event.
      mov   rdi, qword [window + windowT.ref]
      mov   esi, keyboard.KeyCallback
      call  glfwSetKeyCallback

      ; Setting the window's position.
      ; Similarly to when setting the window's size, its initial position is just
      ; a suggestion that the window system is not obligated to follow.
      mov   rdi, qword [window + windowT.ref]
      mov   esi, dword [window + windowT.positionX]
      mov   edx, dword [window + windowT.positionY]
      call  glfwSetWindowPos

      ; Entering the game's infinite loop.
      ; This subroutine is responsible for keeping the game running, responding
      ; to the player's commands and rendering the canvas.
      call  _.main.GameLoop

    .terminate.success:
      call  glfwTerminate
      mov   eax, 0x00
      jmp   .exit

    .terminate.fail:
      call  glfwTerminate
      mov   eax, -0x01

    .exit:
      leave
      ret

  ; The game's infinite loop.
  ; Here, the game's logic is run in an infinite loop until the game is manually
  ; or programmatically closed either by the user or by logic. In summary, in every
  ; iteration, events are polled and processed, the game state is updated and a
  ; new game frame is drawn on the window canvas.
  ; @param (none) The window's context is retrieved from memory.
  _.main.GameLoop:
      push  rbp
      mov   rbp, rsp

      ; As GLFW does not throws the reshape event when a new window is created,
      ; we must manually call the shape subroutine so our viewport is well configured.
      mov   esi, dword [window + windowT.shapeX]
      mov   edx, dword [window + windowT.shapeY]
      call  canvas.ReshapeCallback

      ; Initializes the game state, loads assets, sets variables and logic to the
      ; state expected by the game when starting.
      call  game.InitializeCallback

    .mainloop:
      ; Check whether the game should be finalized.
      ; If so, the game loop is broken, the game state will not be updated anymore
      ; and no other frame will be rendered.
      mov   rdi, qword [window + windowT.ref]
      call  glfwWindowShouldClose
      cmp   eax, 0x00
      jne   .exit

      ; Poll the window's event queue and process the callbacks.
      ; Before any game logic is updated and frame is rendered, we need to poll
      ; events in order to process input changes beforehand.
      call  glfwPollEvents

      ; Updates the game internal logic.
      ; We must update the game logic after the processing of events and before
      ; the next rendering routine. The game works on a constant time ticker. If
      ; an update request happens faster than the expected tick rate, the game might
      ; avoid updating its state to keep time consistency.
      call  game.UpdateCallback

      ; Draws a frame to the window canvas.
      ; A new frame can be drawn to the window whenever the game logic is ready.
      mov   rdi, qword [window + windowT.ref]
      call  canvas.RenderCallback

      jmp   .mainloop

    .exit:
      ; The game finalization callback.
      ; This subroutine executes any game finalization logic, considering that the
      ; game window context is already finalized and unaccessible.
      call  game.FinalizeCallback

      leave
      ret
