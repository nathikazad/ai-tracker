#include "fletcher_checksum.h"

uint32_t fletcher32(uint8_t const *data, size_t len) {
    uint32_t sum1 = 0xffff, sum2 = 0xffff;
    size_t tlen = len;
    
    // Process pairs of bytes as 16-bit words
    while (len > 1) {
        size_t blocks = (len > 718) ? 718 : len;
        len -= blocks;
        blocks /= 2;  // Process two bytes at a time
        
        while (blocks) {
            // Combine two bytes into a 16-bit word
            uint16_t word = (data[0] << 8) | data[1];
            sum1 += word;
            sum2 += sum1;
            data += 2;
            blocks--;
        }
        
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    // Handle last byte if length is odd
    if (len) {
        sum1 += (*data << 8);
        sum2 += sum1;
        sum1 = (sum1 & 0xffff) + (sum1 >> 16);
        sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    }
    
    // Second reduction step to reduce sums to 16 bits
    sum1 = (sum1 & 0xffff) + (sum1 >> 16);
    sum2 = (sum2 & 0xffff) + (sum2 >> 16);
    
    return (sum2 << 16) | sum1;
}