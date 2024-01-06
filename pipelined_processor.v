module pipe_lined_proc;

input 
output

32Bmux_2to1 stage_1mux(.selection(),.in1(pcPlus4),.in2(pc_br),.out(next_insAdd));
WORDR   PC(.clk(clk),.in(next_insAdd),.out(current_insAdd));
adder_cla pcPlus4ADDR(.cin(0),.s(0),.in1(current_insAdd),.in2(4),.sum(pcPlus4),.cout(),.ov());
////rom////
IF_ID_REG IF_ID(.inst(inst),.inst_(inst_),.pcPlus4(pcPlus4),.pcPlus4_(pcPlus4_));
reg_file RF(.clk(clk),.write(RegWrite),.dstReg(dst_WB),.data(WB),.readsrc1(inst_[21:25]),.readdata1(readdata1),.readsrc2(inst_[16:20]),.readdata2(readdata2));
imm_gen sign_ext(.imm(inst_[0:15]),.immse(immse));
control_unit main_cotrol(.clk(clk),.ir(inst_[31:26]),.regdest(regdest),.alusrc(alusrc),.branch(branch),.memread(memread),.memwrite(memwrite),.regwrite(regwrite),.memtoreg(memtoreg),.Jump(Jump));

ID_IE_REG stage2_3
(
       .ir_         (ir_)           ,.ir        (inst_[31:26])  ,
       .regdest_    (regdest_)      ,.regdest   (regdest)       ,
       .alusrc_     (alusrc_)       ,.alusrc    (alusrc)        ,
       .branch_     (branch_)       ,.branch    (branch)        ,
       .memread_    (memread_)      ,.memread   (memread)       ,
       .memwrite_   (memwrite_)     ,.memwrite  (memwrite)      ,
       .regwrite_   (regwrite_)     ,.regwrite  (regwrite)      ,
       .memtoreg_   (memtoreg_)     ,.memtoreg  (memtoreg)      ,
       .Jump_       (Jump_)         ,.Jump      (Jump)          ,
       .inst11_15_  (inst11_15_)    ,.inst11_15 (inst11_15)     ,
       .inst16_20_  (inst16_20_)    ,.inst16_20 (inst16_20)     ,
       .immse_      (immse_)        ,.immse     (immse)         ,
       .readdata1_  (readdata1_)    ,.readdata1 (readdata1)     ,
       .readdata2_  (readdata2_)    ,.readdata2 (readdata2)     ,
       .pcPlus4_    (pcPlus4_2)     ,.pcPlus4   (pcPlus4_)      ,
       .rfmt_       (rfmt_)         ,.rfmt      (inst_[5:0])
);



endmodule


//general world registrer (32-bit reg update at posedge clk)
module WORDR;

input clk;
input in[31:0];
output out[31:0];

always @ (posedge clk) begin 

    out<=in;
    end

endmodule 


module 32Bmux_2to1;
    input selection;
    input [31:0]in1,in2;
    output [31:0]out;

    always @ (*) begin
        case (selection):
        1:out<=in2;
        0:out<=in1;
    end
endmodule

module IF_ID_REG;

input      [31:0]inst,pcPlus4;
output     [31:0]inst_,pcPlus4_;

    always @ (posedge clk) begin 
        inst_<=inst;
        pcPlus4_<=pcPlus4;
    end

endmodule 


//double pumped mips register file (read at posedge and write at negedge)
module reg_file;

input clk;
input write;

input [4:0]readsrc1,readsrc2,dstReg;
input [31:0]readdata1,readdata2,data;

input [31:0] regfile [0:31];

    always @ (posedge clk) begin 
        readdata1<= (!readsrc1)?(0):(regfile[readsrc1]);
        readdata2<= (!readsrc2)?(0):(regfile[readsrc2]);
    end

    always @ (negedge clk) begin 
        if (write) begin
        regfile[dstReg]<= (!dstReg)?(0):(data);
        end
    end
endmodule

module ID_IE_REG;

input      [5:0]ir;
input      regdest,alusrc;
input      branch;
input      memread,memwrite,regwrite,memtoreg;
input      Jump;
input      [4:0]inst11_15,inst16_20;
input      [31:0]immse,readdata1,readdata2,pcPlus4;       
input      [5:0]rfmt; 

output      [5:0]ir_;
output      regdest_,alusrc_;
output      branch_;
output      memread_,memwrite_,regwrite_,memtoreg_;
output      Jump_;
output      [4:0]inst11_15_,inst16_20_;
output      [31:0]immse_,readdata1_,readdata2_,pcPlus4_; 
output      [5:0]rfmt_;     


    always @ (posedge clk) begin 
       ir_          =ir;
       regdest_     =regdest;
       alusrc_      =alusrc;
       branch_      =branch;
       memread_     =memread;
       memwrite_    =memwrite;
       regwrite_    =regwrite;
       memtoreg_    =memtoreg;
       Jump_        =Jump;
       inst11_15_   =inst11_15;
       inst16_20_   =inst16_20;
       immse_       =immse;
       readdata1_   =readdata1;
       readdata2_   =readdata2;
       pcPlus4_     =pcPlus4;
       rfmt_        =rfmt; 
    end

endmodule 
