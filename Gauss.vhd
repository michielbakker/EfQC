library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Gauss_gen is
	port (
		rst           : in std_logic;
		clk           : in std_logic;
		amplitude     : in std_logic_vector(1 downto 0); -- in steps of 250 mV
		def_1X_0H     : in std_logic;
		gauss_signal  : out std_logic_vector(15 downto 0));
	end Gauss_gen;


architecture Behavioral of Gauss_gen is
	signal  sample_logic      : std_logic_vector(4 downto 0);
	signal  mVperstep         : integer := 100;

begin

	process(rst, clk) --sampling
	begin
		if rst = '1' then
			sample_logic  <= (others => '0');
			elsif rising_edge(clk) then
			if def_1X_0H = "0" then           --  HADAMARD
				sample_logic  <= sample_logic + 4;
				amplitude     <= 
			else                              --  X-FLIP
				sample_logic  <= sample_logic + 5;
				amplitude     <= 
			end if;
		end if;
	end process;

	process(rst, clk)
		variable sample_int       : integer;
		variable Gauss_env_int    : integer;
		variable amplitude_int    : integer;
		type ROM is array (0 to 255) of integer;
			variable Gauss_mem      : ROM := (
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
		sample_int      := conv_integer(sample_logic);
		amplitude_int   := conv_integer(amplitude);
		if Rst = '1' then
			Gauss_env     <= (others => '0');
		elsif rising_edge(clk) then
			Gauss_env_int := amplitude_int*Gauss_mem(sample_int)+;
			Gauss_env   <=  conv_std_logic_vector(Gauss_env_int,16);
		end if;
	end process;

end Behavioral;