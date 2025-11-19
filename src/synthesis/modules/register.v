module register #(
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [DATA_WIDTH-1:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output reg [DATA_WIDTH-1:0] out
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        out <= {DATA_WIDTH{1'b0}};
    else if (cl)
        out <= {DATA_WIDTH{1'b0}};
    else if (ld)
        out <= in;
    else if (inc)
        out <= out + 1'b1;
    else if (dec)
        out <= out - 1'b1;
    else if (sr)
        out <= {ir, out[DATA_WIDTH-1:1]};
    else if (sl)
        out <= {out[DATA_WIDTH-2:0], il};
end
    
endmodule