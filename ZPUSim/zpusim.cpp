#include <iostream>
#include <string>
#include <sstream>

#include <getopt.h>

#include "binaryblob.h"
#include "debug.h"

#define STACKSIZE 1024
#define STACKOFFSET 0x04000000

// FIXME - make memory-mapped stack optional.
// FIXME - replicate core generic options.

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
	ZPUMemory(int ramsize) : uartbusyctr(0), ram(0), ramsize(ramsize), uartin(0)
	{
		ram=new int[ramsize/4];
	}
	virtual ~ZPUMemory()
	{
		if(ram)
			delete[] ram;
	}
	virtual void SetUARTIn(const char *c)
	{
		uartin=c;
	}
	virtual int Read(unsigned int addr)
	{
		switch(addr)
		{
			case 0xffffffc4:
				Debug[WARN] << std::endl << "Reading from SPI_CS" << std::endl << std::endl;
				break;
			case 0xffffffc8:
				Debug[WARN] << std::endl << "Reading from SPI" << std::endl << std::endl;
				break;
			case 0xffffffcc:
				Debug[WARN] << std::endl << "Reading from SPI_PUMP" << std::endl << std::endl;
				break;
			case 0xffffff84:
				Debug[WARN] << std::endl << "Reading from UART" << std::endl << std::endl;
				if(uartbusyctr)
				{
					--uartbusyctr;
					return(0);
				}
				else
				{
					int result;
					uartbusyctr=1;	// Make the UART pretend to be busy for the next n cycles
					if(uartin)
						result=0x300 | (unsigned char)*uartin++;	// Received byte ready...
					else
						result=0x300 | (std::cin.get()&0xff);

					if(result==0x300)	// End of string?
						uartin=0;

					if(std::cin.eof())
						throw "End of input data";

					return(result);
				}
				break;
			default:
				if(addr<ramsize)
					return(ram[addr/4]);
		}
		return(0);
	}
	virtual void Write(unsigned int addr,int v)
	{
		switch(addr)
		{
			case 0xffffff84:
				if(v)
				{
					Debug[WARN] << std::endl << "Writing " << char(v) << " to UART" << std::endl << std::endl;
					std::cout << char(v);
				}
				else
				{
					Debug[WARN] << std::endl << "Writing (nul) to UART" << std::endl << std::endl;
					std::cout << "(nul)";
				}
				break;

			case 0xffffff88:
				Debug[WARN] << std::endl << "Setting UART divisor to " << v << std::endl << std::endl;
				break;

			case 0xffffff8C:
				Debug[WARN] << std::endl << "Writing to overlay register: " << v << std::endl << std::endl;
				break;

			case 0xffffff90:
				Debug[WARN] << std::endl << "Writing " << v << " to HEX display" << std::endl << std::endl;
				break;

			case 0xffffffc4:
				Debug[WARN] << std::endl << "Setting spi_cs line " << (v&1 ? "low" : "high" ) << std::endl << std::endl;
				break;

			case 0xffffffc8:
				Debug[WARN] << std::endl << "Writing " << v << " to SPI" << std::endl << std::endl;
				break;

			case 0xffffffcc:
				Debug[WARN] << std::endl << "Writing " << v << " to SPI_pump" << std::endl << std::endl;
				break;
			default:
				if(addr<ramsize)
					ram[addr/4]=v;
		}
	}
	virtual unsigned char &operator[](const int idx)=0;
	protected:
	int uartbusyctr;
	int *ram;
	int ramsize;
	const char *uartin;
};


class ZPUProgram : public BinaryBlob, public ZPUMemory
{
	public:
	ZPUProgram(const char *filename, int ramsize=8*1024*1024) : BinaryBlob(filename), ZPUMemory(ramsize)
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
	ZPUSim(int stacksize=STACKSIZE) : stack(stacksize), initpc(0), steps(-1)
	{		
	}

	~ZPUSim()
	{
	}

	int ParseOptions(int argc,char *argv[])
	{
		static struct option long_options[] =
		{
			{"help",no_argument,NULL,'h'},
			{"steps",required_argument,NULL,'s'},
			{"boot",no_argument,NULL,'b'},
			{"report",required_argument,NULL,'r'},
			{0, 0, 0, 0}
		};

		while(1)
		{
			int c;
			c = getopt_long(argc,argv,"hs:r:b",long_options,NULL);
			if(c==-1)
				break;
			switch (c)
			{
				case 'h':
					printf("Usage: %s [options] <UART input text>\n",argv[0]);
					printf("    -h --help\t  display this message\n");
					printf("    -s --steps\t  Simulate a specific number of steps (default: indefinite)\n");
					printf("    -r --report\t  set reporting level - 0 for silent, 4 for verbose\n");
					printf("    -b --boot\t  set initial PC to boot ROM\n");
					break;
				case 'b':
					initpc=0x04000000;
					break;
				case 's':
					steps=atoi(optarg);
					break;
				case 'r':
					Debug.SetLevel(DebugLevel(atoi(optarg)));
					break;
			}
		}
		return(optind);
	}

	

	int GetOpcode(ZPUMemory &prg, int pc)
	{
		if((pc<0xf0000000) && (pc&STACKOFFSET))
		{
			int t=stack[pc&~3];
			int opcode=t>>((3-(pc&3))<<3);
			return(opcode&0xff);
		}
		else
			return((unsigned char)prg[pc]);
	}

	void CopyProgramToStack(ZPUProgram &prg)
	{
		int s=prg.GetSize()*4;
		int i=0;
		while(i<s)
		{
			int t=(prg[i]<<24)|(prg[i+1]<<16)|(prg[i+2]<<8)|(prg[i+3]);
			stack[STACKOFFSET+i]=t;
			i+=4;
		}
	}

	void Run(ZPUProgram &prg)
	{
		Debug[WARN] << "Starting simulation" << std::endl;
		Debug[ERROR] << std::hex << std::endl;
		pc=initpc;
		if(initpc==STACKOFFSET)
			CopyProgramToStack(prg);
		sp=STACKOFFSET+stack.GetSize()*4-8;

		bool run=true;

		bool immediate_continuation=false;

		while(run)
		{
			int nextpc;
			int opcode=GetOpcode(prg,pc);
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
					int a,b;
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

						case 42:	// lshiftright
							mnem<<"lshiftright ";
							{
								int sh=Pop()&0x3f;
								unsigned int v=(unsigned int)Pop();
								Push(v>>sh);
							}
							break;

						case 43:	// ashiftleft
							mnem<<"ashiftleft ";
							{
								int sh=Pop()&0x3f;
								int v=(int)Pop();
								Push(v<<sh);
							}
							break;

						case 44:	// ashiftright
							mnem<<"ashiftright ";
							{
								int sh=Pop()&0x3f;
								int v=(int)Pop();
								Push(v>>sh);
							}
							break;

						case 45:	// call
							mnem<<"call ";
							{
								nextpc=Pop();
								Push(pc+1);
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
							a=Pop(); b=Pop();
							Push(b-a);
							break;

						case 61: // pushspadd
							mnem<<"pushspadd ";
							Push(sp+Pop()*4);
							break;

						case 36: // lessthan
							mnem<<"lessthan ";
							a=Pop(); b=Pop();
							Push(a<b ? 1 : 0);
							break;

						case 37: // lessthanorequal
							mnem<<"lessthanorequal ";
							a=Pop(); b=Pop();
							Push(a<=b ? 1 : 0);
							break;

						case 38: // ulessthan
							mnem<<"ulessthan ";
							a=Pop(); b=Pop();
							Push(((unsigned int)a)<((unsigned int)b) ? 1 : 0);
							break;

						case 39: // ulessthanorequal
							mnem<<"ulessthanorequal ";
							a=Pop(); b=Pop();
							Push(((unsigned int)a)<=((unsigned int)b) ? 1 : 0);
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
	ZPUStack stack;
	int pc;
	int sp;
	int initpc;
	int steps;
};


int main(int argc, char **argv)
{
	try
	{
		Debug.SetLevel(TRACE);
		if(argc>1)
		{
			int i;
			char *uartin=0;
			ZPUSim sim;
			i=sim.ParseOptions(argc,argv);
			if(i<argc)
			{
				ZPUProgram prg(argv[i++]);
				if(i<argc)
				{
					Debug[TRACE] << "Setting uartin to " << argv[i] << std::endl;
					prg.SetUARTIn(argv[i++]);
				}
				else
				{
					Debug[TRACE] << "All arguments used: " << i << ", " << argc << std::endl;
				}
				sim.Run(prg);
			}
		}
	}
	catch(const char *err)
	{
		std::cerr << "Error: " << err << std::endl;
	}
	return(0);
}

