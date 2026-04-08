module Processor(
    input                   clk_100M,
    output                  clk_POCused,   //POC used clk
    input                   IRQ,
    output  reg             RW,            //1====>Read   0====>Write
    output  reg  [7:0]      Dout,
    input        [7:0]      Din,
    output  reg             ADDR,
    input                   RDY_POC,
    output  reg             rst_n
    
    );
    wire clk_stable_flag;
    //reg address_ready_flag=1'b0;

    reg [7:0] Dout_POC_buffer;

    reg [7:0] data=8'ha8;

    reg break_flag=0;

    always@(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
            if(IRQ==1'b1)
            begin
                ADDR<=1'b0;
                RW<=1'b1;
                if(Din==8'b1000_0000)
                begin
                    RW<=1'b0;
                    ADDR<=1'b1;
                    Dout<=data;
                    if (RDY_POC) 
                    begin
                        ADDR<=1'b0;
                        Dout<=8'b0000_0000;
                    end
                end
            end

            else if((IRQ==1'b0) || (break_flag==1'b1))
            begin
                RW<=1'b0;
                ADDR<=1'b1;
                Dout<=data;
                if(RDY_POC) 
                begin
                    ADDR<=1'b0;
                    Dout<=8'b0000_0001;
                end
            end
        end
    end

    reg up_flag;

    always@(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
            if(IRQ==1'b0)
            begin
                break_flag<=1'b1;
            end

            if(IRQ==1'b1)
            begin
                break_flag<=1'b0;
            end
        end
    end

    // always@(posedge clk_POCused or negedge rst_n)
    // begin
    //     if (!rst_n)begin end
    //     else
    //     begin
    //         if(up_flag==1'b1)
    //         begin
    //             break_flag<=1'b1;
    //             up_flag<=1'b0;
    //         end
    //     end
    // end

    // reg [7:0] cont=0;


    // always@(posedge clk_POCused or negedge rst_n)
    // begin
    //     if (!rst_n)begin end
    //     else
    //     begin
    //         if(cont<=5'b11111)
    //         begin
    //             if((up_flag==1'b0)&&(Din[7]==1'b1))
    //             begin
    //                 break_flag<=1'b0;
    //             end
    //             cont<=0;
    //         end
    //         else
    //         cont<=cont+1'b1;
    //     end
    // end



    POC u2
    (
    .clk_POCused(clk_POCused),   //POC used clk
    .IRQ(IRQ),            //IRQ low_effcient
    .RW(RW),
    .Din(Dout),
    .Dout(Din),
    .ADDR(ADDR),
    .RDY_POC(RDY_POC)
    //.RDY(),
    //.TR(),
    //.PD()
    );


    clk_wiz_0 u1_clk
    (
    .clk_out_POCused(clk_POCused),
    .clk_in1(clk_100M),
    .locked(clk_stable_flag)
    );

    always@(posedge clk_POCused)
    begin
        rst_n<=clk_stable_flag;
    end

endmodule
