module synchronousUpCounter_tb;

  reg clk = 0;
  reg reset = 0;
  reg enable = 0;
  wire [3:0] out;

  // Instantiate the DUT
  synchronousUpCounter uut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .out(out)
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
    $display("Time\tclk\treset\tenable\tout");
    $monitor("%0t\t%b\t%b\t%b\t%04b", $time, clk, reset, enable, out);
  end

endmodule

