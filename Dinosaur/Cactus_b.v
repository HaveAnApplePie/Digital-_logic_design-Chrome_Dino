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
module Cactus_b(					 //�������� big cactus
	 input wire clk_ip,			 //��IP���õ�ʱ���źţ�Ƶ�ʸ��ߣ�clk_div[1]
	 input wire clk,				 //������ǰ�ƶ�һ�е�ʱ���ź�
	 input wire start,			 //��ʼ�ź�,Ϊһ��������  �ӵ�������֮��ʼ���ͼ��
	 input wire rdn,            // read pixel RAM (active_low)11
	 input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	 input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	 output reg [11:0] dout,	 //�������bbbb_gggg_rrrr 
	 output reg finish			 //����ź�
    );
	 parameter	
		HEIGHT  	   = 68,			 //ͼ��߶�
		LENGTH      = 34,			 //ͼ�񳤶�
		COLNUM      = 640,	    //������
		ROW_HIGHEST = 300;	    //��ģ�����ڵ���ߵ���������0��ʼ

	//���������IP�˴���
	 wire [11:0]data;  							//ÿ��Ϊ12λ����
	 wire [15:0]col,row;
	 wire [15:0]addr;								//��Ӧ��       ||||||||||�� ��||||||||||      ��λ��
														//            ||		 ||������||		  ||
														//				  |||||||||| �� ||||||||||
	 initial begin
		count <= LENGTH+COLNUM;					//��֤һ��ʼfinishһֱΪ1���Ӷ����һֱΪ��ɫ
	 end

	
	Cactus_b_ip CACTUS(clk_ip,{addr+1'b1},data);	//ȡ������ֵ����ʱһ��ʱ������clk_ip��Ҫ��Ҫ��address+1������
	
	
	reg [11: 0]count;				 //��ʼ�е�λ��
	always @(posedge clk or posedge start) begin
		if(start)					 //start��0��Ϊ1ʱ,��ʼ���ͼ��
			count <= 0;
		else if(count <= 12'hfff)
			count <= count + 1'b1;
			
		
	end
	
/*	assign col   = HEIGHT - 1 - (row_addr-(ROW_HIGHEST-HEIGHT+1));	//��Ӧ�ļ������
	assign row   = (count+col_addr-COLNUM);								//��Ӧ�ļ������
	assign addr	 =	row*LENGTH+col;					
*/
	assign addr	 =	(row_addr-(ROW_HIGHEST-HEIGHT+1))*LENGTH+			//��Ӧ�ļ������
			          count+col_addr-COLNUM ;						      //��Ӧ�ļ������
						 
	always@(*)begin
		
		if(count>=LENGTH+COLNUM)	 //����Ѿ��Ƴ��������finish�ź�
			finish <= 1;
		else
			finish <= 0;
	end
	
	
	always @(*) begin
		if(!rdn)begin  //�������
			if(!finish)begin	//δ������
				if ( ((count+col_addr) >= COLNUM)&& 				//��߽� ��
					((count+col_addr) < (COLNUM+LENGTH))&&	   	//�ұ߽� ��
					(row_addr <= ROW_HIGHEST) &&						//�±߽� ��
					(row_addr > (ROW_HIGHEST-HEIGHT)))	begin		//�ϱ߽� ��			
					dout <= data;		    							   //�ض���ɫ
					//dout <= 12'h555;
				end
				else begin
					dout <=  12'hfff;    //��ɫ
				end
			end
		end
		else begin	//������
				dout <=  12'hfff;    //��ɫ
		end
	end



endmodule
