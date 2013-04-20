
#define PERIPHERALBASE 0xFFFFFF00

#define HW_PER_L(x) *(volatile unsigned int *)(PERIPHERALBASE+x)

#define PER_HEX 4

int main(int argc,char *argv)
{
	int c=0;
	while(1)
		HW_PER_L(PER_HEX)=c++;
	return(0);
}

