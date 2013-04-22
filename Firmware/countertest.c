
#define COUNTER *(volatile unsigned int *)(0xFFFFFF80)
#define SWITCHES *(volatile unsigned int *)(0xFFFFFF84)

int main(int argc,char *argv)
{
	int c=0;
	while(1)
		COUNTER=SWITCHES*++c; // ++c;
	return(0);
}

