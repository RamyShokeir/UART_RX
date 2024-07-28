`include "UART_RX_FSM.v"
`include "UART_RX_datasampling.v"
`include "UART_RX_deserializer.v"
`include "UART_RX_edgebitcounter.v"

module UART_RX #(parameter Out_Data_width=8, parameter Prescale_Width=6) (
    input wire RX_IN,
    input wire PAR_TYP,
    input wire PAR_EN,
    input wire [Prescale_Width-1:0] Prescale,
    input wire CLK,
    input wire RST,
    output wire [Out_Data_width-1:0] P_DATA,
    output wire Data_Valid,
    output wire par_err,
    output wire stp_err
);

    // Internal signals
    wire [Prescale_Width-1:0] edge_cnt;
    wire dat_samp_en, enable, deser_en;
    wire sampled_bit;
    wire [3:0] bit_cnt;
    // Instantiate data_sampling_Block
    data_sampling_Block #(.Prescale_Width(Prescale_Width)) U0_Data_Sampling (
        .RX_IN(RX_IN),
        .Prescale(Prescale),
        .dat_samp_en(dat_samp_en),
        .CLK(CLK),
        .RST(RST),
        .edge_cnt(edge_cnt),
        .sampled_bit(sampled_bit)
    );

    // Instantiate deserializer_Block
    deserializer_Block #(.Out_Data_width(Out_Data_width),.Prescale_Width(Prescale_Width)) U0_Deserializer (
        .deser_en(deser_en),
        .edge_cnt(edge_cnt),
        .bit_cnt(bit_cnt),
        .Prescale(Prescale),
        .sampled_bit(sampled_bit),
        .CLK(CLK),
        .RST(RST),
        .P_DATA(P_DATA)
    );

    // Instantiate FSM_Block
    FSM_Block #(.Out_Data_width(Out_Data_width),.Prescale_Width(Prescale_Width)) U0_FSM (
        .RX_IN(RX_IN),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .bit_cnt(bit_cnt),
        .sampled_bit(sampled_bit),
        .edge_cnt(edge_cnt),
        .P_DATA(P_DATA),
        .Prescale(Prescale),
        .CLK(CLK),
        .RST(RST),
        .dat_samp_en(dat_samp_en),
        .enable(enable),
        .deser_en(deser_en),
        .par_chk_en(par_chk_en),
        .par_err(par_err),
        .stp_err(stp_err),
        .stp_chk_en(stp_chk_en),
        .strt_chk_en(strt_chk_en),
        .Data_Valid(Data_Valid)
    );
    // Instantiate edge_bit_counter_Block
    edge_bit_counter_Block #(.Prescale_Width(Prescale_Width)) U0_EdgeBit_Counter (
        .enable(enable),
        .Prescale(Prescale),
        .PAR_EN(PAR_EN),
        .CLK(CLK),
        .RST(RST),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt)
    );
endmodule
