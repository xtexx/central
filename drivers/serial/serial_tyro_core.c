// SPDX-License-Identifier: GPL-2.0+

#include <dm.h>
#include <serial.h>

static int tyro_core_serial_setbrg(struct udevice *dev, int baudrate)
{
	return 0;
}

static int tyro_core_serial_getc(struct udevice *dev)
{
	return -EAGAIN;
}

static int tyro_core_serial_pending(struct udevice *dev, bool input)
{
	return 0;
}

static int tyro_core_serial_putc(struct udevice *dev, const char ch)
{
	*(volatile unsigned char *)CONFIG_VAL(DEBUG_UART_BASE) = (unsigned char)ch;
	return 0;
}

static const struct udevice_id tyro_core_serial_ids[] = {
	{ .compatible = "tyro-core-serial" },
	{}
};

const struct dm_serial_ops tyro_core_serial_ops = {
	.putc = tyro_core_serial_putc,
	.pending = tyro_core_serial_pending,
	.getc = tyro_core_serial_getc,
	.setbrg = tyro_core_serial_setbrg,
};

U_BOOT_DRIVER(serial_tyro_core) = {
	.name = "serial_tyro_core",
	.id = UCLASS_SERIAL,
	.of_match = tyro_core_serial_ids,
	.ops = &tyro_core_serial_ops,
};

#ifdef CONFIG_DEBUG_UART_TYRO_CORE

#include <debug_uart.h>

static inline void _debug_uart_init(void)
{
}

static inline void _debug_uart_putc(int ch)
{
	void __iomem *base = (void __iomem *)CONFIG_VAL(DEBUG_UART_BASE);

	__raw_writeb(ch, base);
}

DEBUG_UART_FUNCS
#endif
