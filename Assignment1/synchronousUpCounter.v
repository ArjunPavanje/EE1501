/* implemented using t flip flop kmaps */
module synchronousUpCounter(
  input clk,
  input reset,
  input enable,
  output reg [3:0] out
);
  always @ (posedge clk or posedge reset) begin
    if (reset == 1)
      out <= 4'd0;
    else if (enable == 1) begin
      out[0] <= ~out[0];
      out[1] <= out[1] ^ out[0];
      out[2] <= out[2] ^ (out[0] & out[1]);
      out[3] <= out[3] ^ (out[0] & out[1] & out[2]);
    end
  end
endmodule

/* implemented using adder logic
module synchronousUpCounter (
  input clk, 
  input reset, 
  input enable, 
  output reg [3:0] out
);
always @ (posedge clk or posedge reset) begin
  if (reset == 1) out <= 4'd0;
  else if (enable == 1) begin
    out <= out + 1'b1;
  end
end
endmodule
*/
