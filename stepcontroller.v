module step_controller (
    input wire clk,
    input wire rst,
    input wire start_of_frame,       // Trigger from master
    output reg [7:0] mux_cmd,
    output reg [15:0] dac_val,
    output reg [3:0] tmux_ctrl,
    output reg step_done
);

reg [3:0] step;
reg [15:0] waveform_rom [0:15];
reg [3:0] tmux_rom [0:15];

initial begin
    $readmemh("waveform.hex", waveform_rom);
    $readmemh("tmux_config.hex", tmux_rom);
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        step <= 0;
        step_done <= 0;
        mux_cmd <= 0;
        dac_val <= 0;
        tmux_ctrl <= 0;
    end else if (start_of_frame) begin
        mux_cmd   <= step;
        dac_val   <= waveform_rom[step];
        tmux_ctrl <= tmux_rom[step];
        step_done <= 1;
        step      <= step + 1;
    end else begin
        step_done <= 0;
    end
end

endmodule
