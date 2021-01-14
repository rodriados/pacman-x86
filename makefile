# Pacman-x86: a Pacman implementation in pure x86 assembly.
# @file The game's compilation and instalation script.
# @author Rodrigo Siqueira <rodriados@gmail.com>
# @copyright 2018-present Rodrigo Siqueira
NAME = pacman-x86

SRCDIR = src
OBJDIR = obj

NASM ?= nasm
LINKR ?= gcc

# Target architecture for x86 compilation. This indicates the architecture the code
# will be compiled to but can be changed with environment variables.
ARCH ?= elf64
LINKRFLAGS ?= -lGL -lglut

# Defining macros inside code at compile time. This can be used to enable or disable
# certain features on code or affect the projects compilation.
FLAGS ?=

NASMFLAGS = -f$(ARCH) -I$(SRCDIR) $(ENV) $(FLAGS)
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

$(OBJDIR)/scene.o: $(SRCDIR)/scene.c
	gcc -c $< -o $@ $(LINKFLAGS)

$(NAME): $(OBJFILES) $(OBJDIR)/scene.o
	$(LINKR) $^ $(LINKFLAGS) -o $@

.PHONY: all install debug clean

.PRECIOUS: $(OBJDIR)/%.o
