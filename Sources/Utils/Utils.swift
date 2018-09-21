import Foundation
import Dispatch

public class Utils{
    public static func nanotime(block: () -> Void) -> UInt64 {
            let t1 = DispatchTime.now()
            block()
            let t2 = DispatchTime.now()
            let delay = t2.uptimeNanoseconds - t1.uptimeNanoseconds
            return delay
    }

    public static func loadFolderIntoArrays(folderName: String) -> [[UInt32]] {
        //Load files into arrays
        let fd = FileManager.default
        let currentPath = fd.currentDirectoryPath
        return loadFolderIntoArrays(absolutePath: currentPath + "/" + folderName)
    }

    public static func loadFolderIntoArrays(absolutePath: String) -> [[UInt32]] {
        //Load files into arrays
        let fd = FileManager.default
        var numbers: [[UInt32]] = []
        fd.enumerator(atPath: absolutePath)?.forEach({ (e) in
            if let e = e as? String, let url = URL(string: e) {
                do {
                    let file = try String(contentsOfFile: absolutePath + "/" + url.path)
                    let list: [String] = file.components(separatedBy: ",")
                    let l = list.map { UInt32($0.trimmingCharacters(in: .whitespacesAndNewlines))! }
                    numbers.append(l)
                } catch {
                    Swift.print("Fatal Error: Couldn't read the contents!")
                }
            }
        })
        return numbers
    }

    public static func executeFunctions<T>(functions: [() -> T]){
        var times: [UInt64] = []
        var values: [T] = []

        for f in functions {
            times.append(nanotime(block: { () in values.append(f())}))
        }

        //Print results
        for t in times {
            print(t)
        }
    }
}

