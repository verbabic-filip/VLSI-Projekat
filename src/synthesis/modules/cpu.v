module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] mem,
    input [DATA_WIDTH-1:0] in,
    input control,
    output reg status,
    output reg we,
    output [ADDR_WIDTH-1:0] addr,
    output [DATA_WIDTH-1:0] data,
    output [DATA_WIDTH-1:0] out,
    output [ADDR_WIDTH-1:0] pc,
    output [ADDR_WIDTH-1:0] sp
);

// PC    
reg [5:0] pc_in;
wire [5:0] pc_out;
reg pc_cl, pc_ld, pc_inc, pc_dec, pc_sr, pc_ir, pc_sl, pc_il;

// SP
reg [5:0] sp_in;
wire [5:0] sp_out;
reg sp_cl, sp_ld, sp_inc, sp_dec, sp_sr, sp_ir, sp_sl, sp_il;

// IR
reg [31:0] ir_in;
wire [31:0] ir_out;
reg ir_cl, ir_ld, ir_inc, ir_dec, ir_sr, ir_ir, ir_sl, ir_il;

// MAR
reg [5:0] mar_in;
wire [5:0] mar_out;
reg mar_cl, mar_ld, mar_inc, mar_dec, mar_sr, mar_ir, mar_sl, mar_il;

// MDR
reg [15:0] mdr_in;
wire [15:0] mdr_out;
reg mdr_cl, mdr_ld, mdr_inc, mdr_dec, mdr_sr, mdr_ir, mdr_sl, mdr_il;

// ACC
reg [15:0] a_in;
wire [15:0] a_out;
reg a_cl, a_ld, a_inc, a_dec, a_sr, a_ir, a_sl, a_il;

register #(6) PC(.clk(clk), .rst_n(rst_n), .cl(pc_cl), .ld(pc_ld), .in(pc_in), .inc(pc_inc), .dec(pc_dec), .sr(pc_sr), .ir(pc_ir), .sl(pc_sl), .il(pc_il), .out(pc_out));
register #(6) SP(.clk(clk), .rst_n(rst_n), .cl(sp_cl), .ld(sp_ld), .in(sp_in), .inc(sp_inc), .dec(sp_dec), .sr(sp_sr), .ir(sp_ir), .sl(sp_sl), .il(sp_il), .out(sp_out));
register #(32) IR(.clk(clk), .rst_n(rst_n), .cl(ir_cl), .ld(ir_ld), .in(ir_in), .inc(ir_inc), .dec(ir_dec), .sr(ir_sr), .ir(ir_ir), .sl(ir_sl), .il(ir_il), .out(ir_out));
register #(6) MAR(.clk(clk), .rst_n(rst_n), .cl(mar_cl), .ld(mar_ld), .in(mar_in), .inc(mar_inc), .dec(mar_dec), .sr(mar_sr), .ir(mar_ir), .sl(mar_sl), .il(mar_il), .out(mar_out));
register #(16) MDR(.clk(clk), .rst_n(rst_n), .cl(mdr_cl), .ld(mdr_ld), .in(mdr_in), .inc(mdr_inc), .dec(mdr_dec), .sr(mdr_sr), .ir(mdr_ir), .sl(mdr_sl), .il(mdr_il), .out(mdr_out));
register #(16) A(.clk(clk), .rst_n(rst_n), .cl(a_cl), .ld(a_ld), .in(a_in), .inc(a_inc), .dec(a_dec), .sr(a_sr), .ir(a_ir), .sl(a_sl), .il(a_il), .out(a_out));




localparam reset = 6'd0;
localparam fetch1 = 6'd1;
localparam wait_mem1 = 6'd2;
localparam load_mdr = 6'd3; 
localparam load_ih = 6'd4;
localparam decode1 = 6'd5;  // #5
localparam wait_mem2 = 6'd6; 
localparam load_addrOp1 = 6'd7;
localparam ind_adr1 = 6'd8;
localparam wait_mem3 = 6'd9;
localparam decode2 = 6'd10;
localparam wait_mem4 = 6'd11;
localparam ind_adr2 = 6'd12;
localparam wait_mem5 = 6'd13;
localparam load_addrOp2 = 6'd14;
localparam decode3 = 6'd15;
localparam wait_mem6 = 6'd16;
localparam ind_adr3 = 6'd17;
localparam wait_mem7 = 6'd18;
localparam load_addrOp3 = 6'd19;
localparam execute = 6'd20;
localparam mov_op = 6'd21;
localparam mov_op_execute1 = 6'd22;
localparam mov_op_execute2 = 6'd23;
localparam add_op = 6'd24;
localparam add_op_execute1 = 6'd25;
localparam alu_execute1 = 6'd26;
localparam mem_write_alu1 = 6'd27;
localparam in_op_execute1 = 6'd28;
localparam out_op_execute1 = 6'd29;
localparam stop_op1 = 6'd30;
localparam stop_op2 = 6'd31;
localparam stop_op3 = 6'd32;
localparam mem_write_alu2 = 6'd33;
localparam in_op_execute2 = 6'd34;
localparam check_addr1 = 6'd35;
localparam check_addr2 = 6'd36;
localparam check_addr3 = 6'd37;
localparam check_addr4 = 6'd38;
localparam check_addr5 = 6'd39;  
localparam check_addr6 = 6'd40; // #40
localparam out_op_execute2 = 6'd41;
localparam wait_mem8 = 6'd42;
localparam wait_mem9 = 6'd43;
localparam wait_mem10 = 6'd44;
localparam stopped = 6'd45;



reg [DATA_WIDTH-1:0] out_reg, out_next;
reg [5:0] state_reg, state_next;
reg [2:0] alu_oc;
reg [DATA_WIDTH-1:0] alu_a, alu_b;
wire [DATA_WIDTH-1:0] alu_f;

alu #(16) ALU(.oc(alu_oc), .a(alu_a), .b(alu_b), .f(alu_f));

wire i_d1, i_d2, i_d3;
wire [3:0] oc;

reg [2:0] addr_op1_reg, addr_op1_next, addr_op2_reg, addr_op2_next, addr_op3_reg, addr_op3_next;

reg waiting_for_input;

assign out = out_reg;
assign pc = pc_out;
assign sp = sp_out;
assign addr = mar_out;
assign data = mdr_out;
assign i_d1 = ir_out[27];
assign i_d2 = ir_out[23];
assign i_d3 = ir_out[19];
assign oc = ir_out[31:28];

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        out_reg <= {DATA_WIDTH{1'b0}};
        state_reg <= 6'd0;
        addr_op1_reg <= 3'd0;
        addr_op2_reg <= 3'd0;
        addr_op3_reg <= 3'd0;
    end
    else begin
        out_reg <= out_next;
        state_reg <= state_next;
        addr_op1_reg <= addr_op1_next;
        addr_op2_reg <= addr_op2_next;
        addr_op3_reg <= addr_op3_next;
    end
end

always @(*) begin

    out_next = out_reg;
    state_next = state_reg;
    addr_op1_next = addr_op1_reg;
    addr_op2_next = addr_op2_reg;
    addr_op3_next = addr_op3_reg;

    // PC
    pc_ld  = 1'b0;
    pc_cl  = 1'b0;
    pc_inc = 1'b0;
    pc_dec = 1'b0;
    pc_sr  = 1'b0;
    pc_ir  = 1'b0;
    pc_sl  = 1'b0;
    pc_il  = 1'b0;
    pc_in  = {ADDR_WIDTH{1'b0}};

    // SP
    sp_ld  = 1'b0;
    sp_cl  = 1'b0;
    sp_inc = 1'b0;
    sp_dec = 1'b0;
    sp_sr  = 1'b0;
    sp_ir  = 1'b0;
    sp_sl  = 1'b0;
    sp_il  = 1'b0;
    sp_in  = {ADDR_WIDTH{1'b0}};

    // IR
    ir_ld  = 1'b0;
    ir_cl  = 1'b0;
    ir_inc = 1'b0;
    ir_dec = 1'b0;
    ir_sr  = 1'b0;
    ir_ir  = 1'b0;
    ir_sl  = 1'b0;
    ir_il  = 1'b0;
    ir_in  = {32{1'b0}};

    // MAR
    mar_ld  = 1'b0;
    mar_cl  = 1'b0;
    mar_inc = 1'b0;
    mar_dec = 1'b0;
    mar_sr  = 1'b0;
    mar_ir  = 1'b0;
    mar_sl  = 1'b0;
    mar_il  = 1'b0;
    mar_in  = {ADDR_WIDTH{1'b0}};

    // MDR
    mdr_ld  = 1'b0;
    mdr_cl  = 1'b0;
    mdr_inc = 1'b0;
    mdr_dec = 1'b0;
    mdr_sr  = 1'b0;
    mdr_ir  = 1'b0;
    mdr_sl  = 1'b0;
    mdr_il  = 1'b0;
    mdr_in  = {DATA_WIDTH{1'b0}};

    // ACC
    a_ld  = 1'b0;
    a_cl  = 1'b0;
    a_inc = 1'b0;
    a_dec = 1'b0;
    a_sr  = 1'b0;
    a_ir  = 1'b0;
    a_sl  = 1'b0;
    a_il  = 1'b0;
    a_in  = {DATA_WIDTH{1'b0}};

    // WE
    we = 1'b0;

    // ALU kontrola
    alu_oc = 3'b000;
    alu_a  = {DATA_WIDTH{1'b0}};
    alu_b  = {DATA_WIDTH{1'b0}};

    status = 1'b0;


    case(state_reg)

        //0
        reset: begin
            pc_ld = 1'b1;
            pc_in = 6'd8;
            sp_ld = 1'b1;
            sp_in = {ADDR_WIDTH{1'b1}};
            state_next = fetch1;
        end
        //1
        fetch1: begin
            mar_ld = 1'b1;
            mar_in = pc;
            pc_inc = 1'b1;
            state_next = wait_mem1;
        end
        //2
        wait_mem1: begin
            state_next = load_mdr;
        end
        //3
        load_mdr: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = load_ih;
        end
        //4
        load_ih: begin
            ir_ld = 1'b1;
            ir_in = {mdr_out, {16'd0}};
            state_next = wait_mem3;
        end
        //9
        wait_mem3: begin
             state_next = decode1;
        end

        //5
        decode1: begin
            if (ir_out[27]) begin
                mar_ld = 1'b1;
                mar_in = ir_out[26:24];
                state_next = wait_mem2;
            end
            else begin 
                state_next = load_addrOp1;
            end
            
        end
        //6
        wait_mem2: begin
            state_next = check_addr1;  
        end
        //35
        check_addr1: begin         
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = load_addrOp1;
        end
        

        //7
        load_addrOp1: begin
            if(ir_out[27]) begin
                addr_op1_next = mdr_out;
            end
            else begin
                addr_op1_next =  ir_out[26:24];
            end
            state_next = decode2;
        end
        //10
        decode2: begin
            if (ir_out[23]) begin
                mar_ld = 1'b1;
                mar_in = ir_out[22:20];
                state_next = wait_mem4;
            end
            else begin
                state_next = load_addrOp2;
            end
        end
        //11
        wait_mem4: begin
            state_next = check_addr3;  
        end
        //37
        check_addr3: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = load_addrOp2;
        end
        
        //14
        load_addrOp2: begin
            if(ir_out[23]) begin
                addr_op2_next = mdr_out;
            end
            else begin
                addr_op2_next =  ir_out[22:20];
            end
            state_next = decode3;
        end
        //15
        decode3: begin
            if (ir_out[19]) begin
                mar_ld = 1'b1;
                mar_in = ir_out[18:16];
                state_next = wait_mem6;
            end
            else begin
                state_next = load_addrOp3;
            end
        end
        //16
        wait_mem6: begin
            state_next = check_addr5;  
        end
        //39
        check_addr5: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = load_addrOp3;
        end
        
        //19
        load_addrOp3: begin
            if(ir_out[19]) begin
                addr_op3_next = mdr_out;
            end
            else begin
                addr_op3_next =  ir_out[18:16];
            end
            state_next = execute;
        end
        //20
        execute: begin
            case (oc)
                // MOV
                4'b0000: begin
                    mar_ld = 1'b1;
                    mar_in = {3'b000, addr_op2_next};
                    state_next = wait_mem7;
                end
                
                // ADD
                4'b0001: begin
                    mar_ld = 1'b1;
                    mar_in = {3'b000, addr_op2_next};
                    state_next = wait_mem8;
                end

                // SUB
                4'b0010: begin
                    mar_ld = 1'b1;
                    mar_in = {3'b000, addr_op2_next};
                    state_next = wait_mem8;
                end

                // MUL
                4'b0011: begin
                    mar_ld = 1'b1;
                    mar_in = {3'b000, addr_op2_next};
                    state_next = wait_mem8;
                end

                // DIV
                4'b0011: begin
                    state_next = fetch1;
                end

                // IN
                4'b0111: begin
                    mar_ld = 1'b1;
                    mar_in = addr_op1_next;
    
                    if (control) begin  // If keyboard input is available
                        status = 1'b1;  // Acknowledge we received the input
                        state_next = in_op_execute1;
                        //waiting_for_input = 1'b0;
                    end else begin
                     // Wait for keyboard input
                        status = 1'b1;  // Indicate CPU is ready for input
                        state_next = execute;  // Stay in execute state to keep checking
                        //waiting_for_input = 1'b1;
                    end
                end

                // OUT
                4'b1000: begin
                    mar_ld = 1'b1;
                    mar_in = addr_op1_next;
                    state_next = wait_mem5;
                end

                // STOP
                4'b1111: begin
                    mar_ld = 1'b1;
                    mar_in = addr_op1_next;
                    state_next = stop_op1;
                end

            endcase
        end
        wait_mem7: begin
            state_next = mov_op;
        end
        //21
        mov_op: begin
            if(addr_op3_next == 4'b0000) begin
                mdr_ld = 1'b1;
                mdr_in = mem;
                state_next = mov_op_execute1;
            end
        end
        //22
        mov_op_execute1: begin
            mar_ld = 1'b1;
            mar_in = addr_op1_next;
            state_next = mov_op_execute2;
        end
        //23
        mov_op_execute2: begin
            we = 1'b1;
            state_next = fetch1;
        end
        //42
        wait_mem8: begin
            state_next = add_op;
        end
        //24
        add_op: begin
            a_ld = 1'b1;
            a_in = mem;
            mar_ld = 1'b1;
            mar_in = addr_op3_next;
            state_next = wait_mem9;
        end
        //43
        wait_mem9: begin
            state_next = add_op_execute1;
        end
        //25
        add_op_execute1: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = alu_execute1;
        end
        //26
        alu_execute1: begin
            alu_a = a_out;
            alu_b = mdr_out;

            case(ir_out[31:28])
                4'b0001: alu_oc = 3'b000;
                4'b0010: alu_oc = 3'b001;
                4'b0011: alu_oc = 3'b010;
                4'b0100: alu_oc = 3'b011;
            endcase

            mdr_ld = 1'b1;
            mdr_in = alu_f;
            state_next = mem_write_alu1;
        end
        //27
        mem_write_alu1: begin
            mar_ld = 1'b1;
            mar_in = addr_op1_next;
            
            state_next = wait_mem10;
        end
        //44
        wait_mem10: begin
            state_next = mem_write_alu2;
        end

        //33
        mem_write_alu2: begin
            we = 1'b1;
            state_next = fetch1;
        end
        //28
        in_op_execute1: begin
            mdr_ld = 1'b1;
            mdr_in = in;
            state_next = in_op_execute2;
            waiting_for_input = 1'b0;
        end
        //34
        in_op_execute2: begin
            we = 1'b1;
            state_next = fetch1;
        end
        //13
        wait_mem5: begin
            state_next = out_op_execute1;
        end
        //29
        out_op_execute1: begin
            mdr_ld = 1'b1;
            mdr_in = mem;
            state_next = out_op_execute2;
        end
        //41
        out_op_execute2: begin
            out_next = mdr_out;
            state_next = fetch1;
        end
        //30
        stop_op1: begin
            if(addr_op1_next != 3'b000) begin
                out_next = mem;
            end
            mar_ld = 1'b1;
            mar_in = addr_op2_next;
            state_next = stop_op2;
        end
        //31
        stop_op2: begin
            if(addr_op2_next != 3'b000) begin
                out_next = mem;
            end
            mar_ld = 1'b1;
            mar_in = addr_op3_next;
            state_next = stop_op3;
        end
        //32
        stop_op3: begin
            if(addr_op3_next != 3'b000) begin
                out_next = mem;
            end
            state_next = stopped;
        end

        stopped: begin
            state_next = stopped;
        end

        endcase
end

endmodule