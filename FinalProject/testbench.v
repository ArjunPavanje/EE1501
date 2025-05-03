
module testbench;
    reg clk = 0;
    reg reset;
    reg [4:0] set_hour = 0;
    reg [5:0] set_min = 0;
    reg [5:0] set_sec = 0;
    reg [4:0] set_day = 1;
    reg [3:0] set_month = 1;
    reg [11:0] set_year = 2020;

    wire [4:0] hour;
    wire [5:0] min, sec;
    wire [4:0] day;
    wire [3:0] month;
    wire [11:0] year;

    integer file, mode, res;

    digital_clock uut (
        .clk(clk),
        .reset(reset),
        .set_hour(set_hour),
        .set_min(set_min),
        .set_sec(set_sec),
        .set_day(set_day),
        .set_month(set_month),
        .set_year(set_year),
        .hour(hour),
        .min(min),
        .sec(sec),
        .day(day),
        .month(month),
        .year(year)
    );

    always #0.5 clk = ~clk;  // 1Hz clock

    initial begin
        file = $fopen("input.txt", "r");
        if (!file) begin
            $display("Failed to open input.txt");
            $finish;
        end

        while (!$feof(file)) begin
            res = $fscanf(file, "%d", mode);
            if (mode == 3) begin
                res = $fscanf(file, "%d %d %d %d %d %d", set_hour, set_min, set_sec, set_day, set_month, set_year);
                $display("Setting Time: %02d:%02d:%02d  Date: %02d-%02d-%04d", set_hour, set_min, set_sec, set_day, set_month, set_year);
                reset = 1; #2; reset = 0;
            end else if (mode == 1 || mode == 2) begin
                $display("---- Mode %0d ----", mode);
                repeat (5) begin
                    #1;
                    if (mode == 1) begin
                        $display("Time: %02d:%02d:%02d %s | Date: %02d-%02d-%04d",
                            (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour),
                            min, sec,
                            (hour >= 12) ? "PM" : "AM",
                            day, month, year);
                    end else begin
                        $display("Time: %02d:%02d:%02d | Date: %02d-%02d-%04d",
                            hour, min, sec, day, month, year);
                    end
                end
            end else begin
                $display("Unknown mode: %d", mode);
            end
        end

        $fclose(file);
        $finish;
    end
endmodule
