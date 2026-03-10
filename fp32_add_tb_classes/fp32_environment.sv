/* fp32_environment holds all components of test and connects them.
* Connects mailboxes for communication, Events for triggering tasks,
* and instanciates all test component instances
*/
class fp32_environment;
    //test component instances
    fp32_generator g0;
    fp32_driver d0;
    fp32_monitor m0;
    fp32_scoreboard s0;
    mailbox scb_mailbox;
    virtual fp32_if m_fp32_vif;
    virtual clk_if m_clk_vif;
    
    //mailboxes for component communication
    event driver_done;
    mailbox driver_mailbox;

    //constructs component classes with blank values
    function new();
        d0 = new;
        m0 = new;
        s0 = new;
        scb_mailbox = new();
        g0 = new;
        driver_mailbox = new;
    endfunction

    //connects all components
    virtual task run();
        d0.m_fp32_vif = m_fp32_vif;
        m0.m_fp32_vif = m_fp32_vif;
        d0.m_clk_vif = m_clk_vif;
        m0.m_clk_vif = m_clk_vif;

        d0.driver_mailbox = driver_mailbox;
        g0.driver_mailbox = driver_mailbox;

        m0.scb_mailbox = scb_mailbox;
        s0.scb_mailbox = scb_mailbox;

        d0.driver_done = driver_done;
        g0.driver_done = driver_done;

        //starts all test processes
        //exits on generator end
        fork
            s0.run();
            d0.run();
            m0.run();
            g0.run();
        join_any
        disable fork;

    endtask
    
    //displays final test results (just # failed and total tests for now)
    task wrap_up();
        $display("---------------------------------------");
        $display("Simulation Finished: %d Inputs Processed", g0.loop + 7);
        $display("Total Errors: %0d", s0.error_counter);
        $display("---------------------------------------");
    endtask
endclass