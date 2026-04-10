module sram_ctrl#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_PARITY = 6,
    parameter CODE_WIDTH = 39
)(
    input  wire clk_top,
    input  wire rstn_top,
    
    // Master 0 
    input   wire m0_req,
    input   wire m0_we,
    input   wire [ADDR_WIDTH-1:0] m0_addr,
    input   wire [DATA_WIDTH-1:0] m0_wdata,
    output  wire [DATA_WIDTH-1:0] m0_rdata,
    output  reg  m0_grant,
    
    // Master 1 
    input   wire m1_req,
    input   wire m1_we,
    input   wire [ADDR_WIDTH-1:0] m1_addr,
    input   wire [DATA_WIDTH-1:0] m1_wdata,
    output  wire [DATA_WIDTH-1:0] m1_rdata,
    output  reg  m1_grant,
     
    output  wire  gnt_valid_top,
    
    // ECC Error status
    output  wire sec_corrected_top,
    output  wire ded_error_top  
    );
    
    wire  [1:0] mem_req, mem_grant;
    wire  [ADDR_WIDTH-1:0] addr_master_to_mem;
    wire  [DATA_WIDTH-1:0] data_master_to_enc;
    wire  [DATA_WIDTH-1:0] data_dec_to_master;
    wire  [CODE_WIDTH-1:0] data_mem_to_dec;
    wire  [CODE_WIDTH-1:0] data_enc_to_mem;
    reg   [CODE_WIDTH-1:0] data_enc_to_mem_error;
    wire                  we_master_to_mem;
    wire                  gnt_valid_int;
    reg   [DATA_WIDTH-1:0] fwd_wdata;
    reg   [ADDR_WIDTH-1:0] fwd_waddr;
    reg                    fwd_we;
    
    assign mem_req            = {m1_req, m0_req};    
    assign data_master_to_enc = (mem_grant==2'b01) ? m0_wdata : (mem_grant==2'b10 ? m1_wdata : 39'd0);
    assign addr_master_to_mem = (mem_grant==2'b01) ? m0_addr : (mem_grant==2'b10 ? m1_addr : 0);
    assign we_master_to_mem   = (mem_grant==2'b01) ? m0_we : (mem_grant==2'b10 ? m1_we : 0);
    assign m0_rdata           = (fwd_we && ~m0_we && (m0_addr == fwd_waddr)) ? fwd_wdata : data_dec_to_master;
    assign m1_rdata           = (fwd_we && ~m1_we && (m1_addr == fwd_waddr)) ? fwd_wdata : data_dec_to_master;
    assign gnt_valid_top      = gnt_valid_int;
    
    always@(posedge clk_top) begin
        if(!rstn_top) begin
            m1_grant<=0;
            m0_grant<=0;
        end
        else begin
            if(gnt_valid_int) begin
                m1_grant<=mem_grant[1];
                m0_grant<=mem_grant[0];
            end
            else begin
                m1_grant<=0;
                m0_grant<=0;
            end
        end
    end
    
    always@(*) begin
        data_enc_to_mem_error = data_enc_to_mem;
//        data_enc_to_mem_error[10] = ~data_enc_to_mem[10];
//        data_enc_to_mem_error[11] = ~data_enc_to_mem[11];
    end
    
    always@(posedge clk_top) begin
        if(!rstn_top) begin
            fwd_we    <= 0;
            fwd_waddr <= 0;
            fwd_wdata <= 0;
        end
        else begin
            fwd_we    <= we_master_to_mem;
            fwd_waddr <= addr_master_to_mem;
            fwd_wdata <= data_master_to_enc;
        end
    end
    
    rr_arbiter arbiter1(
                .clk(clk_top),
                .rstn(rstn_top),
                .req(mem_req),
                .gnt_valid(gnt_valid_int),
                .grant(mem_grant)
                );
                
     ecc_encoder #(
                .DATA_WIDTH(DATA_WIDTH),
                .NUM_PARITY(NUM_PARITY),
                .CODE_WIDTH(CODE_WIDTH)
              )
                enc1(
                .data_in(data_master_to_enc),
                .enc_out(data_enc_to_mem)
                );
                
     sram_1p #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(CODE_WIDTH)
              )  
                sram_mem1(
                .clk(clk_top),
                .rstn(rstn_top),
                .we(we_master_to_mem),
                .addr(addr_master_to_mem),
                .din(data_enc_to_mem_error),
                .dout(data_mem_to_dec)
                );
                
     ecc_decoder #(
                .DATA_WIDTH(DATA_WIDTH),
                .NUM_PARITY(NUM_PARITY),
                .CODE_WIDTH(CODE_WIDTH)
              )
                dec1(
                .enc_in(data_mem_to_dec),
                .data_out(data_dec_to_master),
                .sec_corrected(sec_corrected_top),
                .ded_error(ded_error_top)
                );

endmodule