`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 12:19:31 PM
// Design Name: 
// Module Name: sram_1p
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


module sram_1p#(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 39
)
(
    input  wire clk,
    input  wire rstn,
    input  wire we,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout
    );
    
    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];
    
    initial begin
        $readmemh("empty_mem.mem", mem);
    end
    
    always@(posedge clk) begin
        if(!rstn) begin
            dout<=0;
        end
        else begin
            if(we) begin
                mem[addr]<=din;
            end
            else begin
                dout<=mem[addr];
            end
        end
    end
endmodule
