`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:55:21 12/25/2019 
// Design Name: 
// Module Name:    Top 
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
module Top(
	input clk,
	input rst,
	input[15:0] SW,
	output VS,
	output HS,
	output[3:0] R, G, B,
	inout[4:0] BTN_X,
	inout[3:0] BTN_Y,
	output SEGLED_CLK,
	output SEGLED_CLR,
	output SEGLED_DO,
	output SEGLED_PEN,
	input ps2_clk,
	input ps2_data
    );
	 
	wire[31:0] clk_div;
	clkdiv clk0(.clk(clk), .rst(1'b0), .clkdiv(clk_div));	//ʱ�ӷ�Ƶ��
	
	wire[15:0] SW_OK;
	AntiJitter #(4) a0[15:0](.clk(clk_div[15]), .I(SW), .O(SW_OK));	//SW����
	
	wire[4:0] keyCode;
	wire keyReady;
	Keypad k0(.clk(clk_div[15]), .keyX(BTN_Y), .keyY(BTN_X), .keyCode(keyCode), .ready(keyReady));	//BTN����ģʽ����
	
	reg[11:0] vga_data;
	wire[9:0] col_addr;
	wire[8:0] row_addr;
	vgac vga(.vga_clk(clk_div[1]), .clrn(SW_OK[0]), .d_in(vga_data), .row_addr(row_addr), .col_addr(col_addr), .r(R), .g(G), .b(B), .hs(HS), .vs(VS));	//VGA����

	wire[9:0] ps2_dataout;
	wire ps2_ready;
	PS2_keyboard ps2(.clk(clk), .rst(SW_OK[15]), .ps2_clk(ps2_clk), 
							.ps2_data(ps2_data), .data_out(ps2_dataout), .ready(ps2_ready));
	
	reg[18:0] Dino0;	//�� ��ͼ��ip�˵�ַ
	//wire[11:0] spob;	//����ͼ��ip�������4*3 rgb
	reg[9:0] Dino0_X, Dino1_X;	//����λ��X���꣨���Ͻǣ�
	initial Dino0_X <= 10'd30;
	initial Dino1_X <= 10'd30;
	reg[8:0] Dino0_Y, Dino1_Y;	//����λ��Y���꣨���Ͻǣ�
	initial Dino0_Y <= 9'd146;
	initial Dino1_Y <= 9'd386;
	//Dinosaur64 Dino(.addra(Dino0), .douta(spob), .clka(clk_div[1]));	//����ģ��ip��
	wire[11:0] spobDinoL;	//����̧��ͼ��
	DinoL DinoL(.addra(Dino0), .douta(spobDinoL), .clka(clk_div[1]));
	wire[11:0] spobDinoR;	//����̧��ͼ��
	DinoR DinoR(.addra(Dino0), .douta(spobDinoR), .clka(clk_div[1]));
	
	wire[11:0] Obstacle_out;	//�ϰ���ͼ��ip�������4*3 rgb
	Obstacle_layer OLAYER(
		.clk_div(clk_div), 
		.col_addr(col_addr), 
		.row_addr(row_addr - 8'd150), 
		.dout(Obstacle_out)
		);
		
	wire[11:0] Obstacle_out1;	//�ϰ���ͼ��ip�������4*3 rgb
	Obstacle_layer OLAYER1(
		.clk_div(clk_div), 
		.col_addr(col_addr), 
		.row_addr(row_addr + 8'd90), 
		.dout(Obstacle_out1)
		);
	
	reg[1:0] crash;
	initial crash = 2'b0;
	//collision_detection co0(.rst(1'b0), .dino(spobDonoL), .obstacle(Obstacle_out), .rdn(1'b0), .col_addr(col_addr), .row_addr(row_addr), .crash(crash0));
	//collision_detection co1(.rst(1'b0), .dino(spobDinoL), .obstacle(Obstacle_out1), .rdn(1'b0), .col_addr(col_addr), .row_addr(row_addr), .crash(crash1));

	
			
	wire [31:0] segData;
	wire [3:0] sout;
	ScoreCounter Score0(.rst(SW_OK[15]), .clk_div(clk_div), .data(segData), .crash(crash));
	Seg7Device segDevice(.clkIO(clk_div[3]), .clkScan(clk_div[15:14]), .clkBlink(clk_div[25]),
									.data(segData), .point(8'h0), .LES(8'h0),
									.sout(sout));
	assign SEGLED_CLK = sout[3];
	assign SEGLED_DO = sout[2];
	assign SEGLED_PEN = sout[1];
	assign SEGLED_CLR = sout[0];
	
	reg wasReady;
	reg isJump, isJump0;	//�Ƿ�ı������λ��
	reg[7:0] jumpTime, jumpTime0;	//��Ծʱ�������
	initial isJump <= 1'b0;
	initial isJump0 <= 1'b0;
	initial jumpTime <= 8'd128;
	initial jumpTime0 <= 8'd128;
	reg DinoLeg, DinoLeg0;
	initial DinoLeg <= 1'b0;
	initial DinoLeg0 <= 1'b1;
	always@(posedge clk)begin
		
		if(SW_OK[15])begin
			crash <= 2'b0;
		end
	
		wasReady <= keyReady;
		if(!wasReady && keyReady)begin
			case(keyCode)
				5'h10: if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end	//��ʼ��Ծ��������������
				5'h12: if(jumpTime0 >= 8'd64)begin isJump0 <= 1'b1; jumpTime0 <= 8'd0; end
				default:;
			endcase
		end
		
		if(ps2_dataout[7:0]==8'h12 && ps2_ready)//��shift
			if(jumpTime >= 8'd64)begin isJump <= 1'b1; jumpTime <= 8'd0; end
		if(ps2_dataout[7:0]==8'h59 && ps2_ready)//��shiift
			if(jumpTime0 >= 8'd64)begin isJump0 <= 1'b1; jumpTime0 <= 8'd0; end
		if(ps2_dataout[7:0]==8'h29 && ps2_ready)//���¿�ʼ
			begin crash <= 2'b0; end
			
		if(clk_div[23] && DinoLeg)begin
			DinoLeg <= 1'b0;
			DinoLeg0 <= 1'b1;
		end
		else if(!clk_div[23] && !DinoLeg)begin
			DinoLeg <= 1'b1;
			DinoLeg0 <= 1'b0;
		end
		
		if(col_addr >= Dino0_X && col_addr <= Dino0_X + 63 && row_addr >= Dino0_Y && row_addr <= Dino0_Y + 63 && !crash[0])begin //��ɨ�赽����Ӧ�ó��ֵ�λ��ʱ
			Dino0 <= (col_addr-Dino0_X)*64 + (row_addr-Dino0_Y);	//����Ҫ��ȡ���ڴ��ַ����ip��
			if(Obstacle_out1 != 12'hfff)
				crash[0] <= 1;
			//else
			//	crash[0] <= 0;
			if(DinoLeg)
				vga_data <= spobDinoL & Obstacle_out1;	//�������VGA
			else
				vga_data <= spobDinoR & Obstacle_out1;
		end
		else if(col_addr >= Dino1_X && col_addr <= Dino1_X + 63 && row_addr >= Dino1_Y && row_addr <= Dino1_Y + 63 && !crash[1])begin
			Dino0 <= (col_addr-Dino1_X)*64 + (row_addr-Dino1_Y);	//����Ҫ��ȡ���ڴ��ַ����ip��
			if(Obstacle_out != 12'hfff)
				crash[1] <= 1;
			//else
			//	crash[1] <= 0;
			if(DinoLeg0)
				vga_data <= spobDinoL & Obstacle_out;	//�������VGA
			else
				vga_data <= spobDinoR & Obstacle_out;
		end
		else if(row_addr == 9'd211 || row_addr == 9'd451)begin
			vga_data <= 12'h000;
		end
		else begin
			if(crash[0] && !crash[1]) vga_data <= Obstacle_out;
			else if(!crash[0] && crash[1]) vga_data <= Obstacle_out1;
			else if(!crash[0] && !crash[1])
				vga_data <= Obstacle_out & Obstacle_out1;	//������Ⱦ�ϰ���
			else
				vga_data <= 12'hfff;
		end
		
		//ע������/�½������÷������ٶȽ��У�ģ������
		//��Ծ�����׶ο�ʼ
		if(clk_div[19] && isJump && jumpTime < 8'd10)begin
			Dino0_Y <= Dino0_Y - 10'd6;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd10 && jumpTime < 8'd20)begin
			Dino0_Y <= Dino0_Y - 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd20 && jumpTime < 8'd32)begin
			Dino0_Y <= Dino0_Y - 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		//��Ծ�����׶ν���
		else if(!clk_div[19] && !isJump && jumpTime < 8'd64) begin
			isJump <= 1;
		end
		//��Ծ�½��׶ο�ʼ
		if(clk_div[19] && isJump && jumpTime >= 8'd32 && jumpTime < 8'd44)begin
			Dino0_Y <= Dino0_Y + 10'd2;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd44 && jumpTime < 8'd54)begin
			Dino0_Y <= Dino0_Y + 10'd4;
			jumpTime <= jumpTime + 8'd1;
			isJump <= 0;
		end
		if(clk_div[19] && isJump && jumpTime >= 8'd54 && jumpTime < 8'd64)begin
			Dino0_Y <= Dino0_Y + 10'd6;
			jumpTime <= jumpTime + 8'd1;
			isJump <=0;
		end
		//��Ծ�½��׶ν���
		
		
		//ע������/�½������÷������ٶȽ��У�ģ������
		//��Ծ�����׶ο�ʼ
		if(clk_div[19] && isJump0 && jumpTime0 < 8'd10)begin
			Dino1_Y <= Dino1_Y - 10'd6;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd10 && jumpTime0 < 8'd20)begin
			Dino1_Y <= Dino1_Y - 10'd4;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd20 && jumpTime0 < 8'd32)begin
			Dino1_Y <= Dino1_Y - 10'd2;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		//��Ծ�����׶ν���
		else if(!clk_div[19] && !isJump0 && jumpTime0 < 8'd64) begin
			isJump0 <= 1;
		end
		//��Ծ�½��׶ο�ʼ
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd32 && jumpTime0 < 8'd44)begin
			Dino1_Y <= Dino1_Y + 10'd2;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <= 0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd44 && jumpTime0 < 8'd54)begin
			Dino1_Y <= Dino1_Y + 10'd4;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <= 0;
		end
		if(clk_div[19] && isJump0 && jumpTime0 >= 8'd54 && jumpTime0 < 8'd64)begin
			Dino1_Y <= Dino1_Y + 10'd6;
			jumpTime0 <= jumpTime0 + 8'd1;
			isJump0 <=0;
		end
		//��Ծ�½��׶ν���
		
	end
	
	
	
endmodule
