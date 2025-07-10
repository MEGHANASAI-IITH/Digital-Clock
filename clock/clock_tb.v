module clock_tb;

// Parameters
parameter CLK_PERIOD = 2; // Clock period in time units

// Signals
reg clk;
wire buzzer_tb;
reg switch_1;
reg switch_2;
reg switch_3;

// Instantiate the timer module
clock dut (
    .clk(clk),
    .buzzer(buzzer_tb),
    .switch_1(switch_1),
    .switch_2(switch_2),
    .switch_3(switch_3)
);

// Clock generation
always #((CLK_PERIOD / 2)) clk = ~clk;

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, clock_tb);
    // Initialize inputs
	clk = 1;
	switch_1 = 0;
	switch_2 = 0;
	switch_3 = 0;
	#20
	switch_1 = 0;
	#10
	switch_1 = 1;
	#10
	switch_1 = 0;
	#20
	switch_1 = 0;
	#10
	switch_1 = 1;
	#10
	switch_1 = 0;
	#20
	switch_1 = 0;
	#10
	switch_1 = 1;
	#10
	switch_1 = 0;
	#20
	switch_2 = 0;
	#10
	switch_2 = 1;
	#10
	switch_2 = 0;
	#20
	switch_2 = 0;
	#10
	switch_2 = 1;
	#10
	switch_2 = 0; 
	#20
	switch_2 = 0;
	#10
	switch_2 = 1;
	#10
	switch_2 = 0;   
	#20
	switch_3 = 0;
	#10
	switch_3 = 1;
	#10
	switch_3 = 0;
	#20
	switch_3 = 0;
	#10
	switch_3 = 1;
	#10
	switch_3 = 0;
	#10000
	switch_3 = 0;
	#10
	switch_3 = 1;
	#10
	switch_3 = 0;
	#10
	switch_3 = 1;
	#10
	switch_3 = 0;
	#1000
	switch_3 = 0;
	#10
	switch_3 = 1;
	#10
	switch_3 = 0;
	#1000
    // Stop the clock
    $finish;
end

endmodule

