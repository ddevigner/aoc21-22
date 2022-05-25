-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  use IEEE.std_logic_arith.all;
  use IEEE.std_logic_unsigned.all;


  ENTITY testbench_MD_mas_MC IS
  END testbench_MD_mas_MC;

  ARCHITECTURE behavior OF testbench_MD_mas_MC IS 

  -- Component Declaration
  COMPONENT MD_mas_MC is port (
		  CLK : in std_logic;
		  reset: in std_logic; -- sólo resetea el controlador de DMA
		  ADDR : in std_logic_vector (31 downto 0); --Dir 
          Din : in std_logic_vector (31 downto 0);--entrada de datos desde el Mips
          WE : in std_logic;		-- write enable	del MIPS
		  RE : in std_logic;		-- read enable del MIPS	
		   IO_input: in std_logic_vector (31 downto 0); --dato que viene de una entrada del sistema
		  Mem_ready: out std_logic; -- indica si podemos hacer la operación solicitada en el ciclo actual
		  Dout : out std_logic_vector (31 downto 0)); --salida que puede leer el MIPS
end COMPONENT;

          SIGNAL clk, reset, RE, WE, Mem_ready :  std_logic;
          signal ADDR, Din, Dout, IO_input : std_logic_vector (31 downto 0);
         
			           
  -- Clock period definitions
   constant CLK_period : time := 10 ns;
  BEGIN

  -- Component Instantiation
   uut: MD_mas_MC PORT MAP(clk=> clk, reset => reset, ADDR => ADDR, Din => Din, RE => RE, WE => WE, IO_input => IO_input, Mem_ready => Mem_ready, Dout => Dout);

-- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;

 stim_proc: process
   begin		
      		
    	reset <= '1';
  	   	addr <= conv_std_logic_vector(0, 32);--conv_std_logic_vector convierte el primer número (un 0) a un vector de tantos bits como se indiquen (en este caso 32 bits)
  	   	Din <= conv_std_logic_vector(255, 32);
		-- IO_input. Lo voy a ir cambiando para que se vea como cambia en el scratch
  	   	IO_input <= conv_std_logic_vector(1024, 32);
  	   	RE <= '0';
		WE <= '0';
	  	wait for 20 ns;	
	  	reset <= '0';
	  	RE <= '1';
	  	Addr <= conv_std_logic_vector(64, 32); -- Debe ser un fallo de lectura. Traemos: 1,2,3 y 4 al cjto 0 via 0. Mandamos al mips la primera palabra (un 1)
	  	wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; --Este wait espera hasta que se ponga Mem_ready a uno
	  	end if;
		wait for clk_period;
      	Addr <= conv_std_logic_vector(68, 32); --Debe ser un acierto de lectura. Devolvemos un 2 al procesador
	  	wait for 1ns;
      	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		-- IO_input. Segundo valor
		IO_input <= conv_std_logic_vector(2048, 32);
		Addr <= conv_std_logic_vector(72, 32); --Debe ser un acierto de escritura. Escribimos FF en @24 y en la tercera palabra del bloque de MC del cjto 2 via 0
		RE <= '0';
		WE <= '1';
		-- La idea de estos wait es esperar a que la señal Mem_ready se active (y si ya está activa no hacer nada)
		wait for 1ns;
        if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= conv_std_logic_vector(96, 32); --Debe ser un fallo de escritura. NO se trae el bloque. Escribimos FF en memoria 
		RE <= '0';
		WE <= '1';
		wait for 1ns;
        if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		-- IO_input. Tercer valor
		IO_input <= conv_std_logic_vector(4096, 32);
		Addr <= conv_std_logic_vector(128, 32); --Debe ser un fallo de lectura y almacenarse 9, 10, 11 y 12 en el cjto 0 en la via 1
		RE <= '1';
		WE <= '0';
		wait for 1ns;
      	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
       	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= conv_std_logic_vector(64, 32); --Debe ser acierto de lectura
		RE <= '1';
		WE <= '0';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= conv_std_logic_vector(256, 32); --Debe ser fallo de lectura y reemplazar el cjto 0 de la via 0. Traemos c,d,e,f
		RE <= '1';
		WE <= '0';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= conv_std_logic_vector(192, 32); --Debe ser fallo de lectura y reemplazar el cjto 0 de la via 1. Traemos x11,x12,x13,x14
		RE <= '1';
		WE <= '0';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= x"10000004"; --Escritura en la memoria scratch (no cacheable). Se debe escribir FF en la posición 4
		RE <= '0';
		WE <= '1';
		wait for 1ns;
    	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
	  	wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real
	  	if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= x"10000004"; --Lectura de la memoria scratch (no cacheable). Se debe leer FF de la posición 4
		RE <= '1';
		WE <= '0';
		wait for 1ns;
      if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for 1ns;
        -- a veces un pulso espureo (en este caso en mem_ready) puede hacer que vuestro banco de pruebas se adelante. 
        -- si esperamos un ns desaparecerá el pulso espureo, pero no el real	  
		if Mem_ready = '0' then 
			wait until Mem_ready ='1'; 
	  	end if;
		wait for clk_period;
		Addr <= x"10000000"; --Leemos el valor que ha escrito Master_IO. El último es X"00001000"
		RE <= '1';
		WE <= '0';
		wait for 1ns;
--Si no cambiamos los valores nos quedamos pidiendo todo el rato el mismo valor a la memoria scratch. Se puede ver como una y otra vez habrá que esperar a que la memoria lo envie. Ya que al no ser cacheable no se almacena en MC
	  	wait;
   end process;


  END;
