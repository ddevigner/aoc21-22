----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 04/08/2014 
-- Design Name: 
-- Module Name:    
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: La memoria cache está compuesta de 8 bloques de 4 datos con: asociatividad 2, escritura directa, y la politica convencional en fallo de escritura (fetch on write miss). 
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
use ieee.numeric_std.all; -- se usa para convertir std_logic a enteros


entity MC_datos is port (
			CLK : in std_logic;
			reset : in  STD_LOGIC;
			--Interfaz con el MIPS
			--entradas
			ADDR : in std_logic_vector (31 downto 0); --Dir 
			Din : in std_logic_vector (31 downto 0);
			RE : in std_logic;		-- read enable		
			WE : in  STD_LOGIC; 
			--salidas
			ready : out  std_logic;  -- indica si podemos hacer la operación solicitada en el ciclo actual
			Dout : out std_logic_vector (31 downto 0); --dato que se envía al Mips
			--Interfaz con el bus
			--entradas
			MC_Bus_Din : in std_logic_vector (31 downto 0);--para leer datos del bus
			Bus_TRDY : in  STD_LOGIC; --indica que el esclavo (la memoriade datos)  puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			MC_Bus_Grant: in  STD_LOGIC; --indica que el árbitro permite usar el bus a la MC;
			--salidas
			MC_send_addr_ctrl : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
			MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
			MC_frame : out  STD_LOGIC; --indica que la operación no ha terminado
			MC_Bus_ADDR : out std_logic_vector (31 downto 0); --Dir 
			MC_Bus_data_out : out std_logic_vector (31 downto 0);--para enviar datos por el bus
			MC_bus_Rd_Wr : out  STD_LOGIC; --'0' para lectura,  '1' para escritura
			MC_Bus_Req: out  STD_LOGIC; --indica que la MC quiere usar el bus;
			MC_last_word : out  STD_LOGIC --indica que es el último dato de la transferencia
			 );
end MC_datos;

architecture Behavioral of MC_datos is

component UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit0 : in  STD_LOGIC; --se activa si hay acierto en la via 0
			hit1 : in  STD_LOGIC; --se activa si hay acierto en la via 1
			bus_TRDY : in  STD_LOGIC; --indica que la memoria puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la dirección está dentro de su rango
			via_2_rpl :  in  STD_LOGIC; --indica que via se va a reemplazar
			Bus_grant :  in  STD_LOGIC; --indica la concesión del uso del bus
			addr_non_cacheable: in STD_LOGIC; --indica que la dirección no debe almacenarse en MC. En este caso porque pertenece a la scratch
			--salidas
			MC_WE0 : out  STD_LOGIC;
            MC_WE1 : out  STD_LOGIC;
            MC_bus_Rd_Wr : out  STD_LOGIC; --1 para escritura en Memoria y 0 para lectura
			MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
            palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)
            mux_origen: out STD_LOGIC; -- Se utiliza para elegir si el origen de la dirección y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
            ready : out  STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habrá que detener el MIPs
            block_addr : out  STD_LOGIC; -- indica si la dirección a enviar es la de bloque (rm) o la de palabra (w)
			MC_send_addr_ctrl : out  STD_LOGIC; --ordena que se envíen la dirección y las señales de control al bus
            MC_send_data : out  STD_LOGIC; --ordena que se envíen los datos
            Frame : out  STD_LOGIC; --indica que la operación no ha terminado
            inc_m : out STD_LOGIC; -- indica que ha habido un fallo
			inc_w : out STD_LOGIC; -- indica que ha habido una escritura
            mux_output: out  STD_LOGIC; -- para elegir si le mandamos al procesador la salida de MC (valor 0)o los datos que hay en el bus (valor 1)
            last_word : out  STD_LOGIC; --indica que es el último dato de la transferencia
            Bus_req :  out  STD_LOGIC --indica la petición al árbitro del uso del bus
            );
end component;

component reg4 is
    Port (  Din : in  STD_LOGIC_VECTOR (3 downto 0);
            clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
            load : in  STD_LOGIC;
            Dout :out  STD_LOGIC_VECTOR (3 downto 0));
end component;		

component counter is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           count_enable : in  STD_LOGIC;
           load : in  STD_LOGIC;
           D_in  : in  STD_LOGIC_VECTOR (7 downto 0);
		   count : out  STD_LOGIC_VECTOR (7 downto 0));
end component;	  

component Via is 
 	generic ( num_via: integer); -- se usa para los mensajes. Hay que poner el número correcto al instanciarla
 	port (	CLK : in std_logic;
			reset : in  STD_LOGIC;
 			Dir_word: in std_logic_vector(1 downto 0); -- se usa para elegir la palabra a la que se accede en un conjunto la cache de datos. 
 			Dir_cjto: in std_logic_vector(1 downto 0); -- se usa para elegir el conjunto
 			Tag: in std_logic_vector(25 downto 0);
 			Din : in std_logic_vector (31 downto 0);
			RE : in std_logic;		-- read enable		
			WE : in  STD_LOGIC; 	-- write enable	
			Tags_WE : in  STD_LOGIC; 	-- write enable para la memoria de etiquetas 
			hit : out STD_LOGIC; -- indica si es acierto
			Dout : out std_logic_vector (31 downto 0)) ;
end component;

component FIFO_reg is
port (
        clk : in std_logic;
		reset : in std_logic;
        cjto : in std_logic_vector (1 downto 0); --Dir del cjto reemplazado
        new_block : in std_logic;		-- Indica que hay un reemplazo y por tanto hay que actualizar la info del fifo del conjunto correspondiente				        
        via_2_rpl : out std_logic
            );
end component;

signal dir_cjto: std_logic_vector(1 downto 0); -- se usa para elegir el cjto al que se accede en la cache de datos. 
signal dir_word: std_logic_vector(1 downto 0); -- se usa para elegir la dato solicitada de un determinado bloque. 
signal internal_MC_bus_Rd_Wr, mux_origen, MC_Tags_WE, block_addr, new_block: std_logic;
signal via_2_rpl, Tags_WE_via0, Tags_WE_via1,hit0, hit1, WE_via0, WE_via1: std_logic;
signal palabra_UC: std_logic_vector(1 downto 0); --se usa al traer un bloque nuevo a la MC (va cambiando de valor para traer todas las palabras)
signal MC_Din, MC_Dout, Dout_via1, Dout_via0: std_logic_vector (31 downto 0);
signal Tag: std_logic_vector(25 downto 0); 
signal m_count, w_count: std_logic_vector(7 downto 0); 
signal inc_m, inc_w : std_logic;
signal addr_non_cacheable, mux_output, last_word : std_logic;
begin
 -------------------------------------------------------------------------------------------------- 
 -----MC_data: memoria RAM que almacena los 8 bloques de 4 datos que puede guardar la Cache
 -- dir palabra puede venir de la entrada (cuando se busca un dato solicitado por el Mips) o de la Unidad de control, UC, (cuando se está escribiendo un bloque nuevo 
 -------------------------------------------------------------------------------------------------- 
 -- la región que empieza por "00010000000000000000000" está definida como no cacheable.
 -- Las direcciones en esa región se envían a la MD_scratch y cuando responda se reenvia el resultado al procesador. 
 -- Nunca se debe guardar nada de ese intervalo en MC
 
 addr_non_cacheable <= '1' when Addr(31 downto 8) = x"100000" else '0';
 
 tag <= ADDR(31 downto 6); 
 dir_word <= ADDR(3 downto 2) when (mux_origen='0') else palabra_UC;
 dir_cjto <= ADDR(5 downto 4); -- es emplazamiento asociativo
 -- la entrada de datos de la MC puede venir del Mips (acceso normal) o del bus (gestión de fallos)
 MC_Din <= Din when (mux_origen='0') else MC_bus_Din;

Via_0: Via generic map (num_via => 0)PORT MAP(clk => clk, reset => reset, RE => RE, WE => WE_via0, Tags_WE => Tags_WE_via0, hit => hit0, Dir_cjto => Dir_cjto, Dir_word => Dir_word, Tag => Tag, Din => MC_Din, Dout => Dout_via0 );

Via_1: Via generic map (num_via => 1)PORT MAP(clk => clk, reset => reset, RE => RE, WE => WE_via1, Tags_WE => Tags_WE_via1, hit => hit1, Dir_cjto => Dir_cjto, Dir_word => Dir_word, Tag => Tag, Din => MC_Din, Dout => Dout_via1 );

MC_Dout <= Dout_via1 when (hit1='1') else Dout_via0;

new_block <= MC_Tags_WE; -- la info para el fifo se actualiza cada vez que se escribe una nueva etiqueta

Info_FIFO: FIFO_reg PORT MAP(clk => clk, reset => reset, cjto => dir_cjto, new_block => new_block, via_2_rpl => via_2_rpl);

-- se elige en qué via se escribe la nueva etiqueta según indique via_2_rpl
Tags_WE_via0 <= MC_Tags_WE and not(via_2_rpl);
Tags_WE_via1 <= MC_Tags_WE and via_2_rpl;

 
-------------------------------------------------------------------------------------------------- 
-----MC_UC: unidad de control
-------------------------------------------------------------------------------------------------- 
Unidad_Control: UC_MC port map (	clk => clk, reset=> reset, RE => RE, WE => WE, hit0 => hit0, hit1 => hit1, bus_TRDY => bus_TRDY, 
									bus_DevSel => bus_DevSel, MC_WE0 => WE_via0, MC_WE1 => WE_via1, MC_bus_Rd_Wr => internal_MC_bus_Rd_Wr, 
									MC_tags_WE=> MC_tags_WE, palabra => palabra_UC, mux_origen => mux_origen, ready => ready, MC_send_addr_ctrl=> MC_send_addr_ctrl, 
									block_addr => block_addr, MC_send_data => MC_send_data, Frame => MC_Frame, via_2_rpl => via_2_rpl, last_word => MC_last_word,
									addr_non_cacheable => addr_non_cacheable, mux_output=> mux_output, Bus_grant => MC_Bus_grant, Bus_req => MC_Bus_req, inc_m => inc_m, inc_w => inc_w );  
--------------------------------------------------------------------------------------------------
----------- Contadores de eventos
-------------------------------------------------------------------------------------------------- 
cont_m: counter port map (clk => clk, reset => reset, count_enable => inc_m , load=> '0', D_in => "00000000", count => m_count);
cont_w: counter port map (clk => clk, reset => reset, count_enable => inc_w , load=> '0', D_in => "00000000", count => w_count);


--------------------------------------------------------------------------------------------------
----------- Salidas para el bus
-------------------------------------------------------------------------------------------------- 
MC_bus_Rd_Wr <= internal_MC_bus_Rd_Wr;
--Si es escritura se manda la dirección de la palabra y si es un fallo la dirección del bloque que causó el fallo
MC_Bus_ADDR <= 	ADDR(31 downto 2)&"00" when block_addr ='0' else 
				ADDR(31 downto 4)&"0000"; 
					 
MC_Bus_data_out <= Din; -- se usa para mandar el dato a escribir
--------------------------------------------------------------------------------------------------
----------- Salidas para el Mips
-------------------------------------------------------------------------------------------------- 
Dout <= MC_Dout when mux_output ='0' else MC_bus_Din; -- se usa para mandar el dato que ha llegado por el bus directamente al Mips


end Behavioral;
