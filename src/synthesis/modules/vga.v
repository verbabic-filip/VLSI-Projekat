module vga (
    input clk,                  // 50MHz for VGA (800x600 @ 72Hz)
    input rst_n,
    input [23:0] code,          // 24-bit color code: [23:12] = left, [11:0] = right
    output reg hsync,
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

    // VGA timing parameters for 800x600 @ 72Hz with 50MHz clock
    parameter H_DISPLAY = 800;
    parameter H_FRONT = 56;
    parameter H_SYNC = 120;
    parameter H_BACK = 64;
    parameter H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK;
    
    parameter V_DISPLAY = 600;
    parameter V_FRONT = 37;
    parameter V_SYNC = 6;
    parameter V_BACK = 23;
    parameter V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK;

    // Counters
    reg [11:0] h_count;  // Need 11 bits for 1056 total
    reg [10:0] v_count;  // Need 10 bits for 666 total

    // Horizontal counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 12'b0;
        end else if (h_count == H_TOTAL - 1) begin
            h_count <= 12'b0;
        end else begin
            h_count <= h_count + 1;
        end
    end

    // Vertical counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_count <= 11'b0;
        end else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1) begin
                v_count <= 11'b0;
            end else begin
                v_count <= v_count + 1;
            end
        end
    end

    // Generate sync signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            // Horizontal sync (active low)
            hsync <= !((h_count >= H_DISPLAY + H_FRONT) && 
                      (h_count < H_DISPLAY + H_FRONT + H_SYNC));
            
            // Vertical sync (active low)
            vsync <= !((v_count >= V_DISPLAY + V_FRONT) && 
                      (v_count < V_DISPLAY + V_FRONT + V_SYNC));
        end
    end

    // Generate RGB output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 4'b0;
            green <= 4'b0;
            blue <= 4'b0;
        end else if (h_count < H_DISPLAY && v_count < V_DISPLAY) begin
            // Active display area - 800x600
            if (h_count < 400) begin
                // Left half of screen (first 400 pixels) - use first 12 bits
                red <= code[23:20];
                green <= code[19:16];
                blue <= code[15:12];
            end else begin
                // Right half of screen (next 400 pixels) - use last 12 bits
                red <= code[11:8];
                green <= code[7:4];
                blue <= code[3:0];
            end
        end else begin
            // Blanking area
            red <= 4'b0;
            green <= 4'b0;
            blue <= 4'b0;
        end
    end

endmodule