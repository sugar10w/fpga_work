// Created by wxk14, 2016.8
//   serial port for gyro, MPU6050

module gyro(
	clk0,
	probe,
	roll, 
	pitch,
	yaw,
);
    //roll-x; pitch-y; yaw-z
	
    // input & output
	input clk0;
	input probe;
	output reg[15:0] roll;
	output reg[15:0] pitch;
	output reg[15:0] yaw;

	
	
    //////////////////////////////////////// serial port and protocol 
    
    // clock 9600Hz
	wire clk;
	timedivider(clk0, 5104, clk); // todo 9600Hz. FPGA may not have the accurate frequency.
	
	// data received 
	reg receiving;   // receiving info 
	reg [3:0] cnt;   // count the bit (0~8)
	reg [7:0] head;  // 8bits being received
	reg [87:0] data; // cache
    
	//parameter [3:0] n = 3;  // 7Roll, 5Pitch, 3Yaw
	always @ (posedge clk)
	begin
		if (receiving)
		begin			
			if (cnt==8) // end of 8 bit
			begin  
				receiving<=0; cnt<=0; // stop receiving
				data<=data*256+head;  // add head to the cache
				if (data[87:72]==16'h5553) //refer to the protocol here
				begin
					roll[7:0]<=data[71:64];   roll[15:8]<=data[63:56];  
					pitch[7:0]<=data[55:48];  pitch[15:8]<=data[47:40]; 
					yaw[7:0]<=data[39:32];    yaw[15:8]<=data[31:24];
					data<=0;
				end
			end
			else
			begin  // keep receiving
				head[cnt]<=probe;
				cnt<=cnt+1;
			end
		end
		else
		begin // wait for the next 8bits
			if (probe==0) receiving<=1;
		end		
	end
	
endmodule
