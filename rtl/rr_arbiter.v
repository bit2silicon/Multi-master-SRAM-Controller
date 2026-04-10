`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/08/2026 12:25:06 PM
// Design Name: 
// Module Name: rr_arbiter
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


module rr_arbiter(
    input  wire clk,
    input  wire rstn,
    input  wire [1:0] req,
    output reg  [1:0] grant,
    output reg  gnt_valid
    );
    
    reg priority; // 0 - for Master-0 and 1 for Master-1
    
    // grant - should be combinational to not add delay in write or read cycle 
    always@(*) begin
        if(!rstn) begin
            gnt_valid<=1'b0;
            grant<=2'b00;
        end
        else begin
            case(req)
            2'b00: // no request
            begin
                gnt_valid<=1'b0;
                grant<=2'b00;
            end
            2'b01: // Master-0
            begin
                gnt_valid<=1'b1;
                grant<=2'b01;
            end
            2'b10: // Master-1
            begin
                gnt_valid<=1'b1;
                grant<=2'b10;
            end
            2'b11: // clash
            begin
                if(priority)
                    grant<=2'b10;
                else 
                    grant<=2'b01;    
                gnt_valid<=1'b1;
            end
            default:
            begin
                grant<=2'b00;
                gnt_valid<=1'b0;
            end
            endcase
        end
    end
    
    // priority needs to be registered - for bus contention
    always@(posedge clk) begin
        if(!rstn) begin
            priority<=1'b0;
        end
        else begin
            if(req == 2'b11) 
                priority<=~priority;    
            else
                priority<=priority;
        end
    end
    
endmodule
