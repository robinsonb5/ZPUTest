#include <iostream>
#include <string>
#include <sstream>

#include "binaryblob.h"
#include "debug.h"

#define STACKSIZE 1024
#define STACKOFFSET 0x04000000

class ZPUStack
{
	public:
	ZPUStack(const int size) : stack(0), size(size), err(-1)
	{
		stack=new int[size];
		for(int i=0;i<size;++i)
			stack[i]=0;
	}
	~ZPUStack()
	{
		if(stack)
			delete[] stack;
	}
	int &operator[](const int idx)
	{
		int i=(idx-STACKOFFSET)/4;
		if(idx<STACKOFFSET)
			Debug[ERROR] << "Stack pointer missing offset!";
		if(i<0)
			Debug[WARN] << "Stack underflow!";
		if(i>=size)
			return(err);
//			Debug[WARN] << "Stack overflow!";
		return(stack[i]);
	}
	int GetSize()
	{
		return(size);
	}
	void Dump(int sp,int levels,int deeplevels=0)
	{
		for(int i=0;i<levels;++i)
			Debug[TRACE] << "\t" << (*this)[sp+i*4];
		for(int i=levels;i<(levels+deeplevels);++i)
			Debug[MINUTIAE] << "\t" << (*this)[sp+i*4];
	}
	protected:
	int *stack;
	int size;
	int err;
};


class ZPUMemory
{
	public:
	ZPUMemory() : uartbusyctr(0)
	{
	}
	virtual ~ZPUMemory()
	{
	}
	virtual int Read(unsigned int addr)
	{
		switch(addr)
		{
			case 0xffffffc4:
				Debug[TRACE] << std::endl << "Reading from SPI_CS" << std::endl << std::endl;
				break;
			case 0xffffffc8:
				Debug[TRACE] << std::endl << "Reading from SPI" << std::endl << std::endl;
				break;
			case 0xffffffcc:
				Debug[TRACE] << std::endl << "Reading from SPI_PUMP" << std::endl << std::endl;
				break;
			case 0xffffff84:
				Debug[TRACE] << std::endl << "Reading from UART" << std::endl << std::endl;
				if(uartbusyctr)
				{
					--uartbusyctr;
					return(0);
				}
				else
				{
					uartbusyctr=1;	// Make the UART pretend to be busy for the next n cycles
					return(0x100);
				}
				break;
		}
		return(0);
	}
	virtual void Write(unsigned int addr,int v)
	{
		switch(addr)
		{
			case 0xffffff84:
				Debug[TRACE] << std::endl << "Writing " << char(v) << " to UART" << std::endl << std::endl;
				break;

			case 0xffffff88:
				Debug[TRACE] << std::endl << "Setting UART divisor to " << v << std::endl << std::endl;
				break;

			case 0xffffff90:
				Debug[TRACE] << std::endl << "Writing " << v << " to HEX display" << std::endl << std::endl;
				break;

			case 0xffffffc4:
				Debug[TRACE] << std::endl << "Setting spi_cs line " << (v&1 ? "low" : "high" ) << std::endl << std::endl;
				break;

			case 0xffffffc8:
				Debug[TRACE] << std::endl << "Writing " << v << " to SPI" << std::endl << std::endl;
				break;

			case 0xffffffcc:
				Debug[TRACE] << std::endl << "Writing " << v << " to SPI_pump" << std::endl << std::endl;
				break;
		}
	}
	virtual unsigned char &operator[](const int idx)=0;
	protected:
	int uartbusyctr;
};


class ZPUProgram : public BinaryBlob, public ZPUMemory
{
	public:
	ZPUProgram(const char *filename) : BinaryBlob(filename), ZPUMemory()
	{
	}
	~ZPUProgram()
	{
	}
	virtual int Read(unsigned int addr)
	{
		if(addr<(size-3))
		{
			int r=(*this)[addr]<<24;
			r|=(*this)[addr+1]<<16;
			r|=(*this)[addr+2]<<8;
			r|=(*this)[addr+3];
			Debug[WARN] << std::endl << "Reading from " << addr << std::endl;
			return(r);
		}
		return(ZPUMemory::Read(addr));
	}
	virtual void Write(unsigned int addr,int v)
	{
		if(addr<(size-3))
		{
			(*this)[addr]=(v>>24)&255;
			(*this)[addr+1]=(v>>16)&255;
			(*this)[addr+2]=(v>>8)&255;
			(*this)[addr+3]=v&255;
			Debug[WARN] << std::endl << "Writing to " << addr << std::endl;
		}
		else
			ZPUMemory::Write(addr,v);
	}
	unsigned char &operator[](int idx)
	{
		return(BinaryBlob::operator[](idx));
	}
	protected:
};





class ZPUSim 
{
	public:
	ZPUSim(ZPUMemory &prg,int stacksize=STACKSIZE) : prg(prg), stack(stacksize)
	{		
	}
	~ZPUSim()
	{
	}
	void Run(int steps=-1)
	{
		Debug[TRACE] << "Starting simulation" << std::endl;
		Debug[TRACE] << std::hex << std::endl;
		pc=0;
		sp=STACKOFFSET+stack.GetSize()*4-8;
		bool run=true;

		bool immediate_continuation=false;

		while(run)
		{
			int nextpc;
			int opcode=(unsigned char)prg[pc];
			std::stringstream mnem;
			mnem << std::hex;

			int osp=sp;

			nextpc=pc+1;

			if(opcode&128)
			{
				if(immediate_continuation)
				{
					int op=Pop()<<7;
					op|=opcode&127;
					Push(op);
					mnem<<("im (cont) ");
					mnem << op;
				}
				else
				{
					int i=0;
					if(opcode&64)
						i=0xffffff80;
					i|=opcode&127;
					Push(i);
					immediate_continuation=true;
					mnem<<("im ");
					mnem<<(opcode&127);
				}
			}
			else
			{
				immediate_continuation=false;
				if(opcode==0)	// breakpoint
				{
					mnem<<("breakpoint");
					// Perhaps trigger a change in log level?
				}
				else if((opcode&0xf0)==0)	// opcodes with no immediate operand
				{
					switch(opcode&0x0f)
					{
						case 0x4: // poppc
							mnem<<("poppc");
							nextpc=Pop();
							break;
						case 0x8: // load
							{
								int addr=Pop();
								// FIXME - tidy up address decoding
								if((addr<0xf0000000) && (addr>STACKOFFSET))
									Push(stack[addr]);
								else
									Push(prg.Read(addr));
								mnem<<("load");
							}
							break;
						case 0xc: // store
							{
								int addr=Pop();
								int v=Pop();
								if((addr<0xf0000000) && (addr>STACKOFFSET))
									stack[addr]=v;
								else
									prg.Write(addr,v);
								mnem<<"store";
							}
							break;
						case 0x2: // pushsp
							Push(sp);
							mnem<<"pushsp";
							break;
						case 0xd: // popsp
							sp=Pop();
							mnem<<"popsp";
							break;
						case 0x5: // add
							Push(Pop()+Pop());
							mnem<<"add";
							break;
						case 0x6: // and
							Push(Pop()&Pop());
							mnem<<"and";
							break;
						case 0x7: // or
							Push(Pop()|Pop());
							mnem<<"or";
							break;
						case 0x9: // not
							Push(~Pop());
							mnem<<"not";
							break;
						case 0xa: // flip
							{
								unsigned A = Pop();
								unsigned B = 0;
								for (int i=0; i<32; i++)
								{ 
									if (A & (1<<i))
									{
										B |= (1<<(31-i));
									}
								}
								Push(B);
								mnem<<("flip");
							}
							break;
						case 0xb: // nop
							mnem<<("nop");
							break;

					}
				}
				else if((opcode&0xe0)==0x40) // storesp
				{
					int op=(opcode&0x1f)^0x10;
					int v=Pop();
					stack[sp+op*4-4]=v;
					mnem<<"storesp ";
					mnem<<op;
				}
				else if((opcode&0xe0)==0x60) // loadsp
				{
					int op=(opcode&0x1f) ^ 0x10;
					Push(stack[sp+op*4]);
					mnem<<"loadsp ";
					mnem<<op;
				}
				else if((opcode&0xf0)==0x10) // addsp
				{
					int op=opcode&0xf;
					stack[sp]+=stack[sp+op*4];
					mnem<<"addsp ";
					mnem<<op;
				}
				else if((opcode&0xe0)==0x20) // emulate
				{
					switch(opcode)
					{
						case 55:	// eqbranch
							{
								mnem<<"eqbranch ";
								int off=Pop();
								int cmp=Pop();
								if(!cmp)
									nextpc=pc+off;
							}
							break;

						case 56:	// neqbranch
							{
								mnem<<"neqbranch ";
								int off=Pop();
								int cmp=Pop();
								if(cmp)
									nextpc=pc+off;
							}
							break;

						case 46:	// eq
							mnem<<"eq ";
							Push(Pop()==Pop() ? 1 : 0);
							break;

						case 47:	// neq
							mnem<<"neq ";
							Push(Pop()==Pop() ? 0 : 1);
							break;

						case 49:	// sub
							mnem<<"sub ";
							Push(-(Pop()-Pop()));
							break;

						case 61: // pushspadd
							mnem<<"pushspadd ";
							Push(sp+Pop()*4);
							break;

						default:
							{
								int op=opcode&0x1f;
								Push(pc+1);
								nextpc=op*32;
								mnem<<"emulate ";
								mnem<<op;
							}
							break;
					}
				}

				if(steps>0)
					run=(--steps)!=0;
				else
					run=true;

			}
			Debug[TRACE] << "PC: " << pc << "\tOp:" << opcode << "\tSP: " << osp << ", " << sp << "\t" << mnem.str() << "\t";
			stack.Dump(sp,6,6);
			Debug[TRACE] << std::endl;
			pc=nextpc;			
		}
	}
	int Pop()
	{
		int result=stack[sp];
		sp+=4;
		return(result);
	}
	void Push(int v)
	{
		sp-=4;
		stack[sp]=v;
	}
	protected:
	ZPUMemory &prg;
	ZPUStack stack;
	int pc;
	int sp;
};


int main(int argc, char **argv)
{
	Debug.SetLevel(TRACE);
	if(argc>1)
	{
		ZPUProgram prg(argv[1]);
		ZPUSim sim(prg);
		sim.Run(50000);
	}
	return(0);
}

