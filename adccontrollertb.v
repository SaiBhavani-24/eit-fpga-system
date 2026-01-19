module adc7606c_advanced_tb;

    reg clk = 0;
    reg reset_n = 0;
    reg start_config = 0;
	reg step_done = 0;
    reg [7:0] channel_mask;
    wire convst;
    reg busy = 0;
    wire cs_n, sclk, mosi;
    reg miso = 0;
	reg [15:0] adc_data_in_0;
    reg [15:0] adc_data_in_1;
    reg [15:0] adc_data_in_2;
    reg [15:0] adc_data_in_3;
    reg [15:0] adc_data_in_4;
    reg [15:0] adc_data_in_5;
    reg [15:0] adc_data_in_6;
    reg [15:0] adc_data_in_7;
    wire [2:0] channel;
    wire [15:0] data_out;
    wire data_ready;
    wire crc_error;
    wire timeout_error;

    adc7606c_advanced_controller dut (
        .clk(clk),
        .reset_n(reset_n),
        .start_config(start_config),
		.step_done(step_done),
        .channel_mask(channel_mask),
        .convst(convst),
        .busy(busy),
        .cs_n(cs_n),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .adc_data_in_0(adc_data_in_0),
        .adc_data_in_1(adc_data_in_1),
        .adc_data_in_2(adc_data_in_2),
        .adc_data_in_3(adc_data_in_3),
        .adc_data_in_4(adc_data_in_4),
        .adc_data_in_5(adc_data_in_5),
        .adc_data_in_6(adc_data_in_6),
        .adc_data_in_7(adc_data_in_7),
        .channel(channel),
        .data_out(data_out),
        .data_ready(data_ready),
        .crc_error(crc_error),
        .timeout_error(timeout_error)
    );

    always #2.5 clk = ~clk;

    initial begin
        $display("Starting AD7606C Advanced Controller Testbench");
        channel_mask = 8'b11111111;
        adc_data_in_0 = 16'hAAAA;
        adc_data_in_1 = 16'hBBBB;
        adc_data_in_2 = 16'hCCCC;
        adc_data_in_3 = 16'hDDDD;
        adc_data_in_4 = 16'hEEEE;
        adc_data_in_5 = 16'hFFFF;
        adc_data_in_6 = 16'h1234;
        adc_data_in_7 = 16'h5678;

        #10 reset_n = 1;
        #20 start_config = 1;
        #50 start_config = 0;
		#50 step_done = 0;
        #100 busy = 1;
        #100 busy = 0;
        #1000 $finish;
    end

endmodule
