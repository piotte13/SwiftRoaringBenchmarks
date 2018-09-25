#ifndef HEADER_FILE
#define HEADER_FILE
#include <stdio.h>
#include "roaring.h"

static roaring_bitmap_t **create_all_bitmaps(size_t *howmany,
        uint32_t **numbers, size_t count, bool runoptimize, bool copyonwrite, bool verbose);

bool roaring_iterator_increment(uint32_t value, void *param);

void testInit(size_t *_howmany, uint32_t **_numbers, size_t _count, bool _runoptimize, bool _copyonwrite, bool _verbose);

void testDeinit(void);

uint64_t create(void);

uint64_t successiveAnd(void);

uint64_t successiveOr(void);

uint64_t totalOr(void);

uint64_t totalOrHeap(void);

uint64_t quartCount(void);

uint64_t successiveAndNot(void);

uint64_t successiveXor(void);

uint64_t iterate(void);

uint64_t successiveAndCard(void);

uint64_t successiveOrCard(void);

uint64_t successiveAndNotCard(void);

uint64_t successiveXorCard(void);

void restart();

#endif