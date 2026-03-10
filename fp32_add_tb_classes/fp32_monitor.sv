/* fp32_monitor used to send current situation to scoreboard
*/
class fp32_monitor;
    //for monitoring interface data
    virtual fp32_if m_fp32_vif;
    virtual clk_if m_clk_vif;
    //communicate current situation to scoreboard
    mailbox scb_mailbox;

    //get current interface state every clock and send to scoreboard
    task run();
        $display("T=%0t [Monitoring]", $time);

        forever begin
            fp32_packet m_fp32_packet = new();
            #1;
                @(posedge m_clk_vif.tb_clk);
                m_fp32_packet.in1 = m_fp32_vif.in1;
                m_fp32_packet.in2 = m_fp32_vif.in2;
                m_fp32_packet.sum = m_fp32_vif.sum;
                m_fp32_packet.print("Monitor");
            scb_mailbox.put(m_fp32_packet);
        end
    endtask
endclass