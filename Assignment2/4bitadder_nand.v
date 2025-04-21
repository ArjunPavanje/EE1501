`timescale 1ns/1ns
module nand_gate(
  input a,
  input b,
  output out
);
  assign out = ~(a&b);
endmodule

module and_nand(
  input a,
  input b,
  output out
);
  wire temp;
  nand_gate and1 #1(.a(a), .b(b), .out(temp)); 
  nand_gate and2 #1(.a(temp), .b(temp), .out(out)); 
endmodule

module or_nand(
  input a,
  input b,
  output out
);
  wire temp1, temp2;
  nand_gate or1 #1(.a(a), .b(a), .out(temp1));
  nand_gate or2 #1(.a(b), .b(b), .out(temp2));
  nand_gate or3 #1(.a(temp1), .b(temp2), .out(out));
endmodule

module xor_nand(
  input a,
  input b,
  output out
);
  wire temp1, temp2, temp3;
  nand_gate xor1 #1(.a(a), .b(b), .out(temp1));
  nand_gate xor2 #1(.a(a), .b(temp1), .out(temp2));
  nand_gate xor3 #1(.a(temp1), .b(b), .out(temp3));
  nand_gate xor4 #1(.a(temp2), .b(temp3), .out(out));
endmodule

module bitadder(
  input [3:0] a,
  input [3:0] b,
  input carry_in,
  output [3:0] sum,
  output carry_out
);
  wire [4:0] carry;    
  assign carry[0] = carry_in;


  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      wire temp1, temp2, temp3, temp4, temp5;

      xor_nand xor1 (.a(a[i]), .b(b[i]), .out(temp1));
      xor_nand xor2 (.a(temp1), .b(carry[i]), .out(sum[i]));

      and_nand and1 (.a(a[i]), .b(b[i]), .out(temp2));
      and_nand and2 (.a(a[i]), .b(carry[i]), .out(temp3));
      and_nand and3 (.a(b[i]), .b(carry[i]), .out(temp4));

      or_nand or1 (.a(temp2), .b(temp3), .out(temp5));
      or_nand or2 (.a(temp5), .b(temp4), .out(carry[i+1]));
    end
  endgenerate

  assign carry_out = carry[4];

endmodule

module tb_adder;
  reg [3:0] a, b;
  reg carry_in;
  wire [3:0] sum;
  wire carry_out;

  bitadder uut (
    .a(a),
    .b(b),
    .carry_in(carry_in),
    .sum(sum),
    .carry_out(carry_out)
  );
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_adder);

  // Test Case 1
  a = 4'b1101; b = 4'b1011; carry_in = 1;
  #1
  $display("1. %b  %b (%b)  %b (%b)",  a, b, carry_in, sum, carry_out);

  // Test Case 2
  a = 4'b0110; b = 4'b1001; carry_in = 0;
  #1
  $display("w. %b  %b (%b)  %b (%b)",  a, b, carry_in, sum, carry_out);

  // Test Case 3
  a = 4'b1111; b = 4'b1111; carry_in = 0;
  #1
  $display("3. %b  %b (%b)  %b (%b)",  a, b, carry_in, sum, carry_out);

  // Test Case 4
  a = 4'b0000; b = 4'b0000; carry_in = 1;
  #1
  $display("4. %b  %b (%b)  %b (%b)",  a, b, carry_in, sum, carry_out);

  // TEst Case 5 
  a = 4'b1010; b = 4'b0101; carry_in = 0;
  #1
  $display("5. %b  %b (%b)  %b (%b)",  a, b, carry_in, sum, carry_out);

  end


endmodule
