#include <string.h>
#include <misc.h>
#include <usb_lib.h>
#include "rtcc.h"
#include "pressure_sensor.h"
#include "regulators.h"
#include "general_inputs.h"
#include "spi1.h"
#include "storage.h"
#include "micro_sd.h"
#include "led.h"
#include "util.h"
#include "command.h"
#include "clock.h"
#include "io.h"
#include "spi1.h"
#include "sleep.h"
#include "ad.h"
#include "i2c_soft.h"

uint8_t BootloaderToUpdate (void);
void Update_Application (void);
void Run_Application (void);
uint32_t FileOk(uint8_t *file, uint32_t cs);
uint8_t Erase_Application_Pages(uint16_t pages);
