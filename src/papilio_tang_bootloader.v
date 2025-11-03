// This project sets the timer to 60 seconds and connects the spi flash pins. This is for papilio arcade board.

module top(
    input       clk,
    output      reconfig,
    output      led,

    //SPI Flash programming
    input wire          esp_clk,
    input wire          esp_cs_n,
    output  wire          esp_miso,
    input wire          esp_mosi,

    output  wire          spiflash_clk,
    output  wire          spiflash_cs_n,
    input wire          spiflash_miso,
    output  wire          spiflash_mosi
);

reg count_1s_flag;
reg [23:0] count_1s = 'd0;

// 27 MHz clock → 27,000,000 cycles per second
// 5 seconds → 135,000,000 cycles
localparam DELAY_COUNT = 135_000_000;   // 5 seconds

reg [30:0] counter = 0;  // 28-bit counter (covers up to ~268 million)
reg reconfig_r = 1;

always @(posedge clk ) begin
            if (counter < DELAY_COUNT) begin
                   if (esp_cs_n == 0) begin
                        counter <= 0;
                end else begin
                        counter <= counter + 1;
                end
                
            end else begin
                        reconfig_r <= 0;
            end
end

assign reconfig = reconfig_r;

always @(posedge clk ) begin
    if( count_1s < 27000000/2 ) begin
        count_1s <= count_1s + 'd1;
        count_1s_flag <= 'd0;
    end
    else begin
        count_1s <= 'd0;
        count_1s_flag <= 'd1;
    end
end

reg led_value = 'd1;

always @(posedge clk ) begin
    if( count_1s_flag ) begin
    led_value <= ~led_value;
    end
end

assign led = led_value;

// SPI Flash
assign spiflash_clk = esp_clk;
assign spiflash_mosi = esp_mosi;
assign spiflash_cs_n = esp_cs_n;
assign esp_miso = spiflash_miso;

endmodule