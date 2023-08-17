-- ProgAssign_Question_XorNN_demo_ee705_spr_2021_LecLabMeet7_6thFeb_sbp.vhdl
-- --   Sachin B. Patkar ( EE-705-spring-2020-21 , VLSI Design Lab , EE, IITB , 6th Feb 2021 )


-- YOUR TASK ( worth 5% of total course weightage :  
--			programming assignment (3%) + Viva session based on it (2%) ) :

--	Read about sigmoid function ( it appears in popular logistic regression too ).

-- The sigmoid function shape is approximated in the entity "sigmoid_approx" ...
-- I have provided a behavioural model of this grossly approximate piecewise linear model
-- for the sigmoid function.
--		Your task is to provide an architecture, say "rch_rom_based" , that makes
--		use of a ROM-based look-up for values of the same approximation to sigmoid function.
--
--		Note that the input to sigmoid_approx entity, i.e. Y, is in 2's complement format.
--		When Y is positive, it represents the real/rational value given by integer(Y) / 2**8 
--		When Y is negative, then abs_Y represents the real/rational value given by integer(abs_Y) / 2**8
--		
--		Recall  2's complement representation, to note that the 2's complement is found by complementing each bit
--			and then adding 1 to it.
--		You will find vhdl code statements performing such operation in the architecture of sigmoid_approx
--			provided herewith

-- --   Sachin B. Patkar ( EE-705-spring-2020-21 , VLSI Design Lab , EE, IITB , 6th Feb 2021 )
------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- XorNN modeling , Debugging of Sigmoid Model and Testbench
-- Sachin B. Patkar ( Dept. EE, IIT Bombay )
-- Create Date: 5 Jan 2021 
--
-- Borrowed  Neuron Model and the package data_types from 
	-- Code of Diego Ceresuela, Oscar Clemente.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package data_types is
    type vector is array (natural range <>) of STD_LOGIC_VECTOR (15 downto 0); 
    function to_vec (slv: std_logic_vector) return vector;
     function to_slv (v: vector) return std_logic_vector;
end data_types;

package body data_types is

    function to_vec (slv: std_logic_vector) return vector is
    variable c : vector (0 to (slv'length/16)-1);
    begin
        for I in c'range loop
            c(I) := slv((I*16)+15 downto (I*16));
        end loop;
        return c;
    end function to_vec;
    
    function to_slv (v: vector) return std_logic_vector is
    variable slv : std_logic_vector ((v'length*16)-1 downto 0);
    begin
        for I in v'range loop
            slv((I*16)+15 downto (I*16)) := v(I);  
        end loop;
        return slv;
    end function to_slv;
end data_types; 

------------------------------------------------------------------------
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity sigmoid_approx is
    Port ( Y : in STD_LOGIC_VECTOR (15 downto 0);
           O : out STD_LOGIC_VECTOR (15 downto 0);
           clk: in STD_LOGIC );
end sigmoid_approx;

architecture rch_rom_based of sigmoid_approx is


type rom is array (0 to 8) of STD_LOGIC_VECTOR (15 downto 0);
    signal sigmoid_val : rom := (x"0000",x"00BF",x"00FF",x"00C0",x"0080",x"00E3",x"005F",x"0030",x"0043");
    signal ind: integer := 0;
	  signal abs_Y : std_logic_vector( 15 downto 0 ) ;
begin
    
    abs_Y <= Y when Y(15)='0' else std_logic_vector ( unsigned ( Y xor X"FFFF" ) + 1 ) ;
	
    process (clk)
	 begin
	 
        if rising_edge(clk) then
           if ( Y(15) = '0' ) then 
            if ( (unsigned (Y(15 downto 0 )) < 256) AND (unsigned (Y(15 downto 0 ))> 0)  ) then 
                ind <= 1;
				elsif ( (unsigned (Y(15 downto 0 )) < 512) AND (unsigned (Y(15 downto 0 ))> 256)  ) then 
                ind <= 5;
            elsif ( (unsigned (Y(15 downto 0 )) > 512) ) then 
                ind <= 2;
				elsif ( (unsigned (Y(15 downto 0 )) = 256)) then 
                ind <= 3;
				elsif (( unsigned (Y(15 downto 0 )) = 0)) then 
                ind <= 4;
				elsif ( (unsigned (Y(15 downto 0 )) = 512)) then 
                ind <= 2;
            end if;
			 elsif ( Y(15) = '1' ) then 
				 if  ((unsigned (abs_Y(15 downto 0 )) < 256) AND (unsigned (abs_Y(15 downto 0 ))> 0) ) then 
                ind <= 6;
				 elsif  ((unsigned (abs_Y(15 downto 0 )) < 512) AND (unsigned (abs_Y(15 downto 0 ))> 256) ) then 
                ind <= 7;
				elsif ( (unsigned (abs_Y(15 downto 0 )) > 512)) then 
                ind <= 0;
				elsif ( (unsigned (abs_Y(15 downto 0 )) = 256)) then 
                ind <= 8;
				 elsif ( (unsigned (abs_Y(15 downto 0 )) = 512)) then 
                ind <= 0;
				 end if;
			end if;	
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            
				--if ( Y(15) = '0' ) then 
				--	if ( unsigned(Y(15 downto 8)) > 2 ) then 
--					O <= X"00FF" ;
--					end if ;
--				elsif ( Y(15) = '1' ) then 
--					if ( unsigned(abs_Y(15 downto 8)) > 2 ) then 
--					O <= X"0000" ;
--					end if ;
--					 
--            end if; 
				O <= sigmoid_val(ind); 
        end if;
    end process;
         
end rch_rom_based;

----------------------------------------------------------------------------------
-- Engineer: Diego Ceresuela, Oscar Clemente
--		Adapted for modified approximate sigmoid and arithmetic by Sachin B. Patkar 
-- 
-- Create Date: 13.04.2016 09:27:04
-- Module Name: Neuron - Behavioral
-- Description: Implements a neuron prepared to be connected into a network using an aproximation of the sigmoid
--  function based on a ROM and using Q15.16 signed codification.
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 	Worst negative slack is not always in the correct range.
----------------------------------------------------------------------------------

library IEEE; use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;
library work; use work.data_types.all;
entity Neuron is
    generic ( n : integer := 2 );
    Port ( slv_Xin, slv_Win : in STD_LOGIC_VECTOR ((n*16)+15 downto 0); --Values
           clk : in STD_LOGIC;
           O : out STD_LOGIC_VECTOR (15 downto 0)  );
end Neuron;
architecture Behavioral of Neuron is
    component sigmoid_approx
        port ( Y : in STD_LOGIC_VECTOR (15 downto 0);
               O : out STD_LOGIC_VECTOR (15 downto 0);   clk: in STD_LOGIC );
    end component;
    signal sum, sum1 : signed(15 downto 0) := x"0000";
    signal Y : STD_LOGIC_VECTOR (15 downto 0); 
    signal Xin, Win, Prod : vector (0 to n) := (others => x"0000"); 
    signal d : STD_LOGIC_VECTOR ((n*16)+15 downto 0); 
	for SIG : sigmoid_approx use entity work.sigmoid_approx ( rch_rom_based ) ;
begin
    SIG : sigmoid_approx port map (Y => Y, O => O, clk => clk);
	sum1 <=  signed(Prod(2)) + signed(Prod(1)); sum <=  sum1 + signed(Prod(0)) ;
    Xin <= to_vec(slv_Xin);    Win <= to_vec(slv_Win);    d <= to_slv(Prod);
    process (Xin, Win,sum) begin 
        L1: for I in 0 to n loop
            Prod(I) <= to_stdlogicvector(
				to_bitvector(std_logic_vector(signed(Xin(I)) * signed(Win(I)))) sra 8)(15 downto 0);
        end loop L1;
    end process;
    process (clk) begin
        if rising_edge(clk) then
           Y <= std_logic_vector(sum); 
        end if;
    end process;
end Behavioral;

---------------
----------------------------------------------------------------------------------
-- Author : Sachin B. Patkar
-- 
-- Create Date: 5th Feb 2021 
-- Module Name: XorNN
-- Description: Implements an ANN fr XOR by connecting up Neuron 
-- 
----------------------------------------------------------------------------------

library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all ;

entity XorNN is
    	Port ( A,B : in STD_LOGIC_VECTOR (15 downto 0); 
           clk : in STD_LOGIC;
           O : out STD_LOGIC_VECTOR (15 downto 0)  );
end entity ;
architecture rch1 of XorNN is 
	component Neuron is
    	generic ( n : integer := 0 );
    	Port ( slv_Xin, slv_Win : in STD_LOGIC_VECTOR ((n*16)+15 downto 0); --Value 
        	clk : in STD_LOGIC;
			O : out STD_LOGIC_VECTOR (15 downto 0)  );
	end component;
    constant n_inp_hidden_layer, n_inp_out_layer : integer := 2 ;
    constant wt_hidden_layer_node_1
    	: STD_LOGIC_VECTOR ((n_inp_hidden_layer*16)+15 downto 0) 
        := std_logic_vector( to_signed( (-6)*1 * 2**8 , 16 ) )
        	& std_logic_vector( to_signed( 6*1 * 2**8 , 16 ) ) 
            & std_logic_vector( to_signed( (-2)*1 * 2**8 , 16 ) ) ;
    constant wt_hidden_layer_node_0 
    	: STD_LOGIC_VECTOR ((n_inp_hidden_layer*16)+15 downto 0) 
        := std_logic_vector( to_signed( 6*1 * 2**8 , 16 ) )
        	& std_logic_vector( to_signed( (-6)*1 * 2**8 , 16 ) ) 
            & std_logic_vector( to_signed( (-2)*1 * 2**8 , 16 ) ) ;
    constant wt_output_layer_node_0 
    	: STD_LOGIC_VECTOR ((n_inp_out_layer*16)+15 downto 0) 
        := std_logic_vector( to_signed( 4*1 * 2**8 , 16 ) )
        	& std_logic_vector( to_signed( 4*1 * 2**8 , 16 ) ) 
            & std_logic_vector( to_signed( (-3)*1 * 2**8 , 16 ) ) ;          
	constant one_fixed_8_8 : std_logic_vector( 15 downto 0 ) 
    		:= std_logic_vector( to_signed( 1 * 2**8 , 16 ) ) ;
    signal out_h1 , out_h0 : std_logic_vector( 15 downto 0 ) 
    		:= ( others => '0' ) ;
	signal sig1, sig2, sig3 : STD_LOGIC_VECTOR ((n_inp_out_layer*16)+15 downto 0) ;
	signal O_sig : std_logic_vector( 15 downto 0 )  ;
begin
	O <= O_sig ;
	sig1 <= ((A & B) & one_fixed_8_8) ;
	sig2 <= ((A & B) & one_fixed_8_8) ;
	sig3 <= ((out_h0 & out_h1) & one_fixed_8_8) ;
	
	hidden_layer_node_1 : Neuron 
    	generic map ( n => n_inp_hidden_layer ) 
        port map (  sig1  ,    	wt_hidden_layer_node_1 ,  clk , out_h1 ) ;
	hidden_layer_node_0 : Neuron 
    	generic map ( n => n_inp_hidden_layer ) 
        port map ( sig2 , wt_hidden_layer_node_0 ,  clk , out_h0 ) ;
	output_layer_node_0 : Neuron 
    	generic map ( n => n_inp_out_layer ) 
        port map ( sig3, wt_output_layer_node_0 ,  clk , O_sig ) ;
                
end rch1 ;

----------------------------------------------------------------------------------
-- Author : Sachin B. Patkar
-- 
-- Create Date: 5th Feb 2021 
-- Module Name: Testbench  XorNN_test
-- Description: Implements an ANN fr XOR by connecting up Neuron 
-- 
----------------------------------------------------------------------------------
