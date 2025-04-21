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
