/*
* fp32_scoreboard class checks the output of the fp32_add module and
* compares it with expected result.
*/
class fp32_scoreboard;
    //mailbox for packet transfer from monitor
    mailbox scb_mailbox;

    //single percision float data to calculate expected output
    shortreal ref_test_in1;
    shortreal ref_test_in2;
    shortreal ref_test_sum;
    shortreal item_sum;

    //counts total errors in test suite
    int error_counter = 0;

    //gets packet from mailbox
    //compares bits 
    //display pass/fail and data output
    task run();
        forever begin
            fp32_packet fp32_item, ref_fp32_item;
            scb_mailbox.get(fp32_item);
            fp32_item.print("Scoreboard");

            ref_fp32_item = new();
            ref_fp32_item.copy_fp32(fp32_item);

            ref_test_in1 = $bitstoshortreal(ref_fp32_item.in1);
            ref_test_in2 = $bitstoshortreal(ref_fp32_item.in2);

            ref_test_sum = ref_test_in1 + ref_test_in2;
            ref_fp32_item.sum = $shortrealtobits(ref_test_sum);
            item_sum = $bitstoshortreal(fp32_item.sum);
            

            if(ref_fp32_item.sum != fp32_item.sum) begin
                $display("T=%0t Sum values do not match: ref_item= %e, 0x%0h item= %e, 0x%0h", $time, 
                        ref_test_sum, ref_fp32_item.sum, item_sum, fp32_item.sum);
                        error_counter++;
            end else begin
                $display("T=%0t Sum values match: ref_item= %e, 0x%0h item= %e, 0x%0h", $time, 
                        ref_test_sum, ref_fp32_item.sum, item_sum, fp32_item.sum);
            end
        end
    endtask
endclass