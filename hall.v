// hall sensor

module hall(clk0, in, speed);

//input & output
input clk0,in;
output reg[15:0]speed;

reg [15:0] cnt_last, cnt_long, cnt, gap;
reg flag;

wire clk;
timedivider(clk0, 5000, clk); 

always @ (posedge clk)
begin                                     
    cnt_long = cnt_long + 1;
    
    if(in == 0) flag = 1;
    if(flag)
    begin
        if(cnt > 500)           
        begin
            cnt = 0; flag = 0;
            gap = cnt_long - cnt_last;
            cnt_last = cnt_long;
            if(gap != 502)  speed = 10000 / gap;
        end
        else
            cnt = cnt + 1;  
    end
end

endmodule