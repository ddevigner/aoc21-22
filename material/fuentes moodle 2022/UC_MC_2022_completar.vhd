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
-- Additional Comments: la UC incluye un contador de 2 bits para llevar la cuenta de las transferencias de bloque y una máquina de estados
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
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			RE : in  STD_LOGIC; --RE y WE son las ordenes del MIPs
			WE : in  STD_LOGIC;
			hit0 : in  STD_LOGIC; --se activa si hay acierto en la via 0
			hit1 : in  STD_LOGIC; --se activa si hay acierto en la via 1
			addr_non_cacheable: in STD_LOGIC; --indica que la dirección no debe almacenarse en MC. En este caso porque pertenece a la scratch
			bus_TRDY : in  STD_LOGIC; --indica que el esclavo no puede realizar la operación solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que el esclavo ha reconocido que la dirección está dentro de su rango
			via_2_rpl :  in  STD_LOGIC; --indica que via se va a reemplazar
			Bus_grant :  in  STD_LOGIC; --indica la concesión del uso del bus
			Bus_req :  out  STD_LOGIC; --indica la petición al árbitro del uso del bus
         MC_WE0 : out  STD_LOGIC; -- write enable de la VIA0 y 1
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
         last_word : out  STD_LOGIC; --indica que es el último dato de la transferencia
         mux_output: out  STD_LOGIC; -- para elegir si le mandamos al procesador la salida de MC (valor 0)o los datos que hay en el bus (valor 1)
			inc_m : out STD_LOGIC; -- indica que ha habido un fallo
			inc_w : out STD_LOGIC -- indica que ha habido una escritura			
           );
end UC_MC;

architecture Behavioral of UC_MC is


component counter_2bits is
		    Port ( clk : in  STD_LOGIC;
		           reset : in  STD_LOGIC;
		           count_enable : in  STD_LOGIC;
		           count : out  STD_LOGIC_VECTOR (1 downto 0)
					  );
end component;		           
-- Ejemplos de nombres de estado. Poned los vuestros. Nombrad a vuestros estados con nombres descriptivos. Así se facilita la depuración
type state_type is (Inicio, single_word_transfer_addr, single_word_transfer_data); 
signal state, next_state : state_type; 
signal last_word_block: STD_LOGIC; --se activa cuando se está pidiendo la última palabra de un bloque
signal one_word: STD_LOGIC; --se activa cuando sólo se quiere transferir una palabra
signal count_enable: STD_LOGIC; -- se activa si se ha recibido una palabra de un bloque para que se incremente el contador de palabras
signal hit: std_logic;
signal palabra_UC : STD_LOGIC_VECTOR (1 downto 0);
begin
 
hit <= hit0 or hit1;	
 
--el contador nos dice cuantas palabras hemos recibido. Se usa para saber cuando se termina la transferencia del bloque y para direccionar la palabra en la que se escribe el dato leido del bus en la MC
word_counter: counter_2bits port map (clk, reset, count_enable, palabra_UC); --indica la palabra actual dentro de una transferencia de bloque (1ª, 2ª...)

last_word_block <= '1' when palabra_UC="11" else '0';--se activa cuando estamos pidiendo la última palabra


palabra <= palabra_UC;

-- Registro de estado
   SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            state <= Inicio;
         else
            state <= next_state;
         end if;        
      end if;
   end process;
 
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, hit, last_word_block, bus_TRDY, RE, WE, Bus_DevSel, Bus_grant, via_2_rpl, hit0, hit1, addr_non_cacheable)
   begin
-- valores por defecto, si no se asigna otro valor en un estado valdrán lo que se asigna aquí
		MC_WE0 <= '0';
		MC_WE1 <= '0';
		MC_bus_Rd_Wr <= '0';
		MC_tags_WE <= '0';
        ready <= '0';
        mux_origen <= '0';
        MC_send_addr_ctrl <= '0';
        MC_send_data <= '0';
        next_state <= state;  
		count_enable <= '0';
		Frame <= '0';
		block_addr <= '0';
		inc_m <= '0';
		inc_w <= '0';
		Bus_req <= '0';
		one_word <= '0';
		mux_output <= '0';
		last_word <= '0';
				
        -- Estado Inicio          
      	if (state = Inicio and RE= '0' and WE= '0') then -- si no piden nada no hacemos nada
			next_state <= Inicio;
			ready <= '1';
      	elsif (state = Inicio and RE= '1' and  hit='1') then -- si piden y es acierto de lectura mandamos el dato
         	next_state <= Inicio;
			ready <= '1';
			mux_output <= '0'; --Es el valor por defecto. No hace falta ponerlo. Salida de la MC
		elsif --poner el resto de casos. No escribáis nada, hasta tener una máquina de estados bien definida
		
		end if;
		
   end process;
 
   
end Behavioral;

