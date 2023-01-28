#
#  common.mk
#  mkcm
#
#  Copyright (C) 2023 Jaider Angarita.
#  All rights reserved.
#
#  This file is part of the mkcm project.
#
#  mkcm is free software: you can redistribute it and/or modify it under
#  the terms of the GNU General Public License as published by the Free Software
#  Foundation, either version 3 of the License, or (at your option) any later
#  version.
#
#  mkcm is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
#  A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along with
#  mkcm. If not, see <https://www.gnu.org/licenses/>.
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
cflags		+= -g3 -DDEBUG
else
cflags		+= -g0 -flto
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
	-@echo 'CLEAN'
	-$(rm) $(objects) $(depends) $(elf) $(map)

rebuild: clean all

$(elf): $(objects)
	@echo 'LD	$(notdir $@')
	$(ld) $(ldflags) $^ -o $@

$(build)%.o: %.c
	@$(cpp) -MM -MG -MP -MF $(subst .o,.d,$@) -D$(target) $(incpath) $<
	@echo 'CC	$(notdir $<)'
	$(cc) $(cflags) -c $< -o $@
