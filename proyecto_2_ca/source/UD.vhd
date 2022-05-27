library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--Mux 4 a 1
entity UD is
    Port ( 	
		-- Registro Rs en la etapa ID.
		Reg_Rs_ID       : in  STD_LOGIC_VECTOR (4 downto 0);
		-- Registro Rt en la etapa ID.
		Reg_Rt_ID	    : in  STD_LOGIC_VECTOR (4 downto 0);

		-- Info sobre la instruccionn en EX (destino, si lee de memoria y si 
		-- escribe en registro).
		MemRead_EX	    : in  std_logic;
		RegWrite_EX	    : in  std_logic;
		RW_EX		    : in  STD_LOGIC_VECTOR (4 downto 0);

		-- Info sobre instruccion en Mem (destino y si escribe en registro).
		RegWrite_Mem    : in  std_logic;
		RW_Mem		    : in  STD_LOGIC_VECTOR (4 downto 0);
		IR_op_code	    : in  STD_LOGIC_VECTOR (5 downto 0); -- Codigo de operacion de la instruccion en IEEE
        PCSrc		    : in  std_logic; -- 1 cuando se produce un salto 0 en caso contrario
		FP_add_EX	    : in  std_logic; -- Indica si la instruccion en EX es un ADDFP
		FP_done		    : in  std_logic; -- Informa cuando la operacion de suma en FP ha terminado
		RegWrite_FP_EX  : in  std_logic; -- Indica que la instruccion en EX escribe en el banco de registros de FP
		RW_FP_EX        : in  STD_LOGIC_VECTOR (4 downto 0); -- Indica en que registro del banco FP escribe
		RegWrite_FP_MEM : in  std_logic; -- Indica que la instruccion en EX escribe en el banco de registros de FP
		RW_FP_MEM       : in  STD_LOGIC_VECTOR (4 downto 0); -- Indica en que registro del banco FP escribe.
		Mem_Ready	    : in STD_LOGIC; -- Indica que la operacion en memoria puede terminar en el ciclo actual.
		Kill_IF		    : out STD_LOGIC; -- Indica que la instruccion en IF no debe ejecutarse (fallo en la prediccion de salto tomado)
		Parar_ID	    : out STD_LOGIC; -- Indica que las etapas ID y previas deben parar.
		Parar_EX_FP	    : out STD_LOGIC; -- Indica que las etapas EX y previas deben parar.
		Parar_MEM		: out STD_LOGIC -- Indica que las etapas MEM y previas deben parar.
	);
end UD;

Architecture Behavioral of UD is
signal dep_rs_EX, dep_rs_Mem, dep_rt_EX, dep_rt_Mem, ld_uso_rs, ld_uso_rt, BEQ_rs, BEQ_rt : std_logic;
signal FP_inst, parar_ID_FP, parar_EX_FP_internal, riesgo_rs_FP, riesgo_rt_FP, dep_rs_EX_FP, dep_rt_EX_FP, dep_rs_MEM_FP, dep_rt_MEM_FP : std_logic;
CONSTANT NOP   : STD_LOGIC_VECTOR (5 downto 0) := "000000";
CONSTANT LW    : STD_LOGIC_VECTOR (5 downto 0) := "000010";
CONSTANT BEQ   : STD_LOGIC_VECTOR (5 downto 0) := "000100";
CONSTANT ADDFP : STD_LOGIC_VECTOR (5 downto 0) := "100001";
CONSTANT LWFP  : STD_LOGIC_VECTOR (5 downto 0) := "100010";
CONSTANT SWFP  : STD_LOGIC_VECTOR (5 downto 0) := "100011";
begin
	-- Dependencia de datos entre instrucciones INT.
	dep_rs_EX  <= '1' when (Reg_Rs_ID = RW_EX  and RegWrite_EX  = '1') else '0';
	dep_rt_EX  <= '1' when (Reg_Rt_ID = RW_EX  and RegWrite_EX  = '1') else '0';
	dep_rs_Mem <= '1' when (Reg_Rs_ID = RW_Mem and RegWrite_Mem = '1') else '0';
	dep_rt_Mem <= '1' when (Reg_Rt_ID = RW_Mem and RegWrite_Mem = '1') else '0';

	-- Dependencia de datos entre instrucciones FP.
	-- Solo existe dependencia con ADDFP en el registro Rs, el SWFP consume de Rt y el LWFP no consume.
	dep_rs_EX_FP  <= '1' when (RW_FP_EX  = Reg_Rs_ID and RegWrite_FP_EX  = '1' and IR_op_code = ADDFP) else '0';
	dep_rs_MEM_FP <= '1' when (RW_FP_MEM = Reg_Rs_ID and RegWrite_FP_MEM = '1' and IR_op_code = ADDFP) else '0';
	-- Solo existe dependencia con ADDFP y SWFP en registro Rt, el LWFP no consume.
	dep_rt_EX_FP  <= '1' when (RW_FP_EX  = Reg_Rt_ID and RegWrite_FP_EX  = '1' and (IR_op_code = ADDFP or IR_op_code = SWFP)) else '0';
	dep_rt_MEM_FP <= '1' when (RW_FP_MEM = Reg_Rt_ID and RegWrite_FP_MEM = '1' and (IR_op_code = ADDFP or IR_op_code = SWFP)) else '0';

	-- Riesgos load-uso.(Modificado)
	FP_inst <= '1' when (IR_op_code = ADDFP or IR_op_code = LWFP or IR_op_code = SWFP) else '0';
	-- No existe riesgo con NOP ni ADDFP aunque ambas coincidan en registro.
	ld_uso_rs  <= '1' when (Reg_Rs_ID = RW_EX and MemRead_EX = '1' and IR_op_code /= NOP and IR_op_code /= ADDFP and RegWrite_EX = '1') else '0';
	-- No existe riesgo con NOP ni ninguna instruccion FP aunque coincidan en registro.
	ld_uso_rt  <= '1' when (Reg_Rt_ID = RW_EX and MemRead_EX = '1' and IR_op_code /= NOP and FP_inst = '0' and RegWrite_EX = '1') else '0';

	-- Dependencia de datos BEQ.
	BEQ_rs <= '1' when ((dep_rs_EX = '1' or dep_rs_MEM = '1') and IR_op_code = BEQ) else '0';
	BEQ_rt <= '1' when ((dep_rt_EX = '1' or dep_rt_MEM = '1') and IR_op_code = BEQ) else '0';

	-- Riesgos FP.
	riesgo_rs_FP <= '1' when (dep_rs_EX_FP = '1') or (dep_rs_MEM_FP = '1') else '0';
	riesgo_rt_FP <= '1' when (dep_rt_EX_FP = '1') or (dep_rt_MEM_FP = '1') else '0';

	-- Riesgo ld-uso o dependencia de datos de beq/fp.
	parar_ID_FP <= '1' when (riesgo_rs_FP = '1' or riesgo_rt_FP = '1') else '0';
	Parar_ID <= '1' when (ld_uso_rs = '1' or ld_uso_rt = '1' or BEQ_rs = '1' or BEQ_rt = '1' or parar_ID_FP = '1') else '0';
	-- Riesgo de control.
	Kill_IF  <= '1' when (PCSrc = '1') else '0';
	-- Riesgo estructural.
	parar_EX_FP_internal <= '1' when (FP_add_EX = '1' and FP_done = '0') else '0';
	Parar_EX_FP <= '1' when (parar_EX_FP_internal = '1') else '0';
	Parar_Mem <= '1' when (Mem_Ready = '0') else  '0';

end Behavioral;


