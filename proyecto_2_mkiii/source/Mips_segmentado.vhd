-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Author: Departamento de AOC2, Rael Clariana (760617) y Devid Dokash (780131)
-- Description: Mips segmentado + Memoria Cache y Scratch.
-- Revision 0.03 - MD + MC + Scratch.
-------------------------------------------------------------------------------
----------------------------------- MIPS --------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MIPs_segmentado is
    Port ( 
		clk   	 : in  STD_LOGIC;
        reset 	 : in  STD_LOGIC;
		output	 : out STD_LOGIC_VECTOR(31 downto 0);
		-- NEW:
		IO_input : in  STD_LOGIC_VECTOR(31 downto 0) 
	);
end MIPs_segmentado;

architecture Behavioral of MIPs_segmentado is
component reg32 is 
	Port ( 
		Din   : in  STD_LOGIC_VECTOR(31 downto 0);
	    clk   : in  STD_LOGIC;
		reset : in  STD_LOGIC;
	    load  : in  STD_LOGIC;
	    Dout  : out STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component adder32 is
	Port ( 
		Din0 : in  STD_LOGIC_VECTOR(31 downto 0);
	    Din1 : in  STD_LOGIC_VECTOR(31 downto 0);
	    Dout : out STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component mux2_1 is
	Port (
		DIn0 : in  STD_LOGIC_VECTOR(31 downto 0);
	    DIn1 : in  STD_LOGIC_VECTOR(31 downto 0);
		ctrl : in  STD_LOGIC;
	    Dout : out STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

-- NEW: componente de memoria.
component MD_mas_MC is 
	port (
		clk 	  : in  std_logic;
		reset	  : in  std_logic; 
		ADDR 	  : in  std_logic_vector (31 downto 0);
        Din 	  : in  std_logic_vector (31 downto 0);
		WE 		  : in  std_logic;
		RE 		  : in  std_logic;
		IO_input  : in  std_logic_vector (31 downto 0);
		Mem_ready : out std_logic;
		Dout 	  : out std_logic_vector (31 downto 0)
	);
end component;

component memoriaRAM_I is 
	Port (
		clk  : in  std_logic;
		ADDR : in  std_logic_vector(31 downto 0);
        Din  : in  std_logic_vector(31 downto 0);
        WE   : in  std_logic;
		RE   : in  std_logic;
		Dout : out std_logic_vector(31 downto 0)
	);
end component;

component Banco_ID is
 	Port (
		IR_in  : in  STD_LOGIC_VECTOR(31 downto 0); -- Instruccion leida en IF
        PC4_in : in  STD_LOGIC_VECTOR(31 downto 0); -- PC+4 sumado en IF
		clk    : in  STD_LOGIC;
		reset  : in  STD_LOGIC;
        load   : in  STD_LOGIC;
        IR_ID  : out STD_LOGIC_VECTOR(31 downto 0); -- Instruccion en la etapa ID
        PC4_ID : out STD_LOGIC_VECTOR(31 downto 0)
	); -- PC+4 en la etapa ID
end component;

Component BReg
    PORT(
        clk      : IN  std_logic;
		reset    : in  STD_LOGIC;
        RA       : IN  std_logic_vector(4 downto 0);
        RB       : IN  std_logic_vector(4 downto 0);
        RW       : IN  std_logic_vector(4 downto 0);
        BusW     : IN  std_logic_vector(31 downto 0);
        RegWrite : IN  std_logic;
        BusA     : OUT std_logic_vector(31 downto 0);
        BusB     : OUT std_logic_vector(31 downto 0)
    );
END Component;

component Ext_signo is
    Port (
		inm     : in  STD_LOGIC_VECTOR(15 downto 0);
        inm_ext : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component two_bits_shifter is
    Port ( 
		Din  : in  STD_LOGIC_VECTOR(31 downto 0);
        Dout : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component UC is
	Port ( 
		IR_op_code  : in  STD_LOGIC_VECTOR(5 downto 0);
		Branch      : out STD_LOGIC;
		RegDst      : out STD_LOGIC;
		ALUSrc      : out STD_LOGIC;
		MemWrite    : out STD_LOGIC;
		MemRead     : out STD_LOGIC;
		MemtoReg    : out STD_LOGIC;
		RegWrite    : out STD_LOGIC;
		-- Señales para FP.
		FP_add	    : out STD_LOGIC; -- Indica suma en coma flotante.
		FP_mem	    : out STD_LOGIC; -- Indica que es el acceso a memoria debe usar el banco de registros FP
		RegWrite_FP : out STD_LOGIC  -- Indica que la instruccion escribe en el banco de registros FP. 
	);
end component;

-- Unidad de deteccion de riesgos
-- Completar el componente UD de los fuentes, instanciarlo y conectarlo donde se indica en la etapa ID
component UD is
	Port (   	
		Reg_Rs_ID       : in  STD_LOGIC_VECTOR(4 downto 0); --registros Rs y Rt en la etapa ID
		Reg_Rt_ID	    : in  STD_LOGIC_VECTOR(4 downto 0);
		MemRead_EX	    : in  std_logic; -- info sobre la instr en EX (destino, si lee de memoria y si escribe en registro)
		RegWrite_EX	    : in  std_logic;
		RW_EX		    : in  STD_LOGIC_VECTOR(4 downto 0);
		RegWrite_Mem    : in  std_logic; -- informacion sobre la instruccion en Mem (destino y si escribe en registro)
		RW_Mem		    : in  STD_LOGIC_VECTOR(4 downto 0);
		IR_op_code	    : in  STD_LOGIC_VECTOR(5 downto 0); -- c'odigo de operaci'on de la instrucci'on en IEEE
		PCSrc		    : in  std_logic; -- 1 cuando se produce un salto 0 en caso contrario
		FP_add_EX	    : in  std_logic; -- Indica si la instrucci'on en EX es un ADDFP
		FP_done		    : in  std_logic;
		RegWrite_FP_EX  : in  std_logic; -- Indica que la instruccion en EX escribe en el banco de registros de FP
		RW_FP_EX	    : in  STD_LOGIC_VECTOR(4 downto 0); --Indica en que registro del banco FP escribe
		RegWrite_FP_MEM : in  std_logic; -- Indica que la instruccion en EX escribe en el banco de registros de FP
		RW_FP_MEM	    : in  STD_LOGIC_VECTOR(4 downto 0); --Indica en que registro del banco FP escribe
		Kill_IF		    : out STD_LOGIC; -- Indica que la instrucci'on en IF no debe ejecutarse (fallo en la predicci'on de salto tomado)
		Parar_ID	    : out STD_LOGIC; -- Indica que las etapas ID y previas deben parar
		Parar_EX_FP	    : out STD_LOGIC;  -- Indica que las etapas EX y previas deben parar
		Parar_MEM	    : out STD_LOGIC; -- Indica que las etapas MEM y previas deben parar
		Mem_Ready	    : in STD_LOGIC
	);
end component;

Component Banco_EX
    PORT(
        clk         : IN  std_logic;
        reset       : IN  std_logic;
        load        : IN  std_logic;
        busA        : IN  std_logic_vector(31 downto 0);
        busB        : IN  std_logic_vector(31 downto 0);
        busA_EX     : OUT std_logic_vector(31 downto 0);
        busB_EX     : OUT std_logic_vector(31 downto 0);
		inm_ext     : IN  std_logic_vector(31 downto 0);
		inm_ext_EX  : OUT std_logic_vector(31 downto 0);
        RegDst_ID   : IN  std_logic;
        ALUSrc_ID   : IN  std_logic;
        MemWrite_ID : IN  std_logic;
        MemRead_ID  : IN  std_logic;
        MemtoReg_ID : IN  std_logic;
        RegWrite_ID : IN  std_logic;
        RegDst_EX   : OUT std_logic;
        ALUSrc_EX   : OUT std_logic;
        MemWrite_EX : OUT std_logic;
        MemRead_EX  : OUT std_logic;
        MemtoReg_EX : OUT std_logic;
        RegWrite_EX : OUT std_logic;
		Reg_Rs_ID   : in  std_logic_vector(4 downto 0);
		Reg_Rs_EX   : out std_logic_vector(4 downto 0);
		ALUctrl_ID  : in  STD_LOGIC_VECTOR(2 downto 0);
		ALUctrl_EX  : out STD_LOGIC_VECTOR(2 downto 0);
        Reg_Rt_ID   : IN  std_logic_vector(4 downto 0);
        Reg_Rd_ID   : IN  std_logic_vector(4 downto 0);
        Reg_Rt_EX   : OUT std_logic_vector(4 downto 0);
        Reg_Rd_EX   : OUT std_logic_vector(4 downto 0)
    );
END Component;

Component Banco_EX_FP is
    Port (
		clk            : in  STD_LOGIC;
	   	reset          : in  STD_LOGIC;
	   	load           : in  STD_LOGIC;
	   	RegWrite_FP_ID : in  STD_LOGIC;
        RegWrite_FP_EX : out STD_LOGIC;
	   	FP_add_ID      : in  STD_LOGIC;
        FP_add_EX      : out STD_LOGIC;
        FP_mem_ID      : in  STD_LOGIC;
        FP_mem_EX      : out STD_LOGIC;
        busA_FP        : in  std_logic_vector(31 downto 0);
        busB_FP        : in  std_logic_vector(31 downto 0);
        busA_FP_EX     : OUT std_logic_vector(31 downto 0);
        busB_FP_EX     : OUT std_logic_vector(31 downto 0);
	   	Reg_Rd_FP_ID   : IN  std_logic_vector(4 downto 0);
	   	Reg_Rd_FP_EX   : OUT std_logic_vector(4 downto 0);
        Reg_Rs_FP_ID   : IN  std_logic_vector(4 downto 0);
        Reg_Rs_FP_EX   : OUT std_logic_vector(4 downto 0);
        Reg_Rt_FP_ID   : IN  std_logic_vector(4 downto 0);
        Reg_Rt_FP_EX   : OUT std_logic_vector(4 downto 0);
        RegDst_ID      : in  STD_LOGIC;
        RegDst_FP_EX   : out STD_LOGIC
	);
END Component;
    
-- Unidad de anticipacion de operandos.
Component UA
	Port(
		Reg_Rs_EX    : IN  std_logic_vector(4 downto 0); 
		Reg_Rt_EX    : IN  std_logic_vector(4 downto 0);
		RegWrite_MEM : IN  std_logic;
		RW_MEM       : IN  std_logic_vector(4 downto 0);
		RegWrite_WB  : IN  std_logic;
		RW_WB        : IN  std_logic_vector(4 downto 0);
		MUX_ctrl_A   : out std_logic_vector(1 downto 0);
		MUX_ctrl_B   : out std_logic_vector(1 downto 0)
	);
end component;

-- Mux 4 a 1
component mux4_1_32bits is
	Port ( 
		DIn0 : in  STD_LOGIC_VECTOR(31 downto 0);
		DIn1 : in  STD_LOGIC_VECTOR(31 downto 0);
		DIn2 : in  STD_LOGIC_VECTOR(31 downto 0);
		DIn3 : in  STD_LOGIC_VECTOR(31 downto 0);
		ctrl : in  std_logic_vector(1 downto 0);
		Dout : out STD_LOGIC_VECTOR(31 downto 0)
	);
end component;
	
Component ALU
    PORT(
        DA      : IN  std_logic_vector(31 downto 0);
        DB      : IN  std_logic_vector(31 downto 0);
        ALUctrl : IN  std_logic_vector(2 downto 0);
        Dout    : OUT std_logic_vector(31 downto 0)
    );
END Component;

-- Sumador en FP
component FP_ADD_SUB is
	port(
		A      : in  std_logic_vector(31 downto 0);
       	B      : in  std_logic_vector(31 downto 0);
       	clk    : in  std_logic;
       	reset  : in  std_logic;
       	go     : in  std_logic;
       	done   : out std_logic;
       	result : out std_logic_vector(31 downto 0)
    );
end component;
	 
Component mux2_5bits is
	Port ( 
		DIn0 : in  STD_LOGIC_VECTOR(4 downto 0);
		DIn1 : in  STD_LOGIC_VECTOR(4 downto 0);
		ctrl : in  STD_LOGIC;
		Dout : out STD_LOGIC_VECTOR(4 downto 0)
	);
end component;
	
Component Banco_MEM
    PORT(
        ALU_out_EX   : IN  std_logic_vector(31 downto 0);
        ALU_out_MEM  : OUT std_logic_vector(31 downto 0);
        clk          : IN  std_logic;
        reset        : IN  std_logic;
        load         : IN  std_logic;
        MemWrite_EX  : IN  std_logic;
        MemRead_EX   : IN  std_logic;
        MemtoReg_EX  : IN  std_logic;
        RegWrite_EX  : IN  std_logic;
        MemWrite_MEM : OUT std_logic;
        MemRead_MEM  : OUT std_logic;
        MemtoReg_MEM : OUT std_logic;
        RegWrite_MEM : OUT std_logic;
        BusB_EX      : IN  std_logic_vector(31 downto 0);
        BusB_MEM     : OUT std_logic_vector(31 downto 0);
        RW_EX        : IN  std_logic_vector(4 downto 0);
        RW_MEM       : OUT std_logic_vector(4 downto 0)
    );
END Component;
 
Component Banco_MEM_FP is
	Port ( 
		ADD_FP_out      : in  STD_LOGIC_VECTOR(31 downto 0); 
		ADD_FP_out_MEM  : out STD_LOGIC_VECTOR(31 downto 0);
	    clk             : in  STD_LOGIC;
		reset           : in  STD_LOGIC;
	    load            : in  STD_LOGIC;
		RegWrite_FP_EX  : in  STD_LOGIC;
		RegWrite_FP_MEM : out STD_LOGIC;
		FP_mem_EX       : in  STD_LOGIC;
		FP_mem_MEM      : out STD_LOGIC;
		RW_FP_EX        : in  STD_LOGIC_VECTOR(4 downto 0); 
		RW_FP_MEM       : out STD_LOGIC_VECTOR(4 downto 0) 
	);
END Component;

Component Banco_WB
	PORT(
	    ALU_out_MEM  : IN  std_logic_vector(31 downto 0);
	    ALU_out_WB   : OUT std_logic_vector(31 downto 0);
	    MEM_out      : IN  std_logic_vector(31 downto 0);
	    MDR          : OUT std_logic_vector(31 downto 0);
	    clk          : IN  std_logic;
	    reset        : IN  std_logic;
	    load         : IN  std_logic;
	    MemtoReg_MEM : IN  std_logic;
	    RegWrite_MEM : IN  std_logic;
	    MemtoReg_WB  : OUT std_logic;
	    RegWrite_WB  : OUT std_logic;
	    RW_MEM       : IN  std_logic_vector(4 downto 0);
	    RW_WB        : OUT std_logic_vector(4 downto 0)
	);
END Component; 

Component Banco_WB_FP is
	Port (
		ADD_FP_out_MEM  : in  STD_LOGIC_VECTOR(31 downto 0); 
		ADD_FP_out_WB   : out STD_LOGIC_VECTOR(31 downto 0); 
		clk             : in  STD_LOGIC;
		reset           : in  STD_LOGIC;
        load            : in  STD_LOGIC;
		RegWrite_FP_MEM : in  STD_LOGIC;
		RegWrite_FP_WB  : out STD_LOGIC;
        FP_mem_MEM      : in  STD_LOGIC;
        FP_mem_WB       : out STD_LOGIC;
        RW_FP_MEM       : in  STD_LOGIC_VECTOR(4 downto 0);
        RW_FP_WB        : out STD_LOGIC_VECTOR(4 downto 0)
	);
END Component;

-- Componente Contador.
Component counter is
	Port (
		clk   		 : in  STD_LOGIC;
		reset 		 : in  STD_LOGIC;
		count_enable : in  STD_LOGIC;
		load         : in  STD_LOGIC;
		D_in         : in  STD_LOGIC_VECTOR(7 downto 0);
		count        : out STD_LOGIC_VECTOR(7 downto 0)
	);
END Component;

-- Constantes.
Constant ARIT : STD_LOGIC_VECTOR (5 downto 0) := "000001";

----- Señales -----
signal load_PC, PCSrc, RegWrite, RegWrite_ID, RegWrite_EX, RegWrite_MEM, RegWrite_WB, Z, Branch, RegDst_ID, RegDst_EX, ALUSrc_ID, ALUSrc_EX: std_logic;
signal MemtoReg_ID, MemtoReg_EX, MemtoReg_MEM, MemtoReg_WB, MemWrite, MemWrite_ID, MemWrite_EX, MemWrite_MEM, MemRead, MemRead_ID, MemRead_EX, MemRead_MEM: std_logic;
signal PC_in, PC_out, four, PC4, Dirsalto_ID, MemI_out, IR_in, IR_ID, PC4_ID, inm_ext_EX, ALU_Src_out, cero : std_logic_vector(31 downto 0);
signal BusW, BusA, BusB, BusA_EX, BusB_EX, BusB_MEM, inm_ext, inm_ext_x4, ALU_out_EX, ALU_out_MEM, ALU_out_WB, Mem_out, MDR : std_logic_vector(31 downto 0);
signal RW_EX, RW_MEM, RW_WB, Reg_Rs_ID, Reg_Rs_EX, Reg_Rt_ID, Reg_Rd_EX, Reg_Rt_EX: std_logic_vector(4 downto 0);
signal ALUctrl_ID, ALUctrl_EX : std_logic_vector(2 downto 0);
signal ALU_INT_out, Mux_A_out, Mux_B_out: std_logic_vector(31 downto 0);
signal IR_op_code: std_logic_vector(5 downto 0);
signal MUX_ctrl_A, MUX_ctrl_B : std_logic_vector(1 downto 0);
signal RegWrite_FP, RegWrite_FP_ID, RegWrite_FP_EX, RegWrite_FP_EX_mux_out, RegWrite_FP_MEM, RegWrite_FP_WB : std_logic;
signal FP_add, FP_add_ID, FP_add_EX, FP_done : std_logic;
signal FP_mem, FP_mem_EX, FP_mem_MEM, FP_mem_WB : std_logic;
signal RegDst_FP_EX : std_logic;
signal RW_FP_EX, RW_FP_MEM, RW_FP_WB : std_logic_vector(4 downto 0);
signal BusW_FP: std_logic_vector(31 downto 0);
signal busA_FP, busA_FP_EX, busB_FP, busB_FP_EX, BusB_4_MD: std_logic_vector(31 downto 0);
signal Reg_Rd_FP_EX, Reg_Rs_FP_EX, Reg_Rt_FP_EX : std_logic_vector(4 downto 0);
signal MUX_ctrl_A_FP, MUX_ctrl_B_FP : std_logic_vector(1 downto 0);
signal Mux_A_out_FP, Mux_B_out_FP: std_logic_vector(31 downto 0);
signal ADD_FP_out, ADD_FP_out_MEM, ADD_FP_out_WB: std_logic_vector(31 downto 0);

-- Nuevas señales: UD.
signal Kill_If, Parar_ID, Parar_EX_FP, Parar_Mem: std_logic;
signal load_EX_FP : std_logic;
-- Nuevas señales: contadores.
signal c_en_est, c_en_dat, c_en_ctl : std_logic;
signal n_ciclos, paradas_FP, paradas_datos, paradas_control : std_logic_vector(7 downto 0);
-- NEW: Nuevas señales: memoria.
signal Mem_ready : std_logic;
signal io_input_bus : std_logic_vector(31 downto 0);
signal inc_paradas_mem : std_logic;
signal paradas_mem : std_logic_vector(7 downto 0);

begin
-------------------------------------------------------------------------------
--------------------------------- COUNTERS ------------------------------------
-------------------------------------------------------------------------------
-- Contador Riesgos estructurales.
c_en_est <= '1' when (Parar_EX_FP = '1') else '0';
c_r_estructural : counter port map (
	clk          => clk,
	reset        => reset,
	count_enable => c_en_est,
	load         => '0',
	D_in         => x"00",
	count        => paradas_FP
);

-- Contador Riesgos de datos.
c_en_dat <= '1' when (Parar_ID = '1' and Parar_EX_FP = '0') else '0';
c_r_datos : counter port map (
	clk          => clk,
	reset        => reset,
	count_enable => c_en_dat,
	load         => '0',
	D_in         => x"00",
	count        => paradas_datos
);

-- Contador Riesgos de control.
c_en_ctl <= '1' when (Kill_If = '1' and Parar_EX_FP = '0' and Parar_ID = '0') else '0';
c_r_control : counter port map (
	clk          => clk,
	reset        => reset,
	count_enable => c_en_ctl,
	load         => '0',
	D_in         => x"00",
	count        => paradas_control
);

-- NEW: Contador de Paradas de memoria.
inc_paradas_mem <= '1' when (Parar_MEM = '1') else '0'; -- when (...) else '0';
cont_paradas_memoria : counter port map (
	clk          => clk,
	reset        => reset,
	count_enable => inc_paradas_mem,
	load         => '0',
	D_in         => x"00",
	count        => paradas_mem
);

-- Contador de ciclos.
c_ciclos : counter port map (
	clk          => clk,
	reset        => reset,
	count_enable => '1',
	load         => '0',
	D_in         => x"00",
	count        => n_ciclos
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--------------------------------- Etapa IF ------------------------------------
-------------------------------------------------------------------------------
-- Señal load_PC: indica cuando el pc debe o no cargarse. Si hay riesgo de
-- datos, estructural o ambos, el pc se congela.
load_PC <= '0' when (Parar_ID = '1' or Parar_EX_FP = '1' or Parar_MEM = '1') else '1';

-- PC: registro pc.
pc: reg32 port map (
	Din   => PC_in,
	clk   => clk,
	reset => reset,
	load  => load_PC,
	Dout  => PC_out
);

-- Señal load_EX_FP: indica cuando el banco de registros EX debe cargar o no 
-- datos. Si hay riesgo estructural, el banco deja de cargar datos.
load_EX_FP <= not Parar_EX_FP and not Parar_MEM;

-- Constantes: 0 y 4.
four <= "00000000000000000000000000000100";
cero <= "00000000000000000000000000000000";

-- Sumador +4: siguiente direccion de pc.
adder_4: adder32 port map (
	Din0 => PC_out,
	Din1 => four,
	Dout => PC4
);

-- Mux PC_Src: pc+4 o la direccion de salto generada en ID si salto tomado.
muxPC: mux2_1 port map (
	Din0 => PC4,
	DIn1 => Dirsalto_ID,
	ctrl => PCSrc,
	Dout => PC_in
);

-- Mem_I: memoria de instrucciones.
Mem_I: memoriaRAM_I PORT MAP (
	clk  => clk,
	ADDR => PC_out,
	Din  => cero,
	WE   => '0',
	RE   => '1',
	Dout => MemI_out
);

-- IR_in: define la proxima instruccion a ejecutar. Si el salto es no tomado, 
-- la instruccion en ejecucion sigue, si es tomado, se introduce una nop y 
-- se pierde un ciclo.
IR_in <= MemI_out when (Kill_IF = '0') else x"00000000";
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------------- IF/ID --------------------------------------
-------------------------------------------------------------------------------
-- Banco de registros IF. Se utiliza load_PC como señal de load ya que el banco
-- IF y el pc deben congelarse en las mismas condiciones y si la señal vale 0, 
-- ya implica riesgo.
Banco_IF_ID: Banco_ID port map (
	IR_in  => IR_in,
	PC4_in => PC4,
	clk    => clk, 
	reset  => reset,
	load   => load_PC,
	IR_ID  => IR_ID,
	PC4_ID => PC4_ID
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--------------------------------- Etapa ID ------------------------------------
-------------------------------------------------------------------------------
-- Unidad de detencion
Unidad_Det: UD port map (
	Reg_Rs_ID       => Reg_Rs_ID,
	Reg_Rt_ID       => Reg_Rt_ID,
	MemRead_EX      => MemRead_EX,
	RegWrite_EX     => RegWrite_EX,
	RW_EX           => RW_EX,
	RegWrite_Mem    => RegWrite_MEM,
	RW_Mem          => RW_MEM,
	IR_op_code      => IR_op_code,
    PCSrc           => PCSrc,
	FP_add_EX       => FP_add_EX,
	FP_done         => FP_done,
	RegWrite_FP_EX  => RegWrite_FP_EX,
	RW_FP_EX        => RW_FP_EX,
	RegWrite_FP_MEM => RegWrite_FP_MEM,
	RW_FP_MEM       => RW_FP_MEM,
	Kill_IF         => Kill_IF,
	Parar_ID        => Parar_ID,
	Parar_EX_FP     => Parar_EX_FP,
	Parar_MEM       => Parar_MEM,
	Mem_Ready     	=> Mem_Ready
);


-- Codigo de operacion.
IR_op_code <= IR_ID(31 downto 26);

-- Unidad de control.
UC_seg: UC port map (
	-- Señal de entrada.
	IR_op_code  => IR_op_code, 
	-- Señales de control de salida.
	Branch      => Branch,
	RegDst      => RegDst_ID,
	ALUSrc      => ALUSrc_ID,
	MemWrite    => MemWrite,  
	MemRead     => MemRead,
	MemtoReg    => MemtoReg_ID,
	RegWrite    => RegWrite, 
	-- Señales nuevas
	FP_add      => FP_add, 
	FP_mem      => FP_mem, 
	RegWrite_FP => RegWrite_FP
);

-- Mux de burbuja entre las señales originales de la UC o 0. Se utiliza
-- load_PC ya que la señal cubre los requisitos que implican riesgo.
RegWrite_FP_ID <= RegWrite_FP and load_PC;
RegWrite_ID	   <= RegWrite and load_PC;
FP_add_ID	   <= FP_add and load_PC;
MemWrite_ID	   <= MemWrite and load_PC;
MemRead_ID	   <= MemRead and load_PC;

-- Registro Rs.
Reg_Rs_ID <= IR_ID(25 downto 21);

-- Registro Rt.
Reg_Rt_ID <= IR_ID(20 downto 16);

-- Banco de registros de enteros.
INT_Register_bank: BReg PORT MAP (
	clk      => clk,
	reset    => reset,
	RA       => Reg_Rs_ID,
	RB       => Reg_Rt_ID,
	RW       => RW_WB,
	BusW     => BusW,
	RegWrite => RegWrite_WB,
	BusA     => BusA,
	BusB     => BusB
);

-- Banco de registros de FP.								
FP_Register_bank: BReg PORT MAP (
	clk      => clk,
	reset    => reset,
	RA       => Reg_Rs_ID,
	RB       => Reg_Rt_ID,
	RW       => RW_FP_WB,
	BusW     => BusW_FP,
	RegWrite => RegWrite_FP_WB,
	BusA     => BusA_FP,
	BusB     => BusB_FP
);

-- Extensor de signo.
sign_ext: Ext_signo port map (
	inm => IR_ID(15 downto 0),
	inm_ext => inm_ext
);

-- Shifter de 2 bits (multiplicar por 4).
two_bits_shift: two_bits_shifter port map (
	Din  => inm_ext,
	Dout => inm_ext_x4
);

-- Si la operacion es aritmetica (IR_op_code = "000001") miro el campo funct,
-- como solo hay 4 operaciones en la alu, basta con los bits menos 
-- significativos del campo func de la instruccion, si no lo es, le damos el 
-- valor de la suma (000).
ALUctrl_ID <= IR_ID(2 downto 0) when IR_op_code = ARIT else "000"; 

-- Sumador para generar la direccion de salto.
adder_dir: adder32 port map (
	Din0 => inm_ext_x4,
	Din1 => PC4_ID,
	Dout => Dirsalto_ID
);

-- Comparador con flag Z.
Z <= '1' when (busA = busB) else '0';

-- Señal PCSrc, si BEQ y señal Z se carga la direccion de salto, sino PC + 4.
PCSrc <= Branch AND Z; 
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------------- ID/EX --------------------------------------
-------------------------------------------------------------------------------
-- Banco ID/EX para enteros. En esta version del mips, ambos bancos se 
-- congelan si hay un riesgo estructural.
Banco_ID_EX: Banco_EX PORT MAP (
	clk         => clk, 
	reset       => reset, 
	load        => load_EX_FP, 
	busA        => busA, 
	busB        => busB, 
	busA_EX     => busA_EX, 
	busB_EX     => busB_EX,
	RegDst_ID   => RegDst_ID,
	ALUSrc_ID   => ALUSrc_ID,
	MemWrite_ID => MemWrite_ID,
	MemRead_ID 	=> MemRead_ID,
	MemtoReg_ID => MemtoReg_ID, 
	RegWrite_ID => RegWrite_ID, 
	RegDst_EX 	=> RegDst_EX, 
	ALUSrc_EX 	=> ALUSrc_EX,
	MemWrite_EX => MemWrite_EX,
	MemRead_EX 	=> MemRead_EX,
	MemtoReg_EX => MemtoReg_EX,
	RegWrite_EX => RegWrite_EX,
	Reg_Rs_ID 	=> Reg_Rs_ID,
	Reg_Rs_EX 	=> Reg_Rs_EX,
	ALUctrl_ID 	=> ALUctrl_ID,
	ALUctrl_EX 	=> ALUctrl_EX,
	inm_ext 	=> inm_ext,
	inm_ext_EX	=> inm_ext_EX,
	Reg_Rt_ID 	=> IR_ID(20 downto 16),
	Reg_Rd_ID 	=> IR_ID(15 downto 11),
	Reg_Rt_EX 	=> Reg_Rt_EX,
	Reg_Rd_EX 	=> Reg_Rd_EX
);

-- Banco ID/EX para FP
Banco_ID_EX_FP: Banco_EX_FP PORT MAP (
	clk 		   => clk,
	reset 		   => reset,
	load  		   => load_EX_FP,
	RegWrite_FP_ID => RegWrite_FP_ID,
	RegWrite_FP_EX => RegWrite_FP_EX,
	FP_add_ID      => FP_add_ID,
	FP_add_EX      => FP_add_EX,
	FP_mem_ID      => FP_mem,
	FP_mem_EX      => FP_mem_EX,
	busA_FP        => busA_FP,
	busB_FP        => busB_FP,
	busA_FP_EX     => busA_FP_EX,
	busB_FP_EX     => busB_FP_EX,
	Reg_Rd_FP_ID   => IR_ID(15 downto 11),
	Reg_Rd_FP_EX   => Reg_Rd_FP_EX,
	Reg_Rs_FP_ID   => Reg_Rs_ID,
	Reg_Rs_FP_EX   => Reg_Rs_FP_EX,
	Reg_Rt_FP_ID   => IR_ID(20 downto 16),
	Reg_Rt_FP_EX   => Reg_Rt_FP_EX,
	RegDst_ID      => RegDst_ID,
	RegDst_FP_EX   => RegDst_FP_EX
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--------------------------------- Etapa EX ------------------------------------
-------------------------------------------------------------------------------
-- Unidad de anticipacion. Unicamente para parte entera.
Unidad_Ant_INT: UA port map (
	Reg_Rs_EX    => Reg_Rs_EX, 
	Reg_Rt_EX    => Reg_Rt_EX,
	RegWrite_MEM => RegWrite_MEM,
	RW_MEM       => RW_MEM,
	RegWrite_WB  => RegWrite_WB,
	RW_WB        => RW_WB,
	MUX_ctrl_A   => MUX_ctrl_A,
	MUX_ctrl_B   => MUX_ctrl_B
);

-- Muxes de anticipacion del Bus A entre A, dato de MEM o de WB.
Mux_A: mux4_1_32bits port map ( 
	DIn0 => BusA_EX,
	DIn1 => ALU_out_MEM,
	DIn2 => busW,
	DIn3 => cero,
	ctrl => MUX_ctrl_A,
	Dout => Mux_A_out
);

-- Muxes de anticipacion del Bus B entre B, dato de MEM o de WB.
Mux_B: mux4_1_32bits port map (
	DIn0 => BusB_EX,
	DIn1 => ALU_out_MEM,
	DIn2 => busW,
	DIn3 => cero,
	ctrl => MUX_ctrl_B,
	Dout => Mux_B_out
);

-- Mux de entrada de B de la ALU entre la salida de Mux_B o inmediato.
muxALU_src: mux2_1 port map (
	Din0 => Mux_B_out, 
	DIn1 => inm_ext_EX, 
	ctrl => ALUSrc_EX, 
	Dout => ALU_Src_out
);

-- ALU.
ALU_MIPs: ALU PORT MAP (
	DA 		=> Mux_A_out,
	DB 		=> ALU_Src_out,
	ALUctrl => ALUctrl_EX,
	Dout 	=> ALU_out_EX
);

-- Mux registro destino entre Rt o Rd.
mux_dst: mux2_5bits port map (
	Din0 => Reg_Rt_EX,
	DIn1 => Reg_Rd_EX,
	ctrl => RegDst_EX,
	Dout => RW_EX
);

-- Mux de burbuja, elige entre la señal original de UC o 0. Sirve para propagar
-- la burbuja en caso de que una ADDFP siga en computo.
RegWrite_FP_EX_mux_out <= '0' when (load_EX_FP = '0') else RegWrite_FP_EX;

-- Sumador FP. El numero de ciclos depende de los operandos. FP_add_EX indica 
-- al sumador que debe realizar una suma en FP. Cuando termina activa la señal 
-- done. La salida solo dura un ciclo. A y B no pueden cambiar durante la 
-- operacion.
ADD_FP: FP_ADD_SUB port map (
	A 	   => busA_FP_EX,
	B 	   => busB_FP_EX,
	clk    => clk,
	reset  => reset,
	go 	   => FP_add_EX,
	done   => FP_done,
	result => ADD_FP_out
);

-- Mux que elige entre el registro B de INT y FP para guardar en memoria.
BusB_4_MD <= busB_FP_EX when (FP_mem_EX='1') else Mux_B_out;

-- Mux registro destino (FP) entre Rt o Rd.
mux_dst_FP: mux2_5bits port map (
	Din0 => Reg_Rt_FP_EX,
	DIn1 => Reg_Rd_FP_EX,
	ctrl => RegDst_FP_EX,
	Dout => RW_FP_EX
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------------- EX/MEM -------------------------------------
-------------------------------------------------------------------------------
-- Banco de registros EX/MEM.
Banco_EX_MEM: Banco_MEM PORT MAP (
	ALU_out_EX   => ALU_out_EX, 
	ALU_out_MEM  => ALU_out_MEM, 
	clk   		 => clk, 
	reset 		 => reset, 
	load  		 => Parar_Mem, 
	MemWrite_EX  => MemWrite_EX,
	MemRead_EX   => MemRead_EX, 
	MemtoReg_EX  => MemtoReg_EX,
	RegWrite_EX  => RegWrite_EX,
	MemWrite_MEM => MemWrite_MEM,
	MemRead_MEM  => MemRead_MEM,
	MemtoReg_MEM => MemtoReg_MEM,
	RegWrite_MEM => RegWrite_MEM,
	BusB_EX      => BusB_4_MD,
	BusB_MEM     => BusB_MEM, 
	RW_EX        => RW_EX, 
	RW_MEM       => RW_MEM
);

-- Banco de registros EX/MEM de FP.
Banco_EX_FP_MEM: Banco_MEM_FP PORT MAP (
	ADD_FP_out      => ADD_FP_out, 
	ADD_FP_out_MEM  => ADD_FP_out_MEM, 
	clk             => clk, 
	reset           => reset, 
	load            => Parar_Mem, 
	RegWrite_FP_EX  => RegWrite_FP_EX_mux_out, 
	RegWrite_FP_MEM => RegWrite_FP_MEM, 
	FP_mem_EX   	=> FP_mem_EX,
	FP_mem_MEM  	=> FP_mem_MEM,
	RW_FP_EX    	=> RW_FP_EX,
	RW_FP_MEM   	=> RW_FP_MEM
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--------------------------------- Etapa MEM -----------------------------------
-------------------------------------------------------------------------------
-- Memoria de datos.
Mem_D: MD_mas_MC PORT MAP (
	clk       => clk,
	reset     => reset,
	ADDR      => ALU_out_MEM,
	Din       => BusB_MEM,
	WE        => MemWrite_MEM,
	RE        => MemRead_MEM,
	IO_input  => io_input_bus,
	Mem_ready => Mem_ready,
	Dout      => Mem_out
);


-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------------- MEM/WB -------------------------------------
-------------------------------------------------------------------------------
-- Banco de registros MEM/WB.
Banco_MEM_WB: Banco_WB PORT MAP (
	ALU_out_MEM  => ALU_out_MEM,
	ALU_out_WB   => ALU_out_WB,
	Mem_out      => Mem_out,
	MDR          => MDR,
	clk          => clk,
	reset        => reset, 
	load         => '1', 
	MemtoReg_MEM => MemtoReg_MEM ,
	RegWrite_MEM => RegWrite_MEM,
	MemtoReg_WB  => MemtoReg_WB,
	RegWrite_WB  => RegWrite_WB, 
	RW_MEM  	 => RW_MEM,
	RW_WB   	 => RW_WB
);
RegWrite_MEM <= RegWrite_MEM and not(Parar_MEM);


-- Banco de registros MEM/WB del FP.
Banco_MEM_WB_FP: Banco_WB_FP PORT MAP (
	ADD_FP_out_MEM 	=> ADD_FP_out_MEM, 
	ADD_FP_out_WB  	=> ADD_FP_out_WB, 
	clk   		   	=> clk, 
	reset 		   	=> reset, 
	load  		   	=> '1', 
	RegWrite_FP_MEM => RegWrite_FP_MEM, 
	RegWrite_FP_WB 	=> RegWrite_FP_WB,
	FP_mem_MEM 		=> FP_mem_MEM, 
	FP_mem_WB  		=> FP_mem_WB, 
	RW_FP_MEM  		=> RW_FP_MEM, 
	RW_FP_WB   		=> RW_FP_WB
);
RegWrite_FP_MEM <= RegWrite_FP_MEM and not(Parar_MEM);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--------------------------------- Etapa WB ------------------------------------
-------------------------------------------------------------------------------
-- Mux que selecciona el dato a escribir en registro, entre un dato calculado
-- en alu (busW) o un dato cargado de memoria (MDR).
mux_busW: mux2_1 port map (
	Din0 => ALU_out_WB,
	DIn1 => MDR,
	ctrl => MemtoReg_WB,
	Dout => busW
);

-- Mux que selecciona el dato a escribir en registro (FP), entre un dato 
-- calculado en alu (busW_FP) o un dato cargado de memoria (MDR).
mux_busW_FP: mux2_1 port map (
	Din0 => ADD_FP_out_WB,
	DIn1 => MDR,
	ctrl => FP_mem_WB,
	Dout => busW_FP
);
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------------- OUTPUT -------------------------------------
-------------------------------------------------------------------------------
-- No se usa para nada. Esta puesto para que el sistema tenga alguna salida al 
-- exterior.
output <= IR_ID;
-------------------------------------------------------------------------------

end Behavioral;
