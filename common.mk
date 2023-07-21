#
#  common.mk
#  makecm
#
#  Copyright (C) 2023 Jaider Angarita.
#  All rights reserved.
#
#  This file is part of the makecm project.
#

app			?= app
bindir		?= bin/
build		?= build/

elf			:= $(bindir)$(app).elf
map			:= $(bindir)$(app).map

cross		:= arm-none-eabi-
cc			:= $(cross)gcc
cpp			:= $(cross)gcc -E
cxx			:= $(cross)g++
ld			:= $(cross)gcc
rm			:= rm -f

vpath %.c $(srcdir)

objects		:= $(addprefix $(build),$(subst .c,.o,$(sources)))
depends		:= $(addprefix $(build),$(subst .c,.d,$(sources)))

incpath		:= $(addprefix -I ,$(incdirs))

mcpuflags	:= -mthumb -mcpu=$(mcpu)

cflags		:= $(mcpuflags) -D$(target) \
			   -std=$(cstd) $(incpath) -O$(cdebug) \
			   -pipe \
			   -ffunction-sections -fdata-sections \
			   -Wall -Wextra -Werror

ifeq ($(cdebug),g)
	cflags	+= -g3 -DDEBUG
else
	cflags	+= -g0 -flto
endif

ldflags		+= $(mcpuflags) $(ldlibs) -T$(ldscript) \
			   -pipe \
			   --specs=nano.specs \
			   -Wl,-Map=$(map) \
			   -Wl,--start-group \
			   -Wl,--end-group \
			   -Wl,--gc-sections \
			   -Wl,--print-memory-usage

.SILENT:

.PHONY: all clean rebuild

all: $(elf)

clean:
	@echo 'CLEAN'
	-$(rm) $(objects) $(depends) $(elf) $(map)

rebuild: clean all

$(elf): $(objects)
	@echo 'LD	$(notdir $@')
	$(ld) $(ldflags) $^ -o $@

$(build)%.o: %.c
	@$(cpp) -MM -MG -MP -MF $(subst .o,.d,$@) -D$(target) $(incpath) $<
	@echo 'CC	$(notdir $<)'
	$(cc) $(cflags) -c $< -o $@
