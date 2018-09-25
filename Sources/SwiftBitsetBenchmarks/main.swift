import Bitset
import Utils

var folderName = "census-income"
var numbers: [[UInt32]] = Utils.loadFolderIntoArrays(folderName: folderName)
var bitmaps: [Bitset] = []
var mvalue: UInt32 = 0
var maxvalue: Int = 0

for i in 0..<numbers.count {
    if( numbers[i].count > 0 ) {
        if(mvalue < numbers[i][numbers[i].count-1]) {
            mvalue = numbers[i][numbers[i].count-1];
        }
    }
}

maxvalue = Int(mvalue)

var intNumbers: [[Int]] = []
for list in numbers {
        let intArray = list.map { Int($0) }
        intNumbers.append(intArray)
    }


//create all RoaringBitmaps
func create() -> Int{
    for list in intNumbers {
        let temp = Bitset()
        temp.addMany(list)
        bitmaps.append(temp)
    }
    return bitmaps.count;
}

func successiveAnd() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] & bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}

func successiveOr() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] | bitmaps[i + 1]
        count += temp.count()
    }
    return count;
}

func quartCount() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count) {
        count += bitmaps[i].contains((maxvalue/4)) ? 1 : 0
        count += bitmaps[i].contains((maxvalue/2)) ? 1 : 0
        count += bitmaps[i].contains((3*maxvalue/4)) ? 1 : 0
    }

    return count;
}

func successiveAndNot() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] - bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}

func successiveXor() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        let temp = bitmaps[i] ^ bitmaps[i + 1]
        count += temp.count()
    }

    return count;
}


func iterate() -> Int{
    var count: Int = 0;
    
    for b in bitmaps {
        for _ in b{
            count += 1
        }
    }

    return count;
}

func successiveAndCard() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].intersectionCount(bitmaps[i + 1])
    }

    return count;
}

func successiveOrCard() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].unionCount(bitmaps[i + 1])
    }

    return count;
}

func successiveAndNotCard() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].differenceCount(bitmaps[i + 1])
    }

    return count;
}

func successiveXorCard() -> Int{
    var count: Int = 0;
    
    for i in 0..<(bitmaps.count - 1) {
        count += bitmaps[i].symmetricDifferenceCount(bitmaps[i + 1])
    }

    return count;
}

func restart(){
    bitmaps = []
}

//test functions in c
var functions: [(String, () -> Int)] = [
    ("create", create),
    ("intersection", successiveAnd),
    ("union", successiveOr),
    ("contains", quartCount),
    ("substracting", successiveAndNot),
    ("symmetricDifference", successiveXor),
    ("iterator", iterate),
    ("intersectionCount", successiveAndCard),
    ("unionCount", successiveOrCard),
    ("substractingCount", successiveAndNotCard),
    ("symmetricDifferenceCount ", successiveXorCard)
    ]

let fileName = "SwiftBitset"
let data = Utils.executeFunctions(functions: functions, restartFunction: restart)

Utils.writeToFile(data: data, folderName: folderName, fileName: fileName)