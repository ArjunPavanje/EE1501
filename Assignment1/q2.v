module top_module(
  input clk, 
  input reset,
  input enable,
  output reg[3:0] count
);
initial begin
  count = 3'd0;
end
always @(posedge clk or posedge reset) begin
  if (reset) 
    count = 3'd0;

  else if (enable) begin
    count[0] <= ~count[0];
    count[1] <= count[1] ^ count[0];
    count[2] <= count[2] ^ (count[0] & count[1]);
    count[3] <= count[3] ^ (count[0] & count[1] & count[2]);
  end
end
endmodule


module synchronousUpCounter_tb;

reg clk = 0;
reg reset = 0;
reg enable = 0;
wire [3:0] count;

// Instantiate the DUT
top_module uut (
  .clk(clk),
  .reset(reset),
  .enable(enable),
  .count(count)
);

// Clock generation: 10 time units period
always #5 clk = ~clk;

initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0, synchronousUpCounter_tb);

  // Initial state
  reset = 1;
  enable = 0;
  #10;

  // Deassert reset
  reset = 0;
  enable = 1;

  // Count for a while
  #153;

  // Apply reset again
  reset = 1; #10;
  reset = 0; #10;

  // Continue counting
  #100;

  $finish;
end

initial begin
  $display("Time\tclk\treset\tenable\tcount");
  $monitor("%0t\t%b\t%b\t%b\t%04b", $time, clk, reset, enable, count);
end

endmodule

