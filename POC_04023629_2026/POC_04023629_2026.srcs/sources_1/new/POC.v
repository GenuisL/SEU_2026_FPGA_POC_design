module POC(
    input                   clk_POCused,        //POC used clk
    output reg              IRQ=1'b1,            //IRQ low_effcient
    input                   RW,
    input       [7:0]       Din,
    output reg  [7:0]       Dout,
    input                   ADDR,
    
    input       RDY,
    output reg  TR = 1'b0,
    output reg  [7:0] PD = 8'h00,
    output reg  RDY_POC=1'b0,

    input       rst_n
    
    );

    //SR_ADDR====>0
    //BR_ADDR====>1

    reg [7:0] SR=8'b1000_0000;          //SR====>Status Regiter(8bits)
                                        //SR7====>Ready flag bit
                                        //SR0====>Interrupt bit
                                        //SR1-6====>empty
                        
    reg [7:0] BR=8'hef;                 //Buffer Register(8bits)

    parameter Search_con1=8'd0;
    parameter Pause_con2=8'd1;
    parameter Error_conMax=8'hff;

    reg [7:0] counter=8'd0;

    //reg [1:0] Printer_ready=2'b00;

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
            if(SR[0]==1'd0)
            counter<=Search_con1;
        
            else if(SR[0]==1'd1)
            counter<=Pause_con2;
        
            else 
            counter<=Error_conMax;
        end
    end

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
        if(RW==1'b1)
        begin
            if(ADDR==1'b0)
            begin
                Dout<=SR;
            end
            else if(ADDR==1'b1)
            begin
                Dout<=BR;
            end
        end

        else if(RW==1'b0)
        begin
            if(ADDR==1'b0)
            begin
                SR<=Din;
                RDY_POC<=1'b1;
            end
            else if(ADDR==1'b1)
            begin
                BR<=Din;
                RDY_POC<=1'b1;
            end
        end

        if(RDY_POC==1'b1)
            RDY_POC<=1'b0;

        end
    end

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
        case(counter)
            Search_con1:
            begin
                if(SR[7]==1'b0)
                begin
                PD<=BR;
                    if(TR==1'b1)
                    begin
                        TR<=1'b0;
                    end
                    else
                    if((RDY==1'b1)&&(TR==1'b0))
                        begin
                            TR<=1'b1;
                            SR[7]<=1'b1;                        
                        end
                end
            end
                
            Pause_con2:
            begin
                // if(RDY==1'b1)
                // begin
                    IRQ<=1'b0;
                    if(SR[7]==1'b0)
                    begin
                        PD<=BR;
                        if(TR==1'b1)
                        begin
                            TR<=1'b0;
                        end
                        else
                        if((RDY==1'b1)&&(TR==1'b0))
                            begin
                                TR<=1'b1;
                                SR[7]<=1'b1;                        
                            end
                    end
                //end

                Dout<=SR;
            end
                
            Error_conMax:
            begin
            
            end
            
            default :
            begin
            
            end
        endcase
        end
    end

    reg [7:0] cnt=8'h00;

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
            if(cnt>=3'b111)
            begin
                if((IRQ==1'b0)&&(SR[0]==1'b0))
                IRQ<=1'b1;
                cnt<=0;
            end
            else
            cnt<=cnt+1'b1;
        end
    end

    // always @(posedge clk_POCused or negedge rst_n)
    // begin
    //     if (!rst_n)begin end
    //     else
    //     begin


    //     end
    // end


    Printer u3
    (
    .clk_POCused(clk_POCused),   //POC used clk
    .RDY(RDY),
    .TR(TR),
    .PD(PD),
    .rst_n(rst_n)
    );


endmodule
