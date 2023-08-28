// Code your design here
`timescale 1ns/1ps
module spi_master(input clk,
                  input reset,
                  input [4:0]clk_div,
                  input [1:0]mode,
                  input [7:0]i_MOSI_data,
                  input [7:0]i_MISO_data,
                  output reg sclk,
                  output reg master_busy,
                  output reg slave_busy,
                  output reg [7:0]data_master,
                  output reg [7:0]data_slave);

  reg cpol, cpha;
  reg [5:0]sclk_cnt;
  reg sclk_reg;
  reg [7:0]master_data,slave_data;
  reg [3:0]cnt;
  always@(reset)begin
     if(! reset) begin
    	cnt = 4'd8;
    	sclk_cnt = 2*clk_div; 
   		master_busy = 0;
  		slave_busy = 0; 
    	cpol = mode[1];
    	cpha = mode[0];
    	sclk = cpol; 
     end
  end
  
  always @(master_busy)
    begin
      if(~master_busy) begin
        master_data = i_MOSI_data;
         #3 master_busy = 1;
      end
    end
  always @(slave_busy)
    begin
      if(~slave_busy) begin
        slave_data = i_MISO_data;
         #3 slave_busy =  1;
      end
    end 
 
  
  // sclk logic
  always @(posedge clk)
    begin
      if(sclk_cnt==1)begin
        sclk = ~sclk;
        sclk_cnt = 2*clk_div;
      end
      else begin
        sclk_cnt = sclk_cnt-1;
      end
      if(cnt>0) begin
        master_busy = 1;
        slave_busy =1;
      end
      else begin
        //master_busy= 0;
       // slave_busy=0;
      end
    end 
    
  always @(posedge sclk) begin
      case(mode)
        2'b00: begin sample_data(); end
        2'b01: begin change_data(); end
        2'b10: begin change_data(); end
        2'b11: begin sample_data();end
        default: cnt = 0;
       endcase
    end
  always @(negedge sclk) begin
      case(mode)
        2'b00: begin change_data();end
        2'b01: begin sample_data();end
        2'b10: begin sample_data();end
        2'b11: begin change_data();end
        default: cnt = 0;
      endcase
    end
  task change_data;
  begin 
    if(cnt>0) begin
      $display("%d ",cnt); 
      
      slave_data <= slave_data << 1;
      master_data <= master_data << 1;
      slave_data[0] <= master_data[7];
      master_data[0] <= slave_data[7];
      cnt <= cnt-1;
    end
    else begin
      cnt = 4'd8;
    end
  end
endtask 
  
 task sample_data;
   begin
     if(cnt==0) begin
 
        master_busy= 0;
        slave_busy=0;
      
     end
            data_master <= master_data;
        data_slave <= slave_data;
   end
 endtask
     
endmodule

module spi_slave( input clk,
                  input sclk,
                  input reset,
                  input [1:0]mode,
                  input [7:0]i_MISO_data,
                  input MOSI,
                  output reg MISO,
                  output reg slave_busy,
                  output reg [7:0]data_slave);
  reg [7:0]slave_data;
  reg [3:0]cnt;
  always@(reset)begin
     if(! reset) begin
    	cnt = 4'd8;
  		slave_busy = 0; 
     end
  end
  
  always @(slave_busy)
    begin
      if(~slave_busy) begin
        slave_data = i_MISO_data;
         #3 slave_busy =  1;
      end
    end 
 
  
  // sclk logic
  always @(posedge clk)
    begin
      if(cnt>0) begin
        slave_busy =1;
      end
    end 
    
 /* always @(posedge sclk) begin
      case(mode)
        2'b00: begin sample_data(); end
        2'b01: begin change_data(); end
        2'b10: begin change_data(); end
        2'b11: begin sample_data();end
        default: cnt = 0;
       endcase
    end
  always @(negedge sclk) begin
      case(mode)
        2'b00: begin change_data();end
        2'b01: begin sample_data();end
        2'b10: begin sample_data();end
        2'b11: begin change_data();end
        default: cnt = 0;
      endcase
    end
 */
  task change_data;
  begin 
    if(cnt>0) begin
      $display("%d ",cnt);       
      slave_data <= slave_data >> 1;
      slave_data[7] <= MOSI;
      cnt <= cnt-1;
    end
    else begin
      cnt = 4'd8;
    end
  end
endtask 
  
 task sample_data;
   begin
     if(cnt==0) begin
 
        slave_busy=0;
      
     end
        data_slave <= slave_data;
   end
 endtask
endmodule
