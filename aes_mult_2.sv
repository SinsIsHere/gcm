module aes_mult_2 (
    input  logic [7:0] aes_mult_2_in,
    output logic [7:0] aes_mult_2_out
);
    assign aes_mult_2_out = (aes_mult_2_in[7]) ? ({aes_mult_2_in[6:0], 1'b0} ^ 8'b0001_1011)
                                               :  {aes_mult_2_in[6:0], 1'b0};
endmodule
