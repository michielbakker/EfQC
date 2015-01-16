library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

-- the entity is outputing 2 bits - one to confirm the validity of the
-- state and the other to inform about the state
-- Ancilla_state = "01" - measured qubit is zero
-- Ancilla_state = "11" - measured qubit is one
entity Ancilla_readout is 
	port (
		reset			: in std_logic;
		clk				: in std_logic;
		data_in 		: in std_logic_vector(11 downto 0);
		Ancilla_state	: out std_logic_vector(1 downto 0));
end Ancilla_readout;

architecture Behavioral of Ancilla_readout is

signal Set_to_zero, Set_to_one, int_reset : std_logic := '0';
signal Int_ancilla_state : std_logic_vector(1 downto 0);
signal cnt, cnt_zero, cnt_one : std_logic_vector(3 downto 0);

begin
	
	process (clk, reset)
	begin
		if reset = '1' then
			Set_to_one	<='0';
			Set_to_zero	<='0';
		elsif rising_edge(clk) then 
			if (data_in >= x"930" and data_in <= x"9B0") then
				Set_to_zero	<='1';
				Set_to_one	<='0';
			elsif (data_in >= x"880" and data_in <= x"8B0") then
				Set_to_one	<='1';
				Set_to_zero	<='0';
			else
				Set_to_one	<='0';
				Set_to_zero	<='0';
			end if;
		end if;
	end process;
	
	process (clk, reset)
	begin
		if reset = '1' then
			cnt<=(others=>'0');
		elsif rising_edge(clk) then 
			if cnt="1111" then
				int_reset	<= '1';
				cnt			<= cnt + '1';
			else
				int_reset	<= '0';
				cnt			<= cnt + '1';
			end if;
		end if;
	end process;
	
	process (int_reset, clk)
	begin
		if int_reset = '1' then
			cnt_zero	<= (others=>'0');
			cnt_one		<= (others=>'0');
		elsif rising_edge(clk) then
			if Set_to_one = '1' then
				cnt_one		<= cnt_one + '1';
			elsif(Set_to_zero='1') then
				cnt_zero	<= cnt_zero + '1';
			else 
				cnt_zero	<= cnt_zero;
				cnt_one		<= cnt_one;
			end if;
		end if;
	end process;
	
	process (cnt_zero, cnt_one)
	begin
		if cnt_zero > "0010" then
			Int_ancilla_state 	<= "01";
		elsif cnt_zero < cnt_one then
			Int_ancilla_state	<= "11";
		else
			Int_ancilla_state	<= "00";
		end if;
	end process;
	
	Ancilla_state	<= Int_ancilla_state;
	
end Behavioral;

