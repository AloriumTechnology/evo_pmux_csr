//===========================================================================
//  Copyright(c) Alorium Technology Inc., 2020
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : evo_pmux_csr.sv
// Author      : Steve Phillips
// Contact     : support@aloriumtech.com
//
// Description : 
//
// This module takes one of the port pmux busses and allows the user
// to control the pmux buss bitt values via CSR registers. It is
// intended to both provide a way to test the pmux functionality and
// serve as an example to users of how to use the pmux.
//
// The CTL reg allows the user to perform special functions.
// - The CTL_PAT_CMD causes a repeating pattern to be loaded into the
//   selected CSR regs (DIR, OUT, or EN)
// - The CLT_SEL_*** bits specify which reg will be operated on. The 
//   CTL_SEL_ALL causes all three to be operated on
// - The CTL[31:24] bit field is a data field. For instance, it holds 
//   the pattern that will be replicated in the selected CSR for the 
//   CTL_PAT_CMD
//
//===========================================================================

module evo_pmux_csr
  #(parameter CSR_DWIDTH     = 32,
    parameter PORT_DWIDTH    = 32,
    parameter MUX_WIDTH      = 16,
    parameter PMUX_CSR_CTL_ADDR   = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_STS_ADDR   = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_WRADR_ADDR = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_DIR_ADDR   = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_OUT_ADDR   = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_EN_ADDR    = 0, // Actually defined in evo_xb_addr_pkg.sv
    parameter PMUX_CSR_IN_ADDR    = 0  // Actually defined in evo_xb_addr_pkg.sv
    )
   (
    input                                      clk,
    input                                      rstn,
    
    output logic [(PORT_DWIDTH*MUX_WIDTH)-1:0] pmux_dir_o, // To Port logic
    output logic [(PORT_DWIDTH*MUX_WIDTH)-1:0] pmux_out_o, // To Port logic
    output logic [(PORT_DWIDTH*MUX_WIDTH)-1:0] pmux_en_o, // To Port logic
    input logic [PORT_DWIDTH-1:0]              pmux_in_i, // From Pins
    
    // Interface to evo_i2c_ctrl (Avalon MM Slave)
    input logic [CSR_AWIDTH-1:0]               avs_csr_address,
    input logic                                avs_csr_read, 
    output logic                               avs_csr_readdatavalid,
    output logic                               avs_csr_waitrequest,
    input logic                                avs_csr_write,
    input logic [CSR_DWIDTH-1:0]               avs_csr_writedata,
    output logic [CSR_DWIDTH-1:0]              avs_csr_readdata
    );                    
   
   localparam CTL_PAT_CMD  = 1;
   localparam CTL_PAT_SHFT = 2;
   localparam CTL_SEL_DIR  = 4;
   localparam CTL_SEL_OUT  = 5;
   localparam CTL_SEL_EN   = 6;
   localparam CTL_SEL_ALL  = 7;

   logic [63:0]                                pattern_64b;

   logic [CSR_DWIDTH-1:0]                      ctl_f; 
   logic                                       ctl_sel,    ctl_we,    ctl_re; 
   logic [CSR_DWIDTH-1:0]                      sts_f; 
   logic                                       sts_sel,    sts_we,    sts_re; 
   logic [3:0]                                 wr_ptr_f;
   logic                                       wradr_sel,  wradr_we,  wradr_re; 
   logic [MUX_WIDTH-1:0][PORT_DWIDTH-1:0]      dir_f; 
   logic                                       dir_sel,    dir_we,    dir_re; 
   logic [MUX_WIDTH-1:0][PORT_DWIDTH-1:0]      out_f; 
   logic                                       out_sel,    out_we,    out_re; 
   logic [MUX_WIDTH-1:0][PORT_DWIDTH-1:0]      en_f; 
   logic                                       en_sel,     en_we,     en_re; 
   logic [PORT_DWIDTH-1:0]                     in_f; 
   logic                                       in_sel,     in_we,     in_re; 
   
   //===========================================================================
   // CSR interface and register Logic: 
   //===========================================================================
   always_comb ctl_sel    = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_CTL_ADDR;
   always_comb sts_sel    = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_STS_ADDR;
   always_comb wradr_sel  = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_WRADR_ADDR;
   always_comb dir_sel    = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_DIR_ADDR;
   always_comb out_sel    = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_OUT_ADDR;
   always_comb en_sel     = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_EN_ADDR;
   always_comb in_sel     = avs_csr_address[CSR_AWIDTH-1:0] == PMUX_CSR_IN_ADDR;

   always_comb ctl_we     = ctl_sel       && avs_csr_write; 
   always_comb sts_we     = sts_sel       && avs_csr_write; 
   always_comb wradr_we   = wradr_sel     && avs_csr_write; 
   always_comb dir_we     = dir_sel       && avs_csr_write; 
   always_comb out_we     = out_sel       && avs_csr_write; 
   always_comb en_we      = en_sel        && avs_csr_write; 
   always_comb in_we      = in_sel        && avs_csr_write; 

   always_comb ctl_re     = ctl_sel       && avs_csr_read;
   always_comb sts_re     = sts_sel       && avs_csr_read;
   always_comb wradr_re   = wradr_sel     && avs_csr_read;
   always_comb dir_re     = dir_sel       && avs_csr_read;
   always_comb out_re     = out_sel       && avs_csr_read;
   always_comb en_re      = en_sel        && avs_csr_read;
   always_comb in_re      = in_sel        && avs_csr_read;
   
   // Extend 8 bit pattern to 64 bits
   always_comb pattern_64b = {8{ctl_f[31:24]}};

   // The CTL reg allows the user to start the sppecial function statemachines
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         ctl_f  <= 32'h0;
      end else if (ctl_we) begin
         ctl_f <= avs_csr_writedata[CSR_DWIDTH-1:0];         
      end else begin
         ctl_f[CTL_PAT_CMD] <= 1'b0; // Should be a one-shot
      end
   end

   // The STS reg allows the user to read the status. 
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         sts_f  <= 32'h0;
      end else if (sts_we) begin
         sts_f <= avs_csr_writedata[CSR_DWIDTH-1:0];         
      end
   end

   // The wr_ptr keeps track of which CSR reg index we are writing
   // to. A typical write operation would be to write the value for the
   // wr_ptr and then a value for one of the dir/out/en/in regs. It also
   // supports a burst mode in which multiple writes will be written to
   // incrementing wr_ptr values.
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         wr_ptr_f  <= 4'h0;
      end else if (wradr_we) begin
         wr_ptr_f <= avs_csr_writedata[PORT_DWIDTH-1:0];         
         //      end else if (dir_we || out_we || en_we) begin
         //         wr_ptr_f  <= wr_ptr_f + 1;
      end
   end

   // DIR Control
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         for (int i1=0; i1<MUX_WIDTH; i1++) begin
            dir_f[i1]  <= {PORT_DWIDTH{1'b0}};
         end
      end else if (dir_we) begin
         dir_f[wr_ptr_f]  <= avs_csr_writedata[PORT_DWIDTH-1:0];
      end else if (ctl_f[CTL_PAT_CMD]) begin
         if (ctl_f[CTL_SEL_DIR] || ctl_f[CTL_SEL_ALL]) begin
            if ( !ctl_f[CTL_PAT_SHFT] ) begin
               for (int patd=0; patd < MUX_WIDTH; patd++) begin
                  dir_f[patd] <= pattern_64b[PORT_DWIDTH-1:0];
               end 
            end else begin // do pattern shift
               for (int patd=0; patd < MUX_WIDTH; patd++) begin
                  dir_f[patd] <= pattern_64b[(CSR_DWIDTH - patd) +: PORT_DWIDTH];
               end
            end
         end
      end
   end
   
   // OUT Control
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         for (int i2=0; i2<MUX_WIDTH; i2++) begin
            out_f[i2]  <= {PORT_DWIDTH{1'b0}};
         end
      end else if (out_we) begin
         out_f[wr_ptr_f]  <= avs_csr_writedata[PORT_DWIDTH-1:0];
      end else if (ctl_f[CTL_PAT_CMD]) begin
         if (ctl_f[CTL_SEL_OUT] || ctl_f[CTL_SEL_ALL]) begin
            if ( !ctl_f[CTL_PAT_SHFT] ) begin
               for (int pato=0; pato < MUX_WIDTH; pato++) begin
                  out_f[pato] <= pattern_64b[PORT_DWIDTH-1:0];
               end
            end else begin // do pattern shift
               for (int patos=0; patos < MUX_WIDTH; patos++) begin
                  out_f[patos] <= pattern_64b[(CSR_DWIDTH - patos) +: PORT_DWIDTH];
               end
            end
         end
      end
   end
   
   // EN Control
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         for (int i3=0; i3<MUX_WIDTH; i3++) begin
            en_f[i3]  <= {PORT_DWIDTH{1'b0}};
         end
      end else if (en_we) begin
         en_f[wr_ptr_f]  <= avs_csr_writedata[PORT_DWIDTH-1:0];
      end else if (ctl_f[CTL_PAT_CMD]) begin
         if (ctl_f[CTL_SEL_EN] || ctl_f[CTL_SEL_ALL]) begin
            if ( !ctl_f[CTL_PAT_SHFT] ) begin
               for (int pate=0; pate < MUX_WIDTH; pate++) begin
                  en_f[pate] <= pattern_64b[PORT_DWIDTH-1:0];
               end // for
            end else begin // do pattern shift
               for (int pate=0; pate < MUX_WIDTH; pate++) begin
                  en_f[pate] <= pattern_64b[(CSR_DWIDTH - pate) +: PORT_DWIDTH];
               end
            end
         end
      end
   end
   
   // IN Control
   always_ff @(posedge clk or negedge rstn) begin
      if (!rstn) begin 
         in_f  <= {PORT_DWIDTH{1'b0}};
      end else if (in_we) begin
         in_f  <= avs_csr_writedata[PORT_DWIDTH-1:0];
      end
      else begin
         in_f  <= pmux_in_i;
      end
   end
   
   // Set the values for CSR Read operations
   always_ff @(posedge clk) avs_csr_readdata <= ({CSR_DWIDTH{ctl_sel}} & ctl_f) |
                                                ({CSR_DWIDTH{sts_sel}} & sts_f) |
                                                ({{(CSR_DWIDTH-PORT_DWIDTH){1'b0}},
                                                  (
                                                   ({PORT_DWIDTH{wradr_sel}} &       wr_ptr_f)  |
                                                   ({PORT_DWIDTH{dir_sel}}   & dir_f[wr_ptr_f]) |
                                                   ({PORT_DWIDTH{out_sel}}   & out_f[wr_ptr_f]) |
                                                   ({PORT_DWIDTH{en_sel}}    &  en_f[wr_ptr_f]) |
                                                   ({PORT_DWIDTH{in_sel}}    &  in_f)
                                                   )
                                                  }
                                                 );
                                                

   always_ff @(posedge clk) avs_csr_readdatavalid <= ctl_re   ||
                                                     sts_re   ||
                                                     wradr_re ||   
                                                     dir_re   ||
                                                     out_re   ||
                                                     en_re    ||
                                                     in_re;

   // These signals are not used in the current implementation. The
   // QSYS based deisgn will change this
   always_comb avs_csr_waitresponse  = 1'b0;
   always_comb avs_csr_waitrequest   = 1'b0;


   //===========================================================================
   // Build PMUX output
   //===========================================================================

   // For each mux input, 0 thru 15, assign a 32 bit DIR, a 32 bit
   // OUT, and a 32 bit EN value to the appropriate pmux fields
   always_comb begin
      for (int i=0; i<MUX_WIDTH; i++) begin
         // Calculate msb and lsb for the i'th slice
         pmux_dir_o[PORT_DWIDTH*i +: PORT_DWIDTH] = dir_f[i];
         pmux_out_o[PORT_DWIDTH*i +: PORT_DWIDTH] = out_f[i];
         pmux_en_o[PORT_DWIDTH*i +: PORT_DWIDTH]  =  en_f[i];
      end
   end

endmodule
   
