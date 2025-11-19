module scan_codes (
    input clk,
    input rst_n,
    input [15:0] code,
    input status,
    output reg control,
    output reg [3:0] num
);

    reg [15:0] prev_code;
    reg key_released;
    reg [3:0] decoded_num;
    
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_code <= 16'b0;
            key_released <= 1'b0;
            decoded_num <= 4'b0;
        end else begin
            prev_code <= code;
            
            if (prev_code[7:0] == 8'hF0 && code[7:0] != 8'hF0) begin
                key_released <= 1'b1;
                case (code[7:0])
                    8'h45: decoded_num <= 4'h0; 
                    8'h16: decoded_num <= 4'h1; 
                    8'h1E: decoded_num <= 4'h2; 
                    8'h26: decoded_num <= 4'h3; 
                    8'h25: decoded_num <= 4'h4; 
                    8'h2E: decoded_num <= 4'h5; 
                    8'h36: decoded_num <= 4'h6; 
                    8'h3D: decoded_num <= 4'h7; 
                    8'h3E: decoded_num <= 4'h8; 
                    8'h46: decoded_num <= 4'h9; 
                    default: decoded_num <= 4'hF; 
                endcase
            end else begin
                key_released <= 1'b0;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            control <= 1'b0;
            num <= 4'b0;
        end else if (status && key_released && decoded_num != 4'hF) begin
            control <= 1'b1;
            num <= decoded_num;
        end else if (!status) begin
            control <= 1'b0;
        end
    end

endmodule