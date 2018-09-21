import Utils

var numbers: [[UInt32]] = Utils.loadFolderIntoArrays(folderName: "census-income")

var swiftSets: [Set<UInt32>] = []
var maxvalue: UInt32 = 0

for i in 0..<numbers.count {
    if( numbers[i].count > 0 ) {
        if(maxvalue < numbers[i][numbers[i].count-1]) {
            maxvalue = numbers[i][numbers[i].count-1];
        }
    }
}

//create all SwiftSets
func create() -> Int{
    for list in numbers {
        swiftSets.append(Set(list))
    }
    return swiftSets.count;
}

func successiveAnd() -> Int{
    var count: Int = 0;
    
    for i in 0..<(swiftSets.count - 1) {
        let temp = swiftSets[i].intersection(swiftSets[i + 1])
        count += temp.count
    }

    return count;
}

func successiveOr() -> Int{
    var count: Int = 0;
    
    for i in 0..<(swiftSets.count - 1) {
        let temp = swiftSets[i].union(swiftSets[i + 1])
        count += temp.count
    }
    return count;
}

func quartCount() -> Int{
    var count: Int = 0;
    
    for i in 0..<(swiftSets.count) {
        count += swiftSets[i].contains { $0 == (maxvalue/4) } ? 1 : 0
        count += swiftSets[i].contains { $0 == (maxvalue/2) } ? 1 : 0
        count += swiftSets[i].contains { $0 == (3*maxvalue/4) } ? 1 : 0
    }

    return count;
}

func successiveAndNot() -> Int{
    var count: Int = 0;
    
    for i in 0..<(swiftSets.count - 1) {
        let temp = swiftSets[i].subtracting(swiftSets[i + 1])
        count += temp.count
    }

    return count;
}

func successiveXor() -> Int{
    var count: Int = 0;
    
    for i in 0..<(swiftSets.count - 1) {
        let temp = swiftSets[i].symmetricDifference(swiftSets[i + 1])
        count += temp.count
    }

    return count;
}


func iterate() -> Int{
    var count: Int = 0;
    
    for b in swiftSets {
        for _ in b{
            count += 1
        }
    }

    return count;
}


var functions: [() -> Int] = [create, successiveAnd, successiveOr, quartCount, successiveAndNot,
                                successiveXor, iterate]

Utils.executeFunctions(functions: functions)