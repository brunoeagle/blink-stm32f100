#include "stm32f1xx_hal.h"
#include "peripherals/led.h"

int main(void) {
	HAL_Init();

	led_Init();

	while( 1 ) {
		HAL_Delay( 1000 );	// 1 second delay
		led_Toggle();
	}
}
