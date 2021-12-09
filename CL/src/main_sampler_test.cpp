#include "chu_init.h"
#include "gpio_cores.h"
#include "xadc_core.h"
#include "sseg_core.h"
#include "spi_core.h"
#include "i2c_core.h"
#include "ps2_core.h"
#include "ddfs_core.h"
#include "adsr_core.h"
#include "vga_core.h"
#include "scrl_core.h"

void turn_things_off()
{
	io_write(get_sprite_addr(BRIDGE_BASE, V3_GHOST), 0x2000, 0x00000001); 	// bypass ghost
	io_write(get_sprite_addr(BRIDGE_BASE, V1_MOUSE), 0x2000, 0x00000001); 	// bypass mouse
	io_write(get_slot_addr(BRIDGE_BASE, S8_SSEG), 0, 0xffffffff);			// turn 7seg leds off
	io_write(get_slot_addr(BRIDGE_BASE, S8_SSEG), 1, 0xffffffff);			// turn 7seg leds off
}


void osd_overlay(OsdCore *osd_p) {
   osd_p->set_color(0x000, 0xfff); // dark gray/green
   osd_p->bypass(0);

   int notes[8] = {67,68,69,70,71,65,66,67};
   int keys [8] = {81,87,69,82,84,89,85,73};
   for (int i = 0; i < 8; i++){
	   osd_p->wr_char(2+ (4*i),25,notes[i],1);
	   osd_p->wr_char(2+ (4*i),28,keys[i],1);
   }
}

void keyboard(AdsrCore *adsr_p, Ps2Core *ps2_p, GpiCore *sw_p, ScrlCore *scrl_p, DdfsCore *ddfs_p)
{
	#define C 	0
	#define Cs 	1
	#define Db	1
	#define D 	2
	#define Ds 	3
	#define Eb	3
	#define E 	4
	#define F 	5
	#define Fs	6
	#define Gb 	6
	#define G 	7
	#define Gs 	8
	#define Ab	8
	#define A 	9
	#define As 	10
	#define Bb	10
	#define B 	11

	char ch;

	adsr_p->select_env(sw_p->read());
	if(ps2_p->get_kb_ch(&ch)){
        uart.disp(ch);
        uart.disp(" ");
        switch (ch)
        {
        case 'q':
        {adsr_p->play_note(C,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<0*2 );
        break;}

        case 'w':
        {adsr_p->play_note(D,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<1*2 );

        break;}
        case 'e':
        {adsr_p->play_note(E,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<2*2 );
        break;}

        case 'r':
        {adsr_p->play_note(F,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<3*2 );
        break;}

        case 't':
        {adsr_p->play_note(G,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<4*2 );
        break;}

        case 'y':
        {adsr_p->play_note(A,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<5*2 );
        break;}

        case 'u':
        {adsr_p->play_note(B,4,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<6*2 );
        break;}

        case 'i':
        {adsr_p->play_note(C,5,500,0);
        io_write(get_sprite_addr(BRIDGE_BASE, V5_USER5), 0, (uint32_t) 1<<7*2 );
        break;}

        default:break;
        }
        sleep_ms(50);
        scrl_p->release_all_lane();


	}


}

void adsr_player(AdsrCore *adsr_p, GpoCore *led_p, GpiCore *sw_p) {

	//set tempo of music
	#define bpm 120

	// Note field
	#define C 	0
	#define Cs 	1
	#define Db	1
	#define D 	2
	#define Ds 	3
	#define Eb	3
	#define E 	4
	#define F 	5
	#define Fs	6
	#define Gb 	6
	#define G 	7
	#define Gs 	8
	#define Ab	8
	#define A 	9
	#define As 	10
	#define Bb	10
	#define B 	11

   int speed = (60000 / bpm);  // Determines beat of quarter note (i.e. 120bpm = 500ms)

   int hr = speed * 2;			// Half rset
   int qr = speed;				// Quarter rest
   int er = qr / 2;				// Eighth rest
   int dqr = qr + er;			// Dotted Quarter Rest
   int sr = er / 2;				// Sixteenth rest

//   const int melody[] = {C, F, F, G, F, E, D, D, D, G, G, A, G, F, E, C, C, A, A, As, A, G, F, D, C, C, D, G, E, F};
//   const int length[] = {qr,qr,er,er,er,er,qr,qr,qr,qr,er,er,er,er,qr,qr,qr,qr,er,er,er,er,qr,qr,er,er,qr,qr,qr,qr};

   // Music
   	   	   	   	   	   // megalovania. because funny
//   const int melody[] = {D, D, D, A, Gs, G, F, D, F, G,
//		   	   	   	   	 C, C, D, A, Gs, G, F, D, F, G,
//						 B, B, D, A, Gs, G, F, D, F, G,
//						 As, As, D, A, Gs, G, F, D, F, G};

   // array factoring length of notes.
//   const int length[] = {er,er,qr,dqr,qr,qr,qr,er,er,er,
//		   	   	   	   	 er,er,qr,dqr,qr,qr,qr,er,er,er,
//						 er,er,qr,dqr,qr,qr,qr,er,er,er,
//						 er,er,qr,dqr,qr,qr,qr,er,er,er};

//   const int octave[] = {4,4,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 4,4,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 3,3,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 3,3,5,4,4,4,4,4,4,4};
   // some bit on the smash bros melee theme (melody0 is melody, melody1 is baseline)
   const int melody0[] = {B,0,0,0,0,A,G,Fs,E,0,Fs,0,G,0,B,0,A,0,0,0,0,G,Fs,E,E,0,Ds,0,A,0,G,0,G};
   const int melody1[] = {C,G,C,E,G,0,0,0 ,D,A,D,Fs,A,0,0,0,B,Fs,B,Ds,Fs,0,0,0,E,B,E,G,D,A,D,Fs};
   const int length[] = {qr,qr,qr,qr,qr};
   const int octave0[] = {5,0,0,0,0,5,5,5,5,0,5,0,5,0,5,0,5,0,0,0,0,5,5,5,5,0,5,0,5,0,5,0,5};
   const int octave1[] = {3,3,4,4,4,0,0,0,3,3,4,4,4,0,0,0,2,3,3,4,4,0,0,0,3,3,4,4,3,3,4,4};

   int noteAmt = sizeof(melody0)/sizeof(melody0[0]);

   adsr_p->select_env(sw_p->read());

	for (int i = 0; i < noteAmt;i++)
	{

		adsr_p->play_note(melody0[i],octave0[i],500,1);
		adsr_p->play_note(melody1[i],octave1[i],500,0);
//		adsr_p->play_note(C,3,250,0);
//		adsr_p->play_note(C,2,200,0);
//		adsr_p->play_note(E,2,200,1);
//		adsr_p->play_note(G,2,200,2);
//		adsr_p->play_note(C,3,200,3);
//		adsr_p->play_note(E,3,200,4);
//		adsr_p->play_note(G,3,200,5);
//		adsr_p->play_note(C,4,200,6);
//		adsr_p->play_note(E,4,200,7);
		sleep_ms(er);
	}

}

GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
XadcCore adc(get_slot_addr(BRIDGE_BASE, S5_XDAC));
PwmCore pwm(get_slot_addr(BRIDGE_BASE, S6_PWM));
DebounceCore btn(get_slot_addr(BRIDGE_BASE, S7_BTN));
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
SpiCore spi(get_slot_addr(BRIDGE_BASE, S9_SPI));
I2cCore adt7420(get_slot_addr(BRIDGE_BASE, S10_I2C));
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S11_PS2));
DdfsCore ddfs(get_slot_addr(BRIDGE_BASE, S12_DDFS));
AdsrCore adsr(get_slot_addr(BRIDGE_BASE, S13_ADSR), &ddfs);
ScrlCore scrl(get_sprite_addr(BRIDGE_BASE, V5_USER5));
OsdCore osd(get_sprite_addr(BRIDGE_BASE, V2_OSD));

int main() {
   //uint8_t id, ;
	turn_things_off();
	scrl.set_speed(1);
	scrl.down(0);
	scrl.bypass(0);
	adsr.init();
	ps2.init();
   while (1) {

	   keyboard(&adsr, &ps2, &sw, &scrl, &ddfs);
	   osd_overlay(&osd);

   } //while
} //main

