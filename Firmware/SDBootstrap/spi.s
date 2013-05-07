	.file	"spi.c"
	.globl	SDHCtype
.data
	.balign 4;
	.type	SDHCtype, @object
	.size	SDHCtype, 2
SDHCtype:
	.short	1
.text
	.globl	cmd_write
	.type	cmd_write, @function
cmd_write:
	im -3
	pushspadd
	popsp
	loadsp 20
	loadsp 28
	loadsp 4
	im 255
	and
	im -52
	store
	im SDHCtype
	loadh
	loadsp 0
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 16
	storesp 24
	storesp 12
	storesp 12
	loadsp 0
	impcrel .L2
	neqbranch
	loadsp 4
	im 9
	ashiftleft
	storesp 8
.L2:
	loadsp 4
	im 24
	lshiftright
	im -52
	store
	loadsp 4
	im 16
	lshiftright
	loadsp 0
	im 255
	and
	im -52
	store
	storesp 4
	loadsp 4
	im 8
	lshiftright
	loadsp 0
	im 255
	and
	im -52
	store
	storesp 4
	loadsp 4
	im 255
	and
	im -52
	store
	loadsp 8
	im 16
	lshiftright
	loadsp 0
	im 255
	and
	im -52
	store
	storesp 4
	im -52
	load
	loadsp 0
	im 0xff
	and
	storesp 4
	storesp 4
	im 39999
	storesp 8
.L7:
	loadsp 0
	im 255
	eq
	not
	im 1
	and
	impcrel .L4
	neqbranch
	im 255
	nop
	im -52
	store
	im -52
	load
	loadsp 0
	im 0xff
	and
	im -1
	addsp 16
	storesp 16
	storesp 4
	storesp 4
	loadsp 4
	impcrel .L7
	neqbranch
.L4:
	loadsp 0
	im _memreg+0
	store
	im 5
	pushspadd
	popsp
	poppc
	.size	cmd_write, .-cmd_write
	.globl	spi_spin
	.type	spi_spin, @function
spi_spin:
	im 0
	pushspadd
	popsp
	im 199
	storesp 4
.L12:
	im 255
	nop
	im -52
	store
	im -1
	addsp 4
	storesp 4
	loadsp 0
	im 0
	lessthanorequal
	impcrel .L12
	neqbranch
	im 2
	pushspadd
	popsp
	poppc
	.size	spi_spin, .-spi_spin
	.globl	wait_initV2
	.type	wait_initV2, @function
wait_initV2:
	im -4
	pushspadd
	popsp
	impcrel (spi_spin)
	callpcrel
	im 19999
	storesp 20
.L20:
	im 0
	storesp 8
	im 16711799
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	loadsp 0
	storesp 24
	storesp 4
	storesp 12
	loadsp 8
	im 1
	eq
	not
	im 1
	and
	impcrel .L16
	neqbranch
	im 255
	nop
	im -52
	store
	im 1073741824
	storesp 8
	im 8847465
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L19
	neqbranch
	im 255
	nop
	im -52
	store
	loadsp 12
	storesp 12
	impcrel .L15
	poppcrel
.L19:
	impcrel (spi_spin)
	callpcrel
.L16:
	im -1
	addsp 20
	storesp 20
	loadsp 16
	impcrel .L20
	neqbranch
	loadsp 16
	storesp 12
.L15:
	loadsp 8
	im _memreg+0
	store
	im 6
	pushspadd
	popsp
	poppc
	.size	wait_initV2, .-wait_initV2
	.globl	wait_init
	.type	wait_init, @function
wait_init:
	im -3
	pushspadd
	popsp
	im 255
	nop
	im -52
	store
	im 19
	storesp 16
.L27:
	im 0
	storesp 8
	im 16711745
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L26
	neqbranch
	im 255
	nop
	im -52
	store
	im 1
	storesp 12
	impcrel .L23
	poppcrel
.L26:
	impcrel (spi_spin)
	callpcrel
	im -1
	addsp 16
	storesp 16
	loadsp 12
	impcrel .L27
	neqbranch
	loadsp 12
	storesp 12
.L23:
	loadsp 8
	im _memreg+0
	store
	im 5
	pushspadd
	popsp
	poppc
	.size	wait_init, .-wait_init
	.globl	is_sdhc
	.type	is_sdhc, @function
is_sdhc:
	im -3
	pushspadd
	popsp
	impcrel (spi_spin)
	callpcrel
	im 426
	storesp 8
	im 8847432
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	im 1
	eq
	not
	im 1
	and
	impcrel .L47
	neqbranch
	im 255
	nop
	im -52
	store
	im -52
	load
	storesp 12
	im 255
	nop
	im -52
	store
	im -52
	load
	storesp 12
	im 255
	nop
	im -52
	store
	im -52
	load
	loadsp 0
	im 255
	and
	storesp 4
	storesp 12
	loadsp 8
	im 1
	eq
	not
	im 1
	and
	impcrel .L47
	neqbranch
	im 255
	nop
	im -52
	store
	im -52
	load
	loadsp 0
	im 255
	and
	storesp 4
	storesp 12
	loadsp 8
	im 170
	eq
	impcrel .L33
	neqbranch
.L47:
	impcrel (wait_init)
	callpcrel
	impcrel .L45
	poppcrel
.L44:
	im 1
	storesp 16
	impcrel .L30
	poppcrel
.L45:
	im 0
	storesp 16
	impcrel .L30
	poppcrel
.L33:
	im 255
	nop
	im -52
	store
	im 49
	storesp 16
.L41:
	impcrel (wait_initV2)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	im 0
	eq
	impcrel .L36
	neqbranch
	im 0
	storesp 8
	im 16711802
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L36
	neqbranch
	im 255
	nop
	im -52
	store
	im -52
	load
	storesp 12
	im 255
	nop
	im -52
	store
	im 255
	nop
	im -52
	store
	im 255
	nop
	im -52
	store
	im 255
	nop
	im -52
	store
	loadsp 8
	im 6
	lshiftright
	loadsp 0
	im 1
	and
	loadsp 0
	storesp 24
	storesp 4
	storesp 12
	loadsp 8
	im 0
	eq
	impcrel .L30
	neqbranch
	impcrel .L44
	poppcrel
.L36:
	loadsp 12
	im 2
	eq
	impcrel .L45
	neqbranch
	im -1
	addsp 16
	storesp 16
	loadsp 12
	impcrel .L41
	neqbranch
.L30:
	loadsp 12
	im _memreg+0
	store
	im 5
	pushspadd
	popsp
	poppc
	.size	is_sdhc, .-is_sdhc
	.globl	spi_init
	.type	spi_init, @function
spi_init:
	im -3
	pushspadd
	popsp
	im 1
	nop
	im SDHCtype
	storeh
	im 150
	nop
	im -68
	store
.L49:
	im -56
	load
	loadsp 0
	im 15
	lshiftright
	loadsp 0
	im 1
	and
	storesp 4
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L49
	neqbranch
	loadsp 8
	im -56
	store
	impcrel (spi_spin)
	callpcrel
.L51:
	im -56
	load
	loadsp 0
	im 15
	lshiftright
	loadsp 0
	im 1
	and
	storesp 4
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L51
	neqbranch
	im 1
	nop
	im -56
	store
	im 7
	storesp 16
.L57:
	im 0
	storesp 8
	im 9764928
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	im 1
	eq
	impcrel .L63
	neqbranch
	loadsp 12
	im 2
	eq
	not
	im 1
	and
	impcrel .L53
	neqbranch
	im 0
	storesp 12
	impcrel .L48
	poppcrel
.L53:
	im -1
	addsp 16
	storesp 16
	loadsp 12
	impcrel .L57
	neqbranch
.L63:
	impcrel (is_sdhc)
	callpcrel
	im _memreg+0
	load
	im SDHCtype
	storeh
	im 1
	storesp 8
	im 16711760
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im 255
	nop
	im -52
	store
.L59:
	im -56
	load
	loadsp 0
	im 15
	lshiftright
	loadsp 0
	im 1
	and
	storesp 4
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L59
	neqbranch
	loadsp 8
	im -56
	store
	im -40
	load
	im -68
	store
	im 1
	storesp 12
.L48:
	loadsp 8
	im _memreg+0
	store
	im 5
	pushspadd
	popsp
	poppc
	.size	spi_init, .-spi_init
	.globl	sd_write_sector
	.type	sd_write_sector, @function
sd_write_sector:
	im 0
	nop
	im _memreg+0
	store
	poppc
	.size	sd_write_sector, .-sd_write_sector
	.globl	sd_read_sector
	.type	sd_read_sector, @function
sd_read_sector:
	im -5
	pushspadd
	popsp
	loadsp 32
	storesp 20
	im 0
	storesp 24
.L66:
	im -56
	load
	loadsp 0
	im 15
	lshiftright
	loadsp 0
	im 1
	and
	storesp 4
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L66
	neqbranch
	im 1
	nop
	im -56
	store
	im 255
	nop
	im -52
	store
	loadsp 28
	storesp 8
	im 16711761
	storesp 4
	impcrel (cmd_write)
	callpcrel
	im _memreg+0
	load
	im 16
	ashiftleft
	loadsp 0
	im 16
	ashiftright
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L65
	neqbranch
	im 1499999
	storesp 16
.L76:
	im 255
	nop
	im -52
	store
	im -52
	load
	loadsp 0
	im 0xff
	and
	storesp 4
	storesp 12
	loadsp 8
	im 254
	eq
	not
	im 1
	and
	impcrel .L69
	neqbranch
	im -48
	load
	storesp 12
	im 255
	storesp 12
.L75:
	im -48
	load
	loadsp 20
	loadsp 0
	im 4
	add
	storesp 28
	store
	im -1
	addsp 12
	storesp 12
	loadsp 8
	im 0
	lessthanorequal
	impcrel .L75
	neqbranch
	im 1
	storesp 24
	impcrel .L83
	poppcrel
.L69:
	im -1
	addsp 16
	storesp 16
	loadsp 12
	impcrel .L76
	neqbranch
.L83:
	im 255
	nop
	im -52
	store
.L77:
	im -56
	load
	loadsp 0
	im 15
	lshiftright
	loadsp 0
	im 1
	and
	storesp 4
	storesp 4
	storesp 12
	loadsp 8
	impcrel .L77
	neqbranch
	loadsp 8
	im -56
	store
.L65:
	loadsp 20
	im _memreg+0
	store
	im 7
	pushspadd
	popsp
	poppc
	.size	sd_read_sector, .-sd_read_sector
	.comm	SPI_R1,6,4
	.ident	"GCC: (GNU) 3.4.2"
