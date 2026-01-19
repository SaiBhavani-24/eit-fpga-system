module tb_step_controller;

    reg clk = 0;
    reg rst = 1;
    reg start_of_frame = 0;
    wire [7:0] mux_cmd;
    wire [15:0] dac_val;
    wire [3:0] tmux_ctrl;
    wire step_done;

    step_controller uut (
        .clk(clk),
        .rst(rst),
        .start_of_frame(start_of_frame),
        .mux_cmd(mux_cmd),
        .dac_val(dac_val),
        .tmux_ctrl(tmux_ctrl),
        .step_done(step_done)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Starting Step Controller Test...");
        $dumpfile("step_controller.vcd");
        $dumpvars(0, tb_step_controller);

        #10 rst = 0;

        repeat (16) begin
            #10 start_of_frame = 1;
            #10 start_of_frame = 0;
            #10;
            $display("Step: %0d | MUX CMD: %h | DAC VAL: %h | TMUX: %h | DONE: %b",
                     uut.step, mux_cmd, dac_val, tmux_ctrl, step_done);
        end

        #50 $finish;
    end

endmodule
