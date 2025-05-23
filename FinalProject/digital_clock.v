/*
*
  * Mode 1: See time (12 Hr) and Date
  * Mode 2: See time (24hr) and Date
  * Mode 3: Set Time, Date Manually
  * Mode 4: Set Alarm
  * Mode 5: Set Timer 
  * Mode 6: Resetting Date and Time to 1 Jan 2024 12 AM
  * Input Formats:
    * Mode 3: 3 <HH> <MM> <SS> <DD>  <MM> <YY>
    * Mode 1: 1 
    * Mode 2: 2 
    * Mode 4: 4 <HH> <MM> <SS> (in 24 hr format)
    * Mode 5: 5 <MM> <SS> 
    * Mode 6: 6
      */

     `timescale 1s/1ms

     module digital_clock(
       input clk,
       // For Mode 3 (Setting Time, Date manually)
       input reset,
       input [4:0] set_hour,
       input [5:0] set_min,
       input [5:0] set_sec,
       input [4:0] set_day,
       input [3:0] set_month,
       input [11:0] set_year,

       // For Mode 4 (Alarm)
       input [4:0] alarm_hour,
       input [5:0] alarm_min,
       input [5:0] alarm_sec,
       input alarm_enable,

       // For Mode 5 (Timer)
       input [5:0] timer_min,
       input [5:0] timer_sec,
       input timer_enable,

       // Time Related
       output reg [4:0] hour,
       output reg AM_enabled,
       output reg [5:0] min,
       output reg [5:0] sec,
       output reg [4:0] day,
       output reg [3:0] month,
       output reg [11:0] year,
       output reg [2:0] day_of_week,

       output reg [5:0] timer_count_min,
       output reg [5:0] timer_count_sec,
       output reg alarm_buzzer,
       output reg timer_buzzer
       );

       //reg timer_running = 0;
       //reg alarm_triggered = 0;

       // Setting inital values for some parameters
       initial begin
         hour = 0; min = 0; sec = 0;
         day = 1; month = 1; year = 2020;
         alarm_buzzer = 0;
         AM_enabled = 0;
         timer_buzzer = 0;
         timer_count_sec = 0;
         timer_count_min = 0;
       end

       // To calculate day (given date, month, year)
       function [2:0] calc_day_of_week;
         input [4:0] d;
         input [3:0] m;
         input [11:0] y;
         reg [11:0] yy;
         reg [3:0] mm;
         begin
           yy = y;
           mm = m;
           if (mm < 3) begin 
             mm = mm + 12;
             yy = yy - 1;
           end // Calculating using Zeller's Congruence  
           calc_day_of_week = ((d + (13*(mm+1))/5 + yy + (yy/4) - (yy/100) + (yy/400))-1) % 7;
         end
       endfunction

       // Calculating number of days in a month
       function [5:0] days_in_month;
         input [3:0] m;
         input [11:0] y;
         begin
           case (m) // case statement for number of days in each month
             1,3,5,7,8,10,12: days_in_month = 31; 
             4,6,9,11: days_in_month = 30;
             2: days_in_month = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)) ? 29 : 28; // Leap Years
             default: days_in_month = 30;
           endcase
         end
       endfunction

       always @(posedge clk or posedge reset) begin 
         
         if (reset) begin // Manual Reset (Mode 3)
           hour <= set_hour;
           min <= set_min;
           sec <= set_sec;
           day <= set_day;
           month <= set_month;
           year <= set_year;
         end else begin
           // Updating clock
           // We change the value one cycle before it actually has to reflect
           // due to non blocking statements used which are read at the next
           // positive edge of the clock
           sec <= sec + 1;
           // AM_enabled <= (hour < 12); 
           // Setting signal which indicates 'AM' or 'PM'
           if(hour == 23 && min == 59 && sec == 59) AM_enabled = 1; 
           else AM_enabled = (hour < 12);

           // Manual reset after april 2025 to january 2020
           if (day == 30 && month == 4 && year == 2025 && hour == 23 && min == 59 && sec == 59) begin 
             day <= 1;
             month <= 1; 
             year <= 2020;
             hour <= 0; 
             min <= 0;
             sec <= 0;
           end else if (sec == 59) begin // Normal incrementing Date and Time otherwise
             sec <= 0;
             min <= min + 1;
             if (min == 59) begin
               min <= 0;
               hour <= hour + 1;
               if (hour == 23) begin
                 hour <= 0;
                 day <= day + 1;
                 if (day > days_in_month(month, year)-1) begin
                   day <= 1;
                   month <= month + 1;
                   if (month > 11) begin
                     month <= 1;
                     year <= year + 1;
                     if (year > 2025) year <= 2020;
                   end
               end
             end
           end
         end
         // Updating Day 
         // Setting day seperately for last second of day (non blocking
         // assignment)
         if (hour == 23 && min == 59 && sec == 59 && day != 30 && month != 4 && year != 2025) begin 
           day_of_week <= calc_day_of_week(day+1, month, year);
         end 
         // Setting day for wrap-around from April 2025 to January 2020
         else if ( hour == 23 && min == 59 && sec == 59 && day == 30 && month == 4 && year == 2025) begin 
           day_of_week <= calc_day_of_week(1, 1, 2020);
           end 
         // Setting day for leap year
         else if ( hour == 23 && min == 59 && sec == 59 && day == 28 && month == 2 && days_in_month(month, year) == 29) begin 
           day_of_week <= calc_day_of_week(29, 2, year);
           end 
          // Setting day for non leap year
          else if ( hour == 23 && min == 59 && sec == 59 && day == 28 && month == 2 && days_in_month(month, year) == 28) begin 
           day_of_week <= calc_day_of_week(1, 3, year);
           end
           // Normal case
           else begin  
           day_of_week <= calc_day_of_week(day, month, year);
         end
         // Ensuring that alarm and timer only ring ONCE
         if (timer_buzzer) begin
           timer_buzzer <= 0; // Turning the buzzer OFF
         end
         if (alarm_buzzer) begin 
           alarm_buzzer <= 0; // Turning the buzzer OFF
         end

         //$display("Sanity Check: Time: %02d %02d %02d, Alarm TIme: %02d %02d %02d", hour, min, sec, alarm_hour, alarm_min, alarm_sec);
         // Triggering Alarm
         if (alarm_enable && alarm_hour == 0 && alarm_min == 0 && alarm_sec == 0 && 
           hour == 23 && min == 59 && sec == 59) begin
           alarm_buzzer <= 1;
           //alarm_triggered <= 1;
         end else if (alarm_enable &&
           hour == alarm_hour && min == alarm_min && sec + 1 == alarm_sec) begin
           alarm_buzzer <= 1;
           //alarm_triggered <= 1;
         end

         // Timer Check
         if (timer_enable) begin
           timer_count_min <= timer_min;
           timer_count_sec <= timer_sec;
           //timer_running <= 1;
           timer_buzzer <= 0;
         end
         // Triggering Timer 
         if (timer_enable) begin
           //$display("LEFT TIME: %02d %02d", timer_count_min, timer_count_sec);
           if (timer_count_min == 0 && timer_count_sec == 2) begin
             timer_buzzer <= 1;
             //timer_running <= 0; // Turning it OFF 
             timer_count_sec <= 0; // Manually resetting timer to 00 00 again
           end else begin // Decrementing (minutes/seconds) otherwise
             if (timer_count_sec == 0) begin
               if (timer_count_min > 0) begin
                 timer_count_min <= timer_count_min - 1;
                 timer_count_sec <= 59;
               end
             end else begin
               timer_count_sec <= timer_count_sec - 1;
             end
           end
         end
       end
     end
     endmodule


