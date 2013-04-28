#include <stdio.h>

int main(int argc, char **argv)
{
	short op1,op2;
	int passed=1;
	for(op1=-0x7fff;op1<0x70ff;op1+=1024)
	{
		for(op2=-0x7fff;op2<0x70ff;op2+=1024)
		{
			unsigned int sub=(unsigned short)op2;
			sub-=(unsigned short)op1;
			int n1=(op1>>15)&1;
			int n2=(op2>>15)&1;
			int subsign=(sub>>16)&1;
			int eq=op1==op2 ? 1 : 0;
//			int lt=!(n1 ^ n2 ^ subsign ^ eq); // Strictly less than
			int lt=!(n1 ^ n2 ^ subsign); // Less than or equal
			int lts=op1<=op2 ? 1 : 0;
			if(lt!=lts)
			{
				printf("0x%x < 0x%x? N1: %d, N2: %d, Subsign: %d  => %d, %d\n",op1,op2,n1,n2,subsign,lt,lts);
				passed=0;
			}
		}
	}
	if(passed)
		printf("Comparison algorithm test passed.\n");
	else
		printf("Comparison algorithm test failed.\n");

	return(0);
}

