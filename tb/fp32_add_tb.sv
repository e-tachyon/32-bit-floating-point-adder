/* fp32_add_tb is the main testbench setup for
*  verifying the fp32 adder. Uses the custom 
*  test setup via the import package
*/
module fp32_add_tb;

    //imports test components
    import sim_package::*;
    bit tb_clk;

    //interfaces
    clk_if m_clk_if();
    fp32_if m_fp32_if();

    //DUT fp32_adder
    fp32_add #(.SLI(1), .SLO(1), .ELI(8), .ELO(8), .FLI(23), .FLO(23))
        FPA00(.fp32_add_if(m_fp32_if));
    
    //runs test
    initial begin
        fp32_test t0;

        t0 = new;
        t0.e0.m_fp32_vif = m_fp32_if;
        t0.e0.m_clk_vif = m_clk_if;
        t0.run();

        #50 $finish;
    end
endmodule

