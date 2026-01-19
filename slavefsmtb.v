module tb_slave_fsm;

    reg clk = 0, rst = 0;
    reg step_done = 0, adc_ready = 0, dac_ready = 0;
    wire start_mux, start_dac, start_adc, fsm_done, fsm_busy;

    slave_fsm uut (
        .clk(clk), .rst(rst),
        .step_done(step_done), .adc_ready(adc_ready), .dac_ready(dac_ready),
        .start_mux(start_mux), .start_dac(start_dac),
        .start_adc(start_adc), .fsm_done(fsm_done),
        .fsm_busy(fsm_busy)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting FSM Test...");
        $monitor("T=%0t | State=%0d | MUX=%b | DAC=%b | ADC=%b | DONE=%b | BUSY=%b",
                 $time, uut.state, start_mux, start_dac, start_adc, fsm_done, fsm_busy);

        rst = 1; #20; rst = 0;

        // First cycle
        step_done = 1; #10; step_done = 0;
        #10 dac_ready = 1; #10 dac_ready = 0;
        #30 adc_ready = 1; #10 adc_ready = 0;

        // Second cycle
        #50;
        step_done = 1; #10; step_done = 0;
        #10 dac_ready = 1; #10 dac_ready = 0;
        #30 adc_ready = 1; #10 adc_ready = 0;

        #100 $finish;
    end

endmodule

