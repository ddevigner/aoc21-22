-------------------------------------------------------------------------------
-- Este modulo monitoriza una entrada del sistema y la escribe a traves del bus
-- en una direccion de memoria de la Scratch. En la version actual intenta 
-- escribir siempre (IO_M_Req ='1') el dato que recibe (IO_input) que 
-- representa una entrada del sistema. Lo escribe en la ultima palabra de la 
-- Scratch. De esta forma el procesador puede acceder al valor de la entrada. 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IO_master is
    Port (
		clk  		   : in  STD_LOGIC; 
		reset		   : in  STD_LOGIC; 
		IO_M_bus_Grant : in  std_logic; 
		IO_input       : in  STD_LOGIC_VECTOR (31 downto 0);
		-- Indica que el esclavo no puede realizar la operacion solicitada en 
		-- este ciclo.
		bus_TRDY       : in  STD_LOGIC;
		-- Indica que el esclavo ha reconocido que la direccion esta dentro de 
		-- su rango.
		Bus_DevSel     : in  STD_LOGIC;
		IO_M_Req  	   : out std_logic; 
		IO_M_Read 	   : out std_logic;
		IO_M_Write	   : out std_logic;
		IO_M_bus_Frame : out std_logic; 
		IO_M_send_Addr : out std_logic;
		IO_M_send_Data : out std_logic;
		IO_M_last_word : out std_logic;
		IO_M_Addr	   : out STD_LOGIC_VECTOR (31 downto 0);
		IO_M_Data	   : out STD_LOGIC_VECTOR (31 downto 0)
	);
end IO_master;

Architecture Behavioral of IO_master is

type state_type is (Inicio, send_addr, send_data); 
signal state, next_state : state_type;

begin
-------------------------------------------------------------------------------
-- Maquina de estados del master
-------------------------------------------------------------------------------
-- Maquina de estados para de la memoria scratch
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Mealy State-Machine - Outputs based on state and inputs
-------------------------------------------------------------------------------
-- Esta maquina de estados gestiona la escritura de la entrada IO en la ultima 
-- palabra de la Scratch
-------------------------------------------------------------------------------
OUTPUT_DECODE: process (state, IO_M_bus_Grant, bus_TRDY, Bus_DevSel)
begin
	-- Valores por defecto, si no se asigna otro valor en un estado valdran lo 
	-- que se asigna aqui:
	IO_M_Req <= '0'; -- Si no lo tenemos pedimos el bus
	IO_M_bus_Frame <= '0';	
	IO_M_send_Addr <= '0';	
	IO_M_send_Data <= '0';	
	IO_M_last_word <= '0';	
	IO_M_Read <= '0'; -- Nunca lee.
	IO_M_Write <= '0';

	-- Mandamos siempre la misma @ la direccion 0 de la scratch. De esta forma 
	-- el procesador puede leer la entrada externa:
	IO_M_Addr <= X"10000000";
	IO_M_Data <= IO_input; -- escribe el dato de la entrada	
	next_state <= Inicio; --Por defecto nos quedamos en inicio

	-- Estado inicial: Espera   
	if (state = Inicio) then
		IO_M_Req <= '1';
		-- Si no nos dan el bus no hacemos nada.
		if (IO_M_bus_Grant= '0') then 
			next_state <= Inicio;
		-- Si nos dan el bus cambiamos de estado.
      	else  
        	next_state <= send_addr;
		end if;
	-- En este ciclo mandamos la direccion y terminamos.
    elsif (state = send_addr) then 
		IO_M_send_Addr <= '1';
		IO_M_Write <= '1'; -- Indicamos que queremos escribir.
		IO_M_bus_Frame <= '1'; -- Activamos bus_frame para deshabilitar al arbitro.
		-- Si el esclavo reconoce la direccion pasamos a la fase de datos.
		if (Bus_DevSel = '1') then
			next_state <= send_data;
		else
			next_state <= send_addr;
		end if;
    elsif state= send_data then 	
        IO_M_send_Addr <= '0';
		IO_M_bus_Frame <= '1'; -- Activamos bus_frame para deshabilitar al arbitro.
		IO_M_send_Data <= '1'; -- Enviamos el dato de la entrada.
		-- Si el esclavo esta preparado se realiza la escritura en la scratch.
        if (bus_TRDY = '1') then
			next_state <= inicio;
			IO_M_last_word <= '1'; -- Indicamos que es la ultima palabra.
		else
			next_state <= send_data;
		end if;   			
		IO_M_send_Data <= '1'; 
		IO_M_last_word <= '1'; -- Indicamos que es la ultima palabra			
	end if;
end process;

end Behavioral;
