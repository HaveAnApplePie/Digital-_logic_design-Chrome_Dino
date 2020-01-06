`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:37:42 01/02/2020 
// Design Name: 
// Module Name:    Obstacle_layer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Obstacle_layer(			 //�ϰ���ͼ��
	 input wire [31:0]clk_div,	 //����ʱ���ź�  �����ɵ�
										 //clk_div[1] ÿ������ʱ���IP����ȡ����ַ
										 //clk_div[23] ÿ������ʱ������һ���ϰ���
										 //clk_div[19] �ϰ���ÿ������ʱ��ǰ��һ��
	 input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	 input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	 output wire [11:0] dout	    //�ϰ�����������bbbb_gggg_rrrr     
	 );

/*
	wire[11:0] dout;	//�ϰ���ͼ��ip�������4*3 rgb   ʹ�÷���
	Obstacle_layer OLAYER(
		.clk_div(clk_div), 
		.col_addr(col_addr), 
		.row_addr(row_addr), 
		.dout(dout)
		);
*/	


	 parameter	
		min  	   = 0,			 //��Сͼ����
		max      = 5;			 //���ͼ����

	 reg  [max:0]start;		 //��ʼ�źţ��Բ�ͬ�ϰ����ƶ��Ŀ�ʼ�ź�
	 wire [max:0]finish;	 	 //�����źţ��ϰ����ƶ�����
	 wire [11:0]dout_c_s;
	//���������ģ��
	integer seed;

	reg [7:0] rand_num;	//[min,max]��ֵ ��ʱ��[0��5]
	
	initial begin 
		seed = 0;
		start <= 5'b0;
	end


	always @(posedge clk_div[23]) begin   //���
		rand_num <= min + {$random(seed)}%(max-min+1);	//��������ź�
		start <= 5'b0;
		if(finish[rand_num]==0)//�����ϰ����Ѿ�����Ļ���У���������һ���ϰ���
			rand_num <= min+(rand_num+1)%(max-min+1);
		case(rand_num)
			1:begin
				start[0] <= 1;   //�����ϰ���0  С������
			end
			default:;
		endcase
	end

	
   //С������ģ��
   Cactus_s  layer1(.clk_ip(clk_div[1]),.clk(clk_div[19]),.start(start[0]),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_c_s),.finish(finish[0]));
	
	
	//dout
		assign dout = dout_c_s;  //����ͬ��dout������



endmodule
