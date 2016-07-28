let EXHAUSTIVE = 0
class Test {
	
}

class Extension {
	var algorithm = 0
	var networkSize = 8
	func run() {
//		var input = [Int](repeating: 0, count: networkSize)
        var input = [Int](count: networkSize, repeatedValue: 0)
		for index in 0..<networkSize {
			input[index] = index
		}

		// var availablePermutation = [[Int]]()
		// for index in input {

		// }
		// var success = false
		// var stages = 0
		// while !success {
		// 	for index in 0...stages {

		// 	}
		// }

		// func shuffle(input: [Int]) {
		// 	// var output = [[Int]]()
		// 	print("\(input) \n")
		// 	for index in input {
		// 		var out = input
		// 		print("Index: \(index) \n")
		// 		for i in input {
		// 			if i > index {
		// 				out[index] = i
		// 				out[i] = index
		// 				print("\(out) \n")
		// 				availablePermutation.append(out)
		// 				out = input
		// 				// shuffle(input: out) 	
		// 			}
		// 		}
		// 	}
		// 	// return output
		// }

		func shuffle(input: [Int]) -> [[Int]] {
			// var out = []
			// var remain = input
			var outStack = [[Int]]()
			// for index in 1...input.count {
			// 	remain.append(input[index])
			// }
			if input.count == 1 {
				outStack.append(input)
				// return outStack.append(input)
				return outStack
			}
			// print(input)
			// var remainStack = shuffle(remain)
			for index in 0..<input.count {
				var remain = input
//				remain.remove(at: index)
                remain.removeAtIndex(index)
				// out[0] = index
				let remainStack = shuffle(remain)
				for item in remainStack {
					outStack.append([input[index]] + item) 
				}
			}
			return outStack
		}
		// print(shuffle(input: input))
		let availablePermutation = shuffle(input)
		print(availablePermutation.count)
		// if availablePermutation.contains([5,2,3,1,6,0,7,4]) {
		// 	print("Correct")
		// }
	}
	init(algorithm: Int, networkSize: Int) {
		self.algorithm = algorithm
		self.networkSize = networkSize
	}
}