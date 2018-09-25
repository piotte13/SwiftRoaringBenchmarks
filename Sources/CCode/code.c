#include "./include/code.h"

roaring_bitmap_t **bitmaps;
size_t *howmany;
uint32_t **numbers;
size_t count;
uint32_t maxvalue = 0;
bool runoptimize;
bool copyonwrite;
bool verbose;


/**
 * Once you have collected all the integers, build the bitmaps.
 */
static roaring_bitmap_t **create_all_bitmaps(size_t *howmany,
        uint32_t **numbers, size_t count, bool runoptimize, bool copyonwrite, bool verbose) {
    if (numbers == NULL) return NULL;
    size_t savedmem = 0;
    #ifdef RECORD_MALLOCS
        size_t totalmalloced = 0;
    #endif
        roaring_bitmap_t **answer = malloc(sizeof(roaring_bitmap_t *) * count);
    #ifdef RECORD_MALLOCS
        size_t bef = malloced_memory_usage;
    #endif
        for (size_t i = 0; i < count; i++) {
            answer[i] = roaring_bitmap_of_ptr(howmany[i], numbers[i]);
            answer[i]->copy_on_write = copyonwrite;
            if(runoptimize) roaring_bitmap_run_optimize(answer[i]);
        }
    #ifdef RECORD_MALLOCS
        size_t aft = malloced_memory_usage;
        totalmalloced += aft - bef;
        if(verbose) printf("total malloc: %zu vs. reported %llu (%f %%) \n",totalmalloced,(unsigned long long)*totalsize,(totalmalloced-*totalsize)*100.0/ *totalsize);
        *totalsize = totalmalloced;
    #endif
        if(verbose) printf("saved bytes by shrinking : %zu \n",savedmem);
        return answer;
}

void testInit(size_t *_howmany, uint32_t **_numbers, size_t _count, bool _runoptimize, bool _copyonwrite, bool _verbose)
{
    howmany = _howmany;
    numbers = _numbers;
    count = _count;
    runoptimize = _runoptimize;
    copyonwrite = _copyonwrite;
    verbose = _verbose;
    
    for (size_t i = 0; i < count; i++) {
        if( howmany[i] > 0 ) {
            if(maxvalue < numbers[i][howmany[i]-1]) {
                maxvalue = numbers[i][howmany[i]-1];
            }
        }
    }

    return;
}

void testDeinit(void){
    for (int i = 0; i < (int)count; ++i) {
        free(numbers[i]);
        numbers[i] = NULL;  // paranoid
        roaring_bitmap_free(bitmaps[i]);
        bitmaps[i] = NULL;  // paranoid
    }
    free(bitmaps);
    free(howmany);
    free(numbers);
}

uint64_t create(void){
    bitmaps = create_all_bitmaps(howmany, numbers, count,runoptimize,copyonwrite, verbose);  
    return count;
}

uint64_t successiveAnd(void){
    uint64_t successive_and = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        roaring_bitmap_t *tempand =
            roaring_bitmap_and(bitmaps[i], bitmaps[i + 1]);
        successive_and += roaring_bitmap_get_cardinality(tempand);
        roaring_bitmap_free(tempand);
    }

    return successive_and;
}

uint64_t successiveOr(void){
    uint64_t successive_or = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        roaring_bitmap_t *tempor =
            roaring_bitmap_or(bitmaps[i], bitmaps[i + 1]);
        successive_or += roaring_bitmap_get_cardinality(tempor);
        roaring_bitmap_free(tempor);
    }
    return successive_or;
}

uint64_t totalOr(void){
    uint64_t total_or = 0;
    
    roaring_bitmap_t * totalorbitmap = roaring_bitmap_or_many(count,(const roaring_bitmap_t **)bitmaps);
    total_or = roaring_bitmap_get_cardinality(totalorbitmap);
    roaring_bitmap_free(totalorbitmap);

    return total_or;
}

uint64_t totalOrHeap(void){
    uint64_t total_or = 0;
    
    roaring_bitmap_t * totalorbitmapheap = roaring_bitmap_or_many_heap(count,(const roaring_bitmap_t **)bitmaps);
    total_or = roaring_bitmap_get_cardinality(totalorbitmapheap);
    roaring_bitmap_free(totalorbitmapheap);

    return total_or;
}

uint64_t quartCount(void){
    uint64_t quartcount = 0;
    
    for (size_t i = 0; i < count ; ++i) {
        quartcount += roaring_bitmap_contains(bitmaps[i],maxvalue/4);
        quartcount += roaring_bitmap_contains(bitmaps[i],maxvalue/2);
        quartcount += roaring_bitmap_contains(bitmaps[i],3*maxvalue/4);
    }

    return quartcount;
}

uint64_t successiveAndNot(void){
    uint64_t successive_andnot = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        roaring_bitmap_t *tempandnot =
            roaring_bitmap_andnot(bitmaps[i], bitmaps[i + 1]);
        successive_andnot += roaring_bitmap_get_cardinality(tempandnot);
        roaring_bitmap_free(tempandnot);
    }

    return successive_andnot;
}

uint64_t successiveXor(void){
    uint64_t successive_xor = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        roaring_bitmap_t *tempxor =
            roaring_bitmap_xor(bitmaps[i], bitmaps[i + 1]);
        successive_xor += roaring_bitmap_get_cardinality(tempxor);
        roaring_bitmap_free(tempxor);
    }

    return successive_xor;
}

uint64_t iterate(void){
    uint64_t total_count = 0;
    
    for (size_t i = 0; i < count; ++i) {
        roaring_bitmap_t *ra = bitmaps[i];
        roaring_uint32_iterator_t *i = roaring_create_iterator(ra);
        while(i->has_value) {
            total_count += 1;
            roaring_advance_uint32_iterator(i);
        }
    }

    return total_count;
}

uint64_t successiveAndCard(void){
    uint64_t successive_andcard = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        successive_andcard += roaring_bitmap_and_cardinality(bitmaps[i], bitmaps[i + 1]);
    }

    return successive_andcard;
}

uint64_t successiveOrCard(void){
    uint64_t successive_orcard = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        successive_orcard += roaring_bitmap_or_cardinality(bitmaps[i], bitmaps[i + 1]);
    }

    return successive_orcard;
}
uint64_t successiveAndNotCard(void){
    uint64_t successive_andnotcard = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        successive_andnotcard += roaring_bitmap_andnot_cardinality(bitmaps[i], bitmaps[i + 1]);
    }

    return successive_andnotcard;
}
uint64_t successiveXorCard(void){
    uint64_t successive_xorcard = 0;
    
    for (int i = 0; i < (int)count - 1; ++i) {
        successive_xorcard += roaring_bitmap_xor_cardinality(bitmaps[i], bitmaps[i + 1]);
    }

    return successive_xorcard;
}

void restart(){
    for (int i = 0; i < (int)count; ++i) {
        roaring_bitmap_free(bitmaps[i]);
        bitmaps[i] = NULL;  // paranoid
    }
    free(bitmaps);
    bitmaps = NULL;
}