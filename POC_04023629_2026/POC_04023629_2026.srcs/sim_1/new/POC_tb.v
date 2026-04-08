`timescale 1ns / 1ps

module POC_tb();
        reg         clk_100M_in;
        wire        IRQ;
        wire        RW;
        wire  [7:0] Din;
        wire  [7:0] Dout;
        wire        ADDR;
        wire        RDY;
        wire        TR;
        wire  [8:0] PD;
        wire        clk_POCused;                  
        
        initial  clk_100M_in=0;                     // clk_100M   fixed clk
        always #5 clk_100M_in=~clk_100M_in;
        
        initial
        begin
            #1000;
            u1.data=8'h32;
            #1000;
            u1.data=8'h95;
            #1000;
            u1.data=8'hd4;
            #1000;
            u1.data=8'hc0;
            #400;


            #2000;
            u1.u2.SR[0]=1'b1;
            u1.data=8'h99;
            #1000;
            u1.data=8'hd4;
            #400;


            #100;
            force u1.u2.SR[0]=1'b0;
            #200;
            release u1.u2.SR[0];
            u1.data=8'h77;
            #1000;
            u1.data=8'h2a;
            #400;

            #2000;
            $stop;
        end


    Processor u1(
    .clk_100M(clk_100M_in),
    .clk_POCused(clk_POCused),   //POC used clk
    .IRQ(IRQ),
    .RW(RW),            //1====>Read   0====>Write
    .Dout(Dout),
    .Din(Din),
    .ADDR(ADDR)
    
    );




endmodule
