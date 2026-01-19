module adc7606c_advanced_controller (
    input wire clk,
    input wire reset_n,
    input wire start_config,
	input wire step_done,
    input wire [7:0] channel_mask,
    output reg convst,
    input wire busy,
    output reg cs_n,
    output reg sclk,
    output reg mosi,
    input wire miso,
    input wire [15:0] adc_data_in_0,
    input wire [15:0] adc_data_in_1,
    input wire [15:0] adc_data_in_2,
    input wire [15:0] adc_data_in_3,
    input wire [15:0] adc_data_in_4,
    input wire [15:0] adc_data_in_5,
    input wire [15:0] adc_data_in_6,
    input wire [15:0] adc_data_in_7,

    output reg [2:0] channel,
    output reg [15:0] data_out,
    output reg data_ready,
    output reg crc_error,
    output reg timeout_error
);

     parameter IDLE = 3'd0,
          CONFIGURE = 3'd1,
          WAIT_BUSY = 3'd2,
          READ_DATA = 3'd3,
          DONE = 3'd4;

    reg [2:0] state, next_state;

    reg [31:0] spi_frame;
    reg [5:0] spi_bit_cnt;
    reg [7:0] crc;
    reg [2:0] config_channel;
    reg [7:0] mask_latched;
    reg [2:0] read_index;
    reg [15:0] sample_accum[7:0];
    reg [2:0] sample_count;
    reg [15:0] decimated_data;
    reg [15:0] timeout_counter;

    function [7:0] crc8;
        input [23:0] data;
        integer i;
        reg [7:0] crc;
        begin
            crc = 8'h00;
            for (i = 23; i >= 0; i = i - 1) begin
                crc = crc ^ {data[i], 7'b0};
                if (crc[7]) crc = (crc << 1) ^ 8'h07;
                else        crc = (crc << 1);
            end
            crc8 = crc;
        end
    endfunction

    reg [4:0] clk_div;
    wire spi_clk_en = (clk_div == 0);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            cs_n <= 1;
            sclk <= 0;
            mosi <= 0;
            convst <= 0;
            data_out <= 16'h0000;
            channel  <= 3'b000;
            data_ready <= 0;
            config_channel <= 0;
            crc_error <= 0;
            timeout_error <= 0;
            timeout_counter <= 0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    data_ready <= 0;
                    timeout_error <= 0;
                    crc_error <= 0;
                    if (start_config) begin
                        mask_latched <= channel_mask;
                        config_channel <= 0;
                        spi_frame[31:24] <= {1'b0, 1'b0, 6'h01}; // CONFIG1
                        spi_frame[23:8]  <= 16'h00A0; // Example: internal ref, oversampling
                        spi_frame[7:0]   <= crc8(spi_frame[31:8]);
                        spi_bit_cnt <= 0;
                        cs_n <= 0;
                        next_state <= CONFIGURE;
                    end else begin
                        next_state <= WAIT_BUSY;
                    end
                end

                CONFIGURE: begin
                    if (spi_clk_en) begin
                        sclk <= ~sclk;
                        if (sclk == 0) begin
                            mosi <= spi_frame[31];
                            spi_frame <= {spi_frame[30:0], 1'b0};
                            spi_bit_cnt <= spi_bit_cnt + 1;
                            if (spi_bit_cnt == 31) begin
                                cs_n <= 1;
                                next_state <= WAIT_BUSY;
                            end
                        end
                    end
                end

                WAIT_BUSY: begin
                    convst <= 1;
                    if (busy) begin
                        timeout_counter <= 0;
                        next_state <= WAIT_BUSY;
                    end else begin
                        convst <= 0;
                        read_index <= 0;
                        sample_count <= 0;
                        next_state <= READ_DATA;
                    end
                    if (timeout_counter > 16'hFFFF) begin
                        timeout_error <= 1;
                        next_state <= DONE;
                    end else begin
                        timeout_counter <= timeout_counter + 1;
                    end
                end

                READ_DATA: begin
                    if (mask_latched[read_index]) begin
                        sample_accum[read_index] <= adc_data_in_0[read_index];
                        sample_accum[read_index] <= adc_data_in_1[read_index];
                        sample_accum[read_index] <= adc_data_in_2[read_index];
                        sample_accum[read_index] <= adc_data_in_3[read_index];
                        sample_accum[read_index] <= adc_data_in_4[read_index];
                        sample_accum[read_index] <= adc_data_in_5[read_index];
                        sample_accum[read_index] <= adc_data_in_6[read_index];
                        sample_accum[read_index] <= adc_data_in_7[read_index];
                        decimated_data <= sample_accum[read_index]; // Placeholder for averaging
                        data_out <= decimated_data;
                        channel <= read_index;
                        data_ready <= 1;
                    end else begin
                        data_ready <= 0;
                    end
                    if (read_index == 7)
                        next_state <= DONE;
                    else
                        read_index <= read_index + 1;
                end

                DONE: begin
                    data_ready <= 0;
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule
