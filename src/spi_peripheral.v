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
reg [3:0] count;
reg [14:0] data;

always @(posedge clk) begin
    sh_copi <= {sh_copi[0], copi};
    sh_ncs <= {sh_ncs[0], ncs};
    sh_sclk <= {sh_sclk[0], sclk};
end

assign sy_copi = sh_copi[1];
assign sy_ncs = sh_ncs[1];
assign sy_sclk = sh_sclk[1];

always @(posedge sy_sclk or negedge rst_n) begin
    if (!rst_n) begin
        en_reg_out_7_0 <= 0;
        en_reg_out_15_8 <= 0;
        en_reg_pwm_7_0 <= 0;
        en_reg_pwm_15_8 <= 0;  	
        pwm_duty_cycle <= 0;
        count <= 15;
    end else begin
        if (!sy_ncs) begin
            data <= {data[13:0], sy_copi};
            count <= count - 1;
            if (count == 0) begin
                if (data[14] == 1 && data[13:7] <= 4) begin
                    case (data[13:7])
                        0: en_reg_out_7_0 <= {data[6:0], sy_copi};
                        1: en_reg_out_15_8 <= {data[6:0], sy_copi};
                        2: en_reg_pwm_7_0 <= {data[6:0], sy_copi};
                        3: en_reg_pwm_15_8 <= {data[6:0], sy_copi};
                        4: pwm_duty_cycle <= {data[6:0], sy_copi};
                    endcase
                end
            end
        end
    end
end

endmodule