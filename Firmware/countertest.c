
#define COUNTER *(volatile unsigned int *)(0xFFFFFF80)

int main(int argc,char *argv)
{
	int c=0;
	while(1)
		COUNTER=c++;
	return(0);
}

