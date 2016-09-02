// Created by wxk14, 2016.8
//    Main file

module main(
        clk0  // 50MHz
        ,digit,DIG,dot // digit * 4
        ,led           // led * 8
        ,switch        // switch * 8
        ,IN1,IN2          // control the motor
        ,direction_out    // control the direction
        ,ult_trig_1,ult_probe_1 // sensor: ultrasonic (front upside)
        ,ult_trig_2,ult_probe_2 // sensor: ultrasonic (right)
        ,ult_trig_3,ult_probe_3 // sensor: ultrasonic (front downside)
        ,hw_l,hw_r              // sensor: infrared 
        ,hall_in                // sensor: hall 
        ,probe_gyro             // sensor: gyro 
);

    // input
    input clk0;
    input hall_in;
    input ult_probe_1;
    input ult_probe_2;
    input ult_probe_3;
    input hw_l;
    input hw_r;
    input probe_gyro;
    input[8:1] switch;
    
    // output 
    output[7:1] digit;  // main of the digit led
    output[3:0] DIG;    // which digit to be lighten
    output[7:0] led;    // LEDs
    output dot;         // dot of the digit
    output IN1,IN2;
    output ult_trig_1;
    output ult_trig_2;
    output ult_trig_3;
    output direction_out;
    
    //////////////////////////////////////////////// display
    // led assignment
    assign led[1:0]=state;
    // digit display
    showdigit(clk0, ult_result_3, digit, DIG, dot);
    
    //////////////////////////////////////////////// initail
    initial
    begin
       percent1 = 12;
       percent2 = 0;
       direction_length = 2000;
    end
   
    ///////////////////////////////////////////////// sensors
    
    //hall
    wire[15:0] speed;
    reg[15:0] sta_speed;
    hall(clk0,hall_in,speed);   

    //gyro
    wire[15:0] roll;
    wire[15:0] pitch;
    wire[15:0] yaw;
    gyro(clk0,probe_gyro,roll,pitch,yaw);
    
    //ultrasonic
    wire[15:0] ult_result_1;
    wire[15:0] ult_result_2;
    wire[15:0] ult_result_3;
    ultrasonic(clk0,ult_trig_1,ult_probe_1,ult_result_1);
    ultrasonic(clk0,ult_trig_2,ult_probe_2,ult_result_2);
    ultrasonic(clk0,ult_trig_3,ult_probe_3,ult_result_3);
    
    ///////////////////////////////////////////////////// driver
    
    // PWM_per (PWM based on percent) to control the motor
    // percent1  forward  (12~15 suggested)
    // percent2  backward (12~15 suggested)
    reg[15:0] percent1;
    reg[15:0] percent2;
    PWM_per(clk0, percent1, IN1);
    PWM_per(clk0, percent2, IN2);   
    
    // PWM_len (PWM based on length) to control the direction
    // 1700 turn right (1.7ms)
    // 2000 forward
    // 2300 turn left  (2.3ms)
    reg[15:0] direction_length;
    PWM_len(clk0,direction_length,direction_out);
    
    ////////////////////////////////////////////////// state machine 
    reg[1:0] state;
    reg[15:0] std_direction;
    reg[15:0] direction_offset;
    reg[15:0] a1_cnt,b1_cnt,d1_cnt;
    
    wire clk;
    timedivider(clk0,5000000,clk); //10Hz
    always @ (posedge clk)
    begin
        direction_offset = yaw - std_direction ;
        /* direction_offset indicates the direction to the std_direction
            0 //same as the std_direction
            16384 //left to the standard direction
            32768 //back to the standard direction
            49152 //right to the standard direction
        */
        
        case(state)
        0:  // keep going forward; and turn right if neccessary
        begin
            percent1=12; percent2=0; direction_length = 2000; // forward directly
            
            // direction
            if (direction_offset< 1000 || direction_offset> 64536)//correct direction
            begin
                //(when we have 2 ultrasonics, one front, one right: turn right (set std_direction) if possible (have not turn right for a while, and both forward and right side have space, and yaw is within range). anyway, keep the wall right of you.
                if (ult_result_1>600 && ult_result_3>600 && ult_result_2>1500) 
                    std_direction = std_direction - 16384; // std_direciton turn right
            end
            else begin
                if(direction_offset<32768)
                begin
                    if (direction_offset<3000) direction_length = 1850; //turn right slightly 
                                          else direction_length = 1700; // turn right normally
                end
                else begin
                    if (direction_offset>62536) direction_length = 2150; //turn left slightly
                                           else direction_length = 2300; // turn left normally
                end
            end   
            
            // slow down when meeting barriers
            if(ult_result_1 < 400 || ult_result_3 < 400 )
            begin
                percent1 = 0; percent2 = 5; // get backward to slow down
                a1_cnt = a1_cnt + 1; // count the time
            end
            else 
                a1_cnt = 0; // clear the counter
            
            if(a1_cnt >= 5) // the barrier have not disappeared for 0.5s
                begin a1_cnt = 0; state = 1; end //turn to state_1: wait
        end
        1: //face the barrier and wait
        begin
            percent1 = 0; percent2 = 0;//stop to wait
            
            if (direction_offset>17384 && direction_offset<63556) // recheck my direction if neccessary
            begin
                if (direction_offset>49152) std_direction=std_direction-16384;
                else if (direction_offset>32768) std_direction = std_direction+32768;
                else std_direction = std_direction+16384;
            end
            
            if (ult_result_1>400 && ult_result_3>400) 
                begin b1_cnt = 0; state=0; end // stop waiting and keep going forward
            
            b1_cnt = b1_cnt + 1; // count time
            if (b1_cnt >= 5) // have been waiting for 0.5s
            begin
                if(ult_result_1 < 400 || ult_result_3<400) //still barrier
                    begin b1_cnt = 0; state = 2; end //turn to state_2; 
                else//no barrier
                    begin b1_cnt = 0; state = 0; end //turn to state_0; keep going forward
            end
        end
        2: //std_direction turn left
        begin
           percent1=0; percent2=0;
           std_direction = std_direction + 16384; // std_direction turn left
           state = 3; //turn to state_3
        end
        3: // right and back
        begin
            percent1 = 0; percent2 = 20; direction_length = 1700; // right and back
            d1_cnt = d1_cnt + 1;
            if (direction_offset>62535 || direction_offset<3000 || d1_cnt>10 ) 
                begin d1_cnt = 0; state=0; end
        end
        endcase
    end

endmodule
