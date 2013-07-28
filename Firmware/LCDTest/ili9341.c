#include "ili9341.h"

int init_display()
{
	sel_lcd(1);

    write_cmd(LCD_CMD_DISPLAY_OFF);
    mdelay(20);

    //send init commands
    write_cmd(LCD_CMD_POWER_CTRLB);
    write_data(0x00);
    write_data(0x83); //83 81 AA
    write_data(0x30);

    write_cmd(LCD_CMD_POWERON_SEQ_CTRL);
    write_data(0x64); //64 67
    write_data(0x03);
    write_data(0x12);
    write_data(0x81);

    write_cmd(LCD_CMD_DRV_TIMING_CTRLA);
    write_data(0x85);
    write_data(0x01);
    write_data(0x79); //79 78

    write_cmd(LCD_CMD_POWER_CTRLA);
    write_data(0x39);
    write_data(0X2C);
    write_data(0x00);
    write_data(0x34);
    write_data(0x02);

    write_cmd(LCD_CMD_PUMP_RATIO_CTRL);
    write_data(0x20);

    write_cmd(LCD_CMD_DRV_TIMING_CTRLB);
    write_data(0x00);
    write_data(0x00);

    write_cmd(LCD_CMD_POWER_CTRL1);
    write_data(0x26); //26 25

    write_cmd(LCD_CMD_POWER_CTRL2);
    write_data(0x11);

    write_cmd(LCD_CMD_VCOM_CTRL1);
    write_data(0x35);
    write_data(0x3E);

    write_cmd(LCD_CMD_VCOM_CTRL2);
    write_data(0xBE); //BE 94

    write_cmd(LCD_CMD_FRAME_CTRL);
    write_data(0x00);
    write_data(0x1B); //1B 70

    write_cmd(LCD_CMD_DISPLAY_CTRL);
    write_data(0x0A);
    write_data(0x82);
    write_data(0x27);
    write_data(0x00);

    write_cmd(LCD_CMD_ENTRY_MODE);
    write_data(0x07);

    write_cmd(LCD_CMD_PIXEL_FORMAT);
    write_data(0x55); //16bit

    // orientation
    write_cmd(LCD_CMD_MEMACCESS_CTRL);
    write_data((1<<MEM_X));

    write_cmd(LCD_CMD_SLEEPOUT);
    mdelay(120);

    write_cmd(LCD_CMD_DISPLAY_ON);
    mdelay(20);
}
#if 0

void ili9341fb_set_addr_win(struct fbtft_par *int xs, int ys, int xe, int ye)
{
    uint8_t xsl, xsh, xel, xeh, ysl, ysh, yel, yeh;
    u16 *p = (u16 *)par->buf;
    int i = 0;

    fbtft_dev_dbg(DEBUG_SET_ADDR_WIN, par->info->device, "%s(xs=%d, ys=%d, xe=%d, ye=%d)\n", __func__, xs, ys, xe, ye);

    xsl = (uint8_t)(xs & 0xff);
    xsh = (uint8_t)((xs >> 8) & 0xff);
    xel = (uint8_t)(xe & 0xff);
    xeh = (uint8_t)((xe >> 8) & 0xff);

    ysl = (uint8_t)(ys & 0xff);
    ysh = (uint8_t)((ys >> 8) & 0xff);
    yel = (uint8_t)(ye & 0xff);
    yeh = (uint8_t)((ye >> 8) & 0xff);

    write_cmd(FBTFT_CASET);
    write_data(xsh);
    write_data(xsl);
    write_data(xeh);
    write_data(xel);

    write_cmd(FBTFT_RASET);
    write_data(ysh);
    write_data(ysl);
    write_data(yeh);
    write_data(yel);

    write_cmd(FBTFT_RAMWR);

    write_flush(par);
}

static int ili9341fb_write_emulate_9bit(struct fbtft_par *void *buf, size_t len)
{
    u16 *src = buf;
    u8 *dst = par->extra;
    size_t size = len / 2;
    size_t added = 0;
    int bits, i, j;
    u64 val, dc, tmp;

    for (i=0;i<size;i+=8) {
        tmp = 0;
        bits = 63;
        for (j=0;j<7;j++) {
            dc = (*src & 0x0100) ? 1 : 0;
            val = *src & 0x00FF;
            tmp |= dc << bits;
            bits -= 8;
            tmp |= val << bits--;
            src++;
        }
        tmp |= ((*src & 0x0100) ? 1 : 0);
        *(u64 *)dst = cpu_to_be64(tmp);
        dst += 8;
        *dst++ = (u8 )(*src++ & 0x00FF);
        added++;
    }

    return spi_write(par->spi, par->extra, size + added);
}

static unsigned long ili9341fb_request_gpios_match(struct fbtft_par *const struct fbtft_gpio *gpio)
{
    if (strcasecmp(gpio->name, "led") == 0) {
        par->gpio.led[0] = gpio->gpio;
        return GPIOF_OUT_INIT_LOW;
    }

    return FBTFT_GPIO_NO_MATCH;
}

struct fbtft_display ili9341fb_display = {
    .width = WIDTH,
    .height = HEIGHT,
    .txbuflen = TXBUFLEN,
};

static int ili9341fb_probe(struct spi_device *spi)
{
    struct fb_info *info;
    struct fbtft_par *par;
    int ret;

    fbtft_dev_dbg(DEBUG_DRIVER_INIT_FUNCTIONS, &spi->dev, "%s()\n", __func__);

    info = fbtft_framebuffer_alloc(&ili9341fb_display, &spi->dev);
    if (!info)
        return -ENOMEM;

    par = info->par;
    par->spi = spi;
    fbtft_debug_init(par);
    par->fbtftops.init_display = ili9341fb_init_display;
    par->fbtftops.register_backlight = fbtft_register_backlight;
    par->fbtftops.request_gpios_match = ili9341fb_request_gpios_match;
    par->fbtftops.write_data_command = fbtft_write_data_command8_bus9;
    par->fbtftops.write_vmem = fbtft_write_vmem16_bus9;
    par->fbtftops.set_addr_win = ili9341fb_set_addr_win;

    spi->bits_per_word=9;
    ret = spi->master->setup(spi);
    if (ret) {
        dev_warn(&spi->dev, "9-bit SPI not available, emulating using 8-bit.\n");
        spi->bits_per_word=8;
        ret = spi->master->setup(spi);
        if (ret)
            goto fbreg_fail;

        /* allocate buffer with room for dc bits */
        par->extra = vzalloc(par->txbuf.len + (par->txbuf.len / 8));
        if (!par->extra) {
            ret = -ENOMEM;
            goto fbreg_fail;
        }

        par->fbtftops.write = ili9341fb_write_emulate_9bit;
    }

    ret = fbtft_register_framebuffer(info);
    if (ret < 0)
        goto fbreg_fail;

    return 0;

fbreg_fail:
    if (par->extra)
        vfree(par->extra);
    fbtft_framebuffer_release(info);

    return ret;
}

static int ili9341fb_remove(struct spi_device *spi)
{
    struct fb_info *info = spi_get_drvdata(spi);
    struct fbtft_par *par;

    fbtft_dev_dbg(DEBUG_DRIVER_INIT_FUNCTIONS, &spi->dev, "%s()\n", __func__);

    if (info) {
        fbtft_unregister_framebuffer(info);
        par = info->par;
        if (par->extra)
            vfree(par->extra);
        fbtft_framebuffer_release(info);
    }

    return 0;
}

static struct spi_driver ili9341fb_driver = {
    .driver = {
        .name   = DRVNAME,
        .owner  = THIS_MODULE,
    },
    .probe  = ili9341fb_probe,
    .remove = ili9341fb_remove,
};

static int __init ili9341fb_init(void)
{
    fbtft_pr_debug("\n\n"DRVNAME": %s()\n", __func__);
    return spi_register_driver(&ili9341fb_driver);
}

static void __exit ili9341fb_exit(void)
{
    fbtft_pr_debug(DRVNAME": %s()\n", __func__);
    spi_unregister_driver(&ili9341fb_driver);
}
#endif

