module gcm_counter (
    input logic clk,
    input logic rst_n,
    input logic ctr_rst_i,
    input logic ctr_vld_a_i,
    input logic ctr_vld_c_i,
    output logic [127:0] ctr_len_o
);
    logic [63:0] ctr_len_a;
    logic [63:0] ctr_len_c;
    assign ctr_len_o = {ctr_len_a, ctr_len_c};

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) ctr_len_a <= '0;
        else if (ctr_rst_i) ctr_len_a <= '0;
        else if (ctr_vld_a_i) ctr_len_a <= ctr_len_a + 64'd128;
        else ctr_len_a <= ctr_len_a;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) ctr_len_c <= '0;
        else if (ctr_rst_i) ctr_len_c <= '0;
        else if (ctr_vld_c_i) ctr_len_c <= ctr_len_c + 64'd128;
        else ctr_len_c <= ctr_len_c;
    end
endmodule
