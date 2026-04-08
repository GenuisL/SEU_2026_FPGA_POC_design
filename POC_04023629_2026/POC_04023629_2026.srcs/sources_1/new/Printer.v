module Printer(
    input        clk_POCused,   //POC used clk
    output  reg  RDY=1'b1,
    input        TR,
    input  [7:0] PD,

    input       rst_n
    );

    reg [7:0] data_buffer;
    reg [4:0] counter=5'h0;

    parameter [4:0] counter_clk=5'd10;
    reg processing_flag=0;


    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
        if(TR==1)
        begin
            data_buffer<=PD;
            RDY<=1'b0;
            processing_flag=1'b1;
        end

        end
    end

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
        if(processing_flag==1'b0)
        begin
            RDY<=1'b1;
        end
        end
    end

    always @(posedge clk_POCused or negedge rst_n)
    begin
        if (!rst_n)begin end
        else
        begin
        if(processing_flag==1'b1)
        begin
            if(counter<counter_clk)
            begin
                counter<=counter+1'b1;
            end
            else
            begin
            counter=5'h0;
            processing_flag<=1'b0;
            end
        end
        end
    end




endmodule

