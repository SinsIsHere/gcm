module aes_mix_column (
    input  logic [31:0] aes_mix_column_in,
    output logic [31:0] aes_mix_column_out
);
    logic [31:0] aes_mix_column_mult2;
    logic [31:0] aes_mix_column_mult3;

    generate
        for (genvar i = 0; i < 4; i = i + 1) begin
            aes_mult_2 aes_mixcol_mult2 (
                .aes_mult_2_in (aes_mix_column_in[(i+1)*8-1:i*8]),
                .aes_mult_2_out(aes_mix_column_mult2[(i+1)*8-1:i*8])
            );
            aes_mult_3 aes_mixcol_mult3 (
                .aes_mult_3_in (aes_mix_column_in[(i+1)*8-1:i*8]),
                .aes_mult_3_out(aes_mix_column_mult3[(i+1)*8-1:i*8])
            );
        end
    endgenerate

    assign aes_mix_column_out[31:24] =   aes_mix_column_mult2[31:24] ^ aes_mix_column_mult3[23:16]
                                       ^ aes_mix_column_in[15:8]     ^ aes_mix_column_in[7:0];
    assign aes_mix_column_out[23:16] =   aes_mix_column_in[31:24]    ^ aes_mix_column_mult2[23:16]
                                       ^ aes_mix_column_mult3[15:8]  ^ aes_mix_column_in[7:0];
    assign aes_mix_column_out[15:8]  =   aes_mix_column_in[31:24]    ^ aes_mix_column_in[23:16]
                                       ^ aes_mix_column_mult2[15:8]  ^ aes_mix_column_mult3[7:0];
    assign aes_mix_column_out[7:0]   =   aes_mix_column_mult3[31:24] ^ aes_mix_column_in[23:16]
                                       ^ aes_mix_column_in[15:8]     ^ aes_mix_column_mult2[7:0];
endmodule
