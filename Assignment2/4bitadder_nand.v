`timescale 1ns/1ns

module and_nand(
  input a,
  input b,
  output out
);
wire temp;
nand #1(temp, a, b);
nand #1(out, temp, temp);
endmodule

module or_nand(
  input a,
  input b,
  output out
);
wire temp1, temp2;
nand #1(temp1, a, a);
nand #1(temp2, b, b);
nand #1(out, temp1, temp2);
endmodule

module xor_nand(
  input a,
  input b,
  output out
);
wire temp1, temp2, temp3;
nand #1(temp1, a, b);
nand #1(temp2, a, temp1);
nand #1(temp3, b, temp1);
nand #1(out, temp2, temp3);
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
  $dumpfile("4bitadder.vcd");
  $dumpvars(0, tb_adder);
  
  // Test Case 1
  a = 4'b0000; b = 4'b0000; carry_in = 0;
  #50

  // Test Case 2 
  $display("%0t %b  %b (%b)  %b (%b)", $time, a, b, carry_in, sum, carry_out);
  $display("done");

  a = 4'b1111; b = 4'b0000; carry_in = 1;
  #50

  // Test Case 3
  $display("%0t %b  %b (%b)  %b (%b)", $time, a, b, carry_in, sum, carry_out);
  $display("done");

  a = 4'b1111; b = 4'b1111; carry_in = 0;
  #50

  // Test Case 4
  $display("%0t %b  %b (%b)  %b (%b)", $time, a, b, carry_in, sum, carry_out);
  $display("done");

  a = 4'b0000; b = 4'b0000; carry_in = 1;
  #50

  // Test Case 5 
  $display("%0t %b  %b (%b)  %b (%b)", $time, a, b, carry_in, sum, carry_out);
  $display("done");

  a = 4'b1010; b = 4'b0101; carry_in = 0;
  #50 
  $display("%0t %b  %b (%b)  %b (%b)", $time, a, b, carry_in, sum, carry_out);

end
endmodule
