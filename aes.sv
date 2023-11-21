module aes (
    input  logic               clk,
    input  logic               rst_n,
    //input  logic               aes_en,
    input  logic               aes_p_vld,
    input  logic       [127:0] aes_p_in,
    input  logic [10:0][127:0] aes_key_in,
    output logic       [127:0] aes_c_out,
    output logic               aes_c_vld
);
    //logic               aes_central_en;
    logic       [127:0] aes_p_in_reg;
    logic [10:0][127:0] aes_round_data;
    logic [10:1][127:0] aes_round_sbox;
    logic [10:1][127:0] aes_round_shift_row;
    logic [10:1][127:0] aes_round_mix_column;
    logic [21:0]        aes_vld_pipe;

    //assign aes_central_en = aes_en & aes_p_vld;

    generate
        for (genvar i = 0; i < 11; i = i + 1) begin: gen_round
            if (i == 0) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if      (!rst_n)    aes_p_in_reg <= '0;
                    else if (aes_p_vld) aes_p_in_reg <= aes_p_in;
                    else                aes_p_in_reg <= aes_p_in_reg;
                end
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aes_round_data[0] <= '0;
                    else        aes_round_data[0] <= aes_p_in_reg ^ aes_key_in[0];
                end
            end else begin
                for (genvar j = 0; j < 16; j = j + 1) begin
                    aes_sbox round_sbox (
                        .clk         (clk),
                        .rst_n       (rst_n),
                        .aes_sbox_in (aes_round_data[i-1][(j+1)*8-1:j*8]),
                        .aes_sbox_out(aes_round_sbox[i][(j+1)*8-1:j*8])
                    );
                end
                assign aes_round_shift_row[i][127:96] = {aes_round_sbox[i][127:120], aes_round_sbox[i][ 87:80 ], aes_round_sbox[i][ 47:40 ], aes_round_sbox[i][  7:0 ]};
                assign aes_round_shift_row[i][ 95:64] = {aes_round_sbox[i][ 95:88 ], aes_round_sbox[i][ 55:48 ], aes_round_sbox[i][ 15:8  ], aes_round_sbox[i][103:96]};
                assign aes_round_shift_row[i][ 63:32] = {aes_round_sbox[i][ 63:56 ], aes_round_sbox[i][ 23:16 ], aes_round_sbox[i][111:104], aes_round_sbox[i][ 71:64]};
                assign aes_round_shift_row[i][ 31:0 ] = {aes_round_sbox[i][ 31:24 ], aes_round_sbox[i][119:112], aes_round_sbox[i][ 79:72 ], aes_round_sbox[i][ 39:32]};
                if (i < 10) begin
                    aes_mix_column round_mixcol_127_96 (
                        .aes_mix_column_in (aes_round_shift_row[i][127:96]),
                        .aes_mix_column_out(aes_round_mix_column[i][127:96])
                    );
                    aes_mix_column round_mixcol_95_64 (
                        .aes_mix_column_in (aes_round_shift_row[i][95:64]),
                        .aes_mix_column_out(aes_round_mix_column[i][95:64])
                    );
                    aes_mix_column round_mixcol_63_32 (
                        .aes_mix_column_in (aes_round_shift_row[i][63:32]),
                        .aes_mix_column_out(aes_round_mix_column[i][63:32])
                    );
                    aes_mix_column round_mixcol_31_00 (
                        .aes_mix_column_in (aes_round_shift_row[i][31:0]),
                        .aes_mix_column_out(aes_round_mix_column[i][31:0])
                    );
                end else begin
                    assign aes_round_mix_column[10] = aes_round_shift_row[10];
                end
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aes_round_data[i] <= '0;
                    else        aes_round_data[i] <= aes_round_mix_column[i] ^ aes_key_in[i];
                end
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < 22; i = i + 1) begin
            if (i == 0) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aes_vld_pipe[0] <= '0;
                    else        aes_vld_pipe[0] <= aes_p_vld;
                end
            end else begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aes_vld_pipe[i] <= '0;
                    else        aes_vld_pipe[i] <= aes_vld_pipe[i-1];
                end
            end
        end
    endgenerate
    
    assign aes_c_out = aes_round_data[10];
    assign aes_c_vld = aes_vld_pipe[21];
endmodule
