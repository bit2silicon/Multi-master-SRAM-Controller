`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2026 04:37:35 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench;

  // Parameters
  localparam  ADDR_WIDTH = 3;
  localparam  DATA_WIDTH = 32;
  localparam  NUM_PARITY = 6;
  localparam  CODE_WIDTH = 39;

  //Ports
  reg  clk_top;
  reg  rstn_top;
  reg  m0_req;
  reg  m0_we;
  reg [ADDR_WIDTH-1:0] m0_addr;
  reg [DATA_WIDTH-1:0] m0_wdata;
  wire [DATA_WIDTH-1:0] m0_rdata;
  wire m0_grant;
  reg  m1_req;
  reg  m1_we;
  reg [ADDR_WIDTH-1:0] m1_addr;
  reg [DATA_WIDTH-1:0] m1_wdata;
  wire [DATA_WIDTH-1:0] m1_rdata;
  wire m1_grant;
  wire gnt_valid_top;
  wire  sec_corrected_top;
  wire  ded_error_top;

  sram_ctrl # (
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_PARITY(NUM_PARITY),
    .CODE_WIDTH(CODE_WIDTH)
  )
  sram_ctrl_inst (
    .clk_top(clk_top),
    .rstn_top(rstn_top),
    .m0_req(m0_req),
    .m0_we(m0_we),
    .m0_addr(m0_addr),
    .m0_wdata(m0_wdata),
    .m0_rdata(m0_rdata),
    .m0_grant(m0_grant),
    .m1_req(m1_req),
    .m1_we(m1_we),
    .m1_addr(m1_addr),
    .m1_wdata(m1_wdata),
    .m1_rdata(m1_rdata),
    .m1_grant(m1_grant),
    .gnt_valid_top(gnt_valid_top),
    .sec_corrected_top(sec_corrected_top),
    .ded_error_top(ded_error_top)
  );

always #5  clk_top = ! clk_top;


initial begin
    clk_top = 0;
    rstn_top = 0;
    m0_req=0;
    m0_we=0;
    m0_addr=0;
    m0_wdata=0;
    m1_req=0;
    m1_we=0;
    m1_addr=0;
    m1_wdata=0;
    repeat(5) @(posedge clk_top);
    rstn_top = 1;
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b01;
    {m1_we,     m0_we    }  =   2'b01;
    {m1_addr,   m0_addr  }  =  {3'd0,3'd5};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'habcdef11};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b10;
    {m1_we,     m0_we    }  =   2'b00;
    {m1_addr,   m0_addr  }  =  {3'd5,3'd0};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'h0};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b11;
    {m1_we,     m0_we    }  =   2'b11;
    {m1_addr,   m0_addr  }  =  {3'd0,3'd2};
    {m1_wdata,  m0_wdata }  =  {32'h11111111,32'h30303030};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b11;
    {m1_we,     m0_we    }  =   2'b01;
    {m1_addr,   m0_addr  }  =  {3'd1,3'd2};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'h30303030};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b11;
    {m1_we,     m0_we    }  =   2'b00;
    {m1_addr,   m0_addr  }  =  {3'd1,3'd0};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'h0};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b10;
    {m1_we,     m0_we    }  =   2'b00;
    {m1_addr,   m0_addr  }  =  {3'd1,3'd0};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'h0};
    
    @(posedge clk_top);
    {m1_req,    m0_req   }  =   2'b00;
    {m1_we,     m0_we    }  =   2'b00;
    {m1_addr,   m0_addr  }  =  {8'd0,8'd0};
    {m1_wdata,  m0_wdata }  =  {32'h0,32'h0};
    
    repeat(5) @(posedge clk_top);
    $finish;
    
end

endmodule