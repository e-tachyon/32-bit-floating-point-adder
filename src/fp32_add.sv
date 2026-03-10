module fp32_add #(parameter SLI=1, SLO=1, ELI=8, ELO=8, FLI=23, FLO=23, WLI=SLI+ELI+FLI, WLO=SLO+ELO+FLO, FLE=(FLI*2)+3)
                (fp32_if.dut fp32_add_if);
        
        //float data type
        typedef struct packed{
            logic[SLI-1:0] sign;
            logic[ELI-1:0] exponent;
            logic[FLI-1:0] fraction;
        } float_XX;
        
        float_XX input_big;
        float_XX input_small;
        float_XX sum_out;

        logic nan_in1;
        logic nan_in2;

        //variables for working on intermidiate values
        reg[FLE-1:0] in_big_mantissa;
        reg[FLE-1:0] in_small_mantissa;
        reg[ELI-1:0] exponent_shift;
        reg[FLE-1:0] sum_mantissa;
        reg[ELI:0] sum_exponent;
        reg[$clog2(FLE):0] shift;

        //for implicit zero checks
        reg in_big_implicit;
        reg in_small_implicit;

        //larger exponent check
        reg larger_exp;

        //rouding logic bits: guard, round, sticky, lowest bit
        reg [3:0] lgrs;
        reg round_carry;

        //loop variable
        int i;

        /*combinational logic block to add floats
        *   logic:
        *       checks for lower exponent and then shifts to align ->
        *       insersts 1 in front -> 
        *       2's compliment for signed addition/subtraction ->
        *       gets sum sign -> 
        *       shifts fraction to standerd format ->
        *       adjusts exponent
        *
        */
        always_comb begin
            //inserts 3'b001 infront of fraction for implicit 1 and overflow on adding
            larger_exp = fp32_add_if.in1.exponent > fp32_add_if.in2.exponent;
            case(larger_exp)
                1'b1: begin
                    input_big = fp32_add_if.in1;
                    input_small = fp32_add_if.in2;
                end 
                1'b0: begin
                    input_big = fp32_add_if.in2;
                    input_small = fp32_add_if.in1;
                end
            endcase
            sum_exponent = input_big.exponent;

            in_big_implicit = ~| input_big.exponent;
            in_small_implicit = ~| input_small.exponent;

            exponent_shift = input_big.exponent - input_small.exponent;
            if((exponent_shift > 0) & in_small_implicit)
                exponent_shift = exponent_shift - 1;

            case(in_big_implicit)
                1'b1: in_big_mantissa = {3'b000, input_big.fraction, {FLI{1'b0}}};
                1'b0: in_big_mantissa = {3'b001, input_big.fraction, {FLI{1'b0}}};
            endcase

            case(in_small_implicit)
                1'b1: in_small_mantissa = {3'b000, input_small.fraction, {FLI{1'b0}}} >> exponent_shift;
                1'b0: in_small_mantissa = {3'b001, input_small.fraction, {FLI{1'b0}}} >> exponent_shift;
            endcase

            if(input_big.sign == 1)
                in_big_mantissa = ~in_big_mantissa + 1'b1;

            if(input_small.sign == 1)
                in_small_mantissa = ~in_small_mantissa + 1'b1;

            //add 2's compliment numbers together
            sum_mantissa = in_big_mantissa + in_small_mantissa;

            //get sum sign
            sum_out.sign = sum_mantissa[FLE-1];

            //convert back to unsigned
            if(sum_out.sign == 1)
                sum_mantissa = ~sum_mantissa + 1'b1;

            for(i=0; i < FLE; i = i + 1) begin
                if(sum_mantissa[i]) begin
                    shift = FLE - i;
                end
            end

            //adjusts exponent based on shift amount in relation to # of bits added to front (3)
            //if shift causes exponent to go below range, exponent goes to 0
            case((shift > sum_exponent) || (sum_mantissa == 0)) 
                1'b1: begin
                    sum_exponent = {ELI{1'b0}};
                    shift = 3;
                end
                1'b0: begin
                    sum_exponent = (sum_exponent - shift) + 3;
                end
            endcase
            

            //shfits numbr to right leaving the 1 in front for rounding check
            sum_mantissa = sum_mantissa << (shift - 1);

            //gets grs and lowsst bit for rounding check
            lgrs[3:0] = sum_mantissa[FLE-(FLI+1):FLE-(FLI+4)];
            case(shift > 2)
                1'b1: begin
                    lgrs[0] = |sum_mantissa[FLE-(FLI+4):0];
                end 
                1'b0: begin
                    lgrs[0] = |lgrs[1:0];
                end
            endcase
 
            //rounding logic: round to nearest - ties to even
            case(lgrs)
            4'b1111, 4'b0111, 4'b1101, 4'b0101, 4'b1110, 4'b0110, 4'b1100: begin
                {round_carry, sum_mantissa} = sum_mantissa + (1 << (FLE-(FLI+1)));
                end
                default: begin
                {round_carry, sum_mantissa} = sum_mantissa;
                end
            endcase

            
            //checks if rounding caused increase in exponent
            if(round_carry) begin
                sum_mantissa = {round_carry, sum_mantissa};
                sum_exponent = sum_exponent + 1;
            end

            //checks for infinity and NaN values
            nan_in1 = (&fp32_add_if.in1.exponent) && (|fp32_add_if.in1.fraction);
            nan_in2 = (&fp32_add_if.in2.exponent) && (|fp32_add_if.in2.fraction);

            //set output to infinty/normal/nan depneding on inputs and final value
            case({sum_exponent > {{(ELI-1){1'b1}}, 1'b0}, (nan_in1 || nan_in2)}) 
            2'b10: begin
                    sum_out.exponent = {ELI{1'b1}};
                    sum_out.fraction = {FLI{1'b0}};
                end 
            2'b00: begin
                    sum_out.exponent = sum_exponent[ELI-1:0];
                    sum_out.fraction = sum_mantissa[FLE-2:FLE-FLI-1];
                end
            2'b11, 2'b01: begin
                    sum_out.exponent = {ELI{1'b1}};
                    sum_out.fraction = {{(FLI-1){1'b0}}, 1'b1};
                end
            endcase
        end

        assign fp32_add_if.sum = sum_out;
endmodule
                            