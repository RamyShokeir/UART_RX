module edge_bit_counter_Block #(parameter Prescale_Width=6)
(
    input wire enable,
    input wire [Prescale_Width-1:0] Prescale,
    input wire PAR_EN,
    input wire CLK,RST,
    output reg [3:0] bit_cnt,
    output reg [Prescale_Width-1:0] edge_cnt
);
always @( posedge CLK)
begin
    if(!RST)
    begin
        bit_cnt  <='b0;
        edge_cnt <='b0;
    end
    else
    begin
        case(enable)
    1'b0:
    begin
        bit_cnt <= 'b0;
        edge_cnt <= 'b0;
    end
    1'b1:
    begin
        case (PAR_EN)
        1'b0:
        begin
        if( bit_cnt<'b1010 && edge_cnt<(Prescale-'b1))
        begin
            edge_cnt <= edge_cnt + 'b1;
        end
        else if(bit_cnt=='b1001 && edge_cnt== (Prescale-'b1))
        begin
            bit_cnt <= 'b0;
            edge_cnt <= 'b0;
        end
        else if( bit_cnt <'b1010 && edge_cnt>= (Prescale-'b1))
        begin
            bit_cnt <= bit_cnt + 'b1;
            edge_cnt <= 'b0;
        end
        else
        begin
            bit_cnt <= 'b0;
            edge_cnt <= 'b0;
        end
        end

        1'b1:
        begin
        if( bit_cnt<'b1011 && edge_cnt<(Prescale-'b1))
        begin
            edge_cnt <= edge_cnt + 'b1;
        end
        else if(bit_cnt=='b1010 && edge_cnt==(Prescale-'b1))
        begin
            bit_cnt <= 'b0;
            edge_cnt <= 'b0;
        end
        else if( bit_cnt <'b1011 && edge_cnt>=(Prescale-'b1))
        begin
            bit_cnt <= bit_cnt + 'b1;
            edge_cnt <= 'b0;
        end
        else
        begin
            bit_cnt <= 'b0;
            edge_cnt <= 'b0;
        end
        end
        endcase
     end
    endcase
    end
end
endmodule