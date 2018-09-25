import ccode
import Utils

//test functions in c
var functions: [(String, () -> UInt64)] = [
    ("create", create),
    ("intersection", successiveAnd),
    ("union", successiveOr),
    ("unionMany", totalOr),
    ("unionManyHeap",totalOrHeap),
    ("contains", quartCount),
    ("substracting", successiveAndNot),
    ("symmetricDifference", successiveXor),
    ("iterator", iterate),
    ("intersectionCount", successiveAndCard),
    ("unionCount", successiveOrCard),
    ("substractingCount", successiveAndNotCard),
    ("symmetricDifferenceCount ", successiveXorCard)
    ]
var folderName = "census-income"
var howMany: [size_t] = []
var numbers: [[UInt32]] = Utils.loadFolderIntoArrays(folderName: folderName)
for i in numbers{
    howMany.append(i.count)
}

var data = UnsafeMutablePointer<UnsafeMutablePointer<UInt32>?>.allocate(capacity:numbers.count)
for i in 0..<numbers.count{
    data[i] = UnsafeMutablePointer<UInt32>.allocate(capacity: numbers[i].count)
    for j in 0..<numbers[i].count {
          data[i]![j] = numbers[i][j]
    }
}

var dataHowmany = UnsafeMutablePointer<size_t>.allocate(capacity:howMany.count)
for i in 0..<howMany.count{
    dataHowmany[i] = howMany[i]
}

//Execute c tests
testInit(dataHowmany, data, numbers.count, true, false, false)

let fileName = "CRoaring"
let dataResults = Utils.executeFunctions(functions: functions, restartFunction: restart)

Utils.writeToFile(data: dataResults, folderName: folderName, fileName: fileName)

//testDeinit()