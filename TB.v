
`timescale 1ns/1ps

module TB;
  reg reset, clk;
  reg [4:0]clk_div;
  reg [1:0]mode;
  reg [7:0]master_data,slave_data;
  reg slave_select;
  wire sclk,master_busy,slave_busy1,slave_busy2,MOSI,MISO;
  wire [7:0]data_master,data_slave1,data_slave2;
  wire slave_select1,slave_select2;
  
  spi_master master_1(.i_clk(clk),
                 .i_reset(reset),
                 .i_MISO(MISO),
                 .i_clk_div(clk_div),
                 .i_mode(mode),
                 .i_master_data(master_data),
                 .i_slave_select(slave_select),    
                 .o_MOSI(MOSI),
                 .o_sclk(sclk),
                 .o_busy(master_busy),
                      .o_data_master(data_master),
                 .o_slave_select1(slave_select1),
                 .o_slave_select2(slave_select2));
  
 spi_slave slave_1(.i_sclk(sclk),
                    .i_reset(reset),
                    .i_mode(mode),
                   .i_slave_data(slave_data),
                   .i_slave_select(slave_select1),
                   .o_busy(slave_busy1),
                   .i_MOSI(MOSI),
                   .o_MISO(MISO),
                   .o_data_slave(data_slave1));
 spi_slave slave_2(.i_sclk(sclk),
                    .i_reset(reset),
                    .i_mode(mode),
                   .i_slave_data(slave_data),
                   .i_slave_select(slave_select2),
                   .o_busy(slave_busy2),
                   .i_MOSI(MOSI),
                   .o_MISO(MISO),
                   .o_data_slave(data_slave2));                   
 
initial begin
  clk=0;
  reset=0;
  clk_div=2;
  mode=0;
    $dumpfile("TB.vcd");

  $dumpvars(0,TB);
end
always begin
     #5clk=~clk;  

end
 
initial begin 
    slave_select = 0;
    master_data = 8'hab;

  slave_data = 8'hcd;
  #10 reset=1;


  #820 slave_select=1;
  if(~master_busy)
  master_data = 8'hab;
  if(~slave_busy2)
  slave_data = 8'hcd;
  #820 $finish;

end
endmodule






