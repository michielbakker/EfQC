library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Ancilla_measure is
	port (
		run_ancilla :  in std_logic;                                               -- c-phase operation runs while this is "1"
		clk :         in std_logic;
		sig_out0 :     out std_logic_vector(15 downto 0) :="0111111111111111";     -- signal to out0
		sig_out1 :     out std_logic_vector(15 downto 0) :="0111111111111111");    -- signal to out3
	end Ancilla_measure;
	
architecture Behavioral of Ancilla_measure is
begin
	process (clk, run_parity)
	begin
	if rising_edge(clk) then
		if run_parity = '1' then
			sig_out0 <= "1011111111011111"; -- 500 mV
			sig_out1 <= "1011111111011111"; -- 500 mV
		else
			sig_out0 <= "0111111111111111"; -- 0 mV
			sig_out1 <= "0111111111111111"; -- 0 mV
		end if;
	end if;
	end process;
end Behavioral;