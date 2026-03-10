    /* fp32_generator generates random test cases.
    *  Allows for large and random test coverage.
    */
    class fp32_generator;
    int loop = 1000;
    event driver_done;
    mailbox driver_mailbox;
    //some edge case tests
    //each come as a set of 2
    //largest + largest, nan + normal, subnormal + subnormal,
    //largest - largest, 0 + 0, inf + inf, 1 - (largest less than 1) : [catastrophic cancellation]
    logic [31:0] edge_case_q [$] = {'h7f7fffff, 'h7f7fffff, 'hffc00001, 'h7f7f0001, 'h00000001, 'h00000001, 
                                    'h7f7fffff, 'hff7fffff, 'h00000000, 'h00000000, 'h7f800000, 'h7f800000,
                                    'h3f800000, 'hbf7fffff};

    //randomizes packet and sends information to driver
    //waits to generate next case on driver event completion
    task run();
        $display ("T=%0t [Generator] Start", $time);
        while(edge_case_q.size() > 0) begin
            fp32_packet fp32_item = new;
            fp32_item.in1 = edge_case_q.pop_front();
            fp32_item.in2 = edge_case_q.pop_front();
            driver_mailbox.put(fp32_item);
            @(driver_done);
        end
        for(int i = 0; i < loop; i++) begin
            fp32_packet fp32_item = new;
            fp32_item.randomize();
            driver_mailbox.put(fp32_item);
            @(driver_done);
        end

        $display ("T=%0t [Generator] End", $time);
    endtask
endclass