//===========================================================================
//  Copyright(c) Alorium Technology Inc., 2020
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : evo_xb.sv
// Author      : Steve Phillips
// Contact     : support@aloriumtech.com
// Description : 
// 
// The evo_xb module is a wrapper module to allow IP blocks and XB blocks 
// to be instantiated and integrated into tthe Evo FPGA design
//
//===========================================================================

module evo_xb
   (// Basic clock and reset
    input                             clk,
    input                             reset_n,
    // Other clocks and reset
    input                             pwr_on_nrst,
    input                             pll_locked,
    input                             clk_bsp,
    input                             clk_60,
    input                             clk_120,
    input                             clk_16,
    input                             clk_32,
    input                             en16mhz,
    input                             en1mhz,
    input                             en128khz,
    // PMUX connections
    output logic [PORT_D_DWIDTH-1:0]  port_d_pmux_dir_o,
    output logic [PORT_D_DWIDTH-1:0]  port_d_pmux_out_o,
    output logic [PORT_D_DWIDTH-1:0]  port_d_pmux_en_o,
    input logic [PORT_D_DWIDTH-1:0]   port_d_pmux_in_i,
    
    output logic [PORT_E_DWIDTH-1:0]  port_e_pmux_dir_o,
    output logic [PORT_E_DWIDTH-1:0]  port_e_pmux_out_o,
    output logic [PORT_E_DWIDTH-1:0]  port_e_pmux_en_o,
    input logic [PORT_E_DWIDTH-1:0]   port_e_pmux_in_i,
    
    output logic [PORT_F_DWIDTH-1:0]  port_f_pmux_dir_o,
    output logic [PORT_F_DWIDTH-1:0]  port_f_pmux_out_o,
    output logic [PORT_F_DWIDTH-1:0]  port_f_pmux_en_o,
    input logic [PORT_F_DWIDTH-1:0]   port_f_pmux_in_i,
    
    output logic [PORT_G_DWIDTH-1:0]  port_g_pmux_dir_o,
    output logic [PORT_G_DWIDTH-1:0]  port_g_pmux_out_o,
    output logic [PORT_G_DWIDTH-1:0]  port_g_pmux_en_o,
    input logic [PORT_G_DWIDTH-1:0]   port_g_pmux_in_i,
    
    output logic [PORT_Z_DWIDTH-1:0]  port_z_pmux_dir_o,
    output logic [PORT_Z_DWIDTH-1:0]  port_z_pmux_out_o,
    output logic [PORT_Z_DWIDTH-1:0]  port_z_pmux_en_o,
    input logic [PORT_Z_DWIDTH-1:0]   port_z_pmux_in_i,

    // Interface to evo_i2c_ctrl (Avalon MM Slave)
    input logic [MADR_MSB-1:0]        avs_csr_address,
    input logic                       avs_csr_read, 
    output logic                      avs_csr_waitresponse,
    output logic                      avs_csr_readdatavalid,
    output logic                      avs_csr_waitrequest,
    input logic                       avs_csr_write,
    input logic [CSR_DWIDTH-1:0]      avs_csr_writedata,
    output logic [CSR_DWIDTH-1:0]     avs_csr_readdata
    );       

   
   // CSR slave output from the evo_xb_info module
   logic                              avs_info_csr_readdatavalid;
   logic                              avs_info_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_info_csr_readdata;
   // CSR slave output from the evo_pmux_csr module
   logic                              avs_d_csr_readdatavalid;
   logic                              avs_d_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_d_csr_readdata;
   logic                              avs_e_csr_readdatavalid;
   logic                              avs_e_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_e_csr_readdata;
   logic                              avs_f_csr_readdatavalid;
   logic                              avs_f_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_f_csr_readdata;
   logic                              avs_g_csr_readdatavalid;
   logic                              avs_g_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_g_csr_readdata;
   logic                              avs_z_csr_readdatavalid;
   logic                              avs_z_csr_waitrequest;
   logic [CSR_DWIDTH-1:0]             avs_z_csr_readdata;
   
   // OR together the slave outputs of any CSR slaves
   always_comb avs_csr_readdatavalid = avs_info_csr_readdatavalid |
                                       avs_d_csr_readdatavalid    |
                                       avs_e_csr_readdatavalid    |
                                       avs_f_csr_readdatavalid    |
                                       avs_g_csr_readdatavalid    |
                                       avs_z_csr_readdatavalid;
   always_comb avs_csr_waitrequest   = avs_info_csr_waitrequest   |
                                       avs_d_csr_waitrequest      |
                                       avs_e_csr_waitrequest      |
                                       avs_f_csr_waitrequest      |
                                       avs_g_csr_waitrequest      |
                                       avs_z_csr_waitrequest;
   always_comb avs_csr_readdata      = avs_info_csr_readdata      |
                                       avs_d_csr_readdata         |
                                       avs_e_csr_readdata         |
                                       avs_f_csr_readdata         |
                                       avs_g_csr_readdata         |
                                       avs_z_csr_readdata;

   // Tie off waitresponse. Not used.
   always_comb avs_csr_waitresponse  = 1'h0;

   //----------------------------------------------------------------------
   // Instance Name:  evo_xb_info_inst
   // Module Type:    evo_xb_info
   //
   //----------------------------------------------------------------------
   evo_xb_info
   evo_xb_info_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_info_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_info_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_info_csr_readdata)
      );

   //----------------------------------------------------------------------
   // Instance Name:  evo_xb_pmux_inst
   // Module Type:    evo_xb_pmux
   //
   //----------------------------------------------------------------------

   // How many PMUX inputs per port. If multiple XBs will be able
   // to control any one pin then these values should be adjusted
   // accordanly
   localparam PORT_D_PMUX_WIDTH = 4;
   localparam PORT_E_PMUX_WIDTH = 4;
   localparam PORT_F_PMUX_WIDTH = 4;
   localparam PORT_G_PMUX_WIDTH = 4;
   localparam PORT_Z_PMUX_WIDTH = 4;
   
   // Create input busses for port pmux inputs, setting width to be a
   // multiple of the PRT_DWIDTH for that port. The multiple is the
   // max number of XBs that want to contol a single pin in that port
   logic [(PORT_D_DWIDTH*PORT_D_PMUX_WIDTH)-1:0] port_d_pmux_dir_i,
                                                 port_d_pmux_out_i,
                                                 port_d_pmux_en_i;
   logic [(PORT_E_DWIDTH*PORT_E_PMUX_WIDTH)-1:0] port_e_pmux_dir_i,
                                                 port_e_pmux_out_i,
                                                 port_e_pmux_en_i;
   logic [(PORT_F_DWIDTH*PORT_F_PMUX_WIDTH)-1:0] port_f_pmux_dir_i,
                                                 port_f_pmux_out_i,
                                                 port_f_pmux_en_i;
   logic [(PORT_G_DWIDTH*PORT_G_PMUX_WIDTH)-1:0] port_g_pmux_dir_i,
                                                 port_g_pmux_out_i,
                                                 port_g_pmux_en_i;
   logic [(PORT_Z_DWIDTH*PORT_Z_PMUX_WIDTH)-1:0] port_z_pmux_dir_i,
                                                 port_z_pmux_out_i,
                                                 port_z_pmux_en_i;

   // Assign PMUX connections from XB modules to the desired ports and
   // pins. Width of these busses will always be in multiple of the
   // Port width.
/* These are driven by the evo_pmux_csr instantiations below
    always_comb begin
      port_d_pmux_dir_i = 'h0;
      port_d_pmux_out_i = 'h0;
      port_d_pmux_en_i  = 'h0;
      port_e_pmux_dir_i = 'h0;
      port_e_pmux_out_i = 'h0;
      port_e_pmux_en_i  = 'h0;
      port_f_pmux_dir_i = 'h0;
      port_f_pmux_out_i = 'h0;
      port_f_pmux_en_i  = 'h0;
      port_g_pmux_dir_i = 'h0;
      port_g_pmux_out_i = 'h0;
      port_g_pmux_en_i  = 'h0;
      port_z_pmux_dir_i = 'h0;
      port_z_pmux_out_i = 'h0;
      port_z_pmux_en_i  = 'h0;
   end
*/
   evo_xb_pmux
     #(
       .D_MUX_WIDTH (PORT_D_PMUX_WIDTH),
       .E_MUX_WIDTH (PORT_E_PMUX_WIDTH),
       .F_MUX_WIDTH (PORT_F_PMUX_WIDTH),
       .G_MUX_WIDTH (PORT_G_PMUX_WIDTH),
       .Z_MUX_WIDTH (PORT_Z_PMUX_WIDTH)
       )
   evo_xb_pmux_inst
     (// PMUX connections from XB/IP blocks
      .port_d_dir_i (port_d_pmux_dir_i),
      .port_d_out_i (port_d_pmux_out_i),
      .port_d_en_i  (port_d_pmux_en_i),
      .port_e_dir_i (port_e_pmux_dir_i),
      .port_e_out_i (port_e_pmux_out_i),
      .port_e_en_i  (port_e_pmux_en_i),
      .port_f_dir_i (port_f_pmux_dir_i),
      .port_f_out_i (port_f_pmux_out_i),
      .port_f_en_i  (port_f_pmux_en_i),
      .port_g_dir_i (port_g_pmux_dir_i),
      .port_g_out_i (port_g_pmux_out_i),
      .port_g_en_i  (port_g_pmux_en_i),
      .port_z_dir_i (port_z_pmux_dir_i),
      .port_z_out_i (port_z_pmux_out_i),
      .port_z_en_i  (port_z_pmux_en_i),
      // PMUX connections to ports
      .port_d_dir_o (port_d_pmux_dir_o),
      .port_d_out_o (port_d_pmux_out_o),
      .port_d_en_o  (port_d_pmux_en_o),
      .port_e_dir_o (port_e_pmux_dir_o),
      .port_e_out_o (port_e_pmux_out_o),
      .port_e_en_o  (port_e_pmux_en_o),
      .port_f_dir_o (port_f_pmux_dir_o),
      .port_f_out_o (port_f_pmux_out_o),
      .port_f_en_o  (port_f_pmux_en_o),
      .port_g_dir_o (port_g_pmux_dir_o),
      .port_g_out_o (port_g_pmux_out_o),
      .port_g_en_o  (port_g_pmux_en_o),
      .port_z_dir_o (port_z_pmux_dir_o),
      .port_z_out_o (port_z_pmux_out_o),
      .port_z_en_o  (port_z_pmux_en_o)
      );
   
   //======================================================================
   //
   // INSTANTIATE YOUR CUSTOM MODULES HERE
   //
   //======================================================================
   
   //----------------------------------------------------------------------
   // Instance Name:  evo_d_pmux_csr_inst
   // Module Type:    evo_pmux_csr
   //
   //----------------------------------------------------------------------
   evo_pmux_csr
     #(.CSR_DWIDTH          (CSR_DWIDTH),
       .PORT_DWIDTH         (PORT_D_DWIDTH),
       .MUX_WIDTH           (PORT_D_PMUX_WIDTH),
       .PMUX_CSR_CTL_ADDR   (PMUX_D_CSR_CTL_ADDR),
       .PMUX_CSR_STS_ADDR   (PMUX_D_CSR_STS_ADDR),
       .PMUX_CSR_WRADR_ADDR (PMUX_D_CSR_WRADR_ADDR),
       .PMUX_CSR_DIR_ADDR   (PMUX_D_CSR_DIR_ADDR),
       .PMUX_CSR_OUT_ADDR   (PMUX_D_CSR_OUT_ADDR),
       .PMUX_CSR_EN_ADDR    (PMUX_D_CSR_EN_ADDR),
       .PMUX_CSR_IN_ADDR    (PMUX_D_CSR_IN_ADDR)
       )
   evo_d_pmux_csr_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      .pmux_dir_o                     (port_d_pmux_dir_i),
      .pmux_out_o                     (port_d_pmux_out_i),
      .pmux_en_o                      (port_d_pmux_en_i),
      .pmux_in_i                      (port_d_pmux_in_i),   
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_d_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_d_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_d_csr_readdata)
      );

   //----------------------------------------------------------------------
   // Instance Name:  evo_e_pmux_csr_inst
   // Module Type:    evo_pmux_csr
   //
   //----------------------------------------------------------------------
   evo_pmux_csr
     #(.CSR_DWIDTH          (CSR_DWIDTH),
       .PORT_DWIDTH         (PORT_E_DWIDTH),
       .MUX_WIDTH           (PORT_E_PMUX_WIDTH),
       .PMUX_CSR_CTL_ADDR   (PMUX_E_CSR_CTL_ADDR),
       .PMUX_CSR_STS_ADDR   (PMUX_E_CSR_STS_ADDR),
       .PMUX_CSR_WRADR_ADDR (PMUX_E_CSR_WRADR_ADDR),
       .PMUX_CSR_DIR_ADDR   (PMUX_E_CSR_DIR_ADDR),
       .PMUX_CSR_OUT_ADDR   (PMUX_E_CSR_OUT_ADDR),
       .PMUX_CSR_EN_ADDR    (PMUX_E_CSR_EN_ADDR),
       .PMUX_CSR_IN_ADDR    (PMUX_E_CSR_IN_ADDR)
       )
   evo_e_pmux_csr_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      .pmux_dir_o                     (port_e_pmux_dir_i),
      .pmux_out_o                     (port_e_pmux_out_i),
      .pmux_en_o                      (port_e_pmux_en_i),
      .pmux_in_i                      (port_e_pmux_in_i),   
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_e_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_e_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_e_csr_readdata)
      );

   //----------------------------------------------------------------------
   // Instance Name:  evo_f_pmux_csr_inst
   // Module Type:    evo_pmux_csr
   //
   //----------------------------------------------------------------------
   evo_pmux_csr
     #(.CSR_DWIDTH          (CSR_DWIDTH),
       .PORT_DWIDTH         (PORT_F_DWIDTH),
       .MUX_WIDTH           (PORT_F_PMUX_WIDTH),
       .PMUX_CSR_CTL_ADDR   (PMUX_F_CSR_CTL_ADDR),
       .PMUX_CSR_STS_ADDR   (PMUX_F_CSR_STS_ADDR),
       .PMUX_CSR_WRADR_ADDR (PMUX_F_CSR_WRADR_ADDR),
       .PMUX_CSR_DIR_ADDR   (PMUX_F_CSR_DIR_ADDR),
       .PMUX_CSR_OUT_ADDR   (PMUX_F_CSR_OUT_ADDR),
       .PMUX_CSR_EN_ADDR    (PMUX_F_CSR_EN_ADDR),
       .PMUX_CSR_IN_ADDR    (PMUX_F_CSR_IN_ADDR)
       )
   evo_f_pmux_csr_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      .pmux_dir_o                     (port_f_pmux_dir_i),
      .pmux_out_o                     (port_f_pmux_out_i),
      .pmux_en_o                      (port_f_pmux_en_i),
      .pmux_in_i                      (port_f_pmux_in_i),   
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_f_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_f_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_f_csr_readdata)
      );

   //----------------------------------------------------------------------
   // Instance Name:  evo_g_pmux_csr_inst
   // Module Type:    evo_pmux_csr
   //
   //----------------------------------------------------------------------
   evo_pmux_csr
     #(.CSR_DWIDTH          (CSR_DWIDTH),
       .PORT_DWIDTH         (PORT_G_DWIDTH),
       .MUX_WIDTH           (PORT_G_PMUX_WIDTH),
       .PMUX_CSR_CTL_ADDR   (PMUX_G_CSR_CTL_ADDR),
       .PMUX_CSR_STS_ADDR   (PMUX_G_CSR_STS_ADDR),
       .PMUX_CSR_WRADR_ADDR (PMUX_G_CSR_WRADR_ADDR),
       .PMUX_CSR_DIR_ADDR   (PMUX_G_CSR_DIR_ADDR),
       .PMUX_CSR_OUT_ADDR   (PMUX_G_CSR_OUT_ADDR),
       .PMUX_CSR_EN_ADDR    (PMUX_G_CSR_EN_ADDR),
       .PMUX_CSR_IN_ADDR    (PMUX_G_CSR_IN_ADDR)
       )
   evo_g_pmux_csr_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      .pmux_dir_o                     (port_g_pmux_dir_i),
      .pmux_out_o                     (port_g_pmux_out_i),
      .pmux_en_o                      (port_g_pmux_en_i),
      .pmux_in_i                      (port_g_pmux_in_i),   
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_g_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_g_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_g_csr_readdata)
      );

   //----------------------------------------------------------------------
   // Instance Name:  evo_z_pmux_csr_inst
   // Module Type:    evo_pmux_csr
   //
   //----------------------------------------------------------------------
   evo_pmux_csr
     #(.CSR_DWIDTH          (CSR_DWIDTH),
       .PORT_DWIDTH         (PORT_Z_DWIDTH),
       .MUX_WIDTH           (PORT_Z_PMUX_WIDTH),
       .PMUX_CSR_CTL_ADDR   (PMUX_Z_CSR_CTL_ADDR),
       .PMUX_CSR_STS_ADDR   (PMUX_Z_CSR_STS_ADDR),
       .PMUX_CSR_WRADR_ADDR (PMUX_Z_CSR_WRADR_ADDR),
       .PMUX_CSR_DIR_ADDR   (PMUX_Z_CSR_DIR_ADDR),
       .PMUX_CSR_OUT_ADDR   (PMUX_Z_CSR_OUT_ADDR),
       .PMUX_CSR_EN_ADDR    (PMUX_Z_CSR_EN_ADDR),
       .PMUX_CSR_IN_ADDR    (PMUX_Z_CSR_IN_ADDR)
       )
   evo_z_pmux_csr_inst
     (
      .clk                            (clk),
      .rstn                           (reset_n),
      .pmux_dir_o                     (port_z_pmux_dir_i),
      .pmux_out_o                     (port_z_pmux_out_i),
      .pmux_en_o                      (port_z_pmux_en_i),
      .pmux_in_i                      (port_z_pmux_in_i),   
      // CSR bus (Avalon MM Slave)
      .avs_csr_address                (avs_csr_address),
      .avs_csr_read                   (avs_csr_read),
      .avs_csr_readdatavalid          (avs_z_csr_readdatavalid),
      .avs_csr_waitrequest            (avs_z_csr_waitrequest),
      .avs_csr_write                  (avs_csr_write),
      .avs_csr_writedata              (avs_csr_writedata),
      .avs_csr_readdata               (avs_z_csr_readdata)
      );


endmodule // evo_xb
