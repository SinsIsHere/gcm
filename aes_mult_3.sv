module aes_mult_3 (
    input  logic [7:0] aes_mult_3_in,
    output logic [7:0] aes_mult_3_out
);
    logic [7:0] aes_mult_2_out;
    aes_mult_2 aes_mult_2_inst (
        .aes_mult_2_in (aes_mult_3_in),
        .aes_mult_2_out(aes_mult_2_out)
    );
    assign aes_mult_3_out = aes_mult_2_out ^ aes_mult_3_in;
endmodule
