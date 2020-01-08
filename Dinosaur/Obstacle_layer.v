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
	 input wire rdn,            // read pixel RAM (active_low)
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
	 wire [11:0]dout_0,dout_1,dout_2,dout_3,dout_4,dout_5;
	//���������ģ��
	integer seed;
	reg [2:0] i;
	reg [7:0] rand_num;	//[min,max]��ֵ ��ʱ��[0��5]
	
	initial begin 

		seed = 0;
		start <= 5'b0;
	end


	always @(posedge clk_div[27]) begin   //���
		rand_num <= min + {$random(seed)}%(max-min+1);	//��������ź�
		start <= 6'b0;
		
//		for(i=0;i<3 && finish[rand_num]==0;i=i+1)begin								//��forһ������ѭ������ 5��		
//			rand_num <= min+(rand_num+1)%(max-min+1); //�����ϰ����Ѿ�����Ļ���У���������һ���ϰ���
//		end

		if(finish[rand_num]==0)
			rand_num <= min+(rand_num+1)%(max-min+1); 
		
		case(rand_num)
			0:begin
				if(finish[0])	//��һ���Ѿ�����
					start[0] <= 1;   //�����ϰ���0  С������
			end
			1:begin
				if(finish[1])
					start[1] <= 1;   //�����ϰ���1  ��������
			end
			2:begin
				if(finish[2])	//��һ���Ѿ�����
					start[2] <= 1;   //�����ϰ���2  С������
			end
			3:begin
				if(finish[3])	//��һ���Ѿ�����
					start[3] <= 1;   //�����ϰ���3  ��������
			end
			4:begin
				if(finish[4])	//��һ���Ѿ�����
					start[4] <= 1;   //�����ϰ���4  С������
			end
			5:begin
				if(finish[5])	//��һ���Ѿ�����
					start[5] <= 1;   //�����ϰ���5  ����		
			end
			default:;
		endcase
	end

	
   //������ģ��
   Cactus_s  layer0(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[0]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_0),.finish(finish[0]));
	Cactus_b  layer1(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[1]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_1),.finish(finish[1]));
   Cactus_s  layer2(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[2]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_2),.finish(finish[2]));	
	Cactus_b  layer3(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[3]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_3),.finish(finish[3]));
	Cactus_s  layer4(.clk_ip(clk_div[1]),.clk(clk_div[17]),.start(start[4]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_4),.finish(finish[4]));
	
	//����ģ��
	Birds     layer5(.clk_ip(clk_div[1]),.clk_birds(clk_div[24]),.clk(clk_div[18]),.start(start[5]),.rdn(rdn),.col_addr(col_addr),.row_addr(row_addr),.dout(dout_5),.finish(finish[5]));
	
	//dout
		assign dout = dout_0 & dout_1 & dout_2 & dout_3 & dout_4 & dout_5;  //����ͬ��dout������



endmodule
