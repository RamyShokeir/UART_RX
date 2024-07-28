module FSM_Block #(parameter Out_Data_width=8,parameter Prescale_Width=6) (
    input wire RX_IN,
    input wire PAR_EN,
    input wire PAR_TYP,
    input wire [3:0] bit_cnt,
    input wire sampled_bit,
    input wire [Prescale_Width-1:0] Prescale,
    input wire [Prescale_Width-1:0] edge_cnt,
    input wire [Out_Data_width-1:0] P_DATA,
    input wire CLK, RST,
    output reg dat_samp_en, enable, deser_en,
    output reg par_chk_en, stp_chk_en,strt_chk_en,
    output reg par_err,stp_err,
    output reg Data_Valid
);
reg strt_glitch;
reg [4:0] current_state, next_state;
localparam [4:0] IDLE_STATE = 5'b00001,
                START_STATE = 5'b00010,
                DATA_STATE = 5'b00100,
                PARITY_STATE = 5'b01000,
                STOP_STATE = 5'b10000;

// Sequential Block for State Transition 
always @(posedge CLK)
 begin
    if (!RST)
        current_state <= IDLE_STATE;
    else 
        current_state <= next_state;
end

// Combinational Block for Next State Logic and Outputs
always @(*) 
begin
    // Default values for control signals
    dat_samp_en = 1'b0;
    enable = 1'b0;
    deser_en = 1'b0;
    par_chk_en = 1'b0;
    stp_chk_en = 1'b0;
    strt_chk_en = 1'b0;
    Data_Valid = 1'b0;
    par_err =1'b0;
    stp_err =1'b0;
    strt_glitch = 1'b0;
case(current_state)
        IDLE_STATE: 
begin
           dat_samp_en = 1'b0;
            enable = 1'b0;
            deser_en = 1'b0;
            par_chk_en = 1'b0;
            stp_chk_en = 1'b0;
            strt_chk_en = 1'b0;
            Data_Valid = 1'b0;
            par_err =1'b0;
            stp_err =1'b0;
            strt_glitch = 1'b0;
            if (!RX_IN)
             begin
                next_state = START_STATE;
            end 
            else
             begin
                next_state = IDLE_STATE;
            end
end
        START_STATE: 
begin
            strt_chk_en = 1'b1;
            dat_samp_en = 1'b1;
            enable = 1'b1;
            //EL MAFROD ashof dh glitch wla la2 awl ma el sampled bit tkon ghzt msh astna le7ad ma el edge_cnt ygeb el max
          begin
        case(Prescale)
            6'b000100:
            begin
             if(bit_cnt== 4'b0000 && edge_cnt== (Prescale-'b1))
            begin
                 strt_glitch <= (sampled_bit == 1'b1) ? 1'b1 : 1'b0;
                 if(!strt_glitch)
                    next_state <= DATA_STATE; //GLITCH CHECK PASSED
                 else
                    next_state <= IDLE_STATE; //GLITCH CHECK FAILED 
                 
            end
        //Normal case we hwa mfesh ay moshkela kda kda hy3di el cycles kolha we hena hro7 lel DATA_STATE 3shan ana dmnt en el dnia tmam
            else 
             begin
                next_state <= START_STATE;
             end
            end
            default:
            begin
            //Deh fe el case bta3t eno la2a glitch awl ma 3aml el sampling 3ltol 
            if(bit_cnt== 4'b0000 && edge_cnt== ((Prescale>>1)+'b10))
            begin
                 strt_glitch = (sampled_bit == 1'b1) ? 1'b1 : 1'b0;
                 if(!strt_glitch)
                    next_state = START_STATE; //GLITCH CHECK PASSED
                 else
                    next_state = IDLE_STATE; //GLITCH CHECK FAILED   
            end
            
        //Normal case we hwa mfesh ay moshkela kda kda hy3di el cycles kolha we hena hro7 lel DATA_STATE 3shan ana dmnt en el dnia tmam
            else if(bit_cnt== 4'b0000 && edge_cnt== (Prescale-'b1))
             begin
                next_state = DATA_STATE;
             end
             else
             begin
                next_state =START_STATE;
             end
            end
        endcase
          end

end

        DATA_STATE: 
begin
            strt_chk_en = 1'b0;
            dat_samp_en = 1'b1;
            enable = 1'b1;
            deser_en = 1'b1;
            // Hena Mfesh ay checks 
            if (bit_cnt == 4'b1000 && edge_cnt >= (Prescale-'b1))
            begin
                if (PAR_EN)
                    next_state = PARITY_STATE;
                else
                    begin
                    next_state = STOP_STATE;
                    end
            end 
            else 
            begin
                next_state = DATA_STATE;
            end
end

        PARITY_STATE: 
begin
            par_chk_en = 1'b1;
            deser_en = 1'b0;
            dat_samp_en = 1'b1;
            enable = 1'b1;
          begin
            case(Prescale)
                6'b000100:
                begin
                                // 3and edge_cnt b 2 el sampled bit already ghza we 22dr hena a3ml parity check
            if(bit_cnt== 4'b1001 && edge_cnt =='d3)
            begin
                            if(PAR_TYP== 1'b0 && (^(P_DATA) == sampled_bit)) //Even Parity
                                begin
                                     par_err<= 1'b0;
                                     next_state<=STOP_STATE;
                                end
                            else if(PAR_TYP== 1'b0 && (^(P_DATA) != sampled_bit))
                                begin
                                     par_err<= 1'b1;
                                     next_state<=IDLE_STATE;
                                 end
                            else if(PAR_TYP== 1'b1 && ((~^P_DATA) == sampled_bit)) //Odd Parity
                                begin
                                     par_err<= 1'b0;
                                     next_state<=STOP_STATE;
                                 end
                             else if(PAR_TYP== 1'b1 && ((~^P_DATA)!= sampled_bit))
                                 begin
                                     par_err<= 1'b1;
                                     next_state<=IDLE_STATE;
                                 end
                             else
                                begin
                                      par_err<= 1'b0;
                                      next_state<=IDLE_STATE;
                                end
            end
            else 
            begin
                next_state <= PARITY_STATE;
            end
                end
                default:
                begin
            // 3and edge_cnt b 2 el sampled bit already ghza we 22dr hena a3ml parity check
            if(bit_cnt== 4'b1001 && edge_cnt ==((Prescale>>1)+'b10))
            begin
                            if(PAR_TYP== 1'b0 && (^(P_DATA) == sampled_bit)) //Even Parity
                                begin
                                     par_err = 1'b0;
                                     next_state = PARITY_STATE;
                                end
                            else if(PAR_TYP== 1'b0 && (^(P_DATA) != sampled_bit))
                                begin
                                     par_err = 1'b1;
                                     next_state = IDLE_STATE;
                                 end
                            else if(PAR_TYP== 1'b1 && ((~^P_DATA) == sampled_bit)) //Odd Parity
                                begin
                                     par_err = 1'b0;
                                     next_state = PARITY_STATE;
                                 end
                             else if(PAR_TYP== 1'b1 && ((~^P_DATA)!= sampled_bit))
                                 begin
                                     par_err = 1'b1;
                                     next_state = IDLE_STATE;
                                 end
                             else
                                begin
                                      par_err = 1'b0;
                                      next_state = PARITY_STATE;
                                end
            end
            else if(bit_cnt== 4'b1001 && edge_cnt ==(Prescale-'b1)) 
            begin
                next_state  = STOP_STATE;
            end
            else
            begin
                next_state= PARITY_STATE;
            end
                end
            endcase
          end

end
        STOP_STATE:
begin
            stp_chk_en  = 1'b1;
            deser_en = 1'b0;
            dat_samp_en = 1'b1;
            enable = 1'b1;
            begin
                case(Prescale)
                    6'b000100:
                    begin
                if((bit_cnt == 4'b1010 || bit_cnt==4'b1001)  && edge_cnt== (Prescale-'b1) && PAR_EN)
                begin
                    stp_err <= (sampled_bit==1'b1) ?  1'b0 : 1'b1;
                    if(!stp_err)
                        begin
                        Data_Valid<= 1'b1;
                         if(!RX_IN)
                         begin
                            next_state<=START_STATE;
                         end
                         else
                         begin
                            next_state<=IDLE_STATE;
                         end
                        end
                    else
                        begin
                            next_state<=IDLE_STATE;
                        end
                end
            else if((bit_cnt == 4'b1010 || bit_cnt==4'b1001)  && edge_cnt== (Prescale-'b1)  && !PAR_EN)
                begin
                    stp_err <= (sampled_bit==1'b1) ?  1'b0 : 1'b1;
                    if(!stp_err)
                        begin
                        Data_Valid<= 1'b1;
                         if(!RX_IN)
                         begin
                            next_state<=START_STATE;
                         end
                         else
                         begin
                            next_state<=IDLE_STATE;
                         end
                        end
                    else
                        begin
                            next_state<=IDLE_STATE;
                        end
                end
             else
                begin
                    next_state <= STOP_STATE;
                end
                end
                    default:
                    begin
             if((bit_cnt == 4'b1010 || bit_cnt==4'b1001)  && edge_cnt== ((Prescale>>1)+'b10) && PAR_EN )
                begin
                    stp_err = (sampled_bit==1'b1) ?  1'b0 : 1'b1;
                    if(!stp_err)
                        begin
                            next_state = STOP_STATE;
                        end
                    else
                        begin
                            next_state = IDLE_STATE;
                        end
                end
            else if((bit_cnt == 4'b1010 || bit_cnt==4'b1001)  && edge_cnt== ((Prescale>>1)+'b10)  && !PAR_EN)
                begin
                    stp_err = (sampled_bit==1'b1) ?  1'b0 : 1'b1;
                    if(!stp_err)
                        begin
                            next_state = STOP_STATE;
                        end
                    else
                        begin
                            next_state = IDLE_STATE;
                        end
                end

             else if((bit_cnt == 4'b1010 || bit_cnt==4'b1001)  && edge_cnt== ((Prescale-'b1)))
                begin
                    if(!stp_err)
                    begin
                        Data_Valid = 1'b1;
                        if(!RX_IN)
                         begin
                            next_state = START_STATE;
                         end
                         else
                         begin
                            next_state = IDLE_STATE;
                         end
                    end
                    else
                    begin
                        next_state = IDLE_STATE;
                    end

                end
                else
                begin
                    next_state = STOP_STATE;
                end
                    end
                endcase
            end
    end
        
    default:
         begin
            next_state = IDLE_STATE;
            dat_samp_en = 1'b0;
            enable = 1'b0;
            deser_en = 1'b0;
            par_chk_en = 1'b0;
            stp_chk_en = 1'b0;
            strt_chk_en = 1'b0;
            Data_Valid = 1'b0;
            par_err =1'b0;
            stp_err =1'b0;
            strt_glitch = 1'b0;
         end
endcase
end
endmodule