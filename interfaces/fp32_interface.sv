/* fp32_if hold the inputs of the fp32_add module.
*  Organized in interface for better testability
*/
interface fp32_if();
    //fp32 data structure
    typedef struct packed{
            logic sign;
            logic[7:0] exponent;
            logic[22:0] fraction;
    } float_XX;

    //in/outs
    float_XX in1;
    float_XX in2;
    float_XX sum;

    //modport making data directions clear
    modport dut(
        input in1, in2,
        output sum
    );
endinterface