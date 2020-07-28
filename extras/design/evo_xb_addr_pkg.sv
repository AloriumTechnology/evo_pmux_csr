//=================================================================
//  Copyright(c) Alorium Technology Inc., 2020
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : evo_build_template/extras/design/evo_xb_addr_pkg.sv
// Author      : Steve Phillips
// Contact     : support@aloriumtech.com
// Description : 
//
// This package file is used to define addresses for the OpenEvo 
// XB impementations. Each OpenEvo implementation has a unique 
// version of this file.
//
// IMPORTANT: To avoid possible conflicts with the BSP address space, 
//
//            == USE ADDRESSES GREATER THAN 12'h800 ==
//
//

`ifndef _EVO_XB_ADDR_PKG_DONE 
  `define _EVO_XB_ADDR_PKG_DONE // set flag that pkg already included 

package evo_xb_addr_pkg; 
   // Here is where you add your parameter defintions for the addresses 
   // needed to access the CSR regs in the OpenEvo implementation.
   //
   //            == USE ADDRESSES GREATER THAN 12'h800 ==
   //
   // For example:
   // parameter EVO_SERVO_CTL_ADDR = 12'h8AA;
   parameter PMUX_D_CSR_CTL_ADDR   = 12'h911; // Port D Control CSR
   parameter PMUX_D_CSR_STS_ADDR   = 12'h912; // Port D Status CSR
   parameter PMUX_D_CSR_WRADR_ADDR = 12'h913; // Port D Write Pointer CSR
   parameter PMUX_D_CSR_DIR_ADDR   = 12'h914; // Port D Direction CSR
   parameter PMUX_D_CSR_OUT_ADDR   = 12'h915; // Port D Output value CSR
   parameter PMUX_D_CSR_EN_ADDR    = 12'h916; // Port D Enable CSR
   parameter PMUX_D_CSR_IN_ADDR    = 12'h917; // Port D Input CSR
   parameter PMUX_E_CSR_CTL_ADDR   = 12'h921; // Port E Control CSR
   parameter PMUX_E_CSR_STS_ADDR   = 12'h922; // Port e Status CSR
   parameter PMUX_E_CSR_WRADR_ADDR = 12'h923; // Port E Write Pointer CSR
   parameter PMUX_E_CSR_DIR_ADDR   = 12'h924; // Port E Direction CSR
   parameter PMUX_E_CSR_OUT_ADDR   = 12'h925; // Port E Output value CSR
   parameter PMUX_E_CSR_EN_ADDR    = 12'h926; // Port E Enable CSR
   parameter PMUX_E_CSR_IN_ADDR    = 12'h927; // Port E Input CSR
   parameter PMUX_F_CSR_CTL_ADDR   = 12'h931; // Port F Control CSR
   parameter PMUX_F_CSR_STS_ADDR   = 12'h932; // Port F Status CSR
   parameter PMUX_F_CSR_WRADR_ADDR = 12'h933; // Port F Write Pointer CSR
   parameter PMUX_F_CSR_DIR_ADDR   = 12'h934; // Port F Direction CSR
   parameter PMUX_F_CSR_OUT_ADDR   = 12'h935; // Port F Output value CSR
   parameter PMUX_F_CSR_EN_ADDR    = 12'h936; // Port F Enable CSR
   parameter PMUX_F_CSR_IN_ADDR    = 12'h937; // Port F Input CSR
   parameter PMUX_G_CSR_CTL_ADDR   = 12'h941; // Port G Control CSR
   parameter PMUX_G_CSR_STS_ADDR   = 12'h942; // Port G Status CSR
   parameter PMUX_G_CSR_WRADR_ADDR = 12'h943; // Port G Write Pointer CSR
   parameter PMUX_G_CSR_DIR_ADDR   = 12'h944; // Port G Direction CSR
   parameter PMUX_G_CSR_OUT_ADDR   = 12'h945; // Port G Output value CSR
   parameter PMUX_G_CSR_EN_ADDR    = 12'h946; // Port G Enable CSR
   parameter PMUX_G_CSR_IN_ADDR    = 12'h947; // Port G Input CSR
   parameter PMUX_Z_CSR_CTL_ADDR   = 12'h951; // Port Z Control CSR
   parameter PMUX_Z_CSR_STS_ADDR   = 12'h952; // Port Z Status CSR
   parameter PMUX_Z_CSR_WRADR_ADDR = 12'h953; // Port Z Write Pointer CSR
   parameter PMUX_Z_CSR_DIR_ADDR   = 12'h954; // Port Z Direction CSR
   parameter PMUX_Z_CSR_OUT_ADDR   = 12'h955; // Port Z Output value CSR
   parameter PMUX_Z_CSR_EN_ADDR    = 12'h956; // Port Z Enable CSR
   parameter PMUX_Z_CSR_IN_ADDR    = 12'h957; // Port Z Input CSR

endpackage 

   // import into $UNIT 
   import evo_xb_addr_pkg::*; 

`endif 
   
