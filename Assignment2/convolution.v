module convolvolution (
  input  [3:0] x [7:0],   
  input  [3:0] h [7:0],   
  output reg [3:0] y [14:0]   
);

integer n, k, j;
always @(*) begin
  for (n = 0; n < 15; n = n + 1) begin 
    y[n] = 4'd0;
  end
  for (j=0; j < 8; j = j + 1) begin
    for (k = 0; k < 8; k = k + 1) begin
      y[j+k] += x[j]*h[k];
      /*if ((n - k) >= 0 && (n - k) < 8) begin
      y[n] += (x[k] * h[n - k]);
    end*/
 end
  end
end
endmodule

`timescale 1ns / 1ns

module tb_convolvolution;
reg [3:0] x[7:0];
reg [3:0] h[7:0];
wire [3:0] y[14:0];

convolvolution dut(.x(x), .h(h), .y(y));

initial begin
  $dumpfile("convolvolution.vcd");
  $dumpvars(0, tb_convolvolution);

  for (integer i = 0; i < 8; i++) begin
    $dumpvars(0, tb_convolvolution.x[i]);
    $dumpvars(0, tb_convolvolution.h[i]);
  end

  for (integer i = 0; i < 15; i++) begin
    $dumpvars(0, tb_convolvolution.y[i]);
  end

  $monitor("x = [%d, %d, %d, %d, %d, %d, %d, %d]\nh = [%d, %d, %d, %d, %d, %d, %d, %d]\nx*h = [%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d]\n", x[0], x[1], x[2], x[3], x[4], x[5], x[6], x[7], h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7], y[0], y[1], y[2], y[3], y[4], y[5], y[6], y[7], y[8], y[9], y[10], y[11], y[12], y[13], y[14]);

  // Test Case 1 
  x[0] = 4'd1; x[1] = 4'd2; x[2] = 4'd3; x[3] = 4'd4;
  x[4] = 4'd0; x[5] = 4'd1; x[6] = 4'd0; x[7] = 4'd1;
  h[0] = 4'd1; h[1] = 4'd0; h[2] = 4'd1; h[3] = 4'd0;
  h[4] = 4'd1; h[5] = 4'd0; h[6] = 4'd1; h[7] = 4'd0;
  #10

  // Test Case 2
  x[0] = 4'd1; x[1] = 4'd1; x[2] = 4'd1; x[3] = 4'd1;
  x[4] = 4'd1; x[5] = 4'd1; x[6] = 4'd1; x[7] = 4'd1;
  h[0] = 4'd1; h[1] = 4'd1; h[2] = 4'd1; h[3] = 4'd1;
  h[4] = 4'd1; h[5] = 4'd1; h[6] = 4'd1; h[7] = 4'd1;
  #10

  // Test Case 3
  x[0] = 4'd1; x[1] = 4'd2; x[2] = 4'd3; x[3] = 4'd4;
  x[4] = 4'd5; x[5] = 4'd6; x[6] = 4'd7; x[7] = 4'd8;
  h[0] = 4'd1; h[1] = 4'd1; h[2] = 4'd1; h[3] = 4'd1;
  h[4] = 4'd1; h[5] = 4'd1; h[6] = 4'd1; h[7] = 4'd1;
  #10

  // Test Case 4
  x[0] = 4'd5; x[1] = 4'd5; x[2] = 4'd5; x[3] = 4'd5;
  x[4] = 4'd5; x[5] = 4'd5; x[6] = 4'd5; x[7] = 4'd5;
  h[0] = 4'd1; h[1] = 4'd2; h[2] = 4'd3; h[3] = 4'd4;
  h[4] = 4'd5; h[5] = 4'd6; h[6] = 4'd7; h[7] = 4'd8;
  #10

  // Test Case 5
  x[0] = 4'd7; x[1] = 4'd3; x[2] = 4'd9; x[3] = 4'd2;
  x[4] = 4'd5; x[5] = 4'd1; x[6] = 4'd8; x[7] = 4'd4;
  h[0] = 4'd6; h[1] = 4'd2; h[2] = 4'd7; h[3] = 4'd1;
  h[4] = 4'd9; h[5] = 4'd3; h[6] = 4'd5; h[7] = 4'd8;
end
endmodule
