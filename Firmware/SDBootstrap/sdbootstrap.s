*-----------------------------------------------------------
* Program    : TG68SerialBootstrap
* Written by : Alastair M. Robinson
* Date       : 2012-06-23
* Description: Program to bootstrap the TG68 project over RS232.  Receives an S-Record.
*              SD Card bootstrap code borrowed from the Chameleon Minimig port.
*-----------------------------------------------------------


; SD card code, borrowed from Minimig.
       
sd_start:
;		lea	msg_start_init,a0
;		bsr	put_msg
       jsr		asmspi_init
       bne     start2
       
		move.w	#$0002,HEX

		move.w		#$40,_drive	;Superfloppy
		bsr			_FindVolume		
       beq     start5
		clr.w		_drive		;1.Partition
		bsr			_FindVolume
       bne     start3
       
start5
			move.w	#$0003,HEX
			bsr			fat_cdroot
			;d0 - LBA
			lea		mmio_name,a1
			bsr		fat_findfile
			beq     start3	
				
			lea		found_MM,a0
			bsr		put_msg
			move.l		#$2000,a0
			bsr		_LoadFile2
			rts

start3			
		move.w	#$F003,HEX
			lea		notfound,a0
			bsr		put_msg
			rts
			
start2
		move.w	#$F002,HEX
	lea	.failed,a0
	bsr	put_msg

	rts
.failed
	dc.b	'SD init failed',0

notfound   dc.b 'not ' 
found_MM   dc.b	'found '

mmio_name:	dc.b	'BOOT    SRE',0
			CNOP 0,2

;***************************************************
; SPI Commands
;INPUT:   D0 - sector
;         (A0 - Inputbuffer)
;RETURN:  D0=0 => OK D0|=0 => fail
;         D1 - used
;         A0 - Inputbuffer Start
;         
;***************************************************
cmd_read_sector:
			move.w	#$100,HEX
	; vor Einsprung A0 setzen
			lea			_secbuf,a0
			bsr		cmd_read
			bne		read_error3		;Error
			move.w	#$101,HEX
read1
			move.w	#20000,d1		;Timeout counter
;			move.w	#255,PER_SPI_BLOCKING(a1)		;8 Takte fÃ¼rs Lesen
read2		subq.w	#1,d1
			beq		read_error2		;Timeout
			move.w	#$102,HEX
			move.w	#255,PER_SPI_BLOCKING(a1)		;8 Takte fÃ¼rs Lesen
read_w1		move.w	PER_SPI_BLOCKING(a1),d0
			cmp.b	#$fe,d0
			bne		read2			;auf Start warten
			move.w	PER_SPI_PUMP(a1),d0 ; start the data flowing
			move.w	#127,d1
read_w2		move.l	PER_SPI_PUMP(a1),d0
;			move.w	#255,PER_SPI_BLOCKING(a1)		;8 Takte fÃ¼rs Lesen
			move.l	d0,(a0)+
			dbra	d1,read_w2
;			move.w	PER_SPI_PUMP(a1),d0	; Two dummy transfers, guaranteed to have ended when the read finishes
.wait
			move.w	PER_SPI_BLOCKING(a1),d0	; wait for transfer to finish before raising CS
			move.w	#0,PER_SPI_CS(a1)		;sd_cs high
			move.w	#$103,HEX
			lea		-$200(a0),a0
			moveq	#0,d0
			rts
read_error2	
			move.w	#$F102,HEX
			lea		msg_timeout_Error,a0
			bsr		put_msg
			moveq	#-2,d0
			rts		
read_error3
			move.w	#$F103,HEX
			lea		msg_cmdtimeout_Error,a0
			bsr		put_msg
			moveq	#-1,d0
			rts		

		

;******************************************************
; SPI Commands
; INPUT:   D0 - sector
; RETURN:  D0=$FF => Timeout D0|=$FF => Command Return
;          D1|=$00 => Timeout
;          A1 - SPIbase
;******************************************************
cmd_reset:	move.l	#$950040,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_init:	move.l	#$ff0041,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_CMD8:	move.l	#$870048,d1
			move.l	#$1AA,d0
			bra		cmd_wr
			
cmd_CMD41:	move.l	#$870069,d1
			move.l	#$40000000,d0
			bra		cmd_wr
			
cmd_CMD55:	move.l	#$ff0077,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_CMD58:	move.l	#$ff007A,d1
			moveq	#0,d0
			bra		cmd_wr
			
cmd_read:	move.l	#$ff0051,d1

cmd_wr
			lea		PERREGS,a1
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	PER_SPI_BLOCKING(a1),-2(a7)
			move.w	#1,PER_SPI_CS(a1)	;sd_cs low
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	d1,PER_SPI_BLOCKING(a1)		;cmd
			swap	d1
			tst.w	SDHCtype
			beq		cmd_wr12
			rol.l		#8,d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;31..24
			rol.l		#8,d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;23..16
			rol.l		#8,d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;15..8
			rol.l		#8,d0
			bra		cmd_wr13
			
cmd_wr12				
			add.l	d0,d0
			swap	d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;31..24
			swap	d0
			rol.w		#8,d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;23..16
			rol.w		#8,d0
			move.w	d0,PER_SPI_BLOCKING(a1)		;15..8
			moveq	#0,d0
cmd_wr13	move.w	d0,PER_SPI_BLOCKING(a1)		;7..0
			move.w	d1,PER_SPI_BLOCKING(a1)		;crc
;			;wait for answer
			move.l	#400,d1	;Timeout counter
			
cmd_wr10	subq.l		#1,d1
			beq		cmd_wr11	;Timeout
			move.w	#255,PER_SPI_BLOCKING(a1)	;8 Takte fÃ¼rs Lesen
cmd_wr9		move.w	PER_SPI_BLOCKING(a1),d0
			cmp.b	#$ff,d0
			beq		cmd_wr10
cmd_wr11
			or.b	d0,d0
			rts					;If d0=$FF => Timeout 
								
msg_start_init		dc.b	'Start Init'	,$d,$a,0
msg_init_done		dc.b	'Init done'	    ,$d,$a,0
msg_init_fail		dc.b	'Init failure'	    ,$d,$a,0
msg_reset_fail		dc.b	'Reset failure'	    ,$d,$a,0
msg_cmdtimeout_Error	dc.b	'Command Timeout_Error'	    ,$d,$a,0
msg_timeout_Error	dc.b	'Timeout_Error'	    ,$d,$a,0
msg_SDHC			dc.b	'SDHC found '	    ,$d,$a,0
			
			CNOP 0,2
asmspi_init
		move.w	#-1,SDHCtype
			lea		PERREGS,a1
			move.w	#$00,PER_SPI_CS(a1)		;all cs off
			move.w	#150,PER_TIMER_DIV7(a1) ; About 350KHz

			move.w	#200,d1
			add.l	#PER_SPI,a1
spi_init_w1
			move.w	#255,PER_SPI_BLOCKING(a1)	;8 Takte fÃ¼rs Lesen
			dbra	d1,spi_init_w1
			
			move.w	#50,d2
spi_init_w2	bsr		cmd_reset		;use SPI Mode
;			move.w	#255,PER_SPI_BLOCKING(a1)	; Wait for last clocks before deasserting CS
			move.w	PER_SPI_BLOCKING(a1),-2(a7)	; Wait for last clocks before deasserting CS
			move.w	#0,PER_SPI_CS(a1)		;sd_cs high
;			move.w	#255,PER_SPI_BLOCKING(a1)	; Wait for last clocks before deasserting CS
			cmp.b	#1,d0
			beq		spi_init_w3
			dbra	d2,spi_init_w2
			
			pea	msg_reset_fail
			bsr	put_msga7
			lea	4(a7),a7
			moveq	#-1,d0
			rts		;init fault
;reset done			
spi_init_w3	;pea	msg_start_init
			;bsr	put_msga7
spi_init_w5	move.l	#$2000,d1
spi_init_w4	move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			subq.l	#1,d1
			bne		spi_init_w4		;wait
;test SDHC
			bsr		cmd_CMD8
			cmp.b	#1,d0
			bne		noSDHC
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w		PER_SPI_BLOCKING(a1),d0
			cmpi.b		#1,d0
			bne			noSDHC
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w		PER_SPI_BLOCKING(a1),d0
			cmpi.b		#$AA,d0
			bne			noSDHC
			
			move.w	PER_SPI_BLOCKING(a1),-2(a7)
			move.w	#0,PER_SPI_CS(a1)		;sd_cs high
			pea		msg_SDHC
			bsr		put_msga7
			lea		4(a7),a7
			
			move.w	#50,d2
SDHC_1		subq.w	#1,d2
			beq		noSDHC	
			move.w	#2000,d1
SDHC_4		move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			dbra	d1,SDHC_4		;wait
			bsr		cmd_CMD55	;timeout einbauen
			cmp.b	#1,d0
			bne		SDHC_1
			bsr		cmd_CMD41
			bne		SDHC_1
			bsr		cmd_CMD58
			bne		SDHC_1
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w		PER_SPI_BLOCKING(a1),d0
			and.b		#$40,d0
			bne			SDHC_2
			move.w		#0,SDHCtype
SDHC_2
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			bra		spi_init_w6
			
noSDHC		move.w	#0,SDHCtype
			move.w	#10,d2
spi_init_w7	move.w	#2000,d1
spi_init_w8	move.w	#255,PER_SPI_BLOCKING(a1)	;8x clock
			dbra	d1,spi_init_w8		;wait
		bsr		cmd_init
			beq		spi_init_w6
;			move.w	#255,PER_SPI_BLOCKING(a1)	; Wait for last clocks before deasserting CS
			move.w	PER_SPI_BLOCKING(a1),-2(a7)	; Wait for last clocks before deasserting CS
			move.w	#0,PER_SPI_CS(a1)		;sd_cs high
;			move.w	#255,PER_SPI_BLOCKING(a1)	; Wait for last clocks before deasserting CS
			dbra	d2,spi_init_w7
			pea		msg_init_fail
			bsr		put_msga7
			lea		4(a7),a7
			moveq	#-1,d0
			rts		;init fault
			
spi_init_w6
			move.w	PER_SPI_BLOCKING(a1),-2(a7)	; Wait for last clocks before deasserting CS
			move.w	#0,PER_SPI_CS(a1)		;sd_cs high
			move.w	PER_CAP_SPISPEED(a1),PER_TIMER_DIV7(a1)
			pea		msg_init_done
			bsr		put_msga7
			lea		4(a7),a7
			move.w	#$FFFF,HEX
			moveq	#0,d0
			rts

			XDEF put_msga7

;	A0	Stringpointer 
put_msga7
			move.l	a0,-(a7)
			move.l	8(a7),a0
			bsr	put_msg
			move.l	(a7)+,a0
			rts
put_msg
			movem.l		a0/a1,-(a7)
			move.l	textptr,d1
			lea		CHARBUF,a1
put_msg1
			move.b		(a0)+,d0
			beq			put_msg_end
			move.b		d0,(a1,d1)
			addq	#1,d1
			bra			put_msg1
put_msg_end
			add.l	#76,textptr
			movem.l	(a7)+,a0/a1
			rts


_LoadFile:
			tst.w	SDHCtype
			beq		.notsdhc
			lea	.sdhcmessage,a0
			pea	_LoadFile2
			bra put_msg
.sdhcmessage
			dc.b	"SDHC flag still set",0
			cnop 0,2
.notsdhc
			lea	.sdhcmessage2,a0
			pea	_LoadFile2
			bra put_msg
.sdhcmessage2
			dc.b	"SDHC flag cleared",0
			cnop 0,2

_LoadFile2:
			bsr			cluster2lba
_LoadFile1:	
			bsr			cmd_read_sector
			bne		lferror
			
			move.l	#$1ff,d7
			lea	_secbuf,a0
			lea	CHARBUF,a1
.loop
			move.b	(a0)+,d0
			move.b	d0,(a1)+,
			movem.l	d7/a0-1,-(a7)
			bsr	HandleByte
			movem.l	(a7)+,d7/a0-1
			dbf	d7,.loop
		
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		_LoadFile1
			bsr			next_cluster
			bne			_LoadFile2
			move.l		a0,d0
			rts
lferror:	moveq		#0,d0		
			rts
			
			
int _volstart;
int FindVolume(int superfloppy)
{
	if(!sd_read_sector(buf,0))	// Read partition table
	{
		return(0);
	}

	if(buf[0x1fe]!=0x55 || buf[0x1ff]!=0xaa)	// Valid DOS signature?
	{
		return(0);
	}

	if(!superfloppy)	// Partitioned?
	{
		unsigned char *p=(int *)(buf+0x1be);
		_volstart=(p[11)<<24)|(p[10]<<16)|(p[9]<<8)|p[8]; // LBA address
		sd_read_sector(buf,_volstart);
		if(buf[0x1fe]!=0x55 || buf[0x1ff]!=0xaa)	// Valid DOS signature?
		{
			return(0);
		}
	}

}

_FindVolume:

;@checktype:
		move.w	#$0201,HEX
		moveq		#0,d0	;partitionstable
		move.l		d0,_volstart
		move.w	#$0211,HEX
		bsr			cmd_read_sector	; sd_read_sector(buf,0); // Read partition table
		bne 		_error

		move.w	#$0202,HEX

		cmpi.b		#$55,$1fe(a0)
		bne		_error
		cmpi.b		#$AA,$1ff(a0)
		bne		_error
			
		move.w		_drive,d0
		and.w		#$70,d0
		cmp.w		#$40,d0
		bcc		_testfat	;Superfloppy
	
		lea			$1be(a0),a1		; pointer to partition table
		adda.w		d0,a1
		
;_foundfat:
;read_vol_sector	
		move.w	#$0203,HEX
		move.l		8(a1),d0	;LBA
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_volstart
		bsr			cmd_read_sector	; read sector 
		bne		_error
		cmpi.b		#$55,$1fe(a0)
		bne		_error
		cmpi.b		#$AA,$1ff(a0)
		beq		_testfat
_error:
		move.w	#$f201,HEX
		moveq		#-1,d0
		rts


_testfat:
		move.w	#$0204,HEX
		cmpi.l		#$46415431,$36(a0)	;"FAT1"
		bne		_testfat_2
		move.b		#12,_fstype
		cmpi.l		#$32202020,$3A(a0)	;"2   "
		beq		_testfat_ex
		move.b		#16,_fstype
		cmpi.l		#$36202020,$3A(a0)	;"6   "
		beq		_testfat_ex
_testfat_2:
		move.b		#$00,_fstype
		cmpi.l		#$46415433,$52(a0)	;"FAT3"
		bne		_error
		cmpi.l		#$32202020,$56(a0)	;"2   "
		bne		_error
		move.b		#32,_fstype
_testfat_ex:
		move.l		$0a(a0),d0	; make sure sector size is 512
		and.l		#$FFFF00,d0
		cmpi.l		#$00200,d0
		bne		_error
		
			move.l		_volstart,d1
			move.w		$e(a0),d0		;reserved Sectors
			ror.w		#8,d0
			add.l		d0,d1
			move.l		d1,_fatstart			;Fat Table
		cmpi.b		#32,_fstype
		bne		 _fat16
		
;@fat32:
		move.l		$2c(a0),d0	; cluster of root directory
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l		d0,_rootcluster
; find start of clusters
		move.l		$24(a0),d0	;FAT Size
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
_add_start32		
		add.l		d0,d1
		subq.b		#1,$10(a0)
		bne		_add_start32
		bra		subcluster
		
_fat16
			moveq		#0,d0
			move.l		d0,_rootcluster
			move.w		$16(a0),d0				;Sectors per Fat
			ror.w		#8,d0
root_sect	add.l		d0,d1
			subi.b		#1,$10(a0);d2			;number of FAT Copies
			bne			root_sect
			move.l		d1,_rootsector
	move.l	d1,d0		
			move.b		$12(a0),d0
			lsl.w		#8,d0
			move.b		$11(a0),d0
			move.w		d0,_rootdirentrys
			lsr.w		#4,d0
			add.l		d0,d1
subcluster:	
			moveq		#0,d0
			move.b		$d(a0),d0
			move.w		d0,_clustersize
			sub.l		d0,d1					; subtract two clusters to compensate
			sub.l		d0,d1					; for reserved values 0 and 1
			move.l		d1,_datastart			;start of clusters
			
fat_ex:
			move.w	#$0205,HEX
			moveq		#0,d0
			rts


fat_cdroot:
			move.l		_rootcluster,d0	; cluster of basic directory
			move.l		d0,_cluster	
			bne		 cdfat_32
		
			clr.l		_cluster
			move.w		_rootdirentrys,d0
			lsr.w			#4,d0
			move.w		d0,_sectorcnt
			move.l		_rootsector,d0
			move.l		d0,_sectorlba		;lba
			rts

cluster2lba:		
			move.l		_cluster,d0
cdfat_32:	
			move.w		_clustersize,d1
			move.w		d1,_sectorcnt
_fat32_1:		
			lsr.w			#1,d1
			bcs		_fat32_2
			lsl.l		#1,d0
			bra		_fat32_1
_fat32_2:
			add.l		_datastart,d0
			move.l		d0,_sectorlba	
			rts


		
fat_findfile
		movem.l		d2/a2,-(a7)
		move.l		a1,a2
fat_findfile_m4

		bsr			cmd_read_sector	; read sector 
		bne		fat_findfile_m8
			moveq		#15,d2
fat_findfile_m3
			tst.b	(a0)		;end
			beq		fat_findfile_m8
			moveq		#10,d0
fat_findfile_m2			
			move.b		(a2,d0),d1
			cmp.b		(a0,d0),d1
			beq			fat_findfile_m1
			add.b		#$20,d1		;
			cmp.b		(a0,d0),d1
			bne			fat_findfile_m9
fat_findfile_m1	
			dbra		d0,fat_findfile_m2
;file found	
			moveq	#0,d0
			move.b	11(a0),d0
			move.w	d0,_attrib
			cmpi.b		#32,_fstype
			bne		 sfs_m3
			move.w	20(a0),d0		;high cluster
			ror.w	#8,d0
			swap	d0
sfs_m3:		move.w	26(a0),d0		;high cluster
			ror.w	#8,d0
			move.l	d0,_cluster
		movem.l		(a7)+,d2/a2
			moveq	#-1,d0
			rts


fat_findfile_m9
			adda		#$0020,a0
			dbra		d2,fat_findfile_m3		
			
			move.l 		_sectorlba,d0	
			addq.l		#1,d0		 
			move.l 		d0,_sectorlba			 

			subi.w		#1,_sectorcnt
			bne 		fat_findfile_m4
			bsr			next_cluster
			beq		fat_findfile_m8
			bsr			cluster2lba		
			bra			fat_findfile_m4
fat_findfile_m8			
		movem.l		(a7)+,d2/a2
			moveq		#0,d0			;file not found
			rts	
			
next_cluster:
		cmpi.b		#32,_fstype
		beq		 fnc_m32
		cmpi.b		#12,_fstype
		beq		 fnc_m12

;FAT16
		move.l    	_cluster,D0
		lsr.l     	#8,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne		fnc_end
		move.b    	_cluster+3,D0
		add.w		d0,d0
		move.w		(a0,d0),d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$ffff000f,d0
		cmp.w		#$ffff,d0
		rts
fnc_m32:	
;FAT32
		move.l    	_cluster,D0
		lsr.l     	#7,D0
		add.l		_fatstart,D0
		bsr			cmd_read_sector	; read sector 
		bne		fnc_end
		move.b    	_cluster+3,D0
		and.w		#$7f,d0
		add.w		d0,d0
		add.w		d0,d0
		move.l		(a0,d0),d0
		ror.w		#8,d0
		swap		d0
		ror.w		#8,d0
		move.l    	D0,_cluster
		or.l		#$f0000007,d0
		cmp.l		#$ffffffff,d0
		rts
fnc_end:
		moveq		#0,d0
		rts
		

fnc_m12:	
;FAT12
		move.l		d2,-(a7)
		move.l    	_cluster,D0	;cluster
		move.l		d0,d1
		add.l		d0,d0
		add.l		d1,d0		;*3
		move.l		d0,d1		;nibbles
		lsr.l     	#8,D0		
		lsr.l     	#2,D0		;cluster*1.5/256
		add.l		_fatstart,D0
		move.l		d0,d2
		bsr			cmd_read_sector	; read sector 
		bne		fnc_end2
		move.l		d1,d0
		lsr.l		#1,d0
		and.w		#$1ff,d0
		cmp			#$1ff,d0
		bne			fnc_m14
		
		move.b		(a0,d0),d0
		exg.l		d0,d2
		addq.l		#1,d0
		bsr			cmd_read_sector	; read sector 
		bne		fnc_end2
		lsl			#8,d2
		move.b		(a0),d2
		bra		fnc_m15
		
fnc_m14:		
		move.b		(a0,d0),d2
		lsl			#8,d2
		move.b		1(a0,d0.w),d2
fnc_m15:
		rol.w		#8,d2
		and.w			#1,d1
		beq		fnc_m13
		lsr			#4,d2
fnc_m13:
		and.l		#$FFF,d2
		move.l    	D2,_cluster
		or.l		#$fffff00f,d2
		move.l		d2,d0
		move.l		(a7)+,d2
		cmp.w		#$ffff,d0
		rts

fnc_end2:
		move.l		(a7)+,d2
		moveq		#0,d0
		rts

