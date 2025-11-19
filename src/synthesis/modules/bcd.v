module bcd (
    input [5:0] in,
    output reg [3:0] ones,
    output reg [3:0] tens
);

integer i, d;
always @(in) begin
    i = 0;
    d = 0;
    for(i = 0; i < 6; i = i + 1) begin
        if(in[i]) d = d + 2**i;
    end
    ones = d % 10;
    tens = d / 10;
end

    
endmodule