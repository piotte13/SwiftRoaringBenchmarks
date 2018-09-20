print("Hello, world!")


func nanotime(block: () -> Void) -> UInt64 {
        let t1 = DispatchTime.now()
        block()
        let t2 = DispatchTime.now()
        let delay = t2.uptimeNanoseconds - t1.uptimeNanoseconds
        return delay
}