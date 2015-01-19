library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity bitflipcorrector is
 		port(
 				clk				: in STD_LOGIC;
 				
 				stateAncilla0	: in STD_LOGIC_VECTOR(1 downto 0);
 				stateAncilla1	: in STD_LOGIC_VECTOR(1 downto 0);

 				correctQB0		: out STD_LOGIC_VECTOR(15 downto 0) := "0111111111111111";
 				correctQB1		: out STD_LOGIC_VECTOR(15 downto 0) := "0111111111111111";
 				correctQB2		: out STD_LOGIC_VECTOR(15 downto 0) := "0111111111111111");


end bitflipcorrector;

 
 architecture Behavioral of bitflipcorrector is

signal rungauss	: STD_LOGIC := '0';
signal runx		: STD_LOGIC :='0';
signal temp0 : STD_LOGIC_VECTOR(15 downto 0);
signal temp1 : STD_LOGIC_VECTOR(15 downto 0);
signal temp2 : STD_LOGIC_VECTOR(15 downto 0) ;
variable counter : integer := 0;

Component Gauss is
		port (
				run_gauss : in std_logic;
				clk : 	in std_logic;
				def_1X_0H : in std_logic;
				gauss_signal : out std_logic_vector(15 downto 0));

		end Component;


begin 

process(clk, counter )

begin

if rising_edge(clk) then
		

		if counter = 129 then --number of steps to be specified

		rungaus <= '0';
		runx	<= '0';
		counter :=0;

		else 
		rungaus <= '1';
		runx <= '1';
		end if;

	if stateAncilla0 = "01" and stateAncilla1 ="01"  then   -- both qubit are measured 0,

	-- thus they have negative eigenvalues (m=-1), which means that we got a problem
	-- because we dont know which data qubit is corrupted
	-- lets assume the data qubit 1 is corrupted (middle one)

		corrrectQB1 	<= temp1;
		correctQB0		<= "0111111111111111";
 		correctQB2		<= "0111111111111111";

 		counter := counter +1;
	elsif  stateAncilla0 = "11" and stateAncilla1 ="01" then 

	-- Ancilla 1 has m=-1 thus data qubit 2 has to corrected
		
		corrrectQB2 	<= temp2;
		correctQB0		<= "0111111111111111";
 		correctQB1		<= "0111111111111111";
 		

		counter :=counter +1;

	 elsif stateAncilla0 = "01" and stateAncilla1 ="11"  then 

	 -- Ancilla 0 has m=-1 thus data qubit 0 has to be corrected
	 	corrrectQB0 <= temp0;
	 	correctQB1		<= "0111111111111111";
 		correctQB2		<= "0111111111111111";

		counter :=counter +1;
	  elsif stateAncilla0 = "11" and stateAncilla1 ="11" then 
	 -- nothing needs to be corrected
	 	correctQB0		<= "0111111111111111";
 		correctQB1		<= "0111111111111111";
 		correctQB2		<= "0111111111111111";

 		counter := counter +1;
 		

	 end if;
end if;

	


end process


ApplyXrotQB0 : Gauss
		port map (
			run_gauss 		=> rungaus,
			clk				=> clk,
			def_1X_0H		=> runx,
			gauss_signal	=> temp0);

ApplyXrotQB1 : Gauss
		port map (
			run_gauss 		=> rungaus,
			clk				=> clk,
			def_1X_0H		=> runx,
			gauss_signal	=> temp1);


ApplyXrotQB2 : Gauss
		port map (
			run_gauss 		=> rungaus,
			clk				=> clk,
			def_1X_0H		=> runx,
			gauss_signal	=> temp2);




			)

 end Behavioral;

 -- note you shouldn't continously run measurement,
 -- because it takes an amount of clock cycles to corrected
-- the corrupted state. So you have to at least wait the time
-- of the X rotation. That is 640 ns thus 32 clock cycles