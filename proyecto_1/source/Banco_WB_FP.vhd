----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:25:11 04/07/2014 
-- Design Name: 
-- Module Name:    Banco_WB - Behavioral 
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

entity Banco_WB_FP is
Port ( 		ADD_FP_out_MEM : in  STD_LOGIC_VECTOR (31 downto 0); 
			ADD_FP_out_WB : out  STD_LOGIC_VECTOR (31 downto 0); 
			clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
        	load : in  STD_LOGIC;
			RegWrite_FP_MEM : in  STD_LOGIC;
			RegWrite_FP_WB : out  STD_LOGIC;
            FP_mem_MEM : in  STD_LOGIC;
            FP_mem_WB : out  STD_LOGIC;
            RW_FP_MEM : in  STD_LOGIC_VECTOR (4 downto 0);
            RW_FP_WB : out  STD_LOGIC_VECTOR (4 downto 0));
end Banco_WB_FP;

architecture Behavioral of Banco_WB_FP is
begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            ADD_FP_out_WB <= "00000000000000000000000000000000";
			RegWrite_FP_WB <= '0';
			FP_mem_WB <= '0';
			RW_FP_WB <= "00000";
				
         else
            if (load='1') then 
				ADD_FP_out_WB <= ADD_FP_out_MEM;
				RegWrite_FP_WB <= RegWrite_FP_MEM;
				FP_mem_WB <= FP_mem_MEM;
				RW_FP_WB <= RW_FP_MEM;
			end if;	
         end if;        
      end if;
   end process;

end Behavioral;

