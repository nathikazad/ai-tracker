#ifndef FLETCHER_CHECKSUM_H
#define FLETCHER_CHECKSUM_H

#include <stdint.h>
#include <stddef.h>

uint32_t fletcher32(uint8_t const *data, size_t len);

#endif // CHECKSUM_H