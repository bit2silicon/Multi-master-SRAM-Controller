`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 09:48:37 AM
// Design Name: 
// Module Name: encoder
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


module ecc_encoder#(
    parameter DATA_WIDTH = 32,
    parameter NUM_PARITY = 6,
    parameter CODE_WIDTH = 39 // 32-bit data + 6 hamming + 1 overall parity
)(
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg [CODE_WIDTH-1:0] enc_out
    );
    
    integer i,j;
    reg [$clog2(DATA_WIDTH)+1:0] parity_index;
    reg [$clog2(CODE_WIDTH)-1:0] data_index;
    
    always@(*) begin
        data_index=0;
        parity_index=0;
        for(i=0; i<CODE_WIDTH-1; i=i+1) begin
            if(i==(2**parity_index-1)) begin
                enc_out[i]=1'b0;
                parity_index=parity_index+1;
            end
            else begin
                enc_out[i]=data_in[data_index];
                data_index=data_index+1;
            end
        end
        
        for(i=0;i<NUM_PARITY;i=i+1) begin
        $display("P%0d",2**i);
            for(j=1; j<CODE_WIDTH; j=j+1) begin
                if(j & 2**i) begin
                    $display("enc_out[%0d]",j-1);
                    enc_out[2**i-1]=enc_out[2**i-1]^enc_out[j-1];
                end
            end
        end
        enc_out[CODE_WIDTH-1]=^enc_out[CODE_WIDTH-2:0];
    end
    
endmodule
