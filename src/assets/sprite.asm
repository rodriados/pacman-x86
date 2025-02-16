; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's sprite loading and managing functions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2023-present Rodrigo Siqueira
bits 64

%use fp

%include "thirdparty/opengl.inc"

global sprite.board:data
global sprite.LoadGameSpritesCallback:function

; The raw binary sprite data representation.
; The game's binary sprite files are expected to follow this convention.
struc spriteT
  .width:         resd 1
  .height:        resd 1
  .data:          resb 0
endstruc

section .data
  sprite.board:             dd 0

section .rodata
  raw.sprite.board:         incbin "obj/assets/sprites/board.sprite"

section .text
  ; Loads all sprites needed by the game into OpenGL textures.
  ; @param (none) Sprite names are retrieved from global memory.
  sprite.LoadGameSpritesCallback:
    push  rbp
    mov   rbp, rsp

    ; Maps a sprite file to a texture identifier.
    ; @param %1 The name of sprite file to be loaded into texture.
    ; @param %2 The texture identifier to be used for this sprite.
    %macro mapSpriteToTexture 2
      lea   rdi, [%{1}]
      lea   rsi, [%{2}]
      call  _.sprite.LoadSpriteToTexture
    %endmacro

    mapSpriteToTexture raw.sprite.board, sprite.board

    leave
    ret

  ; Loads a sprite from a raw binary blob into an OpenGL texture.
  ; @param rdi The raw binary sprite data to be loaded into a texture.
  ; @param rsi The pointer to texture identifier to be used for this sprite.
  _.sprite.LoadSpriteToTexture:
    push  rbp
    mov   rbp, rsp

    push  rbx
    push  r12

    mov   rbx, rdi            ; Preserving the pointer to sprite data.
    mov   r12, rsi            ; Preserving the pointer to texture.

    mov   rdi, 0x01
    call  glGenTextures

    mov   rdi, GL_TEXTURE_2D
    mov   esi, dword [r12]
    call  glBindTexture

    mov   rdi, GL_UNPACK_ALIGNMENT
    mov   rsi, 0x01
    call  glPixelStorei

    mov   rdi, rbx
    call  _.sprite.LoadTexture

    ; Sets parameters to the currently bound texture.
    ; @param %1 The parameter to be set.
    ; @param %2 The value to set parameter to.
    %macro setTextureParameter 2
      mov   rdi, GL_TEXTURE_2D
      mov   rsi, %{1}
      mov   rdx, %{2}
      call  glTexParameteri
    %endmacro

    setTextureParameter GL_TEXTURE_MIN_FILTER, GL_LINEAR
    setTextureParameter GL_TEXTURE_MAG_FILTER, GL_LINEAR
    setTextureParameter GL_TEXTURE_WRAP_S, GL_CLAMP
    setTextureParameter GL_TEXTURE_WRAP_T, GL_CLAMP

    pop   r12
    pop   rbx

    leave
    ret

  ; Loads a texture into OpenGL from sprite's pixel data.
  ; @param rdi The raw binary sprite data.
  _.sprite.LoadTexture:
    push  rbp
    mov   rbp, rsp
    sub   rsp, 0x08

    mov   ecx, dword [rdi + spriteT.width]
    mov   r8d, dword [rdi + spriteT.height]

    lea   rax, [rdi + spriteT.data]
    push  rax

    push  GL_UNSIGNED_BYTE
    push  GL_RGBA

    mov   r9d, 0x00
    mov   esi, 0x00
    mov   edx, GL_RGBA
    mov   edi, GL_TEXTURE_2D
    call  glTexImage2D

    leave
    ret
