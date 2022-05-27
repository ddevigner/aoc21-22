library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Unidad de anticipación.
entity UA is
	Port(
		Reg_Rs_EX:    in  std_logic_vector(4 downto 0); 
		Reg_Rt_EX:    in  std_logic_vector(4 downto 0);
		RegWrite_MEM: in  std_logic;
		RW_MEM:       in  std_logic_vector(4 downto 0);
		RegWrite_WB:  in  std_logic;
		RW_WB:        in  std_logic_vector(4 downto 0);
		MUX_ctrl_A:   out std_logic_vector(1 downto 0);
		MUX_ctrl_B:   out std_logic_vector(1 downto 0)
	);
end UA;

Architecture Behavioral of UA is
signal Corto_A_Mem, Corto_B_Mem, Corto_A_WB, Corto_B_WB: std_logic;
begin
-- Anticipacion en etapa EX/MEM.
Corto_A_Mem <= '1' when (Reg_Rs_EX = RW_MEM and RegWrite_MEM = '1') else '0';
Corto_B_Mem <= '1' when (Reg_Rt_EX = RW_MEM and RegWrite_MEM = '1') else '0';

-- Anticipacion en etapa EX/WB.
Corto_A_WB <= '1' when (Reg_Rs_EX = RW_WB and RegWrite_WB = '1') else '0';
Corto_B_WB <= '1' when (Reg_Rt_EX = RW_WB and RegWrite_WB = '1') else '0';

-- Entrada 00: dato del banco de registros.
-- Entrada 01: dato de la etapa Mem.
-- Entrada 10: dato de la etapa WB.
MUX_ctrl_A <= "01" when (Corto_A_Mem = '1') else
			  "10" when (Corto_A_WB  = '1') else
			  "00";

MUX_ctrl_B <= "01" when (Corto_B_Mem = '1') else 
              "10" when (Corto_B_WB  = '1') else
			  "00";

end Behavioral;
