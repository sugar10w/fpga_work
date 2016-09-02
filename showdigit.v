// Created by wxk14, 2016.12
//   Display the number to the digit 

module showdigit(
	clk0
	,_num
	//,dot_position
    ,digit
	,DIG
	,dot
);

// input & output
input clk0;
input[15:0] _num;
//input[1:0] dot_position;
output reg[7:1] digit;
output reg[3:0] DIG;
output reg dot;

// number setting
wire[3:0] num[3:0];
assign num[3]=_num[ 3: 0];
assign num[2]=_num[ 7: 4];
assign num[1]=_num[11: 8];
assign num[0]=_num[15:12];
	
// counter
reg[1:0] cnt;

// clock
wire clk;
timedivider(clk0, 20000, clk);

always @ (posedge clk)
begin
	cnt = cnt+1;
	
	case (cnt)
		0: DIG <= 4'b1000;
		1: DIG <= 4'b0100;
		2: DIG <= 4'b0010;
		3: DIG <= 4'b0001;
	endcase
	
	//dot<=  cnt==dot_position;
	
	case (num[cnt])
		0:  digit <= 7'b1111110;
		1:  digit <= 7'b0110000;
		2:  digit <= 7'b1101101;
		3:  digit <= 7'b1111001;
		4:  digit <= 7'b0110011;
		5:  digit <= 7'b1011011;
		6:  digit <= 7'b1011111;
		7:  digit <= 7'b1110000;
		8:  digit <= 7'b1111111;
		9:  digit <= 7'b1111011;
		10: digit <= 7'b1111101;
		11: digit <= 7'b0011111;
		12: digit <= 7'b0001101;
		13: digit <= 7'b0111101;
		14: digit <= 7'b1101111;
		15: digit <= 7'b1000111;
	endcase
end

endmodule
