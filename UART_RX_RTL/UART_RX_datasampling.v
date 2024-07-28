module data_sampling_Block #(parameter Prescale_Width=6)
(
    input wire RX_IN,
    input wire [Prescale_Width-1:0] Prescale,
    input wire dat_samp_en,
    input wire [Prescale_Width-1:0] edge_cnt,
    input wire CLK,
    input wire RST,
    output reg sampled_bit
);
    reg [2:0] middle_bits;
always @(posedge CLK) 
    begin
        if (!RST) 
            begin 
            sampled_bit <= 1'b0;
            middle_bits <= 3'b0;
            end 
        else if (dat_samp_en) 
            begin
                case(Prescale)
                6'b000100:
                begin   
                        if (edge_cnt <= (Prescale-'b1)) 
                            begin
                             // Evaluate sampled_bit at specific edge_cnt
                             //Capturing at the start of 3rd edge and deciding the sampled bit
                                if (edge_cnt == 'd1)
                                    begin
                                    sampled_bit <= RX_IN;
                                    end
                                end
                        else
                            begin
                            sampled_bit<=sampled_bit;
                            end
                end
                default:
                begin           
                        if(edge_cnt <= (Prescale-'b1))
                            begin
                                if(edge_cnt == (Prescale>>1)-'b10)
                                begin
                                    middle_bits[0] <= RX_IN;
                                end
                                else if(edge_cnt ==(Prescale>>1)-'b1)
                                begin
                                    middle_bits[1] <= RX_IN;
                                end
                                else if (edge_cnt == (Prescale>>1))
                                    begin
                                        middle_bits[2] = RX_IN;
                                    // Compare with specific 3-bit patterns
                                    if (middle_bits == 3'b110 || middle_bits == 3'b101 || middle_bits == 3'b011 || middle_bits == 3'b111)
                                    begin
                                        sampled_bit <= 1'b1;
                                    end
                                     else
                                     begin
                                    sampled_bit <= 1'b0;
                                     end
                                    end
                                else
                                    begin 
                                        sampled_bit<=sampled_bit;
                                    end
                             end   
                        else
                            begin
                            sampled_bit<=sampled_bit;
                            end    
                    end
                endcase
            end
        else
            begin
            sampled_bit <= 1'b0;
            end
    end
endmodule