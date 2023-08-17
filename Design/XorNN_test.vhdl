
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity XorNN_test is end entity ;
architecture stim of XorNN_test is
	component XorNN is Port ( A,B : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC; O : out STD_LOGIC_VECTOR (15 downto 0)  );
	end component ;
    signal A,B :  STD_LOGIC_VECTOR (15 downto 0); 
	signal clk : STD_LOGIC := '0' ;
    signal out_xor_nn_fixed_point_8_8 :  STD_LOGIC_VECTOR (15 downto 0 ) ;   
    function from_sl_to_fixed_8_8 ( inp : std_logic )  return std_logic_vector is
	begin
    	if ( inp = '1' ) then return std_logic_vector( to_signed( 1 * 2**8 , 16 ) ) ;
		else   return std_logic_vector( to_signed( 0 * 2**8 , 16 ) ) ;
		end if ;
    end function ;
begin
	dut_XorNN : XorNN port map ( A,B, clk , out_xor_nn_fixed_point_8_8 ) ;
    process 
    	variable i_2bit : std_logic_vector( 1 downto 0 ) ; 
    begin
        A <= std_logic_vector( to_signed( 0 * 2**8 , 16 ) ) ;
        B <= std_logic_vector( to_signed( 0 * 2**8 , 16 ) ) ;
		wait for 0 ns ;
        for i in 0 to 3 loop
        	i_2bit := std_logic_vector( to_unsigned( i,2 ) ) ;
	        A <= from_sl_to_fixed_8_8( i_2bit(1) )  ;
	        B <= from_sl_to_fixed_8_8( i_2bit(0) )  ;
        	wait for 8*2*10 ns ;
        end loop ;
		wait ;
	end process ;
    process begin
    	clk <= '0' ;
		for i in 0 to 40 loop
        	wait for 10 ns ;  clk <= '1' ; wait for 10 ns ;  clk <= '0' ;
        end loop ;
        wait ;
    end process ;
end stim ;