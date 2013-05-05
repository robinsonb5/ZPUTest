/*
 ****************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *                                                                            
 *  Version:    C, Version 2.1
 *                                                                            
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 ****************************************************************************
 */

#include "dhry.h"
#include <stdarg.h>

#include "minisoc_hardware.h"

static int
_cvt(int val, char *buf, int radix, char *digits)
{
	char *temp=(char*)0x18000; // FIXME - allocate this properly
//    char temp[80];
    char *cp = temp;
    int length = 0;

    if (val == 0) {
        /* Special case */
        *cp++ = '0';
    } else {
        while (val) {
            *cp++ = digits[val &15]; // % radix];
            val >>=4; // /= radix;
        }
    }
    while (cp != temp) {
        *buf++ = *--cp;
        length++;
    }
    *buf = '\0';
    return (length);
}

#define is_digit(c) ((c >= '0') && (c <= '9'))


// char vpfbuf[sizeof(long long)*8];

static int
_vprintf(void (*putc)(char c, void **param), void **param, const char *fmt, va_list ap)
{
	char *vpfbuf=(char *)0x18100; // FIXME - allocate this properly.
//    char buf[sizeof(long long)*8];
    char c, sign, *cp=vpfbuf;
    int left_prec, right_prec, zero_fill, pad, pad_on_right, 
        i, islong, islonglong;
    long val = 0;
    int res = 0, length = 0;

    while ((c = *fmt++) != '\0') {
		char tmp[2];
        if (c == '%') {
            c = *fmt++;
            left_prec = right_prec = pad_on_right = islong = islonglong = 0;
            sign = '\0';
            // Fetch value [numeric descriptors only]
            switch (c) {
            case 'd':
                    val = (long)va_arg(ap, int);
//                if ((c == 'd') || (c == 'D')) {
                    if (val < 0) {
                        sign = '-';
                        val = -val;
                    }
 //               } else {
 //                   // Mask to unsigned, sized quantity
 //                   if (islong) {
 //                       val &= ((long)1 << (sizeof(long) * 8)) - 1;
 //                  } else{
 //                       val &= ((long)1 << (sizeof(int) * 8)) - 1;
 //                   }
//                }
                break;
            default:
                break;
            }
            // Process output
            switch (c) {
            case 'd':
                switch (c) {
                case 'd':
                    length = _cvt(val, vpfbuf, 10, "0123456789ABCDEF");
                    break;
                }
                cp = vpfbuf;
                break;
            case 's':
                cp = va_arg(ap, char *);
                length = 0;
                while (cp[length] != '\0') length++;
                break;
            case 'c':
                c = va_arg(ap, int /*char*/);
                (*putc)(c, param);
                res++;
                continue;
            default:
                (*putc)('%', param);
                (*putc)(c, param);
                res += 2;
                continue;
            }
            while (length-- > 0) {
                c = *cp++;
                (*putc)(c, param);
                res++;
            }
        } else {
            (*putc)(c, param);
            res++;
        }
    }
    return (res);
}


// Default wrapper function used by diag_printf
static void
_diag_write_char(char c, void **param)
{
	while(!(HW_PER(PER_UART)&(1<<PER_UART_TXREADY)))
		;
	HW_PER(PER_UART)=c;
}


int
small_printf(const char *fmt, ...)
{
#ifndef TINY
    va_list ap;
    int ret;

    va_start(ap, fmt);
    ret = _vprintf(_diag_write_char, (void **)0, fmt, ap);
    va_end(ap);
    return (ret);
#else
	return 0;
#endif
}




/* Global Variables: */

Rec_Pointer     Ptr_Glob,
                Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
int            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

Enumeration     Func_1 ();
  /* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
        Boolean Reg = false;
#define REG
        /* REG becomes defined as empty */
        /* i.e. no register variables   */
#else
        Boolean Reg = true;
#endif

/* variables for time measurement: */

#ifdef TIMES
struct tms      time_info;
                /* see library function "times" */
#define Too_Small_Time 120
                /* Measurements should last at least about 2 seconds */
#endif
#ifdef TIME
extern long     time();
                /* see library function "time"  */
#define Too_Small_Time 2
                /* Measurements should last at least 2 seconds */
#endif

long           Begin_Time,
                End_Time,
                User_Time;
long            Microseconds,
                Dhrystones_Per_Second,
                Vax_Mips;
                
/* end of variables for time measurement */

int             Number_Of_Runs = 5000;

#define _readMilliseconds() HW_PER(PER_MILLISECONDS);


int main ()
/*****/

  /* main program, corresponds to procedures        */
  /* Main and Proc_0 in the Ada version             */
{
        One_Fifty       Int_1_Loc;
  REG   One_Fifty       Int_2_Loc;
        One_Fifty       Int_3_Loc;
  REG   char            Ch_Index;
        Enumeration     Enum_Loc;

char *Str_1_Loc=0x50000;
char *Str_2_Loc=0x50100;
//        Str_30          Str_1_Loc;
//        Str_30          Str_2_Loc;
  REG   int             Run_Index;

  /* Initializations */
  HW_PER(PER_UART_CLKDIV)=1330000/1152;
  small_printf("UART Initialized\n");

//  Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
//  Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));

Next_Ptr_Glob = (Rec_Pointer) 0x20000;
Ptr_Glob = (Rec_Pointer) 0x30000;

  small_printf("Allocated buffers: %d, %d\n",Next_Ptr_Glob, Ptr_Glob);

  Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
  Ptr_Glob->Discr                       = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp      = 40;
  strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
          "DHRYSTONE PROGRAM, SOME STRING");
  strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  putserial("Done strcpy\n");

  Arr_2_Glob [8][7] = 10;
        /* Was missing in published program. Without this statement,    */
        /* Arr_2_Glob [8][7] would have an undefined value.             */
        /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
        /* overflow may occur for this array element.                   */
//  small_printf ("\n");
  putserial("\nDhrystone Benchmark, Version 2.1 (Language: C)\n");
//  small_printf ("\n");

  if (Reg)
  {
    small_printf ("Program compiled with 'register' attribute\n");
    small_printf ("\n");
  }
  else
  {
    putserial ("Program compiled without 'register' attribute\n");
//    small_printf ("\n");
  }

  small_printf ("Execution starts, %d runs through Dhrystone\n", Number_Of_Runs);

  /***************/
  /* Start timer */
  /***************/

#define STR_BASE 0x40000

#if 0
#ifdef TIMES
  times (&time_info);
  Begin_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  Begin_Time = time ( (long *) 0);
#endif
#else
  Begin_Time = _readMilliseconds();
#endif
  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {
//	putserial(".");
    Proc_5();
    Proc_4();
      /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy (STR_BASE+Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
//	putserial("o");
    Enum_Loc = Ident_2;
    Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      /* Bool_Glob == 1 */
//	putserial("a");
    while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
    {
      Int_3_Loc = (5 * Int_1_Loc - Int_2_Loc);
        /* Int_3_Loc == 7 */
      Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
        /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
//	putserial("b");
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
//    Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
    Proc_8 (0x33000, 0x34000, Int_1_Loc, Int_3_Loc);
      /* Int_Glob == 5 */
    Proc_1 (Ptr_Glob);
//	putserial("c");
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                             /* loop body executed twice */
    {
      if (Enum_Loc == Func_1 (Ch_Index, 'C'))
          /* then, not executed */
        {
        Proc_6 (Ident_1, &Enum_Loc);
        strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
        }
    }
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
      /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2 (&Int_1_Loc);
      /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/
  
#if 0
#ifdef TIMES
  times (&time_info);
  End_Time = (long) time_info.tms_utime;
#endif
#ifdef TIME
  End_Time = time ( (long *) 0);
#endif
#else
  End_Time = _readMilliseconds();
#endif
  
  small_printf ("Execution ends\n");
//  small_printf ("\n");
  small_printf ("Final values of the variables used in the benchmark:\n");
//  small_printf ("\n");
  small_printf ("Int_Glob:            %d\n", Int_Glob);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Bool_Glob:           %d\n", Bool_Glob);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Ch_1_Glob:           %c\n", Ch_1_Glob);
  small_printf ("        should be:   %c\n", 'A');
  small_printf ("Ch_2_Glob:           %c\n", Ch_2_Glob);
  small_printf ("        should be:   %c\n", 'B');
  small_printf ("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
  small_printf ("        should be:   Number_Of_Runs + 10\n");
  small_printf ("Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent)\n");
  small_printf ("  Discr:             %d\n", Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 2);
  small_printf ("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 17);
  small_printf ("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Next_Ptr_Glob->\n");
  small_printf ("  Ptr_Comp:          %d\n", (int) Next_Ptr_Glob->Ptr_Comp);
  small_printf ("        should be:   (implementation-dependent), same as above\n");
  small_printf ("  Discr:             %d\n", Next_Ptr_Glob->Discr);
  small_printf ("        should be:   %d\n", 0);
  small_printf ("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  small_printf ("        should be:   %d\n", 18);
  small_printf ("  Str_Comp:          %s\n",
                                Next_Ptr_Glob->variant.var_1.Str_Comp);
  small_printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
  small_printf ("Int_1_Loc:           %d\n", Int_1_Loc);
  small_printf ("        should be:   %d\n", 5);
  small_printf ("Int_2_Loc:           %d\n", Int_2_Loc);
  small_printf ("        should be:   %d\n", 13);
  small_printf ("Int_3_Loc:           %d\n", Int_3_Loc);
  small_printf ("        should be:   %d\n", 7);
  small_printf ("Enum_Loc:            %d\n", Enum_Loc);
  small_printf ("        should be:   %d\n", 1);
  small_printf ("Str_1_Loc:           %s\n", Str_1_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
  small_printf ("Str_2_Loc:           %s\n", Str_2_Loc);
  small_printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
  small_printf ("\n");

  User_Time = End_Time - Begin_Time;
  small_printf ("Begin time: %d\n", (int)Begin_Time);
  small_printf ("End time: %d\n", (int)End_Time);
  small_printf ("User time: %d\n", (int)User_Time);
  
  if (User_Time < Too_Small_Time)
  {
    small_printf ("Measured time too small to obtain meaningful results\n");
    small_printf ("Please increase number of runs\n");
    small_printf ("\n");
  }
/*   else */
  {
#if 0
#ifdef TIME
    Microseconds = (User_Time * Mic_secs_Per_Second )
                        /  Number_Of_Runs;
    Dhrystones_Per_Second =  Number_Of_Runs / User_Time;
    Vax_Mips = (Number_Of_Runs*1000) / (1757*User_Time);
#else
    Microseconds = (float) User_Time * Mic_secs_Per_Second 
                        / ((float) HZ * ((float) Number_Of_Runs));
    Dhrystones_Per_Second = ((float) HZ * (float) Number_Of_Runs)
                        / (float) User_Time;
    Vax_Mips = Dhrystones_Per_Second / 1757.0;
#endif
#else
    Microseconds = User_Time  / Number_Of_Runs;
    Dhrystones_Per_Second =  (Number_Of_Runs*1000) / User_Time;
	long scaled_time=(1757*User_Time)>>6;
    Vax_Mips = ((Number_Of_Runs)*(1000000/64)) / scaled_time;
#endif 
    small_printf ("Microseconds for one run through Dhrystone: ");
    small_printf ("%d \n", (int)Microseconds);
    small_printf ("Dhrystones per Second:                      ");
    small_printf ("%d \n", (int)Dhrystones_Per_Second);
    small_printf ("VAX MIPS rating * 1000 = %d \n",(int)Vax_Mips);
    small_printf ("\n");
  }
  
  return 0;
}


Proc_1 (Ptr_Val_Par)
/******************/

REG Rec_Pointer Ptr_Val_Par;
    /* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


Proc_2 (Int_Par_Ref)
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
  One_Fifty  Int_Loc;  
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


Proc_3 (Ptr_Ref_Par)
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


Proc_4 () /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


Proc_5 () /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */
#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif


