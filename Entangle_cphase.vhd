library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
entity ent_Cphase is
  port (
    run_entangle  : in std_logic;                                             -- c-phase operation runs while this is "1"
    clk           : in std_logic;
    QB_source     : out std_logic_vector(15 downto 0) :="0111111111111111";   -- Source QB, this state needs to be copied to targetQB
    QB_target     : out std_logic_vector(15 downto 0) :="0111111111111111";   -- Target QB
  end ent_Cphase;
  
architecture Behavioral of ent_Cphase is
  begin
  process (clk, run_entangle)
  variable counter : integer;
  begin
  if rising_edge(clk) then
    if run_entangle = '1' then
      if counter <= 20 then
        QB_source <= "1100110011001101"; -- 400 mV
        QB_target <= "1100110011001101"; -- 400 mV
        counter := counter + 1;
      end if;
      if counter > 20 and counter <= 25 then
          QB_source <= "1100110011001101"; -- 400 mV
          counter := counter + 1;
      end if;
      if counter > 25 and counter <= 35 then
        QB_source <= "0111111111111111"; -- 0 mV
        QB_target <= "0111111111111111"; -- 0 mV
        counter := counter + 1;
      elsif counter > 36 then
        counter := 0;
      end if;
    end if;
  end if;
  end process;
end Behavioral;

-- architecture Behavioral of ent_Cphase is
--   begin
--   process (clk, run_entangle)
--   variable counter : integer;
--   begin
--   if rising_edge(clk) then
--     if run_entangle = '1' then
--       if counter <= 20 then
--         QB_source <= "1100110011001101"; -- 400 mV
--         QB_target <= "1100110011001101"; -- 400 mV
--       elsif counter < 25 then
--         QB_source <= "1100110011001101"; -- 400 mV
--       elsif counter < 50 then
--         QB_source <= "0111111111111111"; -- 0 mV
--         QB_target <= "0111111111111111"; -- 0 mV
--       elsif counter < 51 then
--         counter := 0;
--       end if;
--     end if;
--   end if;
--   end process;
-- end Behavioral;

-- architecture Behavioral of ent_Cphase is
--   begin
--   process (clk, run_entangle)
--   variable counter : integer;
--   begin
--   if rising_edge(clk) then
--     if run_entangle = '1' then
--       if counter <= 20 then
--         QB_source <= "1100110011001101"; -- 400 mV
--         QB_target <= "1100110011001101"; -- 400 mV
--         counter := counter + 1;
--       end if;
--       if counter > 20 then
--         if counter <= 25 then
--           QB_source <= "1100110011001101"; -- 400 mV
--           counter := counter + 1;
--         end if;
--       end if;
--       if counter > 25 then
--         if counter <= 35 then
--         QB_source <= "0111111111111111"; -- 0 mV
--         QB_target <= "0111111111111111"; -- 0 mV
--         counter := counter + 1;
--       elsif counter > 36 then
--         counterer := 0;
--         end if;
--       end if;
--     end if;
--   end if;
--   end process;
-- end Behavioral;