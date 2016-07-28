//
//  main.swift
//  MultistageShuffleExchange
//
//  Created by Nguyen Van Minh on 7/24/16.
//  Copyright © 2016 Nguyen Van Minh. All rights reserved.
//

import Foundation

print("Hello, World!")

// function to write to log file
func log(str: String, fileName: String, erase: Bool = false) {
    if erase {              // erase
        do {
            try ("").writeToFile("log/" + fileName, atomically: false, encoding: NSUTF8StringEncoding)
        } catch {
            print("Ooops! Something went wrong")
        }
        return
    }
    var out = ""
    do {
        // Get the contents
        let contents = try String(contentsOfFile: "log/" + fileName, encoding: NSUTF8StringEncoding)
        out += contents
    } catch {
        print("Ooops! Something went wrong")
    }
    
    do {
        try (out+str).writeToFile("log/" + fileName, atomically: false, encoding: NSUTF8StringEncoding)
    } catch {
        print("Ooops! Something went wrong")
    }
}


// var display = "Something"
// print("show me \(display)")

// var packetStack = [String:Int]()
// packetStack["gb"] = 3

// var array = [Int]()
// array.append(3)
// print("\(array)")

// var view = ViewAssistant()
// print(view.own)
// print(view.love)

// var array2dimension = [[[Int]]]()
// array2dimension += [[[3, 4, 5], [1, 3, 4]], [[1, 2], [5, 6]]]
// print(array2dimension)

// func test(_ str: String, _ gt: String) {
// 	print("\(str) Hello \(gt)")
// }

// test("gb", "gt")

var se = SE(id: 10, flag: SE_INTER)
print(se.id)
print(se.flag)

// var test = [Set<Int>]()
// var x = Set<Int>()
// test.append(x)
// print(test)
var testSE = se
testSE.id = 100
print(testSE)
print(se)

var otherSE = SE(id: se.id, flag: SE_INTER)
// print(otherSE)
// otherSE = se
otherSE.id = 1000
print(otherSE)
print(se)

se.id = 9999
print(otherSE)
print(se)
// Create a network with shuffle-exchange topology
// var network = Network(sizeBase: 3, topology: SHUFFLE_EXCHANGE)
// network.setRoutingAlgorithm(destination: [0, 5, 6, 3, 2, 4, 1, 7])
// network.routing(destination: [0, 5, 6, 3, 2, 4, 1, 7])
var network = Network(sizeBase: 4, topology: SHUFFLE_EXCHANGE)
network.setRoutingAlgorithm([1, 5, 3, 7, 9, 4, 2, 6, 8, 11, 14, 15, 13, 0, 10, 12])
network.routing([1, 5, 3, 7, 9, 4, 2, 6, 8, 11, 14, 15, 13, 0, 10, 12])
print(network.printMatrixStateTopology())
// func test(gb: Int) -> Int {
// 	if gb > 0 {
// 		return 0
// 	} else {

// 	}
// }
// var test = pow((Double)2, (Double)3)
// sth("gb")
// log(str: "", fileName: "topology", erase: true)
// var networkSize = 9
// var test = [Int][repeating: 0, count: 9]
// var ex = Extension(algorithm: EXHAUSTIVE, networkSize: 8)
// ex.run()


// if let outputStream = NSOutputStream(toFileAtPath: "log/topology", append: true) {
//     outputStream.open()
//     let text = "some text"
//     outputStream.write(text, maxLength: 200)

//     outputStream.close()
// } else {
//     print("Unable to open file")
// }
// test("Trang")
// var se1 = SE()
// print(se.id)

// var te: Int?
// te = 10
// if let tmp = te {
// 	print(tmp)
// }

