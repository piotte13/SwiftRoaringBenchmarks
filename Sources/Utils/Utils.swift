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

    public static func executeFunctions<T>(functions: [(String, () -> T)], restartFunction: () -> Void) -> String{
        var times: [[UInt64]] = []
        var values: [[T]] = []
        var data: String = ""

        for (i, (name, _)) in functions.enumerated() {
            if(i < (functions.count - 1) ){
                data.append("\(name),")
            }
            else {
                data.append("\(name)\n")
            }
        }

        for _ in 0..<100 {
            var iterationTimes: [UInt64] = []
            var iterationValues: [T] = []
            for (_, f) in functions {
                let time = nanotime(block: { () in iterationValues.append(f())})
                iterationTimes.append(time)
            }
            times.append(iterationTimes)
            values.append(iterationValues)
            restartFunction()
        }
        for iteration in times {
            for (i, time) in iteration.enumerated(){
                if(i < (iteration.count - 1) ){
                    data.append("\(time),")
                }
                else {
                    data.append("\(time)\n")
                }
            }
        }
        return data
    }

    public static func writeToFile(data: String, folderName: String, fileName: String){
        let fd = FileManager.default
        let currentPath = fd.currentDirectoryPath
        let url = URL(fileURLWithPath: "\(currentPath)/Results/\(folderName)/\(fileName).csv")
        do{
        try fd.createDirectory(atPath: "\(currentPath)/Results/\(folderName)",withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        print(url.absoluteURL)
        //writing
        do {
            try data.write(to: url, atomically: true, encoding: .utf8)
        }
        catch {/* error handling here */}

    }
}

