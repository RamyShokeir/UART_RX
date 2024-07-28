`timescale 1us/1ns
`include "UART_RX_RTL.v"
module UART_RX_TB #(parameter Out_Data_Width_TB=8, parameter Prescale_Width_TB=6) ();
// Defining INPUTS and OUTPUTS
reg  RX_IN_TB;
reg PAR_TYP_TB;
reg PAR_EN_TB;
reg [Prescale_Width_TB-1:0] Prescale_TB;
reg CLK_TB;
reg RST_TB;
reg TX_CLK_TB;
reg parity_flag;
reg stop_flag;
//reg data_flag;
// Those 2 Output Signals to be checked for test cases
wire [Out_Data_Width_TB-1:0] P_DATA_TB;
wire par_err_TB;
wire stp_err_TB;
wire Data_Valid_TB;
// 115.2KHZ TX Frequency , RX Frequency is Prescale * 115.2KHZ so the Clock Period is TX_CLK_PERIOD/Prescale
parameter TX_CLK_PERIOD=8.68;
// INITIAL BLOCK
initial 
begin
    // Initialize 
    initialize();
    // Reset
reset();
        // No Parity Two Consecutive Packets
        //DONE
    $display("**********TEST Case 1*************")  ;   
    parity_configuration(1'b0, 1'b0);
    // Example of loading serial data
    // 1ST SERIAL PACKET
    // 1st Argument Parity Enable , 2nd Argument Parity TYP , 3rd Argument Parity Bit , 4th Argument Stop Bit
    packet_one('b0,'b0,'b0,'b0); // I will make Stop bit equals 0
reset();
      // 1ST SERIAL PACKET
     //1st Argument Parity Enable , 2nd Argument Parity TYP , 3rd Argument Parity Bit , 4th Argument Stop Bit
    //DATA_1="10011001" // DATA_2="01010101"
    $display("**********TEST Case 2*************") ;  
    parity_configuration(1'b1, 1'b0); // Entering Wrong Parity
    packet_one('b1,'b0,'b1,'b1); 
reset();
    $display("**********TEST Case 3*************") ;  
    parity_configuration(1'b1, 1'b0); 
    packet_one('b1,'b0,'b1,'b1); // Entering 2 Wrong Parity Bits
    packet_two('b1,'b0,'b1,'b1);
reset();
    $display("**********TEST Case 4*************") ;  
    parity_configuration(1'b1, 1'b0); 
    packet_one('b1,'b0,'b0,'b1); // Entering 2 Correct Packets
    packet_two('b1,'b0,'b0,'b1);
reset();
    $display("**********TEST Case 5*************") ;  
    parity_configuration(1'b1, 1'b0); 
    packet_one('b1,'b0,'b1,'b1); // Entering 1st Packet with Wrong Parity , 2nd Packet Correct
    packet_two('b1,'b0,'b0,'b1);
reset();
    $display("**********TEST Case 6*************") ;  
    parity_configuration(1'b1, 1'b0); 
    packet_one('b1,'b0,'b0,'b0); // Entering 1st Packet with Wrong STOP Bit , 2nd Packet Correct
    packet_two('b1,'b0,'b0,'b1);
reset();
    $display("**********TEST Case 7*************") ;
    parity_configuration(1'b1, 1'b0); 
    packet_one('b1,'b0,'b0,'b0); // Entering 2 Packets with Wrong STOP Bits
    packet_two('b1,'b0,'b0,'b0);
    #(TX_CLK_PERIOD);
    $stop;
end
// TASKS
// Initialization
task initialize;
begin
    RX_IN_TB = 1'b1;
    PAR_TYP_TB = 1'b0;
    PAR_EN_TB = 1'b0;
    CLK_TB = 1'b0;
    TX_CLK_TB=1'b0;
    RST_TB = 1'b1;
    Prescale_TB = 6'b001000; // Prescale 8
    parity_flag = 1'b0;
    stop_flag = 1'b0;
end
endtask
// Reset
task reset;
begin
    #(TX_CLK_PERIOD);
    RST_TB = 1'b0;
    #(TX_CLK_PERIOD);
    RST_TB = 1'b1;
end
endtask

// Loading Serial Data
task load_serial_data;
input rx_in;
begin
  @(posedge TX_CLK_TB)
    RX_IN_TB = rx_in;
  #(TX_CLK_PERIOD);
end
endtask

task load_data;
input rx_in;
begin
    RX_IN_TB=rx_in;
end
endtask
task packet_one;
input PAR_EN_TB;
input PAR_TYP_TB;
input parity_bit;
input stop_bit;
begin
         load_serial_data('b0); // START BIT
     $display("Loaded START BIT");
    load_serial_data('b1); // 1ST BIT
    $display("Loaded 1ST BIT");
    load_serial_data('b0); // 2ND BIT
    $display("Loaded 2ND BIT");
    load_serial_data('b0); // 3RD BIT
    $display("Loaded 3RD BIT");
    load_serial_data('b1); // 4TH BIT
    $display("Loaded 4TH BIT");
    load_serial_data('b1); // 5TH BIT
    $display("Loaded 5TH BIT");
    load_serial_data('b0); // 6TH BIT
    $display("Loaded 6TH BIT");
    load_serial_data('b0); // 7TH BIT
    $display("Loaded 7TH BIT");
    load_serial_data('b1); // 8TH BIT
    $display("Loaded 8TH BIT");
    if(PAR_EN_TB)
    begin
        load_data(parity_bit); // PARITY BIT
        check_parity_flag(parity_bit,PAR_TYP_TB);
        check_parity;
    end
    if(!parity_flag)
    begin
    load_data(stop_bit); // STOP BIT
    $display("Loaded STOP BIT");
    check_parallel_data_1;
    check_stop_flag(stop_bit);
    check_stop;
    check_Data_Valid;
    end
end
endtask
task packet_two;
input PAR_EN_TB;
input PAR_TYP_TB;
input parity_bit;
input stop_bit;
begin
    load_serial_data('b0); // START BIT
     $display("Loaded START BIT");
    load_serial_data('b1); // 1ST BIT
    $display("Loaded 1ST BIT");
    load_serial_data('b0); // 2ND BIT
    $display("Loaded 2ND BIT");
    load_serial_data('b1); // 3RD BIT
    $display("Loaded 3RD BIT");
    load_serial_data('b0); // 4TH BIT
    $display("Loaded 4TH BIT");
    load_serial_data('b1); // 5TH BIT
    $display("Loaded 5TH BIT");
    load_serial_data('b0); // 6TH BIT
    $display("Loaded 6TH BIT");
    load_serial_data('b1); // 7TH BIT
    $display("Loaded 7TH BIT");
    load_serial_data('b0); // 8TH BIT
    $display("Loaded 8TH BIT");
    if(PAR_EN_TB)
    begin
        load_data(parity_bit); // PARITY BIT
        check_parity_flag(parity_bit,PAR_TYP_TB);
        check_parity;
    end
    if(!parity_flag)
    begin
       load_data(stop_bit); // STOP BIT
       $display("Loaded STOP BIT");
       check_parallel_data_2;
       check_stop_flag(stop_bit);
       check_stop;
       check_Data_Valid;
    end
end
endtask  
//P_DATA checking
task check_parallel_data_1;
begin
if(P_DATA_TB==8'b10011001)
begin
    //data_flag=1'b1;
    $display("P_DATA TEST is Succeeded");
end
else
    begin
      //  data_flag=1'b0;
    $display("P_DATA TEST is Failed");
    end

end
endtask
task check_parallel_data_2;
begin
if(P_DATA_TB==8'b01010101)
begin
    $display("P_DATA TEST is Succeeded");
end
else
    begin
    $display("P_DATA TEST is Failed");
    end

end
endtask
task check_parity_flag;
input parity_bit;
input  PAR_TYP_TB;
    begin
        case(PAR_TYP_TB)
        'b0:
        begin
            if(^P_DATA_TB == parity_bit)
            begin
                 parity_flag=1'b0;
                 #(TX_CLK_PERIOD);
            end
            else
            begin
                @(posedge par_err_TB)
                begin
                parity_flag=1'b1;

                end
            end

        end   
        'b1:
        begin
            if(~^P_DATA_TB == parity_bit)
            begin
                parity_flag=1'b0;
                #(TX_CLK_PERIOD);
            end
            else
            begin
                @(posedge par_err_TB)
                begin
                    parity_flag=1'b1;

                end
            end

        end
        endcase
    end
endtask
task check_stop_flag;
input stop_bit;
begin
    if(stop_bit==1'b1)
    begin
        stop_flag=1'b0;
        #(TX_CLK_PERIOD);

    end
    else
    begin
        @(posedge stp_err_TB)
        begin
            stop_flag=1'b1;
        end
    end
end
endtask
task check_parity;
begin
    if(parity_flag=='b0  && PAR_TYP_TB==1'b0 )
    begin
        $display("PARITY TEST is Succeeded , EVEN PARITY");
    end
    else if(parity_flag=='b0  && PAR_TYP_TB==1'b1)
    begin
        $display("PARITY TEST is Succeeded , ODD PARITY");
    end
    else if(parity_flag=='b1 && PAR_TYP_TB==1'b0)
    begin
        $display(" EVEN PARITY TEST is Succeeded with Incorrect Parity");
    end
    else if(parity_flag=='b1 && PAR_TYP_TB==1'b1 )
    begin
        $display(" ODD PARITY TEST is Succeeded with Incorrect Parity");
    end
    else
    begin
        $display("PARITY TEST is Failed");
    end
end

endtask
task check_stop;
begin
    if(!stop_flag)
    begin
        $display("STOP TEST is Succeeded");
    end
    else
    begin
        $display("STOP TEST is Failed");
    end
end
endtask
task check_Data_Valid;
if(parity_flag==1'b0 && stop_flag==1'b0 )
begin
    $display("DATA VALID TEST is Succeeded");
    $display("TEST CASE PASSED with Correct Parity and Stop Bits");
end
else if(parity_flag==1'b1 && stop_flag==1'b0)
begin

        $display("DATA VALID TEST is Failed");
        $display("TEST CASE PASSED with Incorrect Parity Bit");
        parity_flag=1'b0;
        stop_flag=1'b0;
end
else if(parity_flag==1'b0 && stop_flag==1'b1)
begin
        $display("DATA VALID TEST is Failed");
        $display("TEST CASE PASSED with Incorrect Stop Bit");
        parity_flag=1'b0;
        stop_flag=1'b0;
end
else
begin
        $display("DATA VALID TEST is Failed");
        $display("TEST CASE PASSED with Incorrect Parity and Stop Bits");
        parity_flag=1'b0;
        stop_flag=1'b0;
end

endtask
// Parity Configuration
task parity_configuration;
input parity_enable;
input parity_type;
begin
    // Configuration: set PAR_EN_TB to 1 if parity is needed, 0 if not
    PAR_EN_TB = parity_enable; 
    // Configuration: set PAR_TYP_TB to 0 for even parity, 1 for odd parity
    PAR_TYP_TB = parity_type;
    if (parity_enable)
    begin
        case (parity_type)
        1'b0: $display("PARITY ENABLED, EVEN");
        1'b1: $display("PARITY ENABLED, ODD");
        endcase
    end
    else
    begin
        $display("PARITY DISABLED");
    end
end
endtask
// CLOCK GENERATOR
//RX CLOCK
always #((TX_CLK_PERIOD / (2*Prescale_TB))) CLK_TB = ~CLK_TB;
//TX CLOCK
always #(TX_CLK_PERIOD / 2) TX_CLK_TB = ~TX_CLK_TB;
// Instantiation of UART_RX module
UART_RX #(.Out_Data_width(Out_Data_Width_TB), .Prescale_Width(Prescale_Width_TB)) DUT (
    .RX_IN(RX_IN_TB),
    .PAR_TYP(PAR_TYP_TB),
    .PAR_EN(PAR_EN_TB),
    .Prescale(Prescale_TB),
    .CLK(CLK_TB),
    .RST(RST_TB),
    .P_DATA(P_DATA_TB),
    .Data_Valid(Data_Valid_TB),
    .par_err(par_err_TB),
    .stp_err(stp_err_TB)
);
endmodule

