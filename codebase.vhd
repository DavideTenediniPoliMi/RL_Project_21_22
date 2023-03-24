--------------------------------------------------------------------------------
-------------------------------------- FSA -------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
        i_clk     : in  STD_LOGIC;
        i_rst     : in  STD_LOGIC;
        i_start   : in  STD_LOGIC;
        i_data    : in  STD_LOGIC_VECTOR ( 7 downto 0);
        o_address : out STD_LOGIC_VECTOR (15 downto 0);
        o_done    : out STD_LOGIC;
        o_en      : out STD_LOGIC;
        o_we      : out STD_LOGIC;
        o_data    : out STD_LOGIC_VECTOR ( 7 downto 0)
    );
end project_reti_logiche;
--------------------------------------------------------------------------------
architecture Behavioral of project_reti_logiche is
    component datapath is
        port(
            i_clk          : in  STD_LOGIC;
            i_rst          : in  STD_LOGIC;
            num_load       : in  STD_LOGIC;
            addr_load      : in  STD_LOGIC;
            bit_index_load : in  STD_LOGIC;
            w_load         : in  STD_LOGIC;
            z_load         : in  STD_LOGIC;
            addr_sel       : in  STD_LOGIC;
            bit_index_sel  : in  STD_LOGIC;
            z_sel          : in  STD_LOGIC;
            data_sel       : in  STD_LOGIC;
            conv_en        : in  STD_LOGIC;
            conv_rst       : in  STD_LOGIC;
            i_data         : in  STD_LOGIC_VECTOR ( 7 downto 0);
            o_end          : out STD_LOGIC;
            w_end          : out STD_LOGIC;
            read_addr      : out STD_LOGIC_VECTOR (15 downto 0);
            write_addr_1   : out STD_LOGIC_VECTOR (15 downto 0);
            write_addr_2   : out STD_LOGIC_VECTOR (15 downto 0);
            o_data         : out STD_LOGIC_VECTOR ( 7 downto 0)
        );
    end component;
    signal num_load       : STD_LOGIC;
    signal addr_load      : STD_LOGIC;
    signal bit_index_load : STD_LOGIC;
    signal w_load         : STD_LOGIC;
    signal z_load         : STD_LOGIC;
    signal addr_sel       : STD_LOGIC;
    signal bit_index_sel  : STD_LOGIC;
    signal z_sel          : STD_LOGIC;
    signal data_sel       : STD_LOGIC;
    signal conv_en        : STD_LOGIC;
    signal conv_rst       : STD_LOGIC;
    signal o_end          : STD_LOGIC;
    signal w_end          : STD_LOGIC;
    signal read_addr      : STD_LOGIC_VECTOR (15 downto 0);
    signal write_addr_1   : STD_LOGIC_VECTOR (15 downto 0);
    signal write_addr_2   : STD_LOGIC_VECTOR (15 downto 0);
    type S is (IDLE, FETCH_NUM, LOAD_NUM, FETCH_W, LOAD_W, CONV, LOAD_Z, WRITE_1, WRITE_2, DONE);
    signal curr_state : S;
    signal next_state : S;
--------------------------------------------------------------------------------
begin
    DATAPATH0: datapath port map(
        i_clk,
        i_rst,
        num_load,
        addr_load,
        bit_index_load,
        w_load,
        z_load,
        addr_sel,
        bit_index_sel,
        z_sel,
        data_sel,
        conv_en,
        conv_rst,
        i_data,
        o_end,
        w_end,
        read_addr,
        write_addr_1,
        write_addr_2,
        o_data
    );
    -- REGISTRY
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            curr_state <= IDLE;
        elsif i_clk'event and i_clk = '1' then
            curr_state <= next_state;
        end if;
    end process;
    -- NEXT STATE
    process(curr_state, i_start, w_end, o_end)
    begin
        next_state <= curr_state;
        case curr_state is
            when IDLE =>
                if i_start = '1' then
                    next_state <= FETCH_NUM;
                end if;
            when FETCH_NUM =>
                next_state <= LOAD_NUM;
            when LOAD_NUM =>
                next_state <= FETCH_W;
            when FETCH_W =>
                if o_end = '1' then
                    next_state <= DONE;
                else
                    next_state <= LOAD_W;
                end if;
            when LOAD_W =>
                next_state <= CONV;
            when CONV =>
                if w_end = '1' then
                    next_state <= LOAD_Z;
                end if;
            when LOAD_Z =>
                next_state <= WRITE_1;
            when WRITE_1 =>
                next_state <= WRITE_2;
            when WRITE_2 =>
                next_state <= FETCH_W;
            when DONE =>
                if i_start = '0' then
                    next_state <= IDLE;
                end if;
        end case;
    end process;
    -- SIGNALS
    process(curr_state, read_addr, write_addr_1, write_addr_2)
    begin
        num_load       <= '0';
        addr_load      <= '0';
        bit_index_load <= '0';
        w_load         <= '0';
        z_load         <= '0';
        addr_sel       <= '0';
        bit_index_sel  <= '0';
        z_sel          <= '0';
        data_sel       <= '0';
        conv_en        <= '0';
        conv_rst       <= '0';
        o_address      <= "0000000000000000";
        o_en           <= '0';
        o_we           <= '0';
        o_done         <= '0';
   
        case curr_state is
            when IDLE =>
            when FETCH_NUM =>
                o_en       <= '1';
            when LOAD_NUM =>
                num_load   <= '1';
                addr_load  <= '1';
                conv_rst   <= '1';
            when FETCH_W =>
                o_en       <= '1';
                o_address  <= read_addr;
                bit_index_load <= '1';
                z_load     <= '1';
            when LOAD_W =>
                w_load     <= '1';
            when CONV =>
                conv_en    <= '1';
                bit_index_sel  <= '1';
                bit_index_load <= '1';
                z_sel      <= '1';
                z_load     <= '1';
            when LOAD_Z =>
                z_sel      <= '1';
                z_load     <= '1';
            when WRITE_1 =>
                o_en       <= '1';
                o_we       <= '1';
                o_address  <= write_addr_1;
            when WRITE_2 =>
                o_en       <= '1';
                o_we       <= '1';
                o_address  <= write_addr_2;
                data_sel   <= '1';
                addr_sel   <= '1';
                addr_load  <= '1';
            when DONE =>
                o_done     <= '1';                
        end case;
    end process;

end Behavioral;

--------------------------------------------------------------------------------
----------------------------------- DATAPATH -----------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    port(
        i_clk          : in  STD_LOGIC;
        i_rst          : in  STD_LOGIC;
        num_load       : in  STD_LOGIC;
        addr_load      : in  STD_LOGIC;
        bit_index_load : in  STD_LOGIC;
        w_load         : in  STD_LOGIC;
        z_load         : in  STD_LOGIC;
        addr_sel       : in  STD_LOGIC;
        bit_index_sel  : in  STD_LOGIC;
        z_sel          : in  STD_LOGIC;
        data_sel       : in  STD_LOGIC;
        conv_en        : in  STD_LOGIC;
        conv_rst       : in  STD_LOGIC;
        i_data         : in  STD_LOGIC_VECTOR ( 7 downto 0);
        o_end          : out STD_LOGIC;
        w_end          : out STD_LOGIC;
        read_addr      : out STD_LOGIC_VECTOR (15 downto 0);
        write_addr_1   : out STD_LOGIC_VECTOR (15 downto 0);
        write_addr_2   : out STD_LOGIC_VECTOR (15 downto 0);
        o_data         : out STD_LOGIC_VECTOR ( 7 downto 0)
    );
end datapath;
--------------------------------------------------------------------------------
architecture Behavioral of datapath is
    component convolution is
        port (
            i_clk    : in  STD_LOGIC;
            i_rst    : in  STD_LOGIC;
            conv_en  : in  STD_LOGIC;
            conv_rst : in  STD_LOGIC;
            bit_mux  : in  STD_LOGIC;
            conv_out : out STD_LOGIC_VECTOR (1 downto 0)
        );
    end component;
    component counter is 
        generic(
            rst_val  : STD_LOGIC_VECTOR;
            init_val : STD_LOGIC_VECTOR
        );
        port(
            i_clk     : in  STD_LOGIC;
            i_rst     : in  STD_LOGIC;
            sel       : in  STD_LOGIC;
            load      : in  STD_LOGIC;
            o_val     : out STD_LOGIC_VECTOR (rst_val'length - 1 downto 0);
            o_val_int : out INTEGER
        );
    end component;
    signal num_reg           : STD_LOGIC_VECTOR ( 7 downto 0);
    signal addr_reg          : STD_LOGIC_VECTOR ( 8 downto 0);
    signal addr_int          : INTEGER range 0 to 257;
    signal base_addr_int     : INTEGER;
    signal write_addr_1_uint : UNSIGNED (15 downto 0);
    signal write_addr_2_uint : UNSIGNED (15 downto 0);
    signal bit_index_reg     : STD_LOGIC_VECTOR ( 3 downto 0);
    signal bit_index_int     : INTEGER range 0 to   9;  
    signal w_reg             : STD_LOGIC_VECTOR ( 7 downto 0);
    signal z_reg             : STD_LOGIC_VECTOR (15 downto 0);
    signal bit_mux           : STD_LOGIC;
    signal z_mux             : STD_LOGIC_VECTOR (15 downto 0);
    signal data_mux          : STD_LOGIC_VECTOR ( 7 downto 0);
    signal shift_concat      : STD_LOGIC_VECTOR (15 downto 0);
    signal conv_out          : STD_LOGIC_VECTOR ( 1 downto 0);
    ----------------------------------------------------------------------------
begin
    CONVOLUTION0: convolution port map(
            i_clk,
            i_rst,
            conv_en,
            conv_rst,
            bit_mux,
            conv_out
    );
    
    ADDR_COUNTER: counter generic map(
        rst_val  => "000000000",
        init_val => "000000001"
    )
    port map(
        i_clk,
        i_rst,
        addr_sel,
        addr_load,
        addr_reg,
        addr_int
    );
    
    BIT_INDEX_COUNTER: counter generic map(
        rst_val  => "0000",
        init_val => "0000"
    )
    port map(
        i_clk,
        i_rst,
        bit_index_sel,
        bit_index_load,
        bit_index_reg,
        bit_index_int
    );
    ------------------------------ REGISTRIES ----------------------------------
    -- NUM
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            num_reg <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if num_load = '1' then
                num_reg <= i_data;
            end if;
        end if;
    end process;
    -- W
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            w_reg <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if w_load = '1' then
                w_reg <= i_data;
            end if;
        end if;
    end process;
    -- Z
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            z_reg <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if z_load = '1' then
                z_reg <= z_mux;
            end if;
        end if;
    end process;
    --------------------------------- MUX --------------------------------------
    -- BIT
    with bit_index_reg select
        bit_mux <= w_reg(7) when "0000",
                   w_reg(6) when "0001",
                   w_reg(5) when "0010",
                   w_reg(4) when "0011",
                   w_reg(3) when "0100",
                   w_reg(2) when "0101",
                   w_reg(1) when "0110",
                   w_reg(0) when "0111",
                   'X'      when others;
    -- Z
    with z_sel select
        z_mux <= "0000000000000000" when '0',
                 shift_concat       when '1',
                 "XXXXXXXXXXXXXXXX" when others;
    -- DATA
    with data_sel select
        o_data <= z_reg(15 downto 8) when '0',
                  z_reg( 7 downto 0) when '1',
                  "XXXXXXXX"         when others;
    ------------------------------ OPERATORS -----------------------------------
    base_addr_int     <= to_integer(shift_left(unsigned(addr_reg), 1)) + 998;
    write_addr_1_uint <= to_unsigned(base_addr_int    , 16);
    write_addr_2_uint <= to_unsigned(base_addr_int + 1, 16);
    shift_concat <= z_reg(13 downto 0) & conv_out;
    ------------------------------- OUTPUTS ------------------------------------
    read_addr    <= "0000000" & addr_reg;
    write_addr_1 <= STD_LOGIC_VECTOR(write_addr_1_uint);
    write_addr_2 <= STD_LOGIC_VECTOR(write_addr_2_uint);
    o_end <= '1' when addr_int  >  to_integer(unsigned(num_reg)) else '0';
    w_end <= '1' when bit_index_int >= 7                             else '0';
end Behavioral;

--------------------------------------------------------------------------------
----------------------------------- COUNTER ------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is 
    generic(
        rst_val  : STD_LOGIC_VECTOR;
        init_val : STD_LOGIC_VECTOR
    );
    port(
        i_clk     : in  STD_LOGIC;
        i_rst     : in  STD_LOGIC;
        sel       : in  STD_LOGIC;
        load      : in  STD_LOGIC;
        o_val     : out STD_LOGIC_VECTOR (rst_val'length - 1 downto 0);
        o_val_int : out INTEGER
    );
end counter;
--------------------------------------------------------------------------------
architecture Behavioral of counter is
    signal mux     : STD_LOGIC_VECTOR (rst_val'length - 1 downto 0);
    signal sum     : STD_LOGIC_VECTOR (rst_val'length - 1 downto 0);
    signal val     : STD_LOGIC_VECTOR (rst_val'length - 1 downto 0);
    signal val_int : INTEGER;
    signal undef   : STD_LOGIC_VECTOR (rst_val'length - 1 downto 0) := (others => 'X');
--------------------------------------------------------------------------------
begin
    ------------------------------- REGISTRY -----------------------------------
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            val <= rst_val;
        elsif i_clk'event and i_clk = '1' then
            if load = '1' then
                val <= mux;
            end if;
        end if;
    end process;
    --------------------------------- MUX --------------------------------------
    with sel select
        mux <= init_val when '0',
                sum     when '1',
                undef   when others;
    ------------------------------ OPERATORS -----------------------------------        
    val_int <= to_integer(unsigned(val));
    sum     <= STD_LOGIC_VECTOR(to_unsigned(val_int + 1, rst_val'length));
    ------------------------------- OUTPUTS ------------------------------------
    o_val     <= val;
    o_val_int <= val_int;
end Behavioral;

--------------------------------------------------------------------------------
--------------------------------- CONVOLUTION ----------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity convolution is
    port (
        i_clk    : in  STD_LOGIC;
        i_rst    : in  STD_LOGIC;
        conv_en  : in  STD_LOGIC;
        conv_rst : in  STD_LOGIC;
        bit_mux  : in  STD_LOGIC;
        conv_out : out STD_LOGIC_VECTOR (1 downto 0)
    );
end convolution;
--------------------------------------------------------------------------------
architecture Behavioral of convolution is
    type CONV_S is (CONV_S0, CONV_S1, CONV_S2, CONV_S3);
    signal curr_state    : CONV_S;
    signal next_state    : CONV_S;
    signal next_conv_out : STD_LOGIC_VECTOR(1 downto 0);
--------------------------------------------------------------------------------
begin
    -- REGIRSTRIES
    process(i_clk, i_rst, conv_rst, conv_en)
    begin
        if(i_rst = '1' or conv_rst = '1') then
            curr_state <= CONV_S0;
            conv_out   <= "00";
        elsif i_clk'event and i_clk = '1' and conv_en = '1' then
            curr_state <= next_state;
            conv_out   <= next_conv_out;
        end if;
    end process;
    -- NEXT STATE
    process(curr_state, bit_mux)
    begin
        next_state <= curr_state;
        case curr_state is
            when CONV_S0 | CONV_S2 =>
                if bit_mux = '1' then
                    next_state <= CONV_S1;
                else
                    next_state <= CONV_S0;
                end if;
            when CONV_S1 | CONV_S3 =>
                if bit_mux = '1' then
                    next_state <= CONV_S3;
                else
                    next_state <= CONV_S2;
                end if;
        end case;
    end process;
    -- OUTPUT
    process(curr_state, bit_mux)
    begin
        next_conv_out <= "00";
        case curr_state is
            when CONV_S0 =>
                if bit_mux = '1' then
                    next_conv_out <= "11";
                else
                    next_conv_out <= "00";
                end if;
            when CONV_S1 =>
                if bit_mux = '1' then
                    next_conv_out <= "10";
                else
                    next_conv_out <= "01";
                end if;
            when CONV_S2 =>
                if bit_mux = '1' then
                    next_conv_out <= "00";
                else
                    next_conv_out <= "11";
                end if;
            when CONV_S3 =>
                if bit_mux = '1' then
                    next_conv_out <= "01";
                else
                    next_conv_out <= "10";
                end if;
        end case;
    end process;
end Behavioral;