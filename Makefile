.SUFFIXES:				# ignore builtin rules
.PHONY: all debug release clean

##### Definitions
DEVICE = STM32F100xB
PROJECTNAME = blink-stm32f100

##### Directories
OBJ_DIR = build
EXE_DIR = build/exe
LST_DIR = build/lst

##### Linux Commands (will be overwritten if on Windows)
RMDIRS     := rm -rf
RMFILES    := rm -rf
ALLFILES   := *.*
SHELLNAMES := $(ComSpec)$(COMSPEC)

##### Try autodetecting the environment
ifeq ($(SHELLNAMES),)
  # Assume we are making on a Linux platform
  TOOLDIR := $(LINUXCS)
else
  ifneq ($(COMSPEC),)
    # Assume we are making on a mingw/msys/cygwin platform running on Windows
    # This is a convenient place to override TOOLDIR, DO NOT add trailing
    # whitespace chars, they do matter !
    TOOLDIR := $(PROGRAMFILES)/$(WINDOWSCS)
    ifeq ($(findstring cygdrive,$(shell set)),)
      # We were not on a cygwin platform
      NULLDEVICE := NUL
    endif
  else
    # Assume we are making on a Windows platform
    # This is a convenient place to override TOOLDIR, DO NOT add trailing
    # whitespace chars, they do matter !
    SHELL      := $(SHELLNAMES)
    TOOLDIR    := $(ProgramFiles)/$(WINDOWSCS)
    RMDIRS     := rd /s /q
    RMFILES    := del /s /q
    ALLFILES   := \*.*
    NULLDEVICE := NUL
    OBJ_DIR = build
    EXE_DIR = build\exe
    LST_DIR = build\lst
  endif
endif

##### Create directories and do a clean which is compatible with parallell make
ifeq (clean,$(findstring clean, $(MAKECMDGOALS)))
  ifneq ($(filter $(MAKECMDGOALS),all debug release),)
    $(shell $(RMFILES) $(OBJ_DIR))
    $(shell $(RMFILES) $(EXE_DIR))
    $(shell $(RMFILES) $(LST_DIR))
  endif
else
    $(shell mkdir $(OBJ_DIR))
    $(shell mkdir $(EXE_DIR))
    $(shell mkdir $(LST_DIR))
endif

CC      = arm-none-eabi-gcc
LD      = arm-none-eabi-ld
AR      = arm-none-eabi-ar
OBJCOPY = arm-none-eabi-objcopy
DUMP    = arm-none-eabi-objdump
SIZE    = arm-none-eabi-size

##### Flags
DEPFLAGS = -MMD -MP -MF $(@:.o=.d)

override CFLAGS += -D$(DEVICE) -DUSE_HAL_DRIVER -Wall -Wextra -mcpu=cortex-m3 -mthumb -ffunction-sections \
-fdata-sections -fomit-frame-pointer \
$(DEPFLAGS)

override ASMFLAGS += -x assembler-with-cpp -Wall -Wextra -mcpu=cortex-m3 -mthumb

override LDFLAGS += -Xlinker -Map=$(LST_DIR)/$(PROJECTNAME).map -mcpu=cortex-m3 \
-mthumb -T./linker/STM32F100XB_FLASH.ld \
 -Wl,--gc-sections

LIBS = -Wl,--start-group -lgcc -lc -lnosys   -Wl,--end-group

##### Include paths
INCLUDEPATHS += \
-I.. \
-I../STM32Cube_FW_F1_V1.4.0/Drivers/CMSIS/Include \
-I../STM32Cube_FW_F1_V1.4.0/Drivers/CMSIS/Device/ST/STM32F1xx/Include \
-I../STM32Cube_FW_F1_V1.4.0/Drivers/STM32F1xx_HAL_Driver/Inc \
-I./src \
-I./src/stm32 \
-I./src/application

##### Files to compile
C_SRC +=  \
../STM32Cube_FW_F1_V1.4.0/Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c \
../STM32Cube_FW_F1_V1.4.0/Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c \
../STM32Cube_FW_F1_V1.4.0/Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c \
../STM32Cube_FW_F1_V1.4.0/Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c \
./src/stm32/system_stm32f1xx.c \
./src/peripherals/led.c \
./src/application/main.c

s_SRC += \
./startup/startup_stm32f100xb.s

S_SRC += 

##### Rules
C_FILES = $(notdir $(C_SRC) )
S_FILES = $(notdir $(S_SRC) $(s_SRC) )
#make list of source paths, sort also removes duplicates
C_PATHS = $(sort $(dir $(C_SRC) ) )
S_PATHS = $(sort $(dir $(S_SRC) $(s_SRC) ) )

C_OBJS = $(addprefix $(OBJ_DIR)/, $(C_FILES:.c=.o))
#S_OBJS = $(if $(S_SRC), $(addprefix $(OBJ_DIR)/, $(S_FILES:.S=.o)))
s_OBJS = $(if $(s_SRC), $(addprefix $(OBJ_DIR)/, $(S_FILES:.s=.o)))
C_DEPS = $(addprefix $(OBJ_DIR)/, $(C_FILES:.c=.d))
OBJS = $(C_OBJS) $(S_OBJS) $(s_OBJS)

vpath %.c $(C_PATHS)
vpath %.s $(S_PATHS)
#vpath %.S $(S_PATHS)

##### Default build is debug build
all:      debug

debug:    CFLAGS += -DDEBUG -Og -g3
debug:    $(EXE_DIR)/$(PROJECTNAME).bin

release:  CFLAGS += -DNDEBUG -Og -g3
release:  $(EXE_DIR)/$(PROJECTNAME).bin

# Create objects from C SRC files
$(OBJ_DIR)/%.o: %.c
	@echo "Building file: $<"
	$(CC) $(CFLAGS) $(INCLUDEPATHS) -c -o $@ $<

# Assemble .s/.S files
$(OBJ_DIR)/%.o: %.s
	@echo "Assembling $<"
	$(CC) $(ASMFLAGS) $(INCLUDEPATHS) -c -o $@ $<

#$(OBJ_DIR)/%.o: %.S
#	@echo "Assembling $<"
#	$(CC) $(ASMFLAGS) $(INCLUDEPATHS) -c -o $@ $<

# Link
$(EXE_DIR)/$(PROJECTNAME).out: $(OBJS)
	@echo "Linking target: $@"
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o $(EXE_DIR)/$(PROJECTNAME).out

# Create binary file
$(EXE_DIR)/$(PROJECTNAME).bin: $(EXE_DIR)/$(PROJECTNAME).out
	@echo "Creating binary file"
	$(OBJCOPY) -O binary $(EXE_DIR)/$(PROJECTNAME).out $(PROJECTNAME).bin
	@echo "Used memories:"
	$(SIZE) $(EXE_DIR)/$(PROJECTNAME).out
# Uncomment next line to produce assembly listing of entire program
#	$(DUMP) -h -S -C $(EXE_DIR)/$(PROJECTNAME).out>$(LST_DIR)/$(PROJECTNAME)out.lst

clean:
ifeq ($(filter $(MAKECMDGOALS),all debug release),)
	$(RMDIRS) $(OBJ_DIR)
	$(RMFILES) $(PROJECTNAME).bin
endif
