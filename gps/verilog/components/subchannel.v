`include "global.vh"
`include "ca_upsampler.vh"

module subchannel(
    input                    clk,
    input                    clk_sample,
    input                    global_reset,
    input                    reset,
    input [4:0]              prn,
    input [`INPUT_RANGE]     data,
    input                    seek_en,
    input [`CS_RANGE]        seek_target,
    output wire [`CS_RANGE]  code_shift,
    output wire              ca_bit,
    output wire              ca_clk,
    output wire [9:0]        ca_code_shift,
    output wire [`ACC_RANGE] accumulator);

   //Clock domain crossing.
   wire clk_sample_sync;
   synchronizer input_clk_sync(.clk(clk),
                               .in(clk_sample),
                               .out(clk_sample_sync));
   wire [`INPUT_RANGE] data_sync;
   synchronizer #(.WIDTH(`INPUT_WIDTH))
     input_data_sync(.clk(clk),
                     .in(data),
                     .out(data_sync));

   wire data_available;
   strobe data_available_strobe(.clk(clk),
                                .reset(reset),
                                .in(clk_sample_sync),
                                .out(data_available));
   
   ca_upsampler upsampler(.clk(clk),
                          .reset(global_reset),
                          .enable(data_available),
                          .prn(prn),
                          .code_shift(code_shift),
                          .out(ca_bit),
                          .seek_en(seek_en),
                          .seek_target(seek_target),
                          .ca_clk(ca_clk),
                          .ca_code_shift(ca_code_shift));

   //Delay accumulation 4 cycles to allow
   //for C/A upsampler to update. Delay 1
   //cycle to meet timing from the C/A bit
   //to the track accumulator.
   localparam DATA_DELAY = 5;
   wire data_available_kmn;
   delay #(.DELAY(DATA_DELAY))
     data_available_delay(.clk(clk),
                          .in(data_available),
                          .out(data_available_kmn));
     
   wire [`INPUT_RANGE] data_kmn;
   delay #(.WIDTH(`INPUT_WIDTH),
           .DELAY(DATA_DELAY))
     data_delay(.clk(clk),
                .in(data_sync),
                .out(data_kmn));
   
   wire ca_bit_kmn;
   delay ca_bit_delay(.clk(clk),
                      .in(ca_bit),
                      .out(ca_bit_kmn));

   track track_i(.clk(clk),
                 .reset(reset),
                 .data_available(data_available_kmn),
                 .baseband_input(data_kmn),
                 .ca_bit(ca_bit_kmn),
                 .accumulator(accumulator));
endmodule