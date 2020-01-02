`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:33 12/30/2019 
// Design Name: 
// Module Name:    Cactus_s 
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
module Cactus_s(					 //С������ small cactus
	 input wire clk_ip,			 //��IP���õ�ʱ���źţ�Ƶ�ʸ��ߣ�clk_div[1]
	 input wire clk,				 //������ǰ�ƶ�һ�е�ʱ���ź�
	 input wire start,			 //��ʼ�ź�,Ϊһ��������  �ӵ�������֮��ʼ���ͼ��
	 input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	 input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	 output reg [11:0] dout,	 //�������bbbb_gggg_rrrr 
	 output reg finish			 //����ź�
    );
	 parameter	
		HEIGHT  	   = 10,			 //ͼ��߶�
		LENGTH      = 8,			 //ͼ�񳤶�
		COLNUM      = 640,	    //������
		ROW_HIGHEST = 130;	    //��ģ�����ڵ���ߵ���������0��ʼ

	//���������IP�˴���
	 reg [11:0]data;  							//ÿ��Ϊ12λ����
	 reg [15:0]addr;								//��Ӧ��       ||||||||||�� ��||||||||||      ��λ��
														//            ||		 ||������||		  ||
														//				  |||||||||| �� ||||||||||
	 initial begin
		addr  <= 0;
		count <= LENGTH+COLNUM;					//��֤һ��ʼfinishһֱΪ1���Ӷ����һֱΪ��ɫ
	 end
	//////
	
	Cactus_s_ip CACTUS(clk_ip,addr,data);
	
	
	reg [11: 0]count;				 //��ʼ�е�λ��
	always @(posedge clk or posedge start) begin
		if(start)					 //start��0��Ϊ1ʱ,��ʼ���ͼ��
			count <= 0;
		else
			count <= count + 1'b1;
	end
	
//	assign addr = row_addr*COLNUM+col_addr+count; 	//���з�ͼ�����ص��ֵʱ
	
	

	always@(*)begin
		addr	 <=	(row_addr-(ROW_HIGHEST-HEIGHT+1))*LENGTH+			//��Ӧ�ļ������
			          count+col_addr-COLNUM;						         //��Ӧ�ļ������
		
		if(count>=LENGTH+COLNUM)	 //����Ѿ��Ƴ��������finish�ź�
			finish <= 1;
		else
			finish <= 0;
	end
	
	
	always @(*) begin
		if(!finish)begin	//δ������
			if ((count+col_addr) >= COLNUM && 				//��߽� ��
				(count+col_addr) < (COLNUM+LENGTH) &&	   //�ұ߽� ��
				row_addr <= ROW_HIGHEST &&						//�±߽� ��
				row_addr > (ROW_HIGHEST-HEIGHT))				//�ϱ߽� ��
			
				dout = data;		    							//�ض���ɫ
		end
		else	//������
				dout =  12'hfff;    //��ɫ
	end



endmodule
