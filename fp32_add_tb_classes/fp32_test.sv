/* fp32_test is the top level test class.
*  Seperation of all the classes allows for modularity of the test system.
*  Runs the full test when called
*/
class fp32_test;
    //instantiates test environment
    fp32_environment e0;
    mailbox driver_mailbox;

    function new();
        driver_mailbox = new();
        e0 = new();
    endfunction

    //calls test to run
    //calls final tetst results
    virtual task run();
        e0.d0.driver_mailbox = driver_mailbox;
        e0.run();
        e0.wrap_up();
    endtask
endclass