# Pacman-x86: a Pacman implementation in pure x86 assembly.
# @file The game's compilation and instalation script.
# @author Rodrigo Siqueira <rodriados@gmail.com>
# @copyright 2021-present Rodrigo Siqueira
NAME = pacman-x86

SRCDIR = src
OBJDIR = obj
RSCDIR = resources
SPRITEDIR = $(RSCDIR)/assets/sprites

NASM ?= nasm
PYT3 ?= python3
LINKR ?= gcc

# Target architecture for x86 compilation. This indicates the architecture the code
# will be compiled to but can be changed with environment variables.
ARCH ?= elf64
LINKRFLAGS ?= -pthread -lglfw -lGLU -lGL -lXrandr -lX11 -lrt -ldl

# Defining macros inside code at compile time. This can be used to enable or disable
# certain features on code or affect the projects compilation.
FLAGS ?=

NASMFLAGS = -f$(ARCH) -I$(SRCDIR) $(ENV) $(FLAGS)
LINKFLAGS = $(LINKRFLAGS) $(ENV) $(FLAGS) -no-pie

# Lists all files to be compiled and separates them according to their corresponding
# compilers. Changes in any of these files in will trigger conditional recompilation.
NASMFILES   := $(shell find $(SRCDIR) -name '*.asm')
SPRITEFILES := $(shell find $(SPRITEDIR) -name '*.png')

# Defining the asset converter scripts. These scripts are run during build time
# to convert the game's assets into files readable by the game.
SCRCONVERTSPRITE = $(RSCDIR)/converters/convert-sprite.py

OBJFILES  = $(NASMFILES:$(SRCDIR)/%.asm=$(OBJDIR)/%.o)
BINFILES  = $(SPRITEFILES:$(RSCDIR)/%.png=$(OBJDIR)/%.sprite)

OBJHIERARCHY = $(sort $(dir $(OBJFILES) $(BINFILES)))

all: always debug

always: $(OBJHIERARCHY)

debug: always
debug: override ENV = -g -DDEBUG
debug: $(BINFILES) $(NAME)

clean:
	@rm -rf $(OBJDIR)
	@rm -rf $(SRCDIR)/*~ *~
	@rm -rf $(NAME)

# Creates dependency on included files. This is valuable so that whenever an included
# file is changed, all objects depending on it will also be recompiled.
ifneq ($(wildcard $(OBJDIR)/.),)
-include $(shell find $(OBJDIR) -name '*.d')
endif

# Creates the hierarchy of folders needed to compile the project. This rule should
# be depended upon by every single build.
$(OBJHIERARCHY):
	@mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.asm
	$(NASM) $(NASMFLAGS) -MD $(patsubst %.o,%.d,$@) $< -o $@

$(OBJDIR)/debug.o: $(SRCDIR)/debug.c
	gcc -std=c11 -c $< -o $@ $(LINKFLAGS)

$(NAME): $(OBJFILES) $(OBJDIR)/debug.o
	$(LINKR) $^ $(LINKFLAGS) -o $@

$(OBJDIR)/%.sprite: $(RSCDIR)/%.png
	$(PYT3) $(SCRCONVERTSPRITE) -i $< -o $@

.PHONY: all always debug clean

.PRECIOUS: $(OBJDIR)/%.o
