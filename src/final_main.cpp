#include "chu_init.h"
#include "ps2_core.h"
#include "scrl_core.h"

void turn_things_off()
{
	io_write(get_sprite_addr(BRIDGE_BASE, V3_GHOST), 0x2000, 0x00000001); 	// bypass ghost
	io_write(get_sprite_addr(BRIDGE_BASE, V1_MOUSE), 0x2000, 0x00000001); 	// bypass mouse
	io_write(get_slot_addr(BRIDGE_BASE, S8_SSEG), 0, 0xffffffff);			// turn 7seg leds off
	io_write(get_slot_addr(BRIDGE_BASE, S8_SSEG), 1, 0xffffffff);			// turn 7seg leds off
}

ScrlCore scrl(get_sprite_addr(BRIDGE_BASE, V5_USER5));

int main()
{
	turn_things_off();
	// make scroll 480px/s
	uart.disp("entered main\r\n");
	unsigned int dvsr = 208333;
	dvsr = dvsr >> 12;
	scrl.wr_dvsr(dvsr);
	scrl.down(0);
	scrl.bypass(0);
	while (1)
	{	uart.disp("looping\r\n");
		scrl.suppress();
		sleep_ms(500);
		scrl.release();
		sleep_ms(500);
	}
}
