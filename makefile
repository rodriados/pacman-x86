# Pacman-x86: a Pacman implementation in pure x86 assembly.
# @file The game's compilation and instalation script.
# @author Rodrigo Siqueira <rodriados@gmail.com>
# @copyright 2018-present Rodrigo Siqueira
NAME = pacman-x86

SRCDIR = src
OBJDIR = obj

NASM ?= nasm
LINKR ?= gcc

LINKRFLAGS ?= -lGL -lglut

# Defining macros inside code at compile time. This can be used to enable or disable
# certain features on code or affect the projects compilation.
FLAGS ?=

NASMFLAGS = -felf64 -I$(SRCDIR) $(ENV) $(FLAGS)
LINKFLAGS = $(LINKRFLAGS) $(ENV) $(FLAGS)

# Lists all files to be compiled and separates them according to their corresponding
# compilers. Changes in any of these files in will trigger conditional recompilation.
NASMFILES := $(shell find $(SRCDIR) -name '*.asm')

OBJFILES  = $(NASMFILES:$(SRCDIR)/%.asm=$(OBJDIR)/%.o)

OBJHIERARCHY = $(sort $(dir $(OBJFILES)))

all: debug

install: $(OBJHIERARCHY)

debug: install
debug: override ENV = -g
debug: $(NAME)

clean:
	@rm -rf $(OBJDIR)
	@rm -rf $(SRCDIR)/*~ *~
	@rm -rf $(NAME)

# Creates the hierarchy of folders needed to compile the project. This rule should
# be depended upon by every single build.
$(OBJHIERARCHY):
	@mkdir -p $@

$(OBJDIR)/%.o: $(SRCDIR)/%.asm
	$(NASM) $(NASMFLAGS) $< -o $@

$(NAME): $(OBJFILES)
	$(LINKR) $^ $(LINKFLAGS) -o $@

.PHONY: all install debug clean

.PRECIOUS: $(OBJDIR)/%.o
