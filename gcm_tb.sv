module gcm_tb;
    logic         clk;
    logic         rst_n;
    //logic         gcm_en_i;
    //logic         gcm_decrypt_i;
    logic         gcm_end_i;
    
    logic         gcm_key_vld_i;
    logic [127:0] gcm_key_i;

    logic         gcm_iv_vld_i;
    logic         gcm_aad_vld_i;
    logic         gcm_data_vld_i;
    //logic         gcm_tag_vld_i;

    logic [127:0] gcm_data_i;

    //logic         gcm_ready_o;

    logic         gcm_data_vld_o;
    logic         gcm_tag_vld_o;
    //logic         gcm_ok_vld_o;

    logic [127:0] gcm_data_o;
    //logic         gcm_ok_o;

    gcm gcm_inst(
        .clk(clk),
        .rst_n(rst_n),
        //.gcm_en_i(gcm_en_i),
        //.gcm_decrypt_i(gcm_decrypt_i),
        .gcm_end_i(gcm_end_i),
        
        .gcm_key_vld_i(gcm_key_vld_i),
        .gcm_key_i(gcm_key_i),

        .gcm_iv_vld_i(gcm_iv_vld_i),
        .gcm_aad_vld_i(gcm_aad_vld_i),
        .gcm_data_vld_i(gcm_data_vld_i),
        //.gcm_tag_vld_i(gcm_tag_vld_i),

        .gcm_data_i(gcm_data_i),

        //.gcm_ready_o(gcm_ready_o),

        .gcm_data_vld_o(gcm_data_vld_o),
        .gcm_tag_vld_o(gcm_tag_vld_o),
        //.gcm_ok_vld_o(gcm_ok_vld_o),

        .gcm_data_o(gcm_data_o)
        //.gcm_ok_o(gcm_ok_o)
    );
    
    always #10 clk <= ~clk;

    initial begin
        #000000 clk             <= 1;
                rst_n           <= 0;
                gcm_end_i       <= 0;
                gcm_key_i       <= '0;
                gcm_iv_vld_i    <= 0;
                gcm_key_vld_i   <= 0;
                gcm_aad_vld_i   <= 0;
                gcm_data_vld_i  <= 0;
                gcm_data_i      <= '0;

        #000020 rst_n           <= 1;
                gcm_key_i       <= 128'h11754cd72aec309bf52f7687212e8957;
                gcm_key_vld_i	<= 1;
		gcm_iv_vld_i    <= 1;
                gcm_data_i      <= 128'h3c819d9a9bed087615030b6500000000;
		gcm_end_i       <= 1;

        #000020 gcm_iv_vld_i    <= 0;
                gcm_data_vld_i  <= 0;
		gcm_key_vld_i	<= 0;
                gcm_data_i      <= 128'h0;
                gcm_end_i       <= 0;

        #000020 gcm_data_vld_i  <= '0;
                gcm_end_i       <= 0;




        #000500 gcm_key_i       <= 128'hfe47fcce5fc32665d2ae399e4eec72ba;
                gcm_key_vld_i	<= 1;
		gcm_iv_vld_i    <= 1;
                gcm_data_i      <= 128'h5adb9609dbaeb58cbd6e727500000000;
		gcm_end_i       <= 0;

        #000020 gcm_iv_vld_i    <= 0;
                gcm_data_vld_i  <= 0;
                gcm_key_vld_i	<= 0;
                gcm_aad_vld_i   <= 1;
                gcm_data_i      <= 128'h8831_9d6e_1d3f_fa5f_9871_9916_6c8a_9b56;//c2aeba5a;
                gcm_end_i       <= 0;

        #000020 gcm_data_i      <= 128'hc2ae_ba5a_0000_0000_0000_0000_0000_0000;//c2aeba5a;

        #000020 gcm_aad_vld_i   <= 0;
                gcm_data_vld_i  <= 1;
                gcm_data_i      <= 128'h7c0e_88c8_8899_a779_2284_6507_4797_cd4c;//2e14_98d2_59b5_4390_b85e_3eef_1c02_df60;e743_f1b8_4038_2c4b_ccaf_3baf_b4ca_8429;bea063;
        #000020 gcm_data_i      <= 128'h2e14_98d2_59b5_4390_b85e_3eef_1c02_df60;
        #000020 gcm_data_i      <= 128'he743_f1b8_4038_2c4b_ccaf_3baf_b4ca_8429;
        #000020 gcm_data_i      <= 128'hbea0_6300_0000_0000_0000_0000_0000_0000;
                gcm_end_i       <= 1;
        #000020 gcm_end_i       <= 0;
                gcm_data_vld_i  <= 0;

    end
endmodule
