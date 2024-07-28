module deserializer_Block #(parameter Out_Data_width=8 ,Prescale_Width=6)
(
    input wire deser_en,
    input wire [Prescale_Width-1:0] edge_cnt,
    input wire [3:0] bit_cnt,
    input wire [Prescale_Width-1:0]Prescale,
    input wire sampled_bit,
    input wire CLK,
    input wire RST,
    output reg [Out_Data_width-1:0] P_DATA
);
reg [Prescale_Width:0] count_bits;
reg [Out_Data_width-1:0] P_DATA_comb;

always @(posedge CLK)
 begin
    if(!RST) 
        begin
        count_bits <= 3'b0;
        P_DATA <= 'b0;
        P_DATA_comb <= 'b0;
        end
    else if(deser_en) // Bit count from 1 to 8  (Our DATA)
        begin
            case(Prescale)
                6'b000100:
                begin
                if(edge_cnt==(Prescale>>1))
            begin
            P_DATA_comb <= (P_DATA_comb >> 1) | (sampled_bit << (Out_Data_width-1)); // Taking sampled bits from 1 to 8 LSB First
            count_bits <= count_bits + 'b1;
            end
            else if(bit_cnt=='b1000 && edge_cnt==((Prescale>>1)+'b1))
            begin
                P_DATA<=P_DATA_comb;
            end
                end
                default:
                begin
            if(edge_cnt==(Prescale>>1)+'b1)
            begin
            P_DATA_comb <= (P_DATA_comb >> 1) | (sampled_bit << (Out_Data_width-1)); // Taking sampled bits from 1 to 8  LSB First
            count_bits <= count_bits + 'b1;
            end
            else if(bit_cnt=='b1000 && edge_cnt==(Prescale>>1)+'b10)
            begin
                P_DATA<=P_DATA_comb;
            end
                end
            endcase
    
        end
    else//Bit count 9 this can be either Parity State or Stop State according to the PAR Enabled or not 
     begin
        P_DATA <= P_DATA_comb;// P_DATA is now ready with the 8 bits Data 
        count_bits <= 'b0; // Reset the count_bits after transferring data
    end
end
endmodule
