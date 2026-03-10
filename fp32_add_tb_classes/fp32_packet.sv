/* fp32_packet is the base transaction object for the test.
*  Used by all parts of test setup for checking and monitoring data.
*/
class fp32_packet;
    //fp32 data structure to make testing easier
    typedef struct packed{
            bit sign;
            bit[7:0] exponent;
            bit[22:0] fraction;
    } float_XX;

    //randomize inputs for testing 
    rand float_XX in1;
    rand float_XX in2;
    float_XX sum;
    
    //prints packet data as exponents
    function void print(string tag = "");
        $display("T=%0t %s in1=%e, in2=%e, sum=%e", $time, tag, $bitstoshortreal(in1), $bitstoshortreal(in2), $bitstoshortreal(sum));
    endfunction

    //copy function for packet data transfer (used for scoreboard)
    function void copy_fp32(fp32_packet pack);
        this.in1 = pack.in1;
        this.in2 = pack.in2;
        this.sum = pack.sum;
    endfunction
endclass
