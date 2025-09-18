module spi_peripheral (
    input wire clk,
    input wire rst_n,
    input wire sclk,
    input wire copi,
    input wire ncs,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

reg [1:0] sh_sclk, sh_copi, sh_ncs;
wire sy_sclk, sy_copi, sy_ncs;
reg en;
reg [3:0] count = 15;
reg [15:0] data;

always @(posedge clk) begin
    sh_copi <= {sh_copi[0], copi};
    sh_ncs <= {sh_ncs[0], ncs};
    sh_sclk <= {sh_sclk[0], sclk};
end

assign sy_copi = sh_copi[1];
assign sy_ncs = sh_ncs[1];
assign sy_sclk = sh_sclk[1];

always @(negedge sy_ncs) begin
    en <= 1;
end

always @(posedge sy_ncs) begin
    en <= 0;
    count = 15;
end

always @(posedge sy_sclk) begin
    if (!rst_n) begin
        en_reg_out_7_0 <= 0;
        en_reg_out_15_8 <= 0;
        en_reg_pwm_7_0 <= 0;
        en_reg_pwm_15_8 <= 0;
        pwm_duty_cycle <= 0;
        en <= 0;
        count = 15;
    end
    if (en) begin
        data = {data[14:0], sy_copi};
        count = count - 1;
        if (count == 15) begin
            if (data[15] == 1 && data[14:8] <= 4) begin
                case (data[14:8])
                    0: en_reg_out_7_0 <= data[7:0];
                    1: en_reg_out_15_8 <= data[7:0];
                    2: en_reg_pwm_7_0 <= data[7:0];
                    3: en_reg_pwm_15_8 <= data[7:0];
                    4: pwm_duty_cycle <= data[7:0];
                endcase
            end
        end
    end
end

endmodule