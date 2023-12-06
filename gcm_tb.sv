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
    
    always #10 clk = ~clk;

    initial begin
        #000000 clk              = 1;
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




        #000500 gcm_key_i       <= 128'h1332_2005_e134_02ca_4675_d599_81e5_51b0;
                gcm_key_vld_i	<= 1;
		gcm_iv_vld_i    <= 1;
                gcm_data_i      <= 128'hb5e3_5be4_7112_4098_7ddf_8f39_0000_0000;
		gcm_end_i       <= 0;

        #000020 gcm_iv_vld_i    <= 0;
                gcm_data_vld_i  <= 0;
                gcm_key_vld_i	<= 0;
                gcm_aad_vld_i   <= 1;
                gcm_data_i      <= 128'h54b4_a7d1_85c8_9fd3_d3ef_6f36_7324_b4b9;//c2aeba5a;
                gcm_end_i       <= 0;

        #000020 gcm_data_i      <= 128'h2dbf_e3c2_6bc7_c72f_0697_5908_3ebf_8acf;//c2aeba5a;

        #000020 gcm_aad_vld_i   <= 0;
                gcm_data_vld_i  <= 1;
                gcm_data_i      <= 128'h10b3_ddee_7f11_4a78_d7ed_131a_1d83_f9e5;//2e14_98d2_59b5_4390_b85e_3eef_1c02_df60;e743_f1b8_4038_2c4b_ccaf_3baf_b4ca_8429;bea063;
        #000020 gcm_data_i      <= 128'hca73_7604_1b64_8dcc_1648_1bc9_d493_fd66;
        #000020 gcm_data_i      <= 128'h323e_0295_4c5f_f433_5ed4_e2a5_70a6_160b;
        #000020 gcm_data_i      <= 128'h0aef_5408_2524_4d53_3c21_6738_f940_b024;
                gcm_end_i       <= 1;
        #000020 gcm_end_i       <= 0;
                gcm_data_vld_i  <= 0;

    end
endmodule
