----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:32:19 01/16/2015 
-- Design Name: 
-- Module Name:    Merge_template - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
library UNISIM;
use UNISIM.VComponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Finitestate_machine is
port(
		Out0		: std_logic_vector(15 downto 0);
		out1		: std_logic_vector(15 downto 0);
		Out2 		: std_logic_vecotr(15 downto 0);
		Out3		: std_logic_vector(15 downto 0);

		Ancilla0 	: std_logic_vector(7 downto 0);
		Ancilla1	: std_logic_vector(7 downto 0));

end Finitestate_machine;

architecture Behavioral of Finitestate_machine is



-- Defining all the Components
 
Component Entangle_Cphase is 
port  (
run_entangle	: in std_logic;
clk				: in std_logic;
QB_source		: out std_logic_vector(15 downto 0);
QB_target		: out std_logic_vector(15 downto 0);
)

Component DAC_interface is
	port(
		-- on board signals
		Sys_Rst_pin				:	in std_logic;
		Clk_Locked_pin			:	out std_logic;	
	
		
		-- signals to DAC
		Dac_Sync_p				: 	out std_logic;
		Dac_Sync_n				:	out std_logic;
		Dac_Data_clk_p_pin		:	out std_logic;
		Dac_Data_clk_n_pin		:	out std_logic;
		Dac_Data_out_p_pin		:	out std_logic_vector(15 downto 0);
		Dac_Data_out_n_pin		:	out std_logic_vector(15 downto 0);
		-- signals from DAC
		Dac_FPGA_clk_p_pin		:	in std_logic;
		Dac_FPGA_clk_n_pin		:	in std_logic;
		-- signals from ADC
		Data_in_clk				:	in std_logic;
		Data_rising				:	in std_logic_vector(15 downto 0);
		Data_falling			:	in std_logic_vector(15 downto 0));
		
end Component;

Component Gauss is
		port(
		run_gauss		: in std_logic;
		clk 			: in STD_LOGIC;
		def_1X_0H 		: in STD_LOGIC;
		gauss_signal	: out std_logic_vector(15 downto 0));
		
		
		end Component;
		
		
Component par_Cphase is 
		port(
		run_parity	: in std_logic;
		clk   		: in STD_LOGIC;
		QB1_sig		: out std_logic_vector(15 downto 0);
		QB2_sig		: out std_logic_vector(15 downto 0);
		anc_sig		: out std_logic_vector(15 downto 0));

	end Component;
	
	

Component Ancilla_readout is 
		port(
		clk					: in STD_LOGIC;
		reset				: in STD_LOGIC;
		data_in				: in std_logic_vector(11 downto 0);
		Ancilla_state		: out std_logic_vector(1 downto o));
		
end Component;

Component Measurement is
		port(
				run_ancilla		:in std_logic;
				clk				:in std_logic;
				sig_out0		: out std_logic_vector(15 downto 0)
				sig_out1		: out std_logic_vector(15 downto 0));
end  Component;




Component ADC_top_level is
 port (
		Sys_Rst_pin					: in std_logic; 
		Sys_Clk_p_pin       		: in std_logic;     -- System 200 MHz clock to generate 50 MHz
		Sys_Clk_n_pin       		: in std_logic; 
		-- 50 MHz sampling clock for ADC
		Adc_Sampling_clk_p_pin		: out std_logic;
		Adc_Sampling_clk_n_pin		: out std_logic;
		-- Input data from ADC
		Adc_Bit_clk_p_pin			: in std_logic;         --Bit clk
		Adc_Bit_clk_n_pin			: in std_logic; 
		Adc_Frame_clk_p_pin			: in std_logic;         --Frame clk
		Adc_Frame_clk_n_pin			: in std_logic;
		Adc_Data_In_p_pin			: in std_logic_vector(7 downto 0);         --Data
		Adc_Data_In_n_pin			: in std_logic_vector(7 downto 0);
		
		-- Sampled data i frame clock - shouldn't go outside FPGA
		-- Comment for implementation and use for simulations and final project
		Int_data0					: out std_logic_vector(11 downto 0);
		Int_data1					: out std_logic_vector(11 downto 0);
		Int_data2					: out std_logic_vector(11 downto 0);
		Int_data3					: out std_logic_vector(11 downto 0);
		Int_data4					: out std_logic_vector(11 downto 0);
		Int_data5					: out std_logic_vector(11 downto 0);
		Int_data6					: out std_logic_vector(11 downto 0);
		Int_data7					: out std_logic_vector(11 downto 0);
		Int_Frame_clk_out			: out std_logic);

end Component;


-- Defined All the components

signal Entto_DAC 	: std_logic_vector(15 downto 0);
signal Sigfrom_Ent	: std_logic_vector(15 downto 0);
signal parity 		: std_logic;
signal rungauss		: std_logic;
signal operation	: std_logic;
signal run_entangle	: std_logic;
signal temp_QB1 	: std_logic_vector(15 downto 0);
signal temp_QB2 	: std_logic_vector(15 downto 0);
signal temp_QB3		: std_logic_vector(15 downto 0);
signal temp_Anc		: std_logic_vector(15 downto 0);


variable counter: integer :=0;


begin 

waitfor_100us : process(clk,reset, counter)  -- initializing qubit wait for 100 us, that is 5000 clock cycles
begin

if reset = '1' then
counter :=0;

elsif rising_edge(clk)	then
counter := counter +1;

endif;

end process waitfor100us;

-- waited for 5000 cycles,that is 100 us.

-- entangle/encoding qubit
Entanglement : process (clk, reset, counter)
begin

if reset = '1' then

ENTQ0_toDAC <= (other => '0');
ENTQ1_toDAC <= (other => '0');
ENTQ2_toDAC <= (other => '0');

elsif rising_edge(clk) and counter >= 5000 and counter <= 5026 then		-- 300ns	pulse

run_entangle <= '1'
ENTQ1_toDAC <= temp_QB1; -- put this signal into the DAC and the output of the DAC should be out 0/1/2/3
ENTQ0_toDAC <= temp_QB0;

ENTQ1_toDAC <= temp_QB1;
ENTQ2_toDAC <= temp_QB2;

temp QB0 <= (other => '0');
temp QB1 <= (other => '0');
temp QB2 <= (other => '0');
counter := counter +1;
endif;

if counter :=5027 then

run_entangle <= '0';

endif;

end process Entanglement;


Hadamard : process (clk,reset, counter) -- hadamard on ancilla qubit
begin

if reset ='1' then

elsif rising_edge(clk) an   then

rungauss 	<='1';
operation 	<='1';

Anc0Hadm_toDAC <= temp_hadmAnc0;
Anc1Hadm_toDAC <= temp_hadmAnc1;

end process Hadamard;





C-phase : process(clk, reset, counter)
begin

elsif rising_edge(clk) and counter  then
parity ='1';
-- cphase between D0/D1 and A0
CphaseQB1A0_toDAC <= temp_QB1;
CphaseQB2A0_toDAC <= temp_QB2;
CphaseA0_toDAC <= temp_Anc;


counter:=counter+1;
end if;

end process C-phase;


Entangle : Entangle_Cphase
port  (
run_entangle	=> run_entangle,
clk				=> clk,
QB_source		=> temp_QB1  ;
QB_target		=> temp_QB0);



Cphase_between_ancilla_and_Dataq: Parity_cphase
port map (
run_parity 		=>	parity,	
clk 			=>	clk,
QB1_sig 		=>	temp_QB1,
QB2_sig 		=> 	temp_QB2,
anc_sig 		=>  temp_Anc);



Hadamard : Gauss
		port(
		run_gauss		=> rungauss
		clk 			=> clk
		def_1X_0H 		=> operation
		gauss_signal	=> temp_hadAnc0);

		

Measure: Measurement
		port(
				run_ancilla		=>
				clk				=> clk
				sig_out0		=>
				sig_out1		=>);


Ancillaread : 
		port map(
			clk				=> 
			reset				=>
			data_in			=>
			Ancilla_state	=>




end Behavioral;

