`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/08/2026 12:13:18 PM
// Design Name:
// Module Name: ecc_decoder
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

module ecc_decoder#(
    parameter DATA_WIDTH = 32,
    parameter NUM_PARITY = 6,
    parameter CODE_WIDTH = 39 // 32-bit data + 6 hamming + 1 overall parity
  )(
    input  wire [CODE_WIDTH-1:0] enc_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire                  sec_corrected,
    output wire                  ded_error
  );
  reg [CODE_WIDTH-1:0] enc_error;
  reg [DATA_WIDTH-1:0] data;

  integer i,j,dindex,parity_index;
  wire received_overall_parity, calculated_overall_parity, overall_parity_error;

  reg [NUM_PARITY-1:0] synd;

  always@(*)
  begin
    enc_error = enc_in;
    synd=0;
    dindex=0;
    for(i=0;i<NUM_PARITY;i=i+1)
    begin
      $display("P%0d",2**i);
      for(j=1; j<CODE_WIDTH; j=j+1)
      begin
        if(j & 2**i)
        begin
          $display("enc_out[%0d]",j-1);
          synd[i]=synd[i]^enc_in[j-1];
        end
      end
    end

    if(synd==0 && overall_parity_error==0)
      $display("No error at all");
    else if(synd==0 && overall_parity_error)
      $display("error in the overall parity bit itself, data is fine");
    else if(synd!=0 && overall_parity_error)
    begin
      enc_error[synd-1]=~enc_in[synd-1];
      $display("single bit error → correct it, syndrome tells you which position");
    end
    else if(synd!=0 && overall_parity_error==0)
      $display("double bit error → cannot correct, raise ded_error");

    parity_index=0;
    for(i=0; i<CODE_WIDTH-1; i=i+1)
    begin
      if(i==(2**parity_index-1))
      begin
        parity_index=parity_index+1;
      end
      else
      begin
        data[dindex]=enc_error[i];
        dindex=dindex+1;
      end
    end

  end

  assign received_overall_parity   = enc_in[CODE_WIDTH-1];
  assign calculated_overall_parity = ^enc_in[CODE_WIDTH-2:0];
  assign overall_parity_error      = received_overall_parity ^ calculated_overall_parity;

  assign data_out = data;

  assign sec_corrected = synd!=0 && overall_parity_error;
  assign ded_error     = synd!=0 && overall_parity_error==0;

endmodule

