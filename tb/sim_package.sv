/* sim_package included all components for fp32 adder
*  testing.
*/
package sim_package;
    `include "../fp32_add_tb_classes/fp32_packet.sv"
    `include "../fp32_add_tb_classes/fp32_driver.sv"
    `include "../fp32_add_tb_classes/fp32_monitor.sv"
    `include "../fp32_add_tb_classes/fp32_scoreboard.sv"
    `include "../fp32_add_tb_classes/fp32_generator.sv"
    `include "../fp32_add_tb_classes/fp32_environment.sv"
    `include "../fp32_add_tb_classes/fp32_test.sv"
endpackage