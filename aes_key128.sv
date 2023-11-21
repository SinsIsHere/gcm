module aes_key128 (
    input  logic               clk,
    input  logic               rst_n,
    input  logic               aes_key_vld,
    input  logic       [127:0] aes_key_in,
    output logic [10:0][127:0] aes_key_out
);
    logic [10:1][127:0] aes_key_in_reg;
    logic [10:1][  7:0] aes_rcon;
    logic [10:1][  7:0] aes_sbox_out_31_24;
    logic [10:1][  7:0] aes_sbox_out_23_16;
    logic [10:1][  7:0] aes_sbox_out_15_08;
    logic [10:1][  7:0] aes_sbox_out_07_00;
    logic [10:0][127:0] aes_key;

    assign aes_rcon[01] = 8'h01;
    assign aes_rcon[02] = 8'h02;
    assign aes_rcon[03] = 8'h04;
    assign aes_rcon[04] = 8'h08;
    assign aes_rcon[05] = 8'h10;
    assign aes_rcon[06] = 8'h20;
    assign aes_rcon[07] = 8'h40;
    assign aes_rcon[08] = 8'h80;
    assign aes_rcon[09] = 8'h1B;
    assign aes_rcon[10] = 8'h36;

    generate
        for (genvar i = 0; i < 11; i = i + 1) begin: gen_aes_key_round
            if (i == 0) begin
                assign aes_key[0] = aes_key_in;
                always_ff @(posedge clk, negedge rst_n)
                    if      (!rst_n)      aes_key_out[0] <= '0;
                    else if (aes_key_vld) aes_key_out[0] <= aes_key[0];
                    else                  aes_key_out[0] <= aes_key_out[0];
            end else begin
                always_ff @(posedge clk, negedge rst_n)
                    if(!rst_n) aes_key_in_reg[i] <= '0;
                    else       aes_key_in_reg[i] <= aes_key_out[i-1];

                aes_sbox gen_aes_sbox_31_24 (
                    .clk         (clk),
                    .rst_n       (rst_n),
                    .aes_sbox_in (aes_key_out[i-1][23:16]),
                    .aes_sbox_out(aes_sbox_out_31_24[i])
                );
                aes_sbox gen_aes_sbox_23_16 (
                    .clk         (clk),
                    .rst_n       (rst_n),
                    .aes_sbox_in (aes_key_out[i-1][15:08]),
                    .aes_sbox_out(aes_sbox_out_23_16[i])
                );
                aes_sbox gen_aes_sbox_15_08 (
                    .clk         (clk),
                    .rst_n       (rst_n),
                    .aes_sbox_in (aes_key_out[i-1][07:00]),
                    .aes_sbox_out(aes_sbox_out_15_08[i])
                );
                aes_sbox gen_aes_sbox_07_00 (
                    .clk         (clk),
                    .rst_n       (rst_n),
                    .aes_sbox_in (aes_key_out[i-1][31:24]),
                    .aes_sbox_out(aes_sbox_out_07_00[i])
                );

                assign aes_key[i][127:096] = {aes_rcon[i] ^ aes_sbox_out_31_24[i] ^ aes_key_in_reg[i][127:120],
                                                            aes_sbox_out_23_16[i] ^ aes_key_in_reg[i][119:112],
                                                            aes_sbox_out_15_08[i] ^ aes_key_in_reg[i][111:104],
                                                            aes_sbox_out_07_00[i] ^ aes_key_in_reg[i][103:096]};
                assign aes_key[i][95:64] = aes_key[i][127:096] ^ aes_key_in_reg[i][95:64];
                assign aes_key[i][63:32] = aes_key[i][095:064] ^ aes_key_in_reg[i][63:32];
                assign aes_key[i][31:00] = aes_key[i][063:032] ^ aes_key_in_reg[i][31:00];

                always_ff @(posedge clk, negedge rst_n)
                    if (!rst_n) aes_key_out[i] <= '0;
                    else        aes_key_out[i] <= aes_key[i];                
            end
        end
    endgenerate
endmodule
