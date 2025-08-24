; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's generic character type declaration.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2025-present Rodrigo Siqueira

; Represents the state of a character.
; This structure is responsible for managing all data needed for rendering a character
; and processing its behavior.
struc characterT
  .position:        resq 2
  .direction:       resq 2
  .direction.queue: resq 2
  .track.begin:     resq 2
  .track.end:       resq 2
  .speed:           resq 1
  .warping:         resb 1
endstruc

; Defining macros to help inquiring a character's position.
; @param (none) Gets the requested position dimension by its name.
%define characterT.positionX  (characterT.position + 0)
%define characterT.positionY  (characterT.position + 8)

; Defining macros to help inquiring a character's direction.
; @param (none) Gets the requested direction dimension by its name.
%define characterT.directionX (characterT.direction + 0)
%define characterT.directionY (characterT.direction + 8)

; The character queuable and walkable directions.
; Identifies the direction that can be queued for character movement.
%define character.direction.clear 0
%define character.direction.up    1
%define character.direction.down  2
%define character.direction.left  3
%define character.direction.right 4
