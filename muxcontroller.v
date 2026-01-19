module mux_controller (
    input wire clk,
    input wire rst,
    input wire start_mux,
    input wire [7:0] mux_val,
    output reg mux_done,
    output reg spi_clk,
    output reg spi_mosi,
    output reg spi_cs,
    output reg [7:0] gpio_mux
);

reg [3:0] state;
reg [7:0] shift_reg;
reg [2:0] bit_cnt;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 0;
        spi_cs <= 1;
        spi_clk <= 0;
        spi_mosi <= 0;
        mux_done <= 0;
        gpio_mux <= 0;
    end else begin
        case (state)
            0: if (start_mux) begin
                shift_reg <= mux_val;
                bit_cnt <= 7;
                spi_cs <= 0;
                state <= 1;
            end
            1: begin
                spi_mosi <= shift_reg[bit_cnt];
                spi_clk <= ~spi_clk;
                if (spi_clk) begin
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 0) state <= 2;
                end
            end
            2: begin
                spi_cs <= 1;
                gpio_mux <= mux_val; // For TMUX7219
                mux_done <= 1;
                state <= 3;
            end
            3: if (!start_mux) begin
                mux_done <= 0;
                state <= 0;
            end
        endcase
    end
end

endmodule
