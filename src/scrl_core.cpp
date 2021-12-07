#include "scrl_core.h"

ScrlCore::ScrlCore(uint32_t core_base_addr) {
   base_addr = core_base_addr;
}
ScrlCore::~ScrlCore() {
}
// not used

void ScrlCore::suppress()
{
   io_write(base_addr, LANE_REG, 0xffffffff);
}

void ScrlCore::release()
{
   io_write(base_addr, LANE_REG, 0x00000000);
}

void ScrlCore::wr_one_lane(int lane, int color) {
   unsigned int shamt = lane * LANE_WIDTH;
   lane_reg = lane_reg && (LANE_nMASK << shamt);   // clear that slot
   lane_reg += (color|LANE_MASK) << shamt;         //  fill that slot 
   io_write(base_addr, LANE_REG, (uint32_t ) lane_reg);
}

void ScrlCore::wr_dvsr(int dvsr) {
   io_write(base_addr, DVSR_REG, (uint32_t ) dvsr);
}

void ScrlCore::bypass(int by) {
   io_write(base_addr, BYPS_REG, (uint32_t ) by);
}

// scroll up (0) or down (1)
void ScrlCore::down(int dn)
{
   io_write(base_addr, DOWN_REG, (uint32_t ) dn);
}