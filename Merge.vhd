----------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date: 14:32:19 01/16/2015
-- Design Name:
-- Module Name: Merge_template - Behavioral
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

entity Finitestate_machine is
port(
Out0 : out std_logic_vector(15 downto 0);
out1 : out std_logic_vector(15 downto 0);
Out2 : out std_logic_vector(15 downto 0);
Out3 : out std_logic_vector(15 downto 0);
Ancilla0 : in std_logic_vector(7 downto 0);
Ancilla1 : in std_logic_vector(7 downto 0));

end Finitestate_machine;

architecture Behavioral of Finitestate_machine is
-- Defining all the Components


Component DAC_interface is
port(
-- on board signals
Sys_Rst_pin 			: in std_logic;
Clk_Locked_pin 		: out std_logic;
-- signals to DAC
Dac_Sync_p 				: out std_logic;
Dac_Sync_n 				: out std_logic;
Dac_Data_clk_p_pin 	: out std_logic;
Dac_Data_clk_n_pin 	: out std_logic;
Dac_Data_out_p_pin 	: out std_logic_vector(15 downto 0);
Dac_Data_out_n_pin 	: out std_logic_vector(15 downto 0);
-- signals from DAC
Dac_FPGA_clk_p_pin 	: in std_logic;
Dac_FPGA_clk_n_pin 	: in std_logic;
-- signals from ADC
Data_in_clk 			: in std_logic;
Data_rising 			: in std_logic_vector(15 downto 0);
Data_falling 			: in std_logic_vector(15 downto 0));
end Component;




Component Entangle_Cphase is
port (
run_entangle 	: in std_logic;
clk 				: in std_logic;
QB_source 		: out std_logic_vector(15 downto 0);
QB_target 		: out std_logic_vector(15 downto 0));

end Component;

Component Gauss is
port(
run_gauss : in std_logic;
clk : in STD_LOGIC;
def_1X_0H : in STD_LOGIC;
gauss_signal : out std_logic_vector(15 downto 0));
end Component;

Component parity_Cphase is
port(
run_parity : in std_logic;
clk : in STD_LOGIC;
QB1_sig : out std_logic_vector(15 downto 0);
QB2_sig : out std_logic_vector(15 downto 0);
anc_sig : out std_logic_vector(15 downto 0));
end Component;

Component Ancilla_readout is
port(
clk : in STD_LOGIC;
reset : in STD_LOGIC;
data_in : in std_logic_vector(11 downto 0);
Ancilla_state : out std_logic_vector(1 downto o));
end Component;

Component Ancilla_measure is
port(
run_ancilla :in std_logic;
clk :in std_logic;
sig_out0 : out std_logic_vector(15 downto 0)
sig_out1 : out std_logic_vector(15 downto 0));
end Component;

Component bitflipcorrector is
port(
clk : in STD_LOGIC;
run_corrector : in STD_LOGIC ;
stateAncilla0 : in STD_LOGIC_VECTOR(1 downto 0);
stateAncilla1 : in STD_LOGIC_VECTOR(1 downto 0);
correctQB0 : out STD_LOGIC_VECTOR(15 downto 0) ;
correctQB1 : out STD_LOGIC_VECTOR(15 downto 0) ;
correctQB2 : out STD_LOGIC_VECTOR(15 downto 0) );

end Component; 

Component ADC_top_level is
port (
Sys_Rst_pin : in std_logic;
Sys_Clk_p_pin : in std_logic; -- System 200 MHz clock to generate 50 MHz
Sys_Clk_n_pin : in std_logic;
-- 50 MHz sampling clock for ADC
Adc_Sampling_clk_p_pin : out std_logic;
Adc_Sampling_clk_n_pin : out std_logic;
-- Input data from ADC
Adc_Bit_clk_p_pin : in std_logic; --Bit clk
Adc_Bit_clk_n_pin : in std_logic;
Adc_Frame_clk_p_pin : in std_logic; --Frame clk
Adc_Frame_clk_n_pin : in std_logic;
Adc_Data_In_p_pin : in std_logic_vector(7 downto 0); --Data
Adc_Data_In_n_pin : in std_logic_vector(7 downto 0);
-- Sampled data i frame clock - shouldnt go outside FPGA
-- Comment for implementation and use for simulations and final project
Int_data0 : out std_logic_vector(11 downto 0);
Int_data1 : out std_logic_vector(11 downto 0);
Int_data2 : out std_logic_vector(11 downto 0);
Int_data3 : out std_logic_vector(11 downto 0);
Int_data4 : out std_logic_vector(11 downto 0);
Int_data5 : out std_logic_vector(11 downto 0);
Int_data6 : out std_logic_vector(11 downto 0);
Int_data7 : out std_logic_vector(11 downto 0);
Int_Frame_clk_out : out std_logic);
end Component;
-- end Defined All the components

--DEFINING ALL SIGNALS
-- entanglement signals
signal runentangle : STD_LOGIC :='0';
signal temp_QB1 : std_logic_vector(15 downto 0);
signal temp_QB02 : std_logic_vector(15 downto 0);
signal ENTQ0_toDAC : std_logic_vector(15 downto 0);
signal ENTQ1_toDAC : std_logic_vector(15 downto 0);
signal ENTQ2_toDAC : std_logic_vector(15 downto 0);
----- end entanglement signals

-- haramard signals 
signal temp_hadmAnc01: std_logic_vector (15 downto 0);
signal Anc0Hadm_toDAC : std_logic_vector(15 downto 0);
signal Anc1Hadm_toDAC : std_logic_vector(15 downto 0);
signal runxh : std_logic ;
signal rungauss : std_logic;
-- end hadamard signals

-- Cphase signals 
signal runparity : std_logic;
signal temp_CpQB012 : std_logic_vector(15 downto 0);
signal temp_CpAnc01 : std_logic_vector(15 downto 0);
signal CphaseQB0A0_toDAC : std_logic_vector (15 downto 0);
signal CphaseQB1A0_toDAC : std_logic_vector (15 downto 0);
signal CphaseQB2A0_toDAC : std_logic_vector (15 downto 0);
signal CphaseA0_toDAC : std_logic_vector (15 downto 0);
signal CphaseA1_toDAC : std_logic_vector (15 downto 0);
-- end Cphase signals

-- Signals from Measurement
signal temp_meas0 : std_logic_vector(15 downto 0);
signal temp_meas1 : std_logic_vector(15 downto 0);
signal Anc0_meas_toDAC : std_logic_vector (15 downto 0);
signal Anc1_meas_toDAC : std_logic_vector (15 downto 0);
signal runmeas : std_logic;

-- end signal measurement

-- signals from readout
signal stateAnc0 : std_logic_vector(1 downto 0);
signal stateAnc1 : std_logic_vector(1 downto 0);
signal data_in0	: std_logic_vector(11 downto 0);
signal data_in1	: std_logic_vector(11 downto 0);
-- end signals from readout

-- Correction signals
signal runcorrector : std_logic;
signal correct_QB0toDAC : std_logic_vector (15 downto 0);
signal correct_QB1toDAC : std_logic_vector (15 downto 0);
signal correct_QB2toDAC : std_logic_vector (15 downto 0);
signal temp_cor0 : std_logic_vector (15 downto 0);
signal temp_cor1 : std_logic_vector (15 downto 0);
signal temp_cor2 : std_logic_vector (15 downto 0);

-- end correction signals

-- END ALL SIGNALS

variable counter: integer :=0;
variable a: integer :=30;

begin

-- this process keeps track of counter
waitfor_100us : process(clk,reset) -- initializing qubit wait for 100 us, that is 5000 clock cycles

begin
if reset = '1' then
counter :=0;
elsif rising_edge(clk) then
counter := counter +1;
end if;
end waitfor_100us;

-- waited for 5000 cycles,that is 100 us.
-- entangle/encoding qubit
Entanglement : process (clk, reset)
begin
if reset = '1' then
ENTQ0_toDAC <= (other => '0');
ENTQ1_toDAC <= (other => '0');
ENTQ2_toDAC <= (other => '0');
elsif rising_edge(clk) and counter >= 5000 and counter <= 5026 then	-- 300ns pulse
runentangle <= '1';

ENTQ0_toDAC <= temp_QB02;
out0 <= ENTQ0_toDAC;
ENTQ1_toDAC <= temp_QB1; -- put this signal into the DAC and the output of the DAC should be out 0/1/2/3
out1 <= ENTQ1_toDAC;
--ENTQ1_toDAC <= temp_QB1;
--out2 <= ENTQ1_toDAC;
ENTQ2_toDAC <= temp_QB02;
out3 <= ENTQ2_toDAC;


end if;
-- note to set out signals to zero for at least 15 clock cycles
if rising_edge(clk) and counter >= 5027 and counter <= 5057  then
-- 30 clock cycles of 0 V for DAC
runentangle <= '0';
out0 <= (other => '0');
out1 <= (other => '0');
out2 <= (other => '0');
out3 <= (other => '0');
end if;
end  Entanglement;


Hadamard : process (clk,reset) -- hadamard on ancilla qubit
begin

if rising_edge(clk) and counter >= 5058 and counter<= 5186 then
-- run for 128 clock cycles

rungauss <='1';
runxh <='0';
Anc0Hadm_toDAC <= temp_hadmAnc01;
out2 <= Anc0Hadm_toDAC;			-- out2/out3 for hadamard on A0/A1
Anc1Hadm_toDAC <= temp_hadmAnc01;
out3 <= Anc1Hadm_toDAC;

elsif rising_edge(clk) and counter >= 5186 and counter <=5216 then
rungauss <= '0';
out0 <= (other => '0');
out1 <= (other => '0');
out2 <= (other => '0');
out3 <= (other => '0');

end if;

end Hadamard;


C-phase : process(clk, reset)
begin
if rising_edge(clk) and counter >= 5217 and counter <= 5247 then

-- run the C-phase for 30 clock cycles

runparity <='1';
-- cphase between D0/D1 and A0
CphaseQB0A0_toDAC <= temp_CpQB012;
out0 <= CphaseQB1A0_toDAC;
CphaseQB1A0_toDAC <= temp_CpQB012;
out1 <= CphaseQB2A0_toDAC;
CphaseA0_toDAC <= temp_CpAnc01;
out3 <=  CphaseA0_toDAC;
-- out0 and out1 have qubit0 and qubit1 and out3 has Ancilla0

elsif rising_edge(clk) and  counter >= 5248 and counter <=5278 then
-- 30 clcok cycles of 0 V for DAC
runparity <= '0';
out0 <= (other => '0');
out1 <= (other => '0');
out2 <= (other => '0');
out3 <= (other => '0');


elsif rising_edge(clk) and counter >= 5279 and counter <=5309 then
-- cphase between D1/D2 and A1, run again for 30 clock cycles
runparity <= '1';
CphaseQB1A1_toDAC <= temp_CpQB012;
out1 <= CphaseQB1A0_toDAC;
CphaseQB2A0_toDAC <= temp_CpQB012;
out2 <= CphaseQB2A0_toDAC;
CphaseA1_toDAC <= temp_CpAnc01;
out0 <=  CphaseA1_toDAC;
-- out1 and out2 have qubit1 and qubit2 and out0 has Ancilla1

elsif rising_edge(clk) and counter >= 5310 and counter <=5340 then
runparity <= '0';
out0 <= (other => '0');
out1 <= (other => '0');
out2 <= (other => '0');
out3 <= (other => '0');

end if;

end C-phase;


Hadamard2 : process (clk )
begin

if rising_edge (clk) and counter >= 5341 and counter <= 5469 then
-- run for 128 clock cycles
rungauss <='1';
runxh <='0';
Anc0Hadm_toDAC <= temp_hadmAnc01;
out2 <= Anc0Hadm_toDAC;			-- out2/out3 for hadamard on A0/A1
Anc1Hadm_toDAC <= temp_hadmAnc01;
out3 <= Anc1Hadm_toDAC;
	
	elsif rising_edge (clk) and counter >= 5470 and counter <= 5500 then
	rungauss <= '0';
	out0 <= (other => '0');
	out1 <= (other => '0');
	out2 <= (other => '0');
	out3 <= (other => '0');
	
	
end if;

end Hadamard2;



measure_Anc01 : process(clk)
begin
-- measuring both ancillas
if rising_edge (clk) and counter >= 5501 and counter <= 5516 then
-- to perform measurement, run for 15 clock cycles
runmeas <= '1';

Anc0_meas_toDAC <= temp_meas0;
out0 <= Anc0_meas_toDAC;
Anc1_meas_toDAC <= temp_meas1;
out3 <= Anc1_meas_toDAC;

-- couple Ancilla0 to out0 and Ancilla1 to out3

elsif rising_edge (clk) and counter >= 5517 and counter <= 5547 then
	runmeas <= '0';
	out0 <= (other => '0');
	out1 <= (other => '0');
	out2 <= (other => '0');
	out3 <= (other => '0');

end if;

end measure_Anc01;
 -- set waiting time for ADC to respond to measurement command send
 -- by measure

-- wait 100 clock cycles for emulator to respond
readoutDataADC : process (clk)
begin
if rising_edge(clk) and counter = 5547 then
 
data_in0 <= Int_data0;
data_in1 <= Int_data1;

end if;	

end readoutDataADC


correction : process (clk)
begin
-- correcting the qubits
if rising_edge(clk) and counter >= 5648 and counter <= 5776 then
-- when for example data qubit one is corrupted out 1 is fixe
-- and all the other signals are set to 0V;
runcorrector <='1';

correct_QB0toDAC <= temp_cor0;
out0 <= correct_QB1toDAC;
correct_QB1toDAC <= temp_cor1;
out1 <= correct_QB1toDAC;
correct_QB2toDAC <= temp_cor2;
out2 <= correct_QB2toDAC;

elsif rising_edge(clk) and counter >= 5777 and counter <= 5807 then
   runcorrector <= '0';
	out0 <= (other => '0');
	out1 <= (other => '0');
	out2 <= (other => '0');
	out3 <= (other => '0');

end if ;

end correction




-- Port mapping start here : connecting all the wires(signals to components)

Entangle : Entangle_Cphase
port map (
run_entangle => runentangle,
clk => clk,
QB_source => temp_QB1 ,
QB_target => temp_QB02);
-- qubit one is the source and qubit 0 and 2 are the target qubits

Hadamard : Gauss
port map (
run_gauss => rungauss
clk => clk
def_1X_0H => runxh,
gauss_signal => temp_hadAnc01);


CphaseDQ_Anc: Parity_cphase
port map (
run_parity => runparity,
clk =>	clk,
QB1_sig =>	temp_CpQB012,
QB2_sig => temp_CpQB012,
anc_sig => temp_CpAnc01);



Measure: Ancilla_measure
port map(
run_ancilla => runmeas,
clk => clk,
sig_out0 => temp_meas0,
sig_out1 => temp_meas1);

Ancilla0read : Ancilla_readout
port map(
clk => clk,
reset => reset,
data_in => data_in0,--data from ADC Anc0
Ancilla_state => stateAnc0);

Ancilla1read : Ancilla_readout
port map(
clk => clk,
reset => reset,
data_in => data_in1,--data from ADC Anc1
Ancilla_state => stateAnc1 );

Correcting: bitflipcorrector 
port map (
clk => clk,
run_corrector => runcorrector ,
stateAncilla0 => stateAnc0,
stateAncilla1 => stateAnc1,
correctQB0 => temp_cor0,
correctQB1 => temp_cor1,
correctQB2 => temp_cor2);



end Behavioral;
