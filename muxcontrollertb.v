module mux_controller_tb;
    reg clk = 0, rst = 0, start_mux = 0;
    reg [7:0] mux_val = 8'hA5;
    wire mux_done, spi_clk, spi_mosi, spi_cs;
    wire [7:0] gpio_mux;

    mux_controller uut (
        .clk(clk), .rst(rst), .start_mux(start_mux),
        .mux_val(mux_val), .mux_done(mux_done),
        .spi_clk(spi_clk), .spi_mosi(spi_mosi),
        .spi_cs(spi_cs), .gpio_mux(gpio_mux)
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1; #20; rst = 0;
        start_mux = 1; #100;
        start_mux = 0; #50;
        $finish;
    end
endmodule

