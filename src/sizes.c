#include <stddef.h>
#include <stdio.h>
#include <limits.h>
#include <float.h>
#include <stdint.h>
#include <inttypes.h>

#if defined(__SIZEOF_INT128__)   // GCC/Clang on 64-bit platforms
typedef __int128            int128_t;
typedef unsigned __int128   uint128_t;

// Convert unsigned __int128 to string
static void u128_to_str(uint128_t v, char *buf, size_t n) {
    char tmp[64];
    int pos = 0;
    if (v == 0) {
        snprintf(buf, n, "0");
        return;
    }
    while (v > 0) {
        tmp[pos++] = '0' + (v % 10);
        v /= 10;
    }
    int i = 0;
    for (; i < pos && i + 1 < (int)n; i++)
        buf[i] = tmp[pos - i - 1];
    buf[i] = '\0';
}

// Convert __int128 (signed)
static void s128_to_str(int128_t v, char *buf, size_t n) {
    if (v < 0) {
        if (n > 1) {
            buf[0] = '-';
            u128_to_str((uint128_t)(-v), buf + 1, n - 1);
        }
    } else {
        u128_to_str((uint128_t)v, buf, n);
    }
}
#endif

int main(void) {
    printf("=============================================================\n");
    printf(" TYPE                     SIZE   MIN                           MAX\n");
    printf("=============================================================\n");

    // Primitive integer types
    printf(" char                     %4zu   %28d   %28d\n",
           sizeof(char), CHAR_MIN, CHAR_MAX);

    printf(" signed char              %4zu   %28d   %28d\n",
           sizeof(signed char), SCHAR_MIN, SCHAR_MAX);

    printf(" unsigned char            %4zu   %28u   %28u\n",
           sizeof(unsigned char), 0u, UCHAR_MAX);

    printf(" short                    %4zu   %28d   %28d\n",
           sizeof(short), SHRT_MIN, SHRT_MAX);

    printf(" unsigned short           %4zu   %28u   %28u\n",
           sizeof(unsigned short), 0u, USHRT_MAX);

    printf(" int                      %4zu   %28d   %28d\n",
           sizeof(int), INT_MIN, INT_MAX);

    printf(" unsigned int             %4zu   %28u   %28u\n",
           sizeof(unsigned int), 0u, UINT_MAX);

    printf(" long                     %4zu   %28ld   %28ld\n",
           sizeof(long), LONG_MIN, LONG_MAX);

    printf(" unsigned long            %4zu   %28lu   %28lu\n",
           sizeof(unsigned long), 0ul, ULONG_MAX);

    printf(" long long                %4zu   %28lld   %28lld\n",
           sizeof(long long), LLONG_MIN, LLONG_MAX);

    printf(" unsigned long long       %4zu   %28llu   %28llu\n",
           sizeof(unsigned long long), 0ull, ULLONG_MAX);

#if defined(__SIZEOF_INT128__)
    {
        char minbuf[64], maxbuf[64];
        // signed 128
        s128_to_str(((int128_t)1 << 127), minbuf, sizeof(minbuf)); // -(2^127)
        uint128_t umax = (((uint128_t)1 << 128) - 1);
        u128_to_str(umax, maxbuf, sizeof(maxbuf));

        printf(" __int128                 %4zu   %28s   %28s\n",
               sizeof(int128_t), minbuf, "(2^127 - 1, printing separately)");

        s128_to_str((int128_t)(((uint128_t)1 << 127) - 1), minbuf, sizeof(minbuf));
        printf(" (signed __int128 max)         %28s\n", minbuf);

        u128_to_str(0, minbuf, sizeof(minbuf));
        printf(" unsigned __int128        %4zu   %28s   %28s\n",
               sizeof(uint128_t), "0", maxbuf);
    }
#endif

    printf("=============================================================\n");
    printf(" FIXED-WIDTH TYPES\n");
    printf("=============================================================\n");

    printf(" int8_t                   %4zu   %28" PRId8 "   %28" PRId8 "\n",
           sizeof(int8_t), INT8_MIN, INT8_MAX);

    printf(" uint8_t                  %4zu   %28s   %28" PRIu8 "\n",
           sizeof(uint8_t), "0", UINT8_MAX);

    printf(" int16_t                  %4zu   %28" PRId16 "   %28" PRId16 "\n",
           sizeof(int16_t), INT16_MIN, INT16_MAX);

    printf(" uint16_t                 %4zu   %28s   %28" PRIu16 "\n",
           sizeof(uint16_t), "0", UINT16_MAX);

    printf(" int32_t                  %4zu   %28" PRId32 "   %28" PRId32 "\n",
           sizeof(int32_t), INT32_MIN, INT32_MAX);

    printf(" uint32_t                 %4zu   %28s   %28" PRIu32 "\n",
           sizeof(uint32_t), "0", UINT32_MAX);

    printf(" int64_t                  %4zu   %28" PRId64 "   %28" PRId64 "\n",
           sizeof(int64_t), INT64_MIN, INT64_MAX);

    printf(" uint64_t                 %4zu   %28s   %28" PRIu64 "\n",
           sizeof(uint64_t), "0", UINT64_MAX);

    printf("=============================================================\n");
    printf(" POINTER-SIZED TYPES\n");
    printf("=============================================================\n");

    printf(" size_t                   %4zu   %28s   %28zu\n",
           sizeof(size_t), "0", (size_t)-1);

    printf(" ptrdiff_t                %4zu   %28td   %28td\n",
           sizeof(ptrdiff_t), PTRDIFF_MIN, PTRDIFF_MAX);

    printf(" intptr_t                 %4zu   %28" PRIdPTR "   %28" PRIdPTR "\n",
           sizeof(intptr_t), INTPTR_MIN, INTPTR_MAX);

    printf(" uintptr_t                %4zu   %28s   %28" PRIuPTR "\n",
           sizeof(uintptr_t), "0", UINTPTR_MAX);

    return 0;
}
