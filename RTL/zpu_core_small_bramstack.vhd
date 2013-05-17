-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- 
-- Changes by Alastair M. Robinson, 2013
-- to allow the core to run from external RAM, and to balance performance and area.
-- The goal is to make the ZPU a useful support CPU for such tasks as loading
-- ROMs from SD Card, while keeping the area under 1,000 logic cells.
--
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;


entity zpu_core is
  generic (
    HARDWARE_MULTIPLY : boolean := true; -- Self explanatory
	 COMPARISON_SUB : boolean := true; -- Include sub (and also lessthan, etc - but not yet implemented)
	 EQBRANCH : boolean := true; -- Include eqbranch and neqbranch
	 MMAP_STACK : boolean := true; -- Map the stack to 0x40000000, to allow pushsp, store to work.
	 STOREBH : boolean := true; -- Include halfword and byte writes
	 CALL : boolean := true -- Include call
  );
  port ( 
    clk                 : in std_logic;
    -- asynchronous reset signal
    reset               : in std_logic;
    -- this particular implementation of the ZPU does not
    -- have a clocked enable signal
    enable              : in  std_logic;
    in_mem_busy         : in  std_logic;
    mem_read            : in  std_logic_vector(wordSize-1 downto 0);
    mem_write           : out std_logic_vector(wordSize-1 downto 0);
    out_mem_addr        : out std_logic_vector(maxAddrBitIncIO downto 0);
    out_mem_writeEnable : out std_logic;
    out_mem_writeEnableb : out std_logic;  -- Enable byte write
    out_mem_writeEnableh : out std_logic;  -- Enable halfword write
    out_mem_readEnable  : out std_logic;
    -- this implementation of the ZPU *always* reads and writes entire
    -- 32 bit words, so mem_writeMask is tied to (others => '1').
--    mem_writeMask       : out std_logic_vector(wordBytes-1 downto 0);
    -- Set to one to jump to interrupt vector
    -- The ZPU will communicate with the hardware that caused the
    -- interrupt via memory mapped IO or the interrupt flag can
    -- be cleared automatically
    interrupt           : in  std_logic;
    -- Signal that the break instruction is executed, normally only used
    -- in simulation to stop simulation
    break               : out std_logic
    );
end zpu_core;



architecture behave of zpu_core is

  signal memAWriteEnable : std_logic;
  signal memAAddr        : unsigned(maxAddrBitStackBRAM downto minAddrBit);
  signal memAWrite       : unsigned(wordSize-1 downto 0);
  signal memARead        : unsigned(wordSize-1 downto 0);
  signal memBWriteEnable : std_logic;
  signal memBAddr        : unsigned(maxAddrBitStackBRAM downto minAddrBit);
  signal memBWrite       : unsigned(wordSize-1 downto 0);
  signal memBRead        : unsigned(wordSize-1 downto 0);



  signal pc : unsigned(maxAddrBit downto 0);
  signal sp : unsigned(maxAddrBitStackBRAM downto minAddrBit);

  -- this signal is set upon executing an IM instruction
  -- the subsequence IM instruction will then behave differently.
  -- all other instructions will clear the idim_flag.
  -- this yields highly compact immediate instructions.
  signal idim_flag  : std_logic;
  --
  signal busy       : std_logic;
  --
  signal begin_inst : std_logic;
  signal fetchneeded : std_logic;

  signal trace_opcode      : std_logic_vector(7 downto 0);
  signal trace_pc          : std_logic_vector(maxAddrBitIncIO downto 0);
  signal trace_sp          : std_logic_vector(maxAddrBitIncIO downto minAddrBit);
  signal trace_topOfStack  : std_logic_vector(wordSize-1 downto 0);
  signal trace_topOfStackB : std_logic_vector(wordSize-1 downto 0);

  -- state machine.
  type State_Type is (
    State_Fetch,
    State_WriteIODone,
    State_Execute,
    State_StoreToStack,
    State_Add,
    State_Or,
    State_And,
    State_Store,
    State_ReadIO,
    State_WriteIO,
    State_WriteIOBH,
    State_Load,
    State_FetchNext,
    State_AddSP,
    State_ReadIODone,
    State_Decode,
    State_Resync,
    State_Interrupt,
	 State_Mult,
	 State_Comparison,
	 State_EqNeq,
	 State_Sub,
	 State_IncSP
    );

  type DecodedOpcodeType is (
    Decoded_Nop,
    Decoded_Im,
    Decoded_ImShift,
    Decoded_LoadSP,
    Decoded_StoreSP ,
    Decoded_AddSP,
    Decoded_Emulate,
    Decoded_Break,
    Decoded_PushSP,
    Decoded_PopPC,
    Decoded_Add,
    Decoded_Or,
    Decoded_And,
    Decoded_Load,
    Decoded_Not,
    Decoded_Flip,
    Decoded_Store,
    Decoded_StoreBH,
    Decoded_PopSP,
    Decoded_Interrupt,
	 Decoded_Mult,
	 Decoded_Sub,
	 Decoded_Comparison,
	 Decoded_EqNeq,
	 Decoded_EqBranch,
	 Decoded_Call
    );



  signal sampledOpcode        : std_logic_vector(OpCode_Size-1 downto 0);
  signal opcode               : std_logic_vector(OpCode_Size-1 downto 0);
  --
  signal decodedOpcode        : DecodedOpcodeType;
  signal sampledDecodedOpcode : DecodedOpcodeType;


  signal  state              : State_Type;
  --
  subtype AddrBitBRAM_range is natural range maxAddrBitBRAM downto minAddrBit;
  signal  memAAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);
  signal  memAWrite_stdlogic : std_logic_vector(memAWrite'range);
  signal  memARead_stdlogic  : std_logic_vector(memARead'range);
  signal  memBAddr_stdlogic  : std_logic_vector(AddrBitBRAM_range);
  signal  memBWrite_stdlogic : std_logic_vector(memBWrite'range);
  signal  memBRead_stdlogic  : std_logic_vector(memBRead'range);
  --
  subtype index is integer range 0 to 3;
  --
  signal  tOpcode_sel        : index;
  --
  signal  inInterrupt        : std_logic;

  signal comparison_sub_result : unsigned(wordSize downto 0); -- Extra bit needed for signed comparisons
  signal comparison_eq : std_logic;

  signal eqbranch_zero : std_logic;
  
begin

  -- generate a trace file.
  -- 
  -- This is only used in simulation to see what instructions are
  -- executed. 
  --
  -- a quick & dirty regression test is then to commit trace files
  -- to CVS and compare the latest trace file against the last known
  -- good trace file
  traceFileGenerate : if Generate_Trace generate
    trace_file : trace port map (
      clk        => clk,
      begin_inst => begin_inst,
      pc         => trace_pc,
      opcode     => trace_opcode,
      sp         => trace_sp,
      memA       => trace_topOfStack,
      memB       => trace_topOfStackB,
      busy       => busy,
      intsp      => (others => 'U')
      );
  end generate;



  memAAddr_stdlogic  <= std_logic_vector(memAAddr(AddrBitBRAM_range));
  memAWrite_stdlogic <= std_logic_vector(memAWrite);
  memBAddr_stdlogic  <= std_logic_vector(memBAddr(AddrBitBRAM_range));
  memBWrite_stdlogic <= std_logic_vector(memBWrite);


  -- dualport_ram must be defined by the application. 
  -- 
  -- How this can be implemented is highly dependent on the FPGA
  -- and synthesis technology used. 
  --
  -- sometimes it can be instantiated as in the 
  -- zpu/example/helloworld.vhd, using inference,
  -- but oftentimes it must be instantiated directly
  -- portmapping to part specific FPGA resources
  -- 
  --
  -- DANGER!!!!!! If inference fails, then synthesis will try
  -- to implement the memory using basic logic resources. This
  -- will almost certainly cause the compiler to get "stuck"
  -- since synthesising such a huge number of basic logic resources
  -- will take more or less forever.
  --
  -- So: if your compiler gets "stuck" then inference is not
  -- the way to go.
  memory : stackram port map (
    clk             => clk,
    memAWriteEnable => memAWriteEnable,
    memAAddr        => memAAddr_stdlogic,
    memAWrite       => memAWrite_stdlogic,
    memARead        => memARead_stdlogic,
    memBWriteEnable => memBWriteEnable,
    memBAddr        => memBAddr_stdlogic,
    memBWrite       => memBWrite_stdlogic,
    memBRead        => memBRead_stdlogic
    );
  memARead <= unsigned(memARead_stdlogic);
  memBRead <= unsigned(memBRead_stdlogic);



  tOpcode_sel <= to_integer(pc(minAddrBit-1 downto 0));



  -- move out calculation of the opcode to a separate process
  -- to make things a bit easier to read
  decodeControl : process(mem_read, pc, tOpcode_sel)
    variable tOpcode : std_logic_vector(OpCode_Size-1 downto 0);
  begin

    -- simplify opcode selection a bit so it passes more synthesizers
    case (tOpcode_sel) is

      when 0 => tOpcode := std_logic_vector(mem_read(31 downto 24));

      when 1 => tOpcode := std_logic_vector(mem_read(23 downto 16));

      when 2 => tOpcode := std_logic_vector(mem_read(15 downto 8));

      when 3 => tOpcode := std_logic_vector(mem_read(7 downto 0));

      when others => tOpcode := std_logic_vector(mem_read(7 downto 0));
    end case;

    sampledOpcode <= tOpcode;

    if (tOpcode(7 downto 7) = OpCode_Im) then
      sampledDecodedOpcode <= Decoded_Im;
    elsif (tOpcode(7 downto 5) = OpCode_StoreSP) then
      sampledDecodedOpcode <= Decoded_StoreSP;
    elsif (tOpcode(7 downto 5) = OpCode_LoadSP) then
      sampledDecodedOpcode <= Decoded_LoadSP;
    elsif (tOpcode(7 downto 5) = OpCode_Emulate) then
		sampledDecodedOpcode <= Decoded_Emulate;
		if CALL=true and tOpcode(5 downto 0) = OpCode_Call then
			sampledDecodedOpcode <= Decoded_Call;
		end if;
		if HARDWARE_MULTIPLY=true and tOpcode(5 downto 0) = OpCode_Mult then
			sampledDecodedOpcode <= Decoded_Mult;
		end if;
		if COMPARISON_SUB=true then
			if tOpcode(5 downto 0) = OpCode_Eq
				or tOpcode(5 downto 0) = OpCode_Neq then
					sampledDecodedOpcode <= Decoded_EqNeq;
			elsif tOpcode(5 downto 0)= OpCode_Sub then
				sampledDecodedOpcode <= Decoded_Sub;
			elsif tOpcode(5 downto 0)= OpCode_Lessthanorequal
				or tOpcode(5 downto 0)= OpCode_Lessthan
					then
				sampledDecodedOpcode <= Decoded_Comparison;
			end if;
		end if;
		if EQBRANCH=true then
			if tOpcode(5 downto 0) = OpCode_EqBranch
				or tOpcode(5 downto 0)= OpCode_NeqBranch then
				sampledDecodedOpcode <= Decoded_EqBranch;
			end if;
		end if;
		if STOREBH=true then
			if tOpcode(5 downto 0) = OpCode_StoreB
				or tOpcode(5 downto 0) = OpCode_StoreH then
				sampledDecodedOpcode <= Decoded_StoreBH;
			end if;
		end if;
    elsif (tOpcode(7 downto 4) = OpCode_AddSP) then
      sampledDecodedOpcode <= Decoded_AddSP;
    else
      case tOpcode(3 downto 0) is
        when OpCode_Break =>
          sampledDecodedOpcode <= Decoded_Break;
        when OpCode_PushSP =>
          sampledDecodedOpcode <= Decoded_PushSP;
        when OpCode_PopPC =>
          sampledDecodedOpcode <= Decoded_PopPC;
        when OpCode_Add =>
          sampledDecodedOpcode <= Decoded_Add;
        when OpCode_Or =>
          sampledDecodedOpcode <= Decoded_Or;
        when OpCode_And =>
          sampledDecodedOpcode <= Decoded_And;
        when OpCode_Load =>
          sampledDecodedOpcode <= Decoded_Load;
        when OpCode_Not =>
          sampledDecodedOpcode <= Decoded_Not;
        when OpCode_Flip =>
          sampledDecodedOpcode <= Decoded_Flip;
        when OpCode_Store =>
          sampledDecodedOpcode <= Decoded_Store;
        when OpCode_PopSP =>
          sampledDecodedOpcode <= Decoded_PopSP;
        when others =>
          sampledDecodedOpcode <= Decoded_Nop;
      end case;  -- tOpcode(3 downto 0)
    end if; -- tOpcode
  end process;


  opcodeControl: process(clk, reset)
    variable spOffset : unsigned(4 downto 0);
    variable tMultResult    : unsigned(wordSize*2-1 downto 0);
  begin


		if COMPARISON_SUB=true and comparison_sub_result='0'&X"00000000" then
			comparison_eq<='1';
		else
			comparison_eq<='0';
		end if;
  
--	if STOREBH=false then  -- If we're not implementing storeh or storeb then tie mask to 1
--		mem_writeMask <= (others => '1');
--	end if;
 
    if reset = '1' then
      state               <= State_Resync;
      break               <= '0';
      sp                  <= unsigned(spStart(maxAddrBitStackBRAM downto minAddrBit));
      pc                  <= (others => '0');
      idim_flag           <= '0';
      begin_inst          <= '0';
      memAAddr            <= (others => '0');
      memBAddr            <= (others => '0');
      memAWriteEnable     <= '0';
      memBWriteEnable     <= '0';
      out_mem_writeEnable <= '0';
      out_mem_readEnable  <= '0';
      memAWrite           <= (others => '0');
      memBWrite           <= (others => '0');
      inInterrupt         <= '0';
		fetchneeded			  <= '1';

    elsif (clk'event and clk = '1') then
      memAWriteEnable <= '0';
      memBWriteEnable <= '0';
      -- This saves ca. 100 LUT's, by explicitly declaring that the
      -- memAWrite can be left at whatever value if memAWriteEnable is
      -- not set.
      memAWrite       <= (others => DontCareValue);
      memBWrite       <= (others => DontCareValue);
--    out_mem_addr    <= (others => DontCareValue);
--    mem_write       <= (others => DontCareValue);
      spOffset        := (others => DontCareValue);
		
		-- We want memAAddr to remain stable since the length of the fetch depends on external RAM.
--      memAAddr        <= (others => DontCareValue);
      memBAddr        <= (others => DontCareValue);

      out_mem_writeEnable <= '0';
      out_mem_writeEnableb <= '0';
      out_mem_writeEnableh <= '0';
      out_mem_readEnable  <= '0';
      begin_inst          <= '0';
--      out_mem_addr        <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
--      mem_write           <= std_logic_vector(memBRead);

      decodedOpcode <= sampledDecodedOpcode;
      opcode        <= sampledOpcode;
      if interrupt = '0' then
        inInterrupt <= '0';             -- no longer in an interrupt
      end if;

		if HARDWARE_MULTIPLY=true then
			tMultResult := memARead * memBRead;
		end if;

		if COMPARISON_SUB=true then
			comparison_sub_result<=unsigned(memBRead(wordSize-1)&memBRead)-unsigned(memARead(wordSize-1)&memARead);
		end if;

		eqbranch_zero<='0';
		if EQBRANCH=true and memBRead=X"00000000" then
			eqbranch_zero <='1';
		end if;

      case state is

        when State_Execute =>
          state <= State_Fetch;
          -- at this point:
          -- memBRead contains opcode word
          -- memARead contains top of stack
          pc    <= pc + 1;
			 if pc(1 downto 0)="11" then -- We fetch four bytes at a time.
				fetchneeded<='1'; 
			 end if;

          -- trace
          begin_inst                             <= '1';
          trace_pc                               <= (others => '0');
          trace_pc(maxAddrBit downto 0)          <= std_logic_vector(pc);
          trace_opcode                           <= opcode;
          trace_sp                               <= (others => '0');
          trace_sp(maxAddrBitStackBRAM downto minAddrBit) <= std_logic_vector(sp);
          trace_topOfStack                       <= std_logic_vector(memARead);
          trace_topOfStackB                      <= std_logic_vector(memBRead);

          -- during the next cycle we'll be reading the next opcode       
          spOffset(4)          := not opcode(4);
          spOffset(3 downto 0) := unsigned(opcode(3 downto 0));

          idim_flag <= '0';

          case decodedOpcode is

            when Decoded_Interrupt =>
              sp                             <= sp - 1;
              memAAddr                       <= sp - 1;
              memAWriteEnable                <= '1';
              memAWrite                      <= (others => DontCareValue);
              memAWrite(maxAddrBit downto 0) <= pc;
              pc                             <= to_unsigned(32, maxAddrBit+1);  -- interrupt address
				  fetchneeded<='1'; -- Need to set this any time PC changes.
              report "ZPU jumped to interrupt!" severity note;

            when Decoded_Im =>
              idim_flag       <= '1';
              memAWriteEnable <= '1';
              if (idim_flag = '0') then
                sp       <= sp - 1;
                memAAddr <= sp-1;
                for i in wordSize-1 downto 7 loop
                  memAWrite(i) <= opcode(6);
                end loop;
                memAWrite(6 downto 0) <= unsigned(opcode(6 downto 0));
              else
                memAAddr                       <= sp;
                memAWrite(wordSize-1 downto 7) <= memARead(wordSize-8 downto 0);
                memAWrite(6 downto 0)          <= unsigned(opcode(6 downto 0));
              end if;  -- idim_flag

            when Decoded_StoreSP =>
              memBWriteEnable <= '1';
              memBAddr        <= sp+spOffset;
              memBWrite       <= memARead;
              sp              <= sp + 1;
              state           <= State_Resync;

            when Decoded_LoadSP =>
              sp       <= sp - 1;
              memAAddr <= sp+spOffset;

            when Decoded_Emulate =>
              sp                             <= sp - 1;
              memAWriteEnable                <= '1';
              memAAddr                       <= sp - 1;
              memAWrite                      <= (others => DontCareValue);
              memAWrite(maxAddrBit downto 0) <= pc + 1;
              -- The emulate address is:
              --        98 7654 3210
              -- 0000 00aa aaa0 0000
              pc                             <= (others => '0');
              pc(9 downto 5)                 <= unsigned(opcode(4 downto 0));
				  fetchneeded<='1'; -- Need to set this any time pc changes.


            when Decoded_AddSP =>
              memAAddr <= sp;
              memBAddr <= sp+spOffset;
              state    <= State_AddSP;

            when Decoded_Break =>
              report "Break instruction encountered" severity failure;
              break <= '1';

            when Decoded_PushSP =>
              memAWriteEnable                         <= '1';
              memAAddr                                <= sp - 1;
              sp                                      <= sp - 1;
              memAWrite                               <= (others => DontCareValue);
					if MMAP_STACK=true then
						memAWrite(maxAddrBitIncIO) <='0'; -- Mark address as being in the stack
						memAWrite(stackBit) <='1'; -- Mark address as being in the stack
					end if;
					memAWrite(maxAddrBitStackBRAM downto minAddrBit) <= sp;

            when Decoded_PopPC =>
              pc    <= memARead(maxAddrBit downto 0);
				  fetchneeded<='1'; -- Need to set this any time PC changes.
              sp    <= sp + 1;
              state <= State_Resync;

				when Decoded_EqBranch =>
					if EQBRANCH=true then
						sp    <= sp + 1;
						if (eqbranch_zero xor opcode(0))='0' then -- eqbranch is 55, neqbranch is 56
							pc    <= pc+memARead(maxAddrBit downto 0);
							fetchneeded<='1'; -- Need to set this any time PC changes.
						end if;
						state <= State_IncSP;
					end if;
					
				when Decoded_Comparison =>
					sp    <= sp + 1;
					state <= State_Comparison;

            when Decoded_Add =>
              sp    <= sp + 1;
              state <= State_Add;

			   when Decoded_Sub =>
              sp    <= sp + 1;
              state <= State_Sub;

            when Decoded_Or =>
              sp    <= sp + 1;
              state <= State_Or;

            when Decoded_And =>
              sp    <= sp + 1;
              state <= State_And;

			   when Decoded_Mult =>
              sp    <= sp + 1;
              state <= State_Mult;

            when Decoded_Load =>
              if MMAP_STACK=true and memARead(maxAddrBitIncIO downto stackBit) = "01" then -- Access is bound for stack RAM
                memAAddr <= memARead(maxAddrBitStackBRAM downto minAddrBit);
				  else
					 out_mem_addr(1 downto 0) <="00";
                out_mem_addr(maxAddrBitIncIO downto 2)<= std_logic_vector(memARead(maxAddrBitIncIO downto 2));
                out_mem_readEnable <= '1';
                state              <= State_ReadIO;
             end if;

				when Decoded_EqNeq =>
					sp <= sp + 1;
					state <= State_EqNeq;

            when Decoded_Not =>
              memAAddr        <= sp(maxAddrBitStackBRAM downto minAddrBit);
              memAWriteEnable <= '1';
              memAWrite       <= not memARead;

            when Decoded_Flip =>
              memAAddr        <= sp(maxAddrBitStackBRAM downto minAddrBit);
              memAWriteEnable <= '1';
              for i in 0 to wordSize-1 loop
                memAWrite(i) <= memARead(wordSize-1-i);
              end loop;

            when Decoded_Store =>
              memBAddr <= sp + 1;
              sp       <= sp + 1;
              if MMAP_STACK=true and memARead(maxAddrBitIncIO downto stackBit) = "01" then -- Access is bound for stack RAM
                state <= State_Store;
				  else
                state <= State_WriteIO;
              end if;

				when Decoded_StoreBH =>
				  if STOREBH=true then
					  memBAddr <= sp + 1;
					  sp       <= sp + 1;
					 state <= State_WriteIOBH;
				  end if;

            when Decoded_PopSP =>
              sp    <= memARead(maxAddrBitStackBRAM downto minAddrBit);
              state <= State_Resync;

				when Decoded_Call =>
					if CALL=true then
						pc <= memARead(maxAddrBit downto 0); -- Set PC to value on top of stack
						fetchneeded<='1'; -- Need to set this any time PC changes.

						memAWriteEnable                <= '1';
						memAAddr                       <= sp; -- Replace stack top with PC+1
						memAWrite                      <= (others => DontCareValue);
						memAWrite(maxAddrBit downto 0) <= pc + 1;
					end if;

				when Decoded_Nop =>
              memAAddr <= sp;

            when others =>
              null;

          end case;  -- decodedOpcode

        when State_ReadIO =>
          memAAddr <= sp;
          if (in_mem_busy = '0') then
            state           <= State_Fetch;
            memAWriteEnable <= '1';
            memAWrite       <= unsigned(mem_read);
          end if;
			 fetchneeded<='1'; -- Need to set this any time out_mem_addr changes.

        when State_WriteIO =>
--			 mem_writeMask <= (others => '1');
          sp                  <= sp + 1;
          out_mem_writeEnable <= '1';
          out_mem_addr        <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
          mem_write           <= std_logic_vector(memBRead);
          state               <= State_WriteIODone;
--			 fetchneeded<='1'; -- Need to set this any time out_mem_addr changes.
									-- (actually, not necessary for writes)

			when State_WriteIOBH =>
				if STOREBH=true then
--					mem_writeMask <= (others => '1');
					sp                  <= sp + 1;
					out_mem_writeEnableb <= not opcode(0); -- storeb is opcode 52
					out_mem_writeEnableh <= opcode(1); -- storeh is opcode 35
					out_mem_addr        <= std_logic_vector(memARead(maxAddrBitIncIO downto 0));
					mem_write           <= std_logic_vector(memBRead);
					state               <= State_WriteIODone;
--					fetchneeded<='1'; -- Need to set this any time out_mem_addr changes.
											-- (actually, not necessary for writes)
				end if;

        when State_WriteIODone =>
          if (in_mem_busy = '0') then
            state <= State_Resync;
          end if;

        when State_Fetch =>
			 -- AMR - fetch from external RAM, not Block RAM.
			 out_mem_addr <= (others => '0');
          out_mem_addr(maxAddrBit downto 2)<=std_logic_vector(pc(maxAddrBit downto 2));
          out_mem_readEnable <= fetchneeded;
          -- FIXME - don't refetch if data is still valid.

          -- We need to resync. During the *next* cycle
          -- we'll fetch the opcode @ pc and thus it will
          -- be available for State_Execute the cycle after
          -- next
--          memBAddr <= pc(maxAddrBit downto minAddrBit);
			 state    <= State_FetchNext;

        when State_FetchNext =>
          -- at this point memARead contains the value that is either
          -- from the top of stack or should be copied to the top of the stack
			 if in_mem_busy='0' or fetchneeded='0' then
				 memAWriteEnable <= '1';
				 fetchneeded<='0';
				 memAWrite       <= memARead;
				 memAAddr        <= sp;
				 memBAddr        <= sp + 1;
				 state           <= State_Decode;
			 end if;

        when State_Decode =>
          if interrupt = '1' and inInterrupt = '0' and idim_flag = '0' then
            -- We got an interrupt, execute interrupt instead of next instruction
            inInterrupt   <= '1';
            decodedOpcode <= Decoded_Interrupt;
          end if;
          -- during the State_Execute cycle we'll be fetching SP+1  (AMR - already done at FetchNext, yes?)
          memAAddr <= sp;
          memBAddr <= sp + 1;
          state    <= State_Execute;

        when State_Store =>
          sp              <= sp + 1;
          memAWriteEnable <= '1';
          memAAddr        <= memARead(maxAddrBitStackBRAM downto minAddrBit);
          memAWrite       <= memBRead;
          state           <= State_Resync;

			when State_AddSP =>
				state <= State_Add;

        when State_Add =>
          memAAddr        <= sp;
          memAWriteEnable <= '1';
          memAWrite       <= memARead + memBRead;
          state           <= State_Fetch;

			when State_Sub =>
				memAAddr        <= sp;
				memAWriteEnable <= '1';
				memAWrite       <= comparison_sub_result(wordSize-1 downto 0);
				state           <= State_Fetch;

			when State_Mult =>
          memAAddr        <= sp;
          memAWriteEnable <= '1';
          memAWrite       <= tMultResult(wordSize-1 downto 0);
          state           <= State_Fetch;

		  when State_Or =>
          memAAddr        <= sp;
          memAWriteEnable <= '1';
          memAWrite       <= memARead or memBRead;
          state           <= State_Fetch;

			when State_IncSP =>
				sp<=sp+1;
				state <= State_Resync;

        when State_Resync =>
          memAAddr <= sp;
          state    <= State_Fetch;

        when State_And =>
          memAAddr        <= sp;
          memAWriteEnable <= '1';
          memAWrite       <= memARead and memBRead;
          state           <= State_Fetch;

		  when State_EqNeq =>
				memAAddr <= sp;
				memAWriteEnable <= '1';
				memAWrite       <= (others =>'0');
				memAWrite(0) <= comparison_eq xor opcode(4); -- eq is 46, neq is 48.
				state <= State_Fetch;
				
			when State_Comparison =>
				-- FIXME - what about unsigned comparison - simpler or not?
				memAAddr <= sp;
				memAWriteEnable <= '1';
				memAWrite <= (others => '0');
				memAWrite(0) <= not (comparison_sub_result(wordSize)
											xor (not opCode(0) and comparison_eq));
				state <= State_Fetch;

        when others =>
          null;

      end case;  -- state
      
    end if;  -- reset, enable
  end process;



end behave;
