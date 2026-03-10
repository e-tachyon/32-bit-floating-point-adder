/* fp32_driver drives input values to module based on data
* from generator.
*/
class fp32_driver;
    //virtual interfaces for timing and data output
    virtual fp32_if m_fp32_vif;
    virtual clk_if m_clk_vif;
    //alerts other classes that data has been "driven"
    event driver_done;
    //communicates with genreator/monitor
    mailbox driver_mailbox;

    task run();
        $display("T=%0t [Driver] starting: ", $time);

        forever begin
            fp32_packet fp32_item;

            $display("T=%0t [Driver] waiting for item: ", $time);

            //gets generated data and waits for clk to input to interface
            driver_mailbox.get(fp32_item);
            @(posedge m_clk_vif.tb_clk);
            fp32_item.print("Driver");
            m_fp32_vif.in1 <= fp32_item.in1;
            m_fp32_vif.in2 <= fp32_item.in2;
            ->driver_done;
        end
    endtask
endclass