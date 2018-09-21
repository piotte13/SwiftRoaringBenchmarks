import ccode
import Utils

//test functions in c
var functions: [() -> UInt64] = [create, successiveAnd, successiveOr, totalOr, totalOrHeap, quartCount, successiveAndNot,
                                successiveXor, iterate, successiveAndCard, successiveOrCard, 
                                successiveAndNotCard, successiveXorCard]

var howMany: [size_t] = []
var numbers: [[UInt32]] = Utils.loadFolderIntoArrays(folderName: "census-income")
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

Utils.executeFunctions(functions: functions)

testDeinit()