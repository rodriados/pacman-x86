; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's debug macros and function declarations.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2021-present Rodrigo Siqueira

%ifdef DEBUG
  debug.active:       equ 1

  ; Declaring functions available on the C-implemented debug module.
  ; These functions can only be called on debug mode.
  extern getTime
  extern getFrameRate
%else
  debug.active:       equ 0
%endif

; Executes a command conditionally only if debug mode is active.
; @param %1 The command to be conditionally executed.
%macro debug 1+
  %if debug.active
    %%debug:
      %{1}
  %endif
%endmacro
