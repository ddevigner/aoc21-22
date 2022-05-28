---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:18 05/15/2014 
-- Design Name: 
-- Module Name:    UC_slave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: la UC incluye un contador de 2 bits para llevar la cuenta de las transferencias de bloque y una m�quina de estados
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

entity UC_MC is
    Port (
		clk                : in  STD_LOGIC;
		reset              : in  STD_LOGIC;
		RE                 : in  STD_LOGIC; -- RE y WE son las ordenes del MIPs.
		WE                 : in  STD_LOGIC;
		hit0               : in  STD_LOGIC; -- Se activa si hay acierto en la via 0.
		hit1               : in  STD_LOGIC; -- Se activa si hay acierto en la via 1.
		addr_non_cacheable : in  STD_LOGIC; -- Indica que la direccion no debe almacenarse en MC. En este caso porque pertenece a la scratch.
		bus_TRDY           : in  STD_LOGIC; -- Indica que el esclavo no puede realizar la operacion solicitada en este ciclo
		Bus_DevSel         : in  STD_LOGIC; -- Indica que el esclavo ha reconocido que la direccion esta dentro de su rango
		via_2_rpl          : in  STD_LOGIC; -- Indica que via se va a reemplazar
		Bus_grant          : in  STD_LOGIC; -- Indica la concesion del uso del bus
		Bus_req      	   : out STD_LOGIC; -- Indica la peticion al arbitro del uso del bus
        MC_WE0       	   : out STD_LOGIC; -- Write enable de la via 0.
        MC_WE1       	   : out STD_LOGIC; -- Write enable de la via 1.
        MC_bus_Rd_Wr 	   : out STD_LOGIC; -- 0 si lectura, 1 si escritura en Memoria.
        MC_tags_WE 		   : out STD_LOGIC; -- Para escribir la etiqueta en la memoria de etiquetas
        palabra    		   : out STD_LOGIC_VECTOR (1 downto 0); -- Indica la palabra actual dentro de una transferencia de bloque (1, 2...)
        mux_origen 		   : out STD_LOGIC; -- Se utiliza para elegir si el origen de la direccion y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
        ready      		   : out STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habra que detener el MIPs
        block_addr 		   : out STD_LOGIC; -- indica si la direccion a enviar es la de bloque (rm) o la de palabra (w)
		MC_send_addr_ctrl  : out STD_LOGIC; -- Ordena que se envien la direccion y las señales de control al bus
        MC_send_data 	   : out STD_LOGIC; -- Ordena que se envien los datos
        Frame 		 	   : out STD_LOGIC; -- Indica que la operacion no ha terminado
        last_word 		   : out STD_LOGIC; -- Indica que es el ultimo dato de la transferencia
        mux_output		   : out STD_LOGIC; -- Para elegir si le mandamos al procesador la salida de MC (valor 0)o los datos que hay en el bus (valor 1)
		inc_m     		   : out STD_LOGIC; -- Indica que ha habido un fallo.
		inc_w     		   : out STD_LOGIC  -- Indica que ha habido una escritura.			
    );
end UC_MC;

architecture Behavioral of UC_MC is

component counter_2bits is
	Port (
		clk  		 : in  STD_LOGIC;
		reset		 : in  STD_LOGIC;
		count_enable : in  STD_LOGIC;
		count        : out STD_LOGIC_VECTOR (1 downto 0)
	);
end component;	

-- Estados del automata de la Unidad de Control de la Memoria Cache:
--	1. Fetch: se busca el dato en Memoria Cache, si es Read-hit, continua 
--	   la ejecucion, si no, realiza peticion de bus y una vez concedido
-- 	   comienza las politicas de Lectura/Escritura.
--
--  2. Send_addr: la UC manda la dirección del dato necesitado, si ha habido 
--	   Read-miss sobre direccion cacheable, se mandará la direccion de bloque,
--     si no, será solo del dato, una vez el Worker identifique la dirección, 
-- 	   comenzará la transferencia de datos.
--
-- 	3. Data_trnf: la UC leerá el bloque o la palabra correspondiente si es 
--	   lectura (dependiendo de si la direccion es o no cacheable) o mandará
--	   la palabra (politicas write-through + write-around) una vez el Worker
--	   indique que puede completar la transferencia.
type state_type is (
	Fetch,
	Send_addr,
	Data_trnf
); 

-- Estado actual del sistema y siguiente estado.
signal state, next_state : state_type;
-- Se activa cuando se esta pidiendo la ultima palabra de un bloque.
signal last_word_block	 : std_logic; 
-- Se activa cuando solo se quiere transferir una palabra.
-- signal one_word		 : std_logic;
-- Señal que habilita el contador de palabras transferidas.
signal count_enable		 : std_logic;
-- Señal que indica si ha habido hit en cualquiera de las vias.
signal hit				 : std_logic;
-- Registro del numero de palabras transferidas actual.
signal palabra_UC 		 : STD_LOGIC_VECTOR (1 downto 0);
begin


hit <= hit0 or hit1;	

-- El contador nos dice cuantas palabras hemos recibido. Se usa para saber
-- cuando se termina la transferencia del bloque y para direccionar la palabra 
-- en la que se escribe el dato leido del bus en la MC. Indica la palabra actual 
-- dentro de una transferencia de bloque (1, 2...).
word_counter: counter_2bits port map (clk, reset, count_enable, palabra_UC); 

-- Se activa cuando estamos pidiendo la ultima palabra.
last_word_block <= '1' when (palabra_UC = "11") else '0';

palabra <= palabra_UC;

-- Registro de estado
SYNC_PROC: process (clk)
begin
	if (clk'event and clk = '1') then
    	if (reset = '1') then
        	state <= Fetch;
    	else
        	state <= next_state;
    	end if;        
	end if;
end process;

-- Automata de Mealy de la Unidad de Control.
OUTPUT_DECODE: process (state, RE, WE, hit0, hit1, hit, addr_non_cacheable, 
	bus_TRDY, Bus_DevSel, via_2_rpl, Bus_grant, last_word_block)
begin
	next_state <= state;
	Bus_req <= '0';
	MC_WE0 <= '0';
	MC_WE1 <= '0';
	MC_bus_Rd_Wr <= '0';
	MC_tags_WE <= '0';
	mux_origen <= '0';
	ready <= '0';
	block_addr <= '0';
	MC_send_addr_ctrl <= '0';
	MC_send_data <= '0';
	Frame <= '0';
	count_enable <= '0';
	last_word <= '0';
	mux_output <= '0';
	inc_m <= '0';
	inc_w <= '0';

	-- Estado Fetch:
	if (state = Fetch) then
		if (RE = '0' and WE = '0') or (hit = '1' and RE = '1') then ready <= '1';
		else
			Bus_req <= '1';
			if (Bus_grant = '1') then
				next_state <= Send_addr;
				inc_m <= RE or (WE and not(hit));
			end if;
		end if;
	
	-- Estado Send_addr:
	elsif (state = Send_addr) then 
		MC_send_addr_ctrl <= '1';
		Frame <= '1';

		block_addr <= RE and not(addr_non_cacheable);
		MC_bus_Rd_Wr <= not(RE);

		if (Bus_DevSel = '1') then next_state <= Data_trnf;
		end if;
	
	-- Estado Data_trnf:
	elsif (state = Data_trnf) then
		Frame <= '1';
		if (Bus_TRDY = '1') then
			if (RE = '1') then
				if (addr_non_cacheable = '0') then
					count_enable <= '1';
					mux_origen <= '1';
					inc_w <= '1';

					MC_WE0 <= not(via_2_rpl);
					MC_WE1 <= via_2_rpl;

					if (last_word_block = '1') then 
						next_state <= Fetch;
						MC_tags_WE <= '1';
						last_word <= '1';
					end if;
				else
					next_state <= Fetch;
					ready <= '1';
					mux_output <= '1';
					last_word <= '1';
				end if;
			else
				next_state <= Fetch;
				ready <= '1';
				MC_send_data <= '1';
				last_word <= '1';
				MC_WE0 <= hit0 and not(addr_non_cacheable);
				MC_WE1 <= hit1 and not(addr_non_cacheable);
				inc_w <= not(addr_non_cacheable) and hit;
			end if;
		end if;
	end if;
end process;

end Behavioral;
