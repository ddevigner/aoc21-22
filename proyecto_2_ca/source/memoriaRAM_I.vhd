----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 04/08/2014 
-- Design Name: 
-- Module Name:    memoriaRAM_I - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using arithmetic functions 
-- with Signed or Unsigned values:
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating any Xilinx 
-- primitives in this code:
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoriaRAM_I is port (
		CLK : in std_logic;
		ADDR : in std_logic_vector(31 downto 0); -- Dir 
	    Din : in std_logic_vector(31 downto 0);  -- Entrada de datos para el puerto de escritura
	    WE : in std_logic; -- write enable	
		RE : in std_logic; -- read enable		  
		Dout : out std_logic_vector(31 downto 0)
	);
end memoriaRAM_I;

architecture Behavioral of memoriaRAM_I is
type RamType is array(0 to 127) of std_logic_vector(31 downto 0);
signal RAM : RamType := (	X"88210000", X"84211000", X"8c220004", X"84221800", X"88210004", X"84231000", X"8c210008", X"8821000c", 
							X"84221800", X"84231800", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
							X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

signal dir_7:  std_logic_vector(6 downto 0); 
begin
-- Como la memoria es de 128 paalabras no usamos la direccion completa sino 
-- solo 7 bits. Como se direccionan los bytes, pero damos palabras no usamos 
-- los 2 bits menos significativos:
dir_7 <= ADDR(8 downto 2); 
process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (WE = '1') then -- solo se escribe si WE vale 1
            	RAM(conv_integer(dir_7)) <= Din;
            end if;
        end if;
    end process;
    Dout <= RAM(conv_integer(dir_7)) when (RE='1') else "00000000000000000000000000000000"; --solo se lee si RE vale 1
end Behavioral;


