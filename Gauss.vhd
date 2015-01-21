library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use ieee.math_real.all;

entity Gauss_gen is
	port (
		run_gauss     : in std_logic;
		clk           : in std_logic;
		def_1X_0H     : in std_logic;
		gauss_signal_int	: out	integer;
		gauss_signal  : out std_logic_vector(15 downto 0):="0111111111111111");
	end Gauss_gen;


architecture Behavioral of Gauss_gen is
	signal  sample_logic		: std_logic_vector(7 downto 0) :="00000000";
--	signal  amplitude			: std_logic_vector(15 downto 0) :="0000000000000000";
	signal  amplitude			: integer;

begin

	process(run_gauss, clk) --sampling
	variable	counter	: integer :=0;
	begin
		if rising_edge(clk) then
			if run_gauss = '1' then
				if def_1X_0H = '0' and counter < 25 then			--  HADAMARD
					counter := counter + 1;
					sample_logic  	<= sample_logic + 4;
--					amplitude     	<= "0110000000000000";
					amplitude		<= 9;
				elsif def_1X_0H = '0' and counter >= 25 then
--					amplitude     	<= "0000000000000000";
					sample_logic	<= "11111111";
					amplitude		<= 0;
				elsif def_1X_0H = '1' and counter < 33 then		    --  X-FLIP
					counter := counter + 1;
					sample_logic  	<= sample_logic + 5;
--					amplitude     	<= "0111111111011111";
					amplitude		<= 12;
				elsif def_1X_0H = '1' and counter >= 33 then
--					amplitude     	<= conv_std_logic_vector(0,16);
					sample_logic	<= "11111111";
					amplitude		<= 0;
				end if;
			elsif run_gauss = '0' then
				counter :=0;
				sample_logic	<= "11111111";
			end if;
		end if;
	end process;
	

	process(run_gauss, clk)
		variable sample_int       		: integer;
		variable gauss_signal_int    	: integer;
		variable amplitude_int    		: integer;
		type ROM is array (0 to 255) of integer;
		variable Gauss_mem      		: ROM := (
			200,  226,  256,  288,  325,  365,  409,  457,  511,  
			569,  633,  703,  779,  861,  950,  1047, 1151, 1262, 
			1383, 1511, 1648, 1794, 1950, 2114, 2288, 2472, 2665, 
			2867, 3079, 3300, 3530, 3769, 4016, 4271, 4533, 4802, 
			5077, 5357, 5641, 5930, 6220, 6512, 6805, 7097, 7387, 
			7673, 7956, 8232, 8502, 8763, 9015, 9256, 9485, 9700, 
			9901, 10087,10255,10407,10540,10654,10748,10821,10874,  
			10906,10917,10906,10874,10821,10748,10654,10540,10407,
			10255,10087,9901, 9700, 9485, 9256, 9015, 8763, 8502,
			8232, 7956, 7673, 7387, 7097, 6805, 6512, 6220, 5930, 
			5641, 5357, 5077, 4802, 4533, 4271, 4016, 3769, 3530,
			3300, 3079, 2867, 2665, 2472, 2288, 2114, 1950, 1794, 
			1648, 1511, 1383, 1262, 1151, 1047, 950,  861,  779,  
			703,  633 ,569, 511,  457,  409,  365,  325,  288,
			256,  226, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	begin
		sample_int         		:= conv_integer(sample_logic);
--		amplitude_int      		:= conv_integer(amplitude);
		if run_gauss = '0' then
			gauss_signal	<= "0111111111111111";
		elsif rising_edge(clk) then
--			gauss_signal_int    	:= amplitude*Gauss_mem(sample_int)/10917+32767;
			gauss_signal_int    	:= amplitude*Gauss_mem(sample_int)/4+32767;
			gauss_signal     		<= conv_std_logic_vector(gauss_signal_int,16);
		end if;
	end process;
end Behavioral;
