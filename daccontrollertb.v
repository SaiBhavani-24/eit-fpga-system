module dac_controller_tb;
    reg clk = 0, rst = 0, start_dac = 0;
    reg [15:0] dac_val = 16'h3F3F;
    wire dac_done, spi_clk, spi_mosi, spi_cs;

    dac_controller uut (
        .clk(clk), .rst(rst), .start_dac(start_dac),
        .dac_val(dac_val), .dac_done(dac_done),
        .spi_clk(spi_clk), .spi_mosi(spi_mosi),
        .spi_cs(spi_cs)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1; #20; rst = 0;
        start_dac = 1; #160;
        start_dac = 0; #50;
        $finish;
    end
endmodule

