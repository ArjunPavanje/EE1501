/*
*
  * Mode 1: See time (12 Hr) and Date
  * Mode 2: See time (24hr) and Date
  * Mode 3: Set Time, Date Manually
  * Mode 4: Alarm
  * Input Formats
    * Mode 3: 3 <HH> <MM> <SS> <DD>  <MM> <YY>
    * Mode 1: 1 
    * Mode 2: 2 
    * Mode 4: 4 <time in minutes (int)> 
*/


`timescale 1s/1ms

module digital_clock(
    input clk,
    input reset,
    input [4:0] set_hour,
    input [5:0] set_min,
    input [5:0] set_sec,
    input [4:0] set_day,
    input [3:0] set_month,
    input [11:0] set_year,

    output reg [4:0] hour,
    output reg [5:0] min,
    output reg [5:0] sec,
    output reg [4:0] day,
    output reg [3:0] month,
    output reg [11:0] year
);

initial begin
    hour = 0; min = 0; sec = 0;
    day = 1; month = 1; year = 2020;
end

// Days in month with leap year support
function [5:0] days_in_month;
    input [3:0] m;
    input [11:0] y;
    begin
        case (m)
            1,3,5,7,8,10,12: days_in_month = 31;
            4,6,9,11: days_in_month = 30;
            2: days_in_month = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)) ? 29 : 28;
            default: days_in_month = 30;
        endcase
    end
endfunction

always @(posedge clk or posedge reset) begin
    if (reset) begin
        hour <= set_hour;
        min <= set_min;
        sec <= set_sec;
        day <= set_day;
        month <= set_month;
        year <= set_year;
    end else begin
        sec <= sec + 1;

        if (sec == 60) begin
            sec <= 0;
            min <= min + 1;

            if (min == 60) begin
                min <= 0;
                hour <= hour + 1;

                if (hour == 24) begin
                    hour <= 0;
                    day <= day + 1;

                    if (day > days_in_month(month, year)) begin
                        day <= 1;
                        month <= month + 1;

                        if (month > 12) begin
                            month <= 1;
                            year <= year + 1;

                            if (year > 2025)
                                year <= 2020;
                        end
                    end
                end
            end
        end
    end
end
endmodule



