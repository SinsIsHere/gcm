module gcm (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         gcm_en_i,
    input  logic         gcm_decrypt_i,

    input  logic         gcm_key_vld_i,
    input  logic [127:0] gcm_key_i,

    input  logic         gcm_iv_vld_i,
    input  logic         gcm_aad_vld_i,
    input  logic         gcm_data_vld_i,
    input  logic         gcm_tag_vld_i,
    input  logic         gcm_end_i,

    input  logic [127:0] gcm_data_i,

    output logic         gcm_ready_o,

    output logic         gcm_data_vld_o,
    output logic         gcm_tag_vld_o,
    output logic         gcm_ok_vld_o,

    output logic [127:0] gcm_data_o,
    output logic         gcm_ok_o,
);
//CONNECTIONS-----------------------------------------------------------------//
    logic       [127:0] jn;
    logic       [127:0] aes_p_in;
    logic [10:0][127:0] aes_key_conn;
    logic       [127:0] aes_out;
    logic               aes_out_vld;
    logic       [127:0] pipe_out;
    logic       [127:0] mult_out;
    logic       [127:0] len_out;
//----------------------------------------------------------------------------//





//REGISTERS-------------------------------------------------------------------//
    logic [ 95:0] iv_reg;
    logic [ 31:0] inc1_reg;
    logic         has_aad_reg;
    logic         has_fin_pipe;
    logic         has_end;
    logic         real_end;
    logic [127:0] h_reg;
    logic [127:0] j0_reg;
//----------------------------------------------------------------------------//





//IV-&-INC1-------------------------------------------------------------------//
    always_ff @(posedge clk, negedge rst_n) begin
        if      (!rst_n)       iv_reg <= '0;
        else if (gcm_iv_vld_i) iv_reg <= gcm_data_i[127:32];
        else                   iv_reg <= iv_reg;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if      (!rst_n)                        inc1_reg <= '0;
        else if (gcm_iv_vld_i | gcm_data_vld_i) inc1_reg <= inc1_reg + 1'b1;
        else                                    inc1_reg <= inc1_reg;
    end

    assign jn = {iv_reg, inc1_reg};
//----------------------------------------------------------------------------//





//DATA-PIPELINE---------------------------------------------------------------//
    logic [22:0][127:0] pipe;
    assign pipe_out = pipe[22];
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) has_aad_reg <= '0;
        else if (gcm_aad_vld_i) has_aad_reg <= 1'b1;
        else if (gcm_iv_vld_i) has_aad_reg <= 1'b0;
        else has_aad_reg <= has_aad_reg;
    end
    generate
        for (genvar i = 0; i < 23; i++) begin
            if (i == 0) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) pipe[0] <= '0;
                    else if (!has_aad_reg & gcm_data_vld_i) pipe[0] <= gcm_data_i;
                    else pipe[0] <= pipe[0];
                end
            end else if (i == 1) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) pipe[1] <= '0;
                    else if (has_aad_reg | gcm_aad_vld_i) pipe[1] <= gcm_data_i;
                    else pipe[1] <= pipe[0];
                end
            end else begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) pipe[i] <= '0;
                    else pipe[i] <= pipe[i-1];
                end
            end
        end
    endgenerate
//----------------------------------------------------------------------------//





//AES-&-KEY-EXPANSION---------------------------------------------------------//
    logic aes_h_en;
    logic aes_j0_en;
    logic aes_p_en;
    logic aes_p_vld;

    assign aes_h_en  =   gcm_iv_vld_i;
    assign aes_p_in  = (~gcm_iv_vld_i) ? jn : '0;
    assign aes_p_vld = aes_h_en | aes_j0_en | gcm_data_vld_i;//aes_p_en;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) aes_j0_en <= '0;
        else        aes_j0_en <= gcm_iv_vld_i;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) aes_p_en <= '0;
        else        aes_p_en <= gcm_data_vld_i;
    end

    aes aes_inst (
        .clk(clk),
        .rst_n(rst_n),
        .aes_p_vld(aes_p_vld),
        .aes_p_in(aes_p_in),
        .aes_key_in(aes_key_conn),
        .aes_c_out(aes_out),
        .aes_c_vld(aes_out_vld)
    );

    aes_key128 keys_inst (
        .clk(clk),
        .rst_n(rst_n),
        .aes_key_vld(gcm_key_vld_i),
        .aes_key_in(gcm_key_i),
        .aes_key_out(aes_key_conn)
    );
//----------------------------------------------------------------------------//





//H-REGISTER------------------------------------------------------------------//
    logic [21:0] h_en_pipe;
    logic        h_en;

    generate
        for (genvar i = 0; i < 22; i++) begin
            if (i == 0)
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) h_en_pipe[0] <= 0;
                    else h_en_pipe[0] <= gcm_iv_vld_i;
                end
            else
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) h_en_pipe[i] <= 0;
                    else h_en_pipe[i] <= h_en_pipe[i-1];
                end
        end
    endgenerate

    assign h_en = h_en_pipe[21];

    always_ff @(posedge clk, negedge rst_n) begin
        if      (!rst_n) h_reg <= '0;
        else if (h_en)   h_reg <= aes_out;
        else             h_reg <= h_reg;
    end
//----------------------------------------------------------------------------//





//J0-REGISTER-----------------------------------------------------------------//
    logic        j0_en;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) j0_en <= '0;
        else j0_en <= h_en;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if      (!rst_n) j0_reg <= '0;
        else if (j0_en)   j0_reg <= aes_out;
        else             j0_reg <= j0_reg;
    end
//----------------------------------------------------------------------------//





//MULT------------------------------------------------------------------------//
    logic [21:0]  aad_sel_pipe;
    logic [22:0]  cp_sel_pipe;
    logic         aad_sel;
    logic         cp_sel;
    logic         len_sel;

    logic [127:0] mult_in;

    assign aad_sel = aad_sel_pipe[21];
    assign cp_sel  =  cp_sel_pipe[22];
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) len_sel <= '0;
        else len_sel <= real_end;
    end

    assign mult_in = (aad_sel) ? pipe_out :
                     ( cp_sel) ? pipe_out ^ aes_out :
                     (len_sel) ? len_out  : '0;

    generate
        for (genvar i = 0; i < 22; i++) begin
            if (i == 0) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aad_sel_pipe[0] <= '0;
                    else aad_sel_pipe[0] <= gcm_aad_vld_i;
                end
            end else begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) aad_sel_pipe[i] <= '0;
                    else aad_sel_pipe[i] <= aad_sel_pipe[i-1];
                end
            end
        end
    endgenerate

    generate
        for (genvar i = 0; i < 23; i++) begin
            if (i == 0) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) cp_sel_pipe[0] <= '0;
                    else if (!has_aad_reg & gcm_data_vld_i) cp_sel_pipe[0] <= gcm_data_vld_i;
                    else cp_sel_pipe[0] <= cp_sel_pipe[0];
                end
            end else if (i == 1) begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) cp_sel_pipe[1] <= '0;
                    else if (has_aad_reg | gcm_aad_vld_i) cp_sel_pipe[1] <= gcm_data_vld_i;
                    else cp_sel_pipe[1] <= cp_sel_pipe[0];
                end
            end else begin
                always_ff @(posedge clk, negedge rst_n) begin
                    if (!rst_n) cp_sel_pipe[i] <= '0;
                    else cp_sel_pipe[i] <= cp_sel_pipe[i-1];
                end
            end
        end
    endgenerate

    gcm_mult gcm_mult_inst(
        .clk(clk),
        .rst_n(rst_n),
        .x(mult_in ^ mult_out),
        .y(h_reg),
        .z(mult_out)
    );
//----------------------------------------------------------------------------//





//"HAS"-SIGNALS-----------------------------------------------------------------//
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) has_fin_pipe <= '0;
        else if (j0_en) has_fin_pipe <= 1'b1;
        else if (gcm_iv_vld_i | real_end) has_fin_pipe <= 1'b0;
        else has_fin_pipe <= has_fin_pipe;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) has_end <= '0;
        else if (gcm_end_i) has_end <= 1'b1;
        else if (gcm_iv_vld_i | real_end) has_end <= 1'b0;
        else has_end <= has_end;
    end

    assign real_end = has_end & has_fin_pipe & ~aad_sel & ~cp_sel;
//----------------------------------------------------------------------------//





//LENGTH-COUNTER--------------------------------------------------------------//
    gcm_counter len_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ctr_rst_i(gcm_iv_vld_i),
        .ctr_vld_a_i(gcm_aad_vld_i),
        .ctr_vld_c_i(gcm_data_vld_i),
        .ctr_len_o(len_out)
    );
//----------------------------------------------------------------------------//





//DATA-OUT--------------------------------------------------------------------//
    logic [127:0] dout_in;
    logic         tag_sel;
    assign dout_in = (aad_sel) ? pipe_out :
                     ( cp_sel) ? pipe_out ^ aes_out :
                     (tag_sel) ? mult_out ^  j0_reg : '0;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) tag_sel <= '0;
        else if (gcm_iv_vld_i) tag_sel <= '0;
        else tag_sel <= len_sel;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) gcm_data_vld_o <= '0;
        else gcm_data_vld_o <= aad_sel | cp_sel;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) gcm_tag_vld_o <= '0;
        else gcm_tag_vld_o <= tag_sel;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) gcm_data_o <= '0;
        else gcm_data_o <= dout_in;
    end
//----------------------------------------------------------------------------//





//COMPARATOR------------------------------------------------------------------//
    logic [127:0] tag_in;
    logic         ok_out;
    assign ok_out = (tag_in == (mult_out ^  j0_reg)) ? 1'b1 : 1'b0;
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) gcm_ok_vld_o <= '0;
        else        gcm_ok_vld_o <= tag_sel & gcm_decrypt_i;
    end
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) gcm_ok_o <= '0;
        else        gcm_ok_o <= ok_out & gcm_decrypt_i;
    end
//----------------------------------------------------------------------------//
endmodule
