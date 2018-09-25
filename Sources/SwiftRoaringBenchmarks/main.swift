import SwiftRoaring
import Utils

var folderName = "census-income"
var numbers: [[UInt32]] = Utils.loadFolderIntoArrays(folderName: folderName)
var bitmaps: [RoaringBitmap] = []
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
        let temp = RoaringBitmap(values: list)
        let _ = temp.runOptimize()
        bitmaps.append(temp)
    }
    return UInt64(bitmaps.count);
}

func successiveAnd() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] & bitmaps[i + 1]
        count += temp.count
    }

    return count;
}

func successiveOr() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] | bitmaps[i + 1]
        count += temp.count
    }
    return count;
}

func totalOr() -> UInt64{
    var count: UInt64 = 0;
    let temp = bitmaps[0].unionMany(Array(bitmaps.dropFirst()))
    count += temp.count
    return count;
}

func totalOrHeap() -> UInt64{
    var count: UInt64 = 0;
    
    let temp = bitmaps[0].unionManyHeap(Array(bitmaps.dropFirst()))
    count += temp.count

    return count;
}

func quartCount() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count) {
        count += bitmaps[i].contains((maxvalue/4)) ? 1 : 0
        count += bitmaps[i].contains((maxvalue/2)) ? 1 : 0
        count += bitmaps[i].contains((3*maxvalue/4)) ? 1 : 0
    }

    return count;
}

func successiveAndNot() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] - bitmaps[i + 1]
        count += temp.count
    }

    return count;
}

func successiveXor() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] ^ bitmaps[i + 1]
        count += temp.count
    }

    return count;
}


func iterate() -> UInt64{
    var count: UInt64 = 0;
    
    for b in bitmaps {
        for _ in b{
            count += 1
        }
    }

    return count;
}

func successiveAndCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].intersectionCount(bitmaps[i + 1])
    }

    return count;
}

func successiveOrCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].unionCount(bitmaps[i + 1])
    }

    return count;
}

func successiveAndNotCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].subtractingCount(bitmaps[i + 1])
    }

    return count;
}

func successiveXorCard() -> UInt64{
    var count: UInt64 = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].symmetricDifferenceCount(bitmaps[i + 1])
    }

    return count;
}

func restart(){
    bitmaps = []
}

//test functions in c
var functions: [(String, () -> UInt64)] = [
    ("create", create),
    ("intersection", successiveAnd),
    ("union", successiveOr),
    ("unionMany", totalOr),
    ("unionManyHeap",totalOrHeap),
    ("contains", quartCount),
    ("subtracting", successiveAndNot),
    ("symmetricDifference", successiveXor),
    ("iterator", iterate),
    ("intersectionCount", successiveAndCard),
    ("unionCount", successiveOrCard),
    ("subtractingCount", successiveAndNotCard),
    ("symmetricDifferenceCount ", successiveXorCard)
    ]

let fileName = "SwiftRoaring"
let data = Utils.executeFunctions(functions: functions, restartFunction: restart)

Utils.writeToFile(data: data, folderName: folderName, fileName: fileName)