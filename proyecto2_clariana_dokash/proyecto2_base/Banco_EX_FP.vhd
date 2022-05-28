----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:46:01 04/07/2014 
-- Design Name: 
-- Module Name:    Banco_EX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Banco_EX_FP is
    Port ( clk : in  STD_LOGIC;
		   reset : in  STD_LOGIC;
		   load : in  STD_LOGIC;
	       RegWrite_FP_ID : in  STD_LOGIC;
           RegWrite_FP_EX : out  STD_LOGIC;
		   FP_add_ID : in  STD_LOGIC;
           FP_add_EX : out  STD_LOGIC;
           FP_mem_ID : in  STD_LOGIC;
           FP_mem_EX : out  STD_LOGIC;
           busA_FP : in  std_logic_vector(31 downto 0);
           busB_FP : in  std_logic_vector(31 downto 0);
           busA_FP_EX : OUT  std_logic_vector(31 downto 0);
           busB_FP_EX : OUT  std_logic_vector(31 downto 0);
		   Reg_Rd_FP_ID: IN  std_logic_vector(4 downto 0);
		   Reg_Rd_FP_EX: OUT  std_logic_vector(4 downto 0);
           Reg_Rs_FP_ID : IN  std_logic_vector(4 downto 0);
           Reg_Rs_FP_EX : OUT  std_logic_vector(4 downto 0);
           Reg_Rt_FP_ID : IN  std_logic_vector(4 downto 0);
           Reg_Rt_FP_EX : OUT  std_logic_vector(4 downto 0);
           RegDst_ID : in  STD_LOGIC;
           RegDst_FP_EX : out  STD_LOGIC);
end Banco_EX_FP;

architecture Behavioral of Banco_EX_FP is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            	RegWrite_FP_EX <= '0';
				FP_add_EX <= '0';
				FP_mem_EX <= '0';
				busA_FP_EX <= "00000000000000000000000000000000";
				busB_FP_EX <= "00000000000000000000000000000000";
				Reg_Rd_FP_EX <= "00000";
				Reg_Rs_FP_EX <= "00000";
				Reg_Rt_FP_EX <= "00000";
				RegDst_FP_EX <= '0';
				 
         else
            if (load='1') then 
				RegWrite_FP_EX <= RegWrite_FP_ID;
				FP_add_EX <= FP_add_ID;
				FP_mem_EX <= FP_mem_ID;
				busA_FP_EX <= busA_FP;
				busB_FP_EX <= busB_FP;
				Reg_Rd_FP_EX <= Reg_Rd_FP_ID;
				Reg_Rs_FP_EX <= Reg_Rs_FP_ID;
				Reg_Rt_FP_EX <= Reg_Rt_FP_ID;
				RegDst_FP_EX <= RegDst_ID;
				end if;	
         end if;        
      end if;
   end process;

end Behavioral;

