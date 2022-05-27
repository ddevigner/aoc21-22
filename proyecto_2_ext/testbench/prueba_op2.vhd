-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

ENTITY testbench_MD_mas_MC IS
END testbench_MD_mas_MC;

ARCHITECTURE behavior OF testbench_MD_mas_MC IS 
COMPONENT MD_mas_MC is
	port (
		CLK       : in  std_logic;
		reset     : in  std_logic; -- Solo resetea el controlador de DMA.
		ADDR      : in  std_logic_vector (31 downto 0); -- Dir.
        Din       : in  std_logic_vector (31 downto 0); -- Entrada de datos desde el Mips.
        WE        : in  std_logic; -- Write enable del Mips.
		RE        : in  std_logic; -- Read enable del Mips.
		IO_input  : in  std_logic_vector (31 downto 0); -- Dato que viene de una entrada del sistema.
		Mem_ready : out std_logic; -- Indica si podemos hacer la operacion solicitada en el ciclo actual.
		Dout 	  : out std_logic_vector (31 downto 0)  -- Salida que puede leer el MIPS.
	);
end COMPONENT;

SIGNAL clk, reset, RE, WE, Mem_ready : std_logic;
signal ADDR, Din, Dout, IO_input : std_logic_vector (31 downto 0);			           
constant CLK_period : time := 10 ns; -- Clock period definitions
BEGIN

-- Component Instantiation
uut: MD_mas_MC PORT MAP (
	clk       => clk,
	reset     => reset,
	ADDR      => ADDR,
	Din       => Din,
	RE        => RE,
	WE        => WE,
	IO_input  => IO_input,
	Mem_ready => Mem_ready,
	Dout      => Dout
);

-- Clock process definitions
CLK_process: process
begin
	CLK <= '0';
	wait for CLK_period/2;
	CLK <= '1';
	wait for CLK_period/2;
end process;

stim_proc: process
begin
	---------------------------------------------------------------------------
	-- Init
	---------------------------------------------------------------------------
	reset <= '1';
	-- conv_std_logic_vector convierte el primer numero (un 0) a un vector de 
	-- tantos bits como se indiquen (en este caso 32 bits).
	addr <= conv_std_logic_vector(0, 32); -- x"00000000"
	Din  <= conv_std_logic_vector(255, 32); -- x"000000FF"

	-- IO_input. Lo voy a ir cambiando para que se vea como cambia en el 
	-- scratch.
  	IO_input <= conv_std_logic_vector(1024, 32); -- x"00000400"
  	RE <= '0';
	WE <= '0';
	wait for 20 ns;	
	reset <= '0';
	
	---------------------------------------------------------------------------
	-- Prueba 1. Read-Miss: TAG1 SET0 W0.
	--	@MC_T[0] = 1, @MC_D[Set0, W0, 0-3] = [1,2,3,4]
	---------------------------------------------------------------------------
	-- Debe ser un fallo de lectura. Traemos: 1,2,3 y 4 al cjto 0 via 0. 
	-- Mandamos al mips la primera palabra (un 1).
	RE <= '1';
	Addr <= conv_std_logic_vector(64, 32); -- x"00000040"
	wait for 1 ns;
	-- Este wait espera hasta que se ponga Mem_ready a uno.
    if Mem_ready = '0' then
		wait until Mem_ready ='1';
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 2. Intruccion que no accede a memoria
	--	
	---------------------------------------------------------------------------

    Addr <= conv_std_logic_vector(0, 32); -- x"00000000"
	wait for 1 ns;
	RE <= '0';
	WE <= '0';
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 3. Intruccion que no accede a memoria
	--	
	---------------------------------------------------------------------------

    Addr <= conv_std_logic_vector(1, 32); -- x"00000001"
	wait for 1 ns;
	RE <= '0';
	WE <= '0';
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;
	
	---------------------------------------------------------------------------
	-- Prueba 4. Read-Hit: TAG1 SET0 W0.
	--	
	---------------------------------------------------------------------------
	-- Debe ser un acierto de lectura. 
	RE <= '1';
	Addr <= conv_std_logic_vector(64, 32); -- x"00000040"
	wait for 1 ns;
	-- Este wait espera hasta que se ponga Mem_ready a uno.
    if Mem_ready = '0' then
		wait until Mem_ready ='1';
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 3. Intruccion que no accede a memoria
	--	
	---------------------------------------------------------------------------

    Addr <= conv_std_logic_vector(2, 32); -- x"00000002"
	wait for 1 ns;
	RE <= '0';
	WE <= '0';
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;
	

	-- Si no cambiamos los valores nos quedamos pidiendo todo el rato el mismo
	-- valor a la memoria scratch. Se puede ver como una y otra vez habra que 
	-- esperar a que la memoria lo envie. Ya que al no ser cacheable no se 
	-- almacena en MC.
	wait;
end process;

END;
