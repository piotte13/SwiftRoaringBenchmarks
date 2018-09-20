import SwiftRoaring
import Foundation
import Dispatch

func nanotime(block: () -> Void) -> UInt64 {
        let t1 = DispatchTime.now()
        block()
        let t2 = DispatchTime.now()
        let delay = t2.uptimeNanoseconds - t1.uptimeNanoseconds
        return delay
}

//Load files into arrays
let fd = FileManager.default
let currentPath = fd.currentDirectoryPath
var numbers: [[UInt32]] = [[]]
fd.enumerator(atPath: currentPath + "/census-income")?.forEach({ (e) in
    if let e = e as? String, let url = URL(string: e) {
        do {
            let file = try String(contentsOfFile: currentPath + "/census-income/" + url.path)
            let list: [String] = file.components(separatedBy: ",")
            let l = list.map { UInt32($0)! }
            numbers.append(l)
        } catch {
            Swift.print("Fatal Error: Couldn't read the contents!")
        }
    }
})

var bitmaps: [RoaringBitmap] = []
//TODO: SEE WITH DANIEL LEMIRE!!!
var maxvalue: UInt32 = 0

for i in 0..<numbers.count {
    if( numbers[i].count > 0 ) {
        if(maxvalue < numbers[i][numbers[i].count-1]) {
            maxvalue = numbers[i][numbers[i].count-1];
        }
    }
}

//create all RoaringBitmaps
func create() -> UInt64{
    for list in numbers {
        bitmaps.append(RoaringBitmap(values: list))
    }
    return UInt64(bitmaps.count);
}

func successiveAnd() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] & bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}

func successiveOr() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] | bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}

func totalOr() -> UInt64{
    var count: UInt64 = 0;
    let temp = bitmaps[0].orMany(Array(bitmaps.dropFirst()))
    count += temp.count()

    return count;
}

func totalOrHeap() -> UInt64{
    var count: UInt64 = 0;
    
    let temp = bitmaps[0].orManyHeap(Array(bitmaps.dropFirst()))
    count += temp.count()

    return count;
}

func quartCount() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count) {
        count += bitmaps[i].contains(value: (maxvalue/4)) ? 1 : 0
        count += bitmaps[i].contains(value: (maxvalue/2)) ? 1 : 0
        count += bitmaps[i].contains(value: (3*maxvalue/4)) ? 1 : 0
    }

    return count;
}

func successiveAndNot() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] - bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}

func successiveXor() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] ^ bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}


func iterate() -> UInt64{
    var count: UInt64 = 0;
    
    for _ in bitmaps {
        count += 1
    }

    return count;
}

func successiveAndCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].andCardinality(bitmaps[i + 1])
    }

    return count;
}

func successiveOrCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].orCardinality(bitmaps[i + 1])
    }

    return count;
}

func successiveAndNotCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].andNotCardinality(bitmaps[i + 1])
    }

    return count;
}

func successiveXorCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].xorCardinality(bitmaps[i + 1])
    }

    return count;
}


var times: [UInt64] = []
var values: [UInt64] = []
//test functions in c
var functions: [() -> UInt64] = [create, successiveAnd, totalOr, totalOrHeap, quartCount, successiveAndNot,
                                successiveXor, iterate, successiveAndCard, successiveOrCard, 
                                successiveAndNotCard, successiveXorCard]

for f in functions {
    times.append(nanotime(block: { () in values.append(f())}))
}

//Print results
for t in times {
    print(t)
}