----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:28:20 04/07/2014 
-- Design Name: 
-- Module Name:    Banco_MEM - Behavioral 
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

entity Banco_MEM_FP is
Port ( 		ADD_FP_out : in  STD_LOGIC_VECTOR (31 downto 0); 
			ADD_FP_out_MEM : out  STD_LOGIC_VECTOR (31 downto 0); -- instrucción leida en IF
        	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
         	load : in  STD_LOGIC;
			RegWrite_FP_EX : in  STD_LOGIC;
			RegWrite_FP_MEM : out  STD_LOGIC;
			FP_mem_EX: in  STD_LOGIC;
			FP_mem_MEM : out  STD_LOGIC;
			RW_FP_EX: in  STD_LOGIC_VECTOR (4 downto 0); 
			RW_FP_MEM : out  STD_LOGIC_VECTOR (4 downto 0) 
			); -- PC+4 en la etapa ID
end Banco_MEM_FP;


architecture Behavioral of Banco_MEM_FP is

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            	ADD_FP_out_MEM <= x"00000000";
				RegWrite_FP_MEM <= '0';
				FP_mem_MEM <= '0';
				RW_FP_MEM <= "00000";
				
         else
            if (load='1') then 
				ADD_FP_out_MEM <= ADD_FP_out;
				RegWrite_FP_MEM <= RegWrite_FP_EX ;
				FP_mem_MEM <= FP_mem_EX;
				RW_FP_MEM <= RW_FP_EX;
				end if;	
         end if;        
      end if;
   end process;

end Behavioral;

