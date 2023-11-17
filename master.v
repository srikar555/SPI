`timescale 1ns/1ps

module spi_master(input i_clk,
    input i_reset,
    input i_MISO,
    input [4:0]i_clk_div,
    input [1:0]i_mode,
    input [7:0]i_master_data,
    input  i_slave_select,              
    output o_MOSI,
    output o_sclk,
    output o_busy,
                  output [7:0]o_data_master,
    output o_slave_select1,
    output o_slave_select2);
  reg [7:0]r_data_master;
    reg r_busy;
    reg r_cpol, r_cpha;
    reg [5:0]r_sclk_cnt;
    reg r_sclk;
    reg [7:0]master_data;
    reg [3:0]cnt;
    assign o_busy=r_busy;
  assign o_MOSI = master_data[7];
  assign o_data_master=r_data_master;
    assign o_sclk = r_sclk;  
  assign o_slave_select1=(~i_slave_select)?0:1;
  assign o_slave_select2=(~i_slave_select)?1:0;
  always @(posedge i_clk) begin
        if(r_sclk_cnt==1) begin
            r_sclk = ~r_sclk;
            r_sclk_cnt = 2*i_clk_div;
        end
        else begin
            r_sclk_cnt = r_sclk_cnt-1;
        end
    end

    always @(posedge r_sclk, negedge i_reset) begin
        if(i_reset==0) begin
            cnt <= 4'd8;
            r_sclk_cnt <= 2*i_clk_div;
            r_busy <= 0;
            r_cpol <= i_mode[1];
            r_cpha <= i_mode[0];
            r_sclk <= r_cpol;
            master_data<=0;
            r_data_master<=0;
        end
        else begin
            if(i_reset==1 && r_busy==0) begin
                master_data=i_master_data;
            end
            else begin
                case(i_mode)
                    2'b00: begin sample_data(); end
                    2'b01: begin change_data(); end
                    2'b10: begin change_data(); end
                    2'b11: begin sample_data();end
                    default: cnt = 0;
                endcase
            end
        end
    end
    always @(negedge r_sclk,negedge i_reset) begin
        if(i_reset==0) begin
        cnt = 4'd8;
        r_sclk_cnt = 2*i_clk_div;
        r_busy = 0;
        r_cpol = i_mode[1];
        r_cpha = i_mode[0];
        r_sclk = r_cpol;
        master_data=0;
        end
        else begin
        if(i_reset==1 && r_busy==0) begin
        master_data=i_master_data;
        r_busy=1;
        end
        else begin
        case(i_mode)
        2'b00: begin change_data();end
        2'b01: begin sample_data();end
        2'b10: begin sample_data();end
        2'b11: begin change_data();end
        default: cnt = 0;
        endcase
        end
        end
    end
    task change_data; 
      begin
    if(cnt>0) begin
      master_data <= master_data << 1;
      master_data[0] <= i_MISO;  
    cnt <= cnt-1;
    end
    else begin
    cnt = 4'd8;
    r_busy= 0;
    end
      end
    endtask
    task sample_data;
      r_data_master <= master_data;
    endtask
endmodule







module spi_slave( input i_sclk,
    input i_reset,
    input [1:0]i_mode,
    input [7:0]i_slave_data,             
    input i_MOSI,
    input i_slave_select,             
    output wire o_busy,
    output  wire o_MISO,
    output wire [7:0]o_data_slave
);
  reg [7:0]r_data_slave;
    reg r_busy;
    reg r_invalid_mode;
    reg [7:0]r_slave_data;
    reg [3:0]cnt;
  
    always @(posedge i_sclk, negedge i_reset) begin
      if(i_slave_select==1) begin
            cnt <= 4'd8;
            r_busy <= 0;
            r_slave_data<=0;
            r_invalid_mode<=0;
            r_data_slave=0;
      end
      else begin
        if(i_reset==0) begin
            cnt <= 4'd8;
            r_busy <= 0;
            r_slave_data<=0;
          r_invalid_mode<=0;
                      r_data_slave=0;

        end
        else begin
          if(i_reset==1 && r_busy==0) begin
                r_slave_data=i_slave_data;
            end
            else begin

                case(i_mode)
                    2'b00: begin sample_data(); end
                    2'b01: begin change_data(); end
                    2'b10: begin change_data(); end
                    2'b11: begin sample_data();end
                    default: r_invalid_mode = 1;
                endcase

             end
        end
      end
    end
    always @(negedge i_sclk,negedge i_reset) begin
     if(i_slave_select==1) begin
           cnt <= 4'd8;
            r_busy <= 0;
            r_slave_data<=0;
          r_invalid_mode<=0;
       r_data_slave=0;
      end
      else begin
        if(i_reset==0) begin
            r_busy = 0;
            r_slave_data=0;
        end
        else begin

          if(i_reset==1 && r_busy==0) begin
                r_slave_data=i_slave_data;
                r_busy=1;
            end
            else begin
                    case(i_mode)
                    2'b00: begin change_data();end
                    2'b01: begin sample_data();end
                    2'b10: begin sample_data();end
                    2'b11: begin change_data();end
                    default: r_invalid_mode = 1;
                    endcase

            end
        end
      end
    end
  assign o_data_slave=r_data_slave;
    assign o_busy=r_busy;
    assign o_MISO = r_slave_data[7];
    task change_data; begin

    if(cnt>0) begin
            r_slave_data = r_slave_data << 1;
            r_slave_data[0] = i_MOSI;
    cnt <= cnt-1;
    end
    else begin
    cnt = 4'd8;
    r_busy= 0;
    end
        end
      
    endtask

    task sample_data;
        r_data_slave <= r_slave_data;
    endtask
endmodule



