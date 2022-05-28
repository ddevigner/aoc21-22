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
	-- Prueba 2. Read-Hit: TAG1 SET0 W0
	--	Dout = @MC_D[Set0, W0, 1] = 2
	---------------------------------------------------------------------------
	-- Debe ser un acierto de lectura. Devolvemos un 2 al procesador
    Addr <= conv_std_logic_vector(68, 32); -- x"00000044"
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;
	
	---------------------------------------------------------------------------
	-- Prueba 3. Write-Hit: TAG1 SET0 W0
	--	@MD[18] = @MC_D[SET0, W0, 2] = x"000000FF"
	---------------------------------------------------------------------------
	-- IO_input. Segundo valor
	IO_input <= conv_std_logic_vector(2048, 32); -- x"00000800"

	-- Debe ser un acierto de escritura. Escribimos FF en @18 y en la tercera 
	-- palabra del bloque de MC del cjto 0 via 0.
	Addr <= conv_std_logic_vector(72, 32); -- x"00000048"
	RE <= '0';
	WE <= '1';
	-- La idea de estos wait es esperar a que la señal Mem_ready se active (y 
	-- si ya esta activa no hacer nada).
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 4. Write-Miss: TAG1 SET2 W0
	--	@MD[24] = x"000000FF"
	---------------------------------------------------------------------------
	-- Debe ser un fallo de escritura. NO se trae el bloque. Escribimos FF en 
	-- memoria.
	Addr <= conv_std_logic_vector(96, 32); -- x"0000004C"
	RE <= '0';
	WE <= '1';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 5. Read-Miss: TAG2 SET0 W1 WORD 0.
	--	@MC_T[SET0] = 2, @MC_D[SET0 W1 0-3] = [0x9,0xa,0xb,0xc]
	---------------------------------------------------------------------------
	-- IO_input. Tercer valor
	IO_input <= conv_std_logic_vector(4096, 32); -- x"00001000"

	-- Debe ser un fallo de lectura y almacenarse 9, a, b y c en el cjto 0 
	-- en la via 1.
	Addr <= conv_std_logic_vector(128, 32); -- x"00000080"
	RE <= '1';
	WE <= '0';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
    wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 6. Read-Hit: TAG1 SET0 W0 WORD 0.
	--	Dout = @MC_D[SET0 W0 0] = 1
	---------------------------------------------------------------------------
	-- Debe ser acierto de lectura.
	Addr <= conv_std_logic_vector(64, 32); -- x"00000040"
	RE <= '1';
	WE <= '0';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 7. Read-Miss: TAG4 SET0 W0 WORD 0
	--	@MC_T[SET0] = 4, @MC_D[SET0 W1 0-3] = [0xc,0xd,0xe,0xf]
	---------------------------------------------------------------------------
	-- Debe ser fallo de lectura y reemplazar el cjto 0 de la via 0. Traemos 
	-- c,d,e,f.
	Addr <= conv_std_logic_vector(256, 32); -- x"00000100"
	RE <= '1';
	WE <= '0';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 8. Read-Miss: TAG3 SET0 W1 WORD 0
	--	@MC_T[SET0] = 3, @MC_D[SET0 W1 0-3] = [0x10,0x11,0x12,0x13]
	---------------------------------------------------------------------------
	-- Debe ser fallo de lectura y reemplazar el cjto 0 de la via 1. Traemos 
	-- x11,x12,x13,x14.
	Addr <= conv_std_logic_vector(192, 32); -- x"000000C0"
	RE <= '1';
	WE <= '0';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 9. Write de Memoria Scratch, no cacheable.
	--	@MD_S[1] = x"000000FF"
	---------------------------------------------------------------------------
	-- Escritura en la memoria scratch (no cacheable). Se debe escribir FF en 
	-- la posicion 1 (4/4).
	Addr <= x"10000004"; 
	RE <= '0';
	WE <= '1';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 10. Read de Memoria Scratch, no cacheable.
	--	Dout = @MD_S[1] = x"000000FF"
	---------------------------------------------------------------------------
	-- Lectura de la memoria scratch (no cacheable). Se debe leer FF de la 
	-- posicion 1 (4/4).
	Addr <= x"10000004"; 
	RE <= '1';
	WE <= '0';
	wait for 1 ns;
    if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for 1 ns;
    -- A veces un pulso espureo (en este caso en Mem_ready) puede hacer que 
	-- vuestro banco de pruebas se adelante. Si esperamos un ns desaparecera el 
	-- pulso espureo, pero no el real.	  
	if Mem_ready = '0' then 
		wait until Mem_ready ='1'; 
	end if;
	wait for clk_period;

	---------------------------------------------------------------------------
	-- Prueba 11. Read de Master_IO
	--	Dout = x"00001000"
	---------------------------------------------------------------------------
	-- Leemos el valor que ha escrito Master_IO. El ultimo es X"00001000".
	Addr <= x"10000000";
	RE <= '1';
	WE <= '0';
	wait for 1 ns;

	-- Si no cambiamos los valores nos quedamos pidiendo todo el rato el mismo
	-- valor a la memoria scratch. Se puede ver como una y otra vez habra que 
	-- esperar a que la memoria lo envie. Ya que al no ser cacheable no se 
	-- almacena en MC.
	wait;
end process;

END;
