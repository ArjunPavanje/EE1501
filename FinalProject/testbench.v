// Setting timescale
`timescale 1s/1ms

module tb_clock;

// Initializing input and output variables

reg clk = 0;
reg reset = 0;

reg [4:0] set_hour = 0;
reg [5:0] set_min = 0, set_sec = 0;
reg [4:0] set_day = 1;
reg [3:0] set_month = 1;
reg [11:0] set_year = 2020;

reg [4:0] alarm_hour = 0;
reg [5:0] alarm_min = 0, alarm_sec = 0;
reg alarm_enable = 0;

reg [5:0] timer_min = 0, timer_sec = 0;
reg timer_enable = 0;

wire AM_enabled;
wire [4:0] hour;
wire [5:0] min, sec;
wire [4:0] day;
wire [3:0] month;
wire [11:0] year;
wire [2:0] day_of_week;
wire [5:0] timer_count_min, timer_count_sec;
wire alarm_buzzer, timer_buzzer;

// Initializing some variables
integer file, mode, res;
integer display_mode = 2;
integer ticks_after_event = 0;
//assign timer_count_min = 6'd0;
//assign timer_count_sec = 6'd0;

// Instantiating Module of Clock
digital_clock uut (
  .clk(clk), .reset(reset), .AM_enabled(AM_enabled),
  .set_hour(set_hour), .set_min(set_min), .set_sec(set_sec),
  .set_day(set_day), .set_month(set_month), .set_year(set_year),
  .alarm_hour(alarm_hour), .alarm_min(alarm_min), .alarm_sec(alarm_sec),
  .alarm_enable(alarm_enable),
  .timer_min(timer_min), .timer_sec(timer_sec),
  .timer_enable(timer_enable),
  .hour(hour), .min(min), .sec(sec),
  .day(day), .month(month), .year(year), .day_of_week(day_of_week),
  .timer_count_min(timer_count_min), .timer_count_sec(timer_count_sec),
  .alarm_buzzer(alarm_buzzer), .timer_buzzer(timer_buzzer)
);


reg [8*10:1] day_names [0:6];
always #0.5 clk = ~clk;  
// Setting Clock cycle as 0.5 seconds as changes are only read at positive edge of clock 
// (if clock period was kept as 1 second, changes would be read every two seconds instead of 1)

// Reading data from text file for which Mode to follow
initial begin 
    file = $fopen("input.txt", "r");
  if (!file) begin
    $display("Cannot open input.txt");
    $finish;
  end

  while (!$feof(file)) begin
    res = $fscanf(file, "%d", mode); 
    day_names[0] = "Sunday";
    day_names[1] = "Monday";
    day_names[2] = "Tuesday";
    day_names[3] = "Wednesday";
    day_names[4] = "Thursday";
    day_names[5] = "Friday";
    day_names[6] = "Saturday";

    // If Mode is either 1 or 2, displaying time (5 times) in 12 hour or
    // 24 hour format respectively
    if (mode == 1 || mode == 2) begin
      repeat (5) begin
        #1;
        // Checking if timer or alarm rings while the repeat block is
        // active
        if (alarm_buzzer) begin
          $display("ALARM RINGING! Time: %02d:%02d:%02d", hour, min, sec);
          alarm_enable = 0; // Turning the alarm OFF
          ticks_after_event = 0;
        end 
        if (timer_buzzer) begin // It is an 'if' statement, not an 'else if' as both a timer and an alarm may be active
          $display("TIMER DONE!");
          timer_enable = 0; // Turning the timer OFF
          ticks_after_event = 0;
        end if (mode == 1) begin // 12 hour time format
          $display("Time: %02d:%02d:%02d %s | Date: %02d-%02d-%04d (%s)",
            (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour),
            min, sec,
            (AM_enabled) ? "AM" : "PM", // AM or PM
            day, month, year, day_names[day_of_week]);
        end else begin // 24 hour time format
          $display("Time: %02d:%02d:%02d | Date: %02d-%02d-%04d (%s)",
            hour, min, sec, day, month, year, day_names[day_of_week]);
        end
      end
    end else if (mode == 3) begin // Setting time and Date Manually
      res = $fscanf(file, "%d %d %d %d %d %d",
        set_hour, set_min, set_sec,
        set_day, set_month, set_year); 
      $display("Setting time to %02d:%02d:%02d and date to %02d-%02d-%04d",
        set_hour, set_min, set_sec, set_day, set_month, set_year);
      reset = 1; #0.5; reset = 0;
    end else if (mode == 4) begin // Setting alarm
      res = $fscanf(file, "%d %d %d", alarm_hour, alarm_min, alarm_sec);
      alarm_enable = 1; // Turning the alarm ON
      $display("Alarm set for %02d:%02d:%02d", alarm_hour, alarm_min, alarm_sec);
    end else if (mode == 5 && !timer_enable) begin // Setting timer
      res = $fscanf(file, "%d %d", timer_min, timer_sec);
      timer_enable = 1; // Turning the timer ON
      $display("Current time: %02d : %02d : %02d, Timer set for %02d minutes %02d seconds", hour, min, sec, timer_min, timer_sec);
    end else if(mode == 5 && timer_enable) begin
    end else if (mode == 6) begin 
        set_hour = 0;
    set_min = 0;
    set_sec = 0;
    set_day = 1;
    set_month = 1;
    set_year = 2020;
    reset = 1; #0.5; reset = 0;
    $display("RESET! Time: %02d:%02d:%02d | Date: %02d-%02d-%04d (%s)",
            hour, min, sec, day, month, year, day_names[day_of_week]);

  end else begin
    $display("Unknown mode: %d", mode);
  end
  //#1;
end
$fclose(file);

repeat (300) begin
  #1; 
  if (alarm_buzzer) begin // Ringing alarm (when it occurs outside Mode 1 or 2)
    $display("ALARM RINGING! Time: %02d:%02d:%02d | Date: %02d-%02d-%04d", hour, min, sec, day, month, year);
    alarm_enable = 0; // Turning the alarm OFF
    ticks_after_event = 0;
  end if (timer_buzzer) begin  // Ringing timer (when it occurs outside Mode 1 or 2)
    $display("TIMER DONE! Time: %02d:%02d:%02d | Date: %02d-%02d-%04d", hour, min, sec, day, month, year);
    timer_enable = 0; // Turning the timer OFF
    ticks_after_event = 0;
  end /*else if (timer_count_min || timer_count_sec) begin
    $display("TIMER: %02d:%02d", timer_count_min, timer_count_sec);
    ticks_after_event = 0;
  end*/ 
  if(alarm_buzzer == 0 && timer_buzzer == 0) begin // Displaying time in either 24 hour or 12 hour format
    if (display_mode == 1)
      $display("Time: %02d:%02d:%02d %s | Date: %02d-%02d-%04d",
    (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour),
    min, sec,
    (AM_enabled) ? "AM" : "PM",
    day, month, year);
    else
      $display("Time: %02d:%02d:%02d | Date: %02d-%02d-%04d (%s)",
    hour, min, sec, day, month, year, day_names[day_of_week]);
    ticks_after_event = ticks_after_event + 1;
  end
//$display("Sanity Check: alarm buzzer: %d, timer buzzer: %d, timer: %d: %d, alarm enabled? %d, ticks after event: %d", alarm_buzzer, timer_buzzer, timer_count_min, timer_count_sec, alarm_enable, ticks_after_event);
// The below line is to ensure that as long as timer/alarm is active program
// continues to show time even though Mode 1 or Mode 2 is not specified
// suffeciently for timer/alarm to run down and ring.
if (!alarm_buzzer && !timer_buzzer && !timer_enable &&
  ticks_after_event > 5 && !alarm_enable) begin
  $display("Simulation complete.");
  $finish;
end
        end

        $display("Simulation timeout.");
        $finish;
      end
      endmodule



