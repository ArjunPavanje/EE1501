module bitadder(
  input [7:0] a,
  input [7:0] b,
  input carry_in,
  output reg [7:0] sum,
  output reg carry_out
);
reg carry;
integer i;

always @(*) begin
  carry = carry_in;
  for (i = 0; i < 8; i = i + 1) begin
    sum[i] = a[i] ^ b[i] ^ carry;
    carry = (a[i] & b[i]) | (a[i] & carry) | (b[i] & carry);
  end
  carry_out = carry;
end
endmodule

module tb_adder;
reg[7:0] a, b;
reg carry_in;
wire [7:0] sum;
wire carry_out;

bitadder uut(
  .a(a),
  .b(b),
  .carry_in(carry_in),
  .sum(sum),
  .carry_out(carry_out)
);
initial begin
  $dumpfile("8bitadder.vcd");
  $dumpvars(0, tb_adder);

  $display("Test Cases");
  // Test Case 1
  a = 8'b01101101; b = 8'b10110010; carry_in = 0;
  $monitor("%0t. %b  %b (%b)  %b (%b)",  $time, a, b, carry_in, sum, carry_out);
  #10
  // Test Case 2
  a = 8'b11010110; b = 8'b01010101; carry_in = 0;
  #10

  // Test Case 3
  a = 8'b11111111; b = 8'b00000001; carry_in = 0;
  #10

  // Test Case 4
  a = 8'b10011001; b = 8'b01101100; carry_in = 1;
  #10

  // Test Case 5
  a = 8'b01010101; b = 8'b11101010; carry_in = 1;

end
endmodule

