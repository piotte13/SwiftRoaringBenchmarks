import ccode
import Foundation
import Dispatch

var times: [UInt64] = []
var values: [UInt64] = []
//test functions in c
var functions: [() -> UInt64] = [create, successiveAnd, totalOr, totalOrHeap, quartCount, successiveAndNot,
                                successiveXor, iterate, successiveAndCard, successiveOrCard, 
                                successiveAndNotCard, successiveXorCard]

// Function to time the execution of a given function
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
var howMany: [size_t] = []
var numbers: [[UInt32]] = [[]]
fd.enumerator(atPath: currentPath + "/census-income")?.forEach({ (e) in
    if let e = e as? String, let url = URL(string: e) {
        do {
            let file = try String(contentsOfFile: currentPath + "/census-income/" + url.path)
            let list: [String] = file.components(separatedBy: ",")
            let l = list.map { UInt32($0)! }
            howMany.append(l.count)
            numbers.append(l)
        } catch {
            Swift.print("Fatal Error: Couldn't read the contents!")
        }
    }
})

//Convert arrays to pointers for c code
let l:[UnsafeMutablePointer<UInt32>?] = numbers.map { UnsafeMutablePointer(mutating: $0) }
let ptrNumbers: UnsafeMutablePointer<UnsafeMutablePointer<UInt32>?>? = UnsafeMutablePointer(mutating: l)


//Execute c tests
testInit(&howMany, ptrNumbers, numbers.count, false, false, false)

for f in functions {
    times.append(nanotime(block: { () in values.append(f())}))
}

testDeinit()

//Print results
for t in times {
    print(t)
}