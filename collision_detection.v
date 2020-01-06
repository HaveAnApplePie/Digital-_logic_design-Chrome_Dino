`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:50:02 01/06/2020 
// Design Name: 
// Module Name:    collision_detection 
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
module collision_detection(
	input wire rst,
	input wire [11:0]dino,		//����
	input wire [11:0]obstacle, //�ϰ���
	input wire rdn,            // read pixel RAM (active_low)11
	input wire [9:0] col_addr, // pixel ram row address, 480 (512) lines
	input wire [8:0] row_addr, // pixel ram col address, 640 (1024) pixels
	output reg crash				//�Ƿ���ײ
    );

	 parameter	
		LEFT      = 30,	    //�������
		RIGHT 	 = 93;	    //�����Ҳ�
	
	initial begin
		crash <= 0;
	end
	
	always@(*)begin
		if(rst)begin			//��λ
			crash <= 0;
		end
		else if(!rdn)begin
			if(col_addr<=RIGHT && col_addr>=LEFT)begin
				if(dino == 12'hfff || obstacle == 12'hfff)	//�������ϰ���������һ��Ϊ�հױ�ʾΪ��ײ
					crash <= 0;
				else
					crash <= 1;											//��ײ
			end
		end
	end

endmodule
