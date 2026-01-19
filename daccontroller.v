module dac_controller (
    input wire clk,
    input wire rst,
    input wire start_dac,
    input wire [15:0] dac_val,
    output reg dac_done,
    output reg spi_clk,
    output reg spi_mosi,
    output reg spi_cs
);

reg [3:0] state;
reg [15:0] shift_reg;
reg [4:0] bit_cnt;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 0;
        spi_cs <= 1;
        spi_clk <= 0;
        spi_mosi <= 0;
        dac_done <= 0;
    end else begin
        case (state)
            0: if (start_dac) begin
                shift_reg <= dac_val;
                bit_cnt <= 15;
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
                dac_done <= 1;
                state <= 3;
            end
            3: if (!start_dac) begin
                dac_done <= 0;
                state <= 0;
            end
        endcase
    end
end

endmodule
