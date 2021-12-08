#ifndef _SCRL_H_INCLUDED
#define _SCRL_H_INCLUDED

#include "chu_init.h"
#include <stdlib.h>

class ScrlCore {
public:
   /**
    * register map
    *
    */
   enum {
      LANE_REG = 0x0000,
	   DVSR_REG = 0x0001,
	   BYPS_REG = 0x0002,
	   DOWN_REG = 0x0003
   };
   const int LANE_COUNT = 8;
   const int LANE_WIDTH = 2;
   const uint32_t LANE_MASK = (1 << LANE_WIDTH) - 1;
   const uint32_t LANE_nMASK = ~LANE_MASK;
   /* methods */
   ScrlCore(uint32_t core_base_addr);
   ~ScrlCore();                  // not used

   void suppress();
   void release();

   void wr_one_lane(int lane, int color);

   void wr_dvsr(int dvsr);

   /**
    * enable/disable core bypass
    * @param by 1: bypass current core; 0: not bypass
    *
    */
   void bypass(int by);

   // scroll up (0) or down (1)
   void down(int dn);

private:
   uint32_t base_addr;
   uint32_t lane_reg;
};

#endif