module slave_fsm (
    input wire clk,
    input wire rst,
    input wire step_done,
    input wire dac_ready,
    input wire adc_ready,
    output reg start_mux,
    output reg start_dac,
    output reg start_adc,
    output reg fsm_done,
    output reg fsm_busy
);

reg [2:0] state;
localparam IDLE = 3'd0,
           MUX = 3'd1,
           DAC = 3'd2,
           WAIT_STIM = 3'd3,
           ADC = 3'd4,
           DONE = 3'd5;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        start_mux <= 0;
        start_dac <= 0;
        start_adc <= 0;
        fsm_done <= 0;
        fsm_busy <= 0;
    end else begin
        // Default outputs
        start_mux <= 0;
        start_dac <= 0;
        start_adc <= 0;
        fsm_done <= 0;
        fsm_busy <= (state != IDLE);

        case (state)
            IDLE: if (step_done) state <= DAC;

            DAC: begin
                start_dac <= 1;
                state <= WAIT_STIM;
            end

            WAIT_STIM: if (dac_ready) state <= MUX;

            MUX: begin
                start_mux <= 1;
                state <= ADC;
            end

            ADC: begin
                start_adc <= 1;
                if (adc_ready) state <= DONE;
            end

            DONE: begin
                fsm_done <= 1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule
