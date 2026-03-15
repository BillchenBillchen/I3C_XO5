#ifndef CCC_H
#define CCC_H

#include <stdint.h>
#include <stdbool.h>


/* Commands valid in both broadcast and unicast modes */
#define I3C_CCC_ENEC		0x0
#define I3C_CCC_DISEC		0x1
#define I3C_CCC_RSTDAA		0x6
#define I3C_CCC_SETMWL		0x9
#define I3C_CCC_SETMRL		0xa
#define I3C_CCC_SETXTIME	0x28

/* Broadcast-only commands */
#define I3C_CCC_ENTDAA			0x7
/* Unicast-only commands */
#define I3C_CCC_SETDASA			0x87
#define I3C_CCC_SETNEWDA		0x88
#define I3C_CCC_SETMWL_D		0x89
#define I3C_CCC_SETMRL_D		0x8a
#define I3C_CCC_GETMWL			0x8b
#define I3C_CCC_GETMRL			0x8c
#define I3C_CCC_GETPID			0x8d
#define I3C_CCC_GETBCR			0x8e
#define I3C_CCC_GETDCR			0x8f
#define I3C_CCC_GETSTATUS		0x90
#define I3C_CCC_GETHDRCAP		0x95
#define I3C_CCC_SETXTIME_D		0x98
#define I3C_CCC_GETXTIME		0x99



/**
 * struct i3c_ccc_cmd - CCC command
 *
 * @rnw: true if the CCC should retrieve data from the device. Only valid for
 *	 unicast commands
 * @id: CCC command id
 * @ndests: number of destinations. Should always be one for broadcast commands
 * @addr: can be an I3C device address or the broadcast address if this is a
 *	  broadcast CCC
 * @len: payload length
 * @data: payload data.
 */
struct i3c_ccc_cmd {
	uint8_t rnw;
	uint8_t id;
	uint32_t ndests;
	uint8_t addr;
	uint8_t len;
	uint8_t *data;
};


#endif
