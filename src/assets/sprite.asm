; Pacman-x86: a Pacman implementation in pure x86 assembly.
; @file The game's sprite loading and managing functions.
; @author Rodrigo Siqueira <rodriados@gmail.com>
; @copyright 2023-present Rodrigo Siqueira
bits 64

%use fp

%include "thirdparty/opengl.inc"

extern fopen, fread, fclose
extern malloc, free

;global sprite.board:data
global _spriteBoard:data
global sprite.LoadGameSprites:function

section .data
  ;sprite.board:             dd 0
  _spriteBoard:  dd 0

section .rodata
  filename.board:           db "obj/assets/sprites/board.sprite", 0

section .text
  ; Loads all sprites needed by the game into OpenGL textures.
  ; @param (none) Sprite names are retrieved from global memory.
  sprite.LoadGameSprites:
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

    mapSpriteToTexture filename.board, _spriteBoard;sprite.board

    leave
    ret

  ; Loads a sprite from a raw binary image file into an OpenGL texture.
  ; @param rdi The name of sprite file to be loaded into texture.
  ; @param rsi The pointer to texture identifier to be used for this sprite.
  _.sprite.LoadSpriteToTexture:
    %push _.context.ToggleOn
    %stacksize flat64
    %assign %$localsize 0x00

    %local .width:dword
    %local .height:dword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      push  r12
      push  rbx
      mov   rbx, rsi                ; Preserving the pointer to texture identifier.

      call  _.sprite.LoadSpriteFile
      mov   dword [.width],  ecx
      mov   dword [.height], edx
      mov   r12, rax                ; Preserving the pointer to image pixels.

      mov   rdi, 0x01
      mov   rsi, rbx
      call  glGenTextures

      mov   rdi, GL_TEXTURE_2D
      mov   esi, dword [rbx]
      call  glBindTexture

      mov   rdi, GL_UNPACK_ALIGNMENT
      mov   rsi, 0x01
      call  glPixelStorei

      mov   rdx, r12
      mov   edi, dword [.width]
      mov   esi, dword [.height]
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

      mov   rdi, r12
      call  free

      pop   rbx
      pop   r12

      leave
      ret
    %pop

  ; Loads the contents of a raw binary sprite file into memory.
  ; @param rdi The name of the sprite file to be loaded into memory.
  ; @return rax The owned pointer to memory where sprite is loaded.
  ; @return ecx The width of the loaded sprite in pixels.
  ; @return edx The heigth of the loaded sprite in pixels.
  _.sprite.LoadSpriteFile:
    %push _.context.ToggleOn
    %stacksize flat64
    %assign %$localsize 0x00

    %local .width:dword
    %local .height:dword
      push  rbp
      mov   rbp, rsp
      sub   rsp, %$localsize

      push  rbx
      push  r12
      push  r13

      ; Opening the sprite file in binary readonly mode. The logic for loading sprites
      ; here implemented assumes that every sprite file has been created by the
      ; project's sprite converter script.
      lea   rsi, [file.mode]
      call  fopen

      mov   rbx, rax                ; Preserving sprite file pointer.

      mov   rcx, rbx
      mov   rdx, 0x01
      mov   rsi, 0x04
      lea   rdi, [.width]
      call  fread

      mov   rcx, rbx
      mov   rdx, 0x01
      mov   rsi, 0x04
      lea   rdi, [.height]
      call  fread

      xor   rax, rax
      mov   eax, 0x04
      mul   dword [.width]
      mul   dword [.height]

      mov   r12, rax
      mov   rdi, rax
      call  malloc

      mov   r13, rax                ; Preserving the malloc'd memory pointer.

      ; Reading the pixel bytes from the sprite binary file. It is assumed that
      ; the sprite's pixel bytes are in raw RBGA format.
      mov   rdi, r13
      mov   rsi, r12
      mov   rdx, 0x01
      mov   rcx, rbx
      call  fread

      mov   rdi, rbx
      call  fclose

      mov   rax, r13
      mov   ecx, dword [.width]
      mov   edx, dword [.height]

      pop   r13
      pop   r12
      pop   rbx

      leave
      ret
    %pop

  ; Loads a texture into OpenGL from sprite's pixel data.
  ; @param edi The width of the spite image to be loaded.
  ; @param esi The height of the sprite image to be loaded.
  ; @param rdx The pointer to memory holding the sprite's pixel data.
  _.sprite.LoadTexture:
    push  rbp
    mov   rbp, rsp
    sub   rsp, 0x08

    push  rdx
    push  GL_UNSIGNED_BYTE
    push  GL_RGBA

    mov   r8d, esi
    mov   ecx, edi
    mov   r9d, 0x00
    mov   esi, 0x00
    mov   edx, GL_RGBA
    mov   edi, GL_TEXTURE_2D
    call  glTexImage2D

    leave
    ret

section .rodata
  file.mode                 db "rb", 0
