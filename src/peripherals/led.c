#include "stm32f1xx_hal.h"
#include "stm32f1xx_hal_gpio.h"
#include "led.h"

#define	LED_PORT	GPIOA
#define LED_PIN		GPIO_PIN_0

void led_Init( void ) {
	GPIO_InitTypeDef  GPIO_InitStruct;

	__HAL_RCC_GPIOA_CLK_ENABLE();
	GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull  = GPIO_PULLUP;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;

	GPIO_InitStruct.Pin = LED_PIN;
	HAL_GPIO_Init( LED_PORT, &GPIO_InitStruct );
}

void led_Toggle( void ) {
	HAL_GPIO_TogglePin( LED_PORT, LED_PIN );
}

