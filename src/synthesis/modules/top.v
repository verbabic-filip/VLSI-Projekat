module top #(
    parameter DIVISOR = 50000000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input [1:0] kbd,        // kbd[0] = PS2_CLK, kbd[1] = PS2_DATA
    input [2:0] btn,
    input [9:0] sw,
    output [9:0] led,
    output [27:0] hex,
    output [13:0] mnt
);
    wire slow_clk;

    clk_div #(DIVISOR) s_clk (
        .clk(clk),
        .rst_n(rst_n & sw[9]),
        .out(slow_clk)
    );

    // Signals for CPU and MEMORY
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] data_in, data_out;
    wire we;
    wire [DATA_WIDTH-1:0] mem;

    wire [ADDR_WIDTH-1:0] pc_val, sp_val;
    wire [DATA_WIDTH-1:0] cpu_out;

    wire [5:0] vga_num;         // 6-bit number for VGA display (0-63)
    wire [23:0] color_code; 

    wire hsync, vsync;
    wire [3:0] red, green, blue;
    
    // PS/2 Keyboard signals
    wire [15:0] ps2_code;
    wire scan_control;
    wire [3:0] scan_num;
    wire cpu_status;

    assign led[4:0] = cpu_out[4:0];

    color_codes color_inst (
        .num(cpu_out),
        .code(color_code)
    );
    
    // VGA controller - runs at 50MHz
    vga vga_inst (
        .clk(clk),              // 50MHz directly
        .rst_n(rst_n),
        .code(color_code),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    assign mnt[13] = hsync;     // hsync
    assign mnt[12] = vsync;     // vsync
    assign mnt[11:8] = red;     // red[3:0]
    assign mnt[7:4] = green;    // green[3:0]
    assign mnt[3:0] = blue;     // blue[3:0]
    
    
    // PS/2 Controller
    ps2 ps2_inst (
        .clk(clk),           // Use fast clock for PS/2
        .rst_n(rst_n),
        .ps2_clk(kbd[0]),    // kbd[0] = PS2 clock
        .ps2_data(kbd[1]),   // kbd[1] = PS2 data
        .code(ps2_code)
    );
    
    // Scan Codes Decoder
    scan_codes scan_inst (
        .clk(clk),           // Use fast clock for scanning
        .rst_n(rst_n),
        .code(ps2_code),
        .status(cpu_status), // Connect to CPU status
        .control(scan_control),
        .num(scan_num)
    );
    
    // CPU input comes ONLY from keyboard now
    wire [3:0] cpu_input = scan_num;
    wire cpu_control = scan_control;

    // CPU instance
    cpu #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) cpu_inst (
        .clk(slow_clk),
        .rst_n(rst_n),
        .in({12'b0, cpu_input}),  // 4-bit keyboard input extended to 16-bit
        .control(cpu_control),    // Keyboard data ready signal
        .status(cpu_status),      // CPU ready for input signal
        .we(we),
        .addr(addr),
        .data(data_out),
        .mem(mem),
        .pc(pc_val),
        .sp(sp_val),
        .out(cpu_out)
    );

    // MEMORY instance
    memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FILE_NAME(FILE_NAME)
    ) mem_inst (
        .clk(slow_clk),
        .we(we),
        .addr(addr),
        .data(data_out),
        .out(mem)
    );

    // BCD to SSD display for PC and SP
    wire [3:0] ones_pc, tens_pc, ones_sp, tens_sp;

    bcd bcd_pc (.in(pc_val), .ones(ones_pc), .tens(tens_pc));
    bcd bcd_sp (.in(sp_val), .ones(ones_sp), .tens(tens_sp));

    ssd ssd0 (.in(ones_pc), .out(hex[6:0]));
    ssd ssd1 (.in(tens_pc), .out(hex[13:7]));
    ssd ssd2 (.in(ones_sp), .out(hex[20:14]));
    ssd ssd3 (.in(tens_sp), .out(hex[27:21]));
    
    // LED indicators for debugging
    assign led[9] = 1'b0;       // LED9 = CPU ready for input
    assign led[8] = 1'b0;     // LED8 = Key pressed detected
    assign led[7] = 1'b0; // LED7 = Keyboard input active
    assign led[6] = 1'b0;             // LED6 unused
    assign led[5] = cpu_status;             // LED5 unused

endmodule