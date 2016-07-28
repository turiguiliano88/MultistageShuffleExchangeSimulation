let SHUFFLE_EXCHANGE = 1
// class to handle Network
class Network: CustomStringConvertible {
	var networkSize = 2
	var sizeBase = 1
	var stages = 1
	var net = [[SE]]()
	var elemNum = 1
    var topology = 1
    // var arrive = [Int]()
    // var destination = [Int]()
    var description: String {
        var tmp = ""
        for i in 0..<elemNum {
            for j in 0..<stages {
                let seId = net[j][i].id
                let type = net[j][i].typeDescription()
                // print(currSe.typeDescription())
                // tmp += "\(net[j][i].typeDescription()) "
                tmp += "[\(seId)]\(type)  "
            }
            tmp += "\n"
        }
        return tmp
    }

	init(sizeBase: Int, topology: Int) {
		self.sizeBase = sizeBase
        self.topology = topology
		// networkSize = pow(2, sizeBase)
		for _ in 0..<sizeBase-1 {
			networkSize *= 2
		}
		elemNum = networkSize / 2
		log("Create network with size: \(networkSize) inputs and outputs!", fileName: "topology", erase: true)

		// create stages
		switch (sizeBase, topology) {
		case (3, SHUFFLE_EXCHANGE):
			stages = 5 
		case (4, SHUFFLE_EXCHANGE):
			stages = 8
		case (let x, SHUFFLE_EXCHANGE) where x >= 5:
			stages = 3 * sizeBase - 4
		default:
			print("Currently not consider this network type yet!")
		}
		print(stages)
		// initialize network elements
		var firstStagesNet = [SE]()
		// var midStagesNet = [SE]()
		var lastStagesNet = [SE]()
		var id = 0
		for _ in 0..<elemNum {
			firstStagesNet.append(SE(id: id, flag: SE_INPUT))
			id+=1
		}
		net.append(firstStagesNet)
		for _ in 1..<stages-1 {
            var midStagesNet = [SE]()
			for _ in 0..<elemNum {
				midStagesNet.append(SE(id: id, flag: SE_INTER))
				id+=1	
			}
            // id+=1
			net.append(midStagesNet)
		}
		for _ in 0..<elemNum {
			lastStagesNet.append(SE(id: id, flag: SE_OUTPUT))	
			id+=1
		}
		net.append(lastStagesNet)
        // print(self)
		var node_in = SE()
		var node_out = SE()
		// connect every elements together
		var output = 0
		for i in 0..<stages-1 {
            for j in 0..<elemNum {
                node_in = net[i][j]

                // For out0
                output = (2*(2*j+0) + (2*(2*j+0)/networkSize)) % networkSize
                node_out = net[i+1][output/2]
                node_in.out0 = node_out
                node_in.out0_port = output % 2
                if (i == 0) {
                    // printf("%02d[%02d]-->%02d[%02d]   \n", (int)(2*j+0),node_in->id, output, node_out->id)
                    print("\(2*j)[\(node_in.id)]-->\(output)[\(node_out.id)]")
                }


                // Link reverse
                if ((output % 2) ==  0) {
                    node_out.in0 = node_in
                    node_out.in0_port = 0
                } else {
                    node_out.in1 = node_in
                    node_out.in1_port = 0
                }

                // For out1
                output = (2*(2*j+1) + (2*(2*j+1)/networkSize)) % networkSize
                node_out = net[i+1][output/2]
                node_in.out1 = node_out
                node_in.out1_port = output % 2
                if (i == 0) {
                	print("\(2*j+1)[\(node_in.id)]-->\(output)[\(node_out.id)]")
                    // printf("%02d[%02d]-->%02d[%02d]   \n", (int)(2*j+1),node_in->id, output, node_out->id)
                }

                // Link reverse
                if ((output % 2) ==  0)  {
                    node_out.in0 = node_in
                    node_out.in0_port = 1
                } else {
                    node_out.in1 = node_in
                    node_out.in1_port = 1
                }
            }
        }
        // print(self)
        // write into log file topology
        // log(str: "NETWORK TOPOLOGY: \n", fileName: "topology", erase: false)
        // var outNode: SE?
        // for i in 0..<elemNum*2 {
        // 	for j in 0..<stages {
        // 		var port = 0
        // 		let node = net[j][i/2]
        // 		var dstPort = 0
        // 		if i%2 == 0 {
        // 			port = 0
        // 			outNode = node.out0
        // 			dstPort = node.out0_port
        // 		} else {
        // 			port = 1
        // 			outNode = node.out1
        // 			dstPort = node.out1_port
        // 		}

        // 		if let outID = outNode?.id {
        // 			log(str: "[\(node.id)](\(port))-->[\(outID)](\(dstPort))  ", fileName: "topology", erase: false)
        // 		} else {
        // 			log(str: "[\(node.id)](\(port))-->[OUTPUT]", fileName: "topology", erase: false)
        // 		}
        // 	}
        // 	log(str: "\n", fileName: "topology", erase: false)
        // }
	}

    func setRoutingAlgorithm(destination: [Int]) {
        switch (sizeBase, topology) {
        case (3, SHUFFLE_EXCHANGE):
            algShuffleEight(destination)
        case (4, SHUFFLE_EXCHANGE):
            algShuffleSixteen(destination)
        case (5, SHUFFLE_EXCHANGE):
            algShuffleThirtyTwo(destination)
        // case (let x, SHUFFLE_EXCHANGE) where x > 5:
        //     algShuffleGeneral()
        default:
            break
        }
    }

    func loopingAlgorithm(destination: [Int], network: [[SE]]) {
        // print("Count \(network.count)")
        var dic = [Int: Int]() // dictionary
        var dicReverse = [Int: Int]()
        var dicVisit = [Int: Bool]()
        var dicReverseVisit = [Int: Bool]()
        // print("Destination: \(destination) and \(destination.count)")
        for i in 0..<destination.count {
            dic[i] = destination[i]
            dicVisit[i] = false
            dicReverse[destination[i]] = i
            dicReverseVisit[destination[i]] = false
        }
        // dic.removeValue(forKey: 0)
        print("Dictionayr: ")
        print(dic)
        // print(dic[15])
        print(dicReverse)
        // print(network)
        // print(12/2)
        func loopRoute() {
            print("Begin loop route")
            if let first = Array(dic).first {
//                let firstInput = first.key
//                let firstOutput = first.value
                let firstInput = first.0
                let firstOutput = first.1
                var loopProcess = true
                // print(firstInput)
                // print(firstOutput)
                func loop(IN: [SE], OUT: [SE], input: Int, reverse: Bool) -> Int {
                    print("Begin loop: ")
                    var output = 0
                    if reverse {
                        output = dicReverse[input]!
                    } else {
                        output = dic[input]!
                    }
                    print(input)
                    print(output)
                    print(IN[input / 2])

                    if reverse {
                        if dicReverseVisit[input]! {
                            print("Stop when \(dicReverseVisit)")
                            return 0
                        }
                    } else {
                        if dicVisit[input]! {
                            print("Stop when \(dicVisit)")
                            return 0
                        }
                    }

                    if reverse {
                        dicReverseVisit[input] = true
                    } else {
                        dicVisit[input] = true
                    }  

                    if let type = IN[input / 2].type { // SE already set
                        print(OUT[output/2])
                        if input % 2 ^ type == 0 {  // belong to subnetwork 0
                            // SE at output must set to ensure output belong to subnetwork 0
                            if let typeOut = OUT[output / 2].type {
                                if output % 2 ^ typeOut == 0 {
                                    // loopProcess = true
                                } else {
                                    loopProcess = false
                                }
                            } else {
                                var nodeOut = OUT[output / 2]
                                if output % 2 == 0 {
                                    nodeOut.type = STRAIGHT
                                } else {
                                    nodeOut.type = CROSS
                                }
                            }
                        } else {    // belong to subnetwork 1
                            // SE at output must set to ensure output belong to subnetwork 0
                            if let typeOut = OUT[output / 2].type {
                                if output % 2 ^ typeOut == 1 {
                                    // loopProcess = true
                                } else {
                                    loopProcess = false
                                }
                            } else {
                                var nodeOut = OUT[output / 2]
                                if output % 2 == 1 {
                                    nodeOut.type = STRAIGHT
                                } else {
                                    nodeOut.type = CROSS
                                }
                            }
                        }
                        let neighbor = output ^ 1
                        // reverse = !reverse
                        loop(OUT, OUT: IN, input: neighbor, reverse: !reverse)
                    } else {    
                        // first set type to straight
                        IN[input / 2].type = STRAIGHT
                        print(IN[input / 2])
                        var nodeDes = OUT[output / 2]
                        // var neighbor = output
                        print(nodeDes)
                        if input % 2 == 0 {   // belong to subnetwork 0
                            // SE at output must set to ensure output belong to subnetwork 0
                            if output % 2 == 0 {
                                nodeDes.type = STRAIGHT
                                // neighbor = output + 1
                            } else {
                                nodeDes.type = CROSS
                            }
                        } else {   // belong to subnetwork 1
                            // SE at output must set to ensure output belong to subnetwork 1
                            if output % 2 == 0 {
                                nodeDes.type = CROSS
                            } else {
                                nodeDes.type = STRAIGHT
                            }
                        }
                        // find the neighbour of output
                        let neighbor = output ^ 1
                        // reverse = !reverse
                        loop(OUT, OUT: IN, input: neighbor, reverse: !reverse)

                        // if set to straight lead to wrong then change to cross
                        if !loopProcess {
                            IN[input / 2].type = CROSS
                            var nodeDes = OUT[output / 2]
                            // var neighbor = output

                            if input % 2 == 0 {   // belong to subnetwork 1
                                // SE at output must set to ensure output belong to subnetwork 1
                                if output % 2 == 0 {
                                    nodeDes.type = CROSS
                                    // neighbor = output + 1
                                } else {
                                    nodeDes.type = STRAIGHT
                                }
                            } else {   // belong to subnetwork 0
                                // SE at output must set to ensure output belong to subnetwork 0
                                if output % 2 == 0 {
                                    nodeDes.type = STRAIGHT
                                } else {
                                    nodeDes.type = CROSS
                                }
                            }
                            // find the neighbour of output
                            let neighbor = output ^ 1
                            // reverse = !reverse
                            loop(OUT, OUT: IN, input: neighbor, reverse: !reverse)                            
                        }
                    }
                    return 0
                }
                loop(network[0], OUT: network[network.count - 1], input: firstInput, reverse: false)
            }
        }
        while !dic.isEmpty && !dicReverse.isEmpty {
            loopRoute()
            for i in dic.keys where dicVisit[i] == true{
//                dic.removeValue(forKey: i)
                dic.removeValueForKey(i)
            }
            for i in dicReverse.keys where dicReverseVisit[i] == true{
//                dicReverse.removeValue(forKey: i)
                dic.removeValueForKey(i)
            }
            print(dic)
            print(dicReverse)
        }
        print(network[0])
        print(network[network.count - 1])
        // for i in 0..<elemNum {
        //     print(net[0][i])
        // }
        // loopRoute()
    }

    func algShuffleSixteen(destination: [Int]) {
        // set specific matrix at stages 4
        for i in 0..<elemNum {
            net[4][i].type = i%2 
        }
        // print(destination)
        // need to redefine the destination...for ex: 8->1
        // var first_stage_dic = [Int: Int]()
        // for i in 0..<networkSize {
        //     first_stage_dic[i] = (2*i + 2*i / networkSize) % networkSize
        // }

        // for i in 0..
        // let map_first = [0: 0, 8: 1, 1: 2, 9: 3, 2: 4, 10: 5, 3: 6, 11: 7, 4: 8, 12: 9, 5: 10, 13: 11, 6: 12, 14: 13, 7: 14, 15: 15]
        let map_first = [0: 0, 1: 8, 2: 1, 3: 9, 4: 2, 5: 10, 6: 3, 7: 11, 8: 4, 9: 12, 10: 5, 11: 13, 12: 6, 13: 14, 14: 7, 15: 15]

        let map_last = [0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 9, 9: 8, 10: 11, 11: 10, 12: 13, 13: 12, 14: 15, 15: 14]

        var new_destination = [Int]()
        var dic_new_destination = [Int: Int]()
        for i in 0..<destination.count {
            let des = map_last[destination[map_first[i]!]]!
            print("In \(i) with \(map_first[i]!) and \(des)")
            new_destination.append(des)
            dic_new_destination[i] = des
        }
        print("New destination: \(new_destination)")

        // set first and last stage SE by looping algorithm
        loopingAlgorithm(new_destination, network: net)

        var dic_forward_subnet1 = [Int: Int]()
        var dic_forward_subnet2 = [Int: Int]()
        var dic_backward_subnet1 = [Int: Int]()
        var dic_backward_subnet2 = [Int: Int]()

        let tmp = [0, 1, 2, 3]
        // set map
        for i in 0..<elemNum {
            let setmp = net[0][i]
            // print("Size net: \(net.count)")
            let setmp_backward = net[net.count - 1][i]
            // input port 0: number i*2
            if setmp.type == STRAIGHT {
                // port 0 goes to subnet1
                dic_forward_subnet1[i*2] = (setmp.out0.id%elemNum)*2 + setmp.out0_port
                // port 1 goes to subnet 2
                dic_forward_subnet2[i*2 + 1] = (setmp.out1.id%elemNum)*2 + setmp.out1_port
                // print("STRAIGHT")
                // print("In 0: \(setmp_backward.in0)")
                // print("In 1: \(setmp_backward.in1)")

                
            } else {
                // port 0 goes to subnet 2
                dic_forward_subnet2[i*2] = (setmp.out1.id%elemNum)*2 + setmp.out1_port
                // port 1 goes to subnet 1
                dic_forward_subnet1[i*2 + 1] = (setmp.out0.id%elemNum)*2 + setmp.out0_port
                // print("CROSS")
                // print("In 0: \(setmp_backward.in0)")
                // print("In 1: \(setmp_backward.in1)")

              
            }

            // var in0_back = 0, in1_back = 0
            if setmp_backward.type == STRAIGHT {
                // in0_back = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                // in1_back = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port

                if tmp.contains(i) {
                    dic_backward_subnet1[i*2] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                    dic_backward_subnet2[i*2 + 1] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port    
                } else {
                    dic_backward_subnet1[i*2] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                    dic_backward_subnet2[i*2 + 1] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port    
                }
                // dic_backward_subnet1[i*2] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                // dic_backward_subnet2[i*2 + 1] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                print("STRAIGHT")
                print("In 0: \(setmp_backward.in0)")
                print("In 1: \(setmp_backward.in1)")

            } else {
                // in1_back = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                // in0_back = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                  // port 0 goes to subnet 2
                if tmp.contains(i) {
                    dic_backward_subnet2[i*2] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                    dic_backward_subnet1[i*2 + 1] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port    
                } else {
                    dic_backward_subnet2[i*2] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                    dic_backward_subnet1[i*2 + 1] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                }
                // dic_backward_subnet2[i*2] = (setmp_backward.in1.id%elemNum)*2 + setmp_backward.in1_port
                // dic_backward_subnet1[i*2 + 1] = (setmp_backward.in0.id%elemNum)*2 + setmp_backward.in0_port
                print("CROSS")
                print("In 0: \(setmp_backward.in0)")
                print("In 1: \(setmp_backward.in1)")
            }
            
            // switch i {
            // case 0, 1, 2, 3:
            //     dic_backward_subnet1[i*2] = in0_back
            //     dic_backward_subnet2
            // case 4, 5, 6, 7:

            // default:
            // }
        }

        // next step we have this map: with subnet1: 0->0, 2->1, 4->2, 6->3
        let map_forward_sub1 = [0: 0, 1: 1, 4: 2, 5: 3, 8: 4, 9: 5, 12: 6, 13: 7]
        let map_forward_sub2 = [2: 0, 3: 1, 6: 2, 7: 3, 10: 4, 11: 5, 14: 6, 15: 7]

        let map_backward_sub1 = [0: 0, 1: 1, 2: 2, 3: 3, 12: 4, 13: 5, 14: 6, 15: 7]
        let map_backward_sub2 = [4: 0, 5: 1, 6: 2, 7: 3, 8: 4, 9: 5, 10: 6, 11: 7]
        
        print(dic_forward_subnet1)
        print(dic_forward_subnet2)

        print("Forward goes wrong")
        for (k, v) in dic_forward_subnet1 {
            if let newval = map_forward_sub1[v] {
                dic_forward_subnet1.updateValue(newval, forKey: k)    
            } else {
                print("Error")
            }
        }

        for (k, v) in dic_forward_subnet2 {
            if let newval = map_forward_sub2[v] {
                dic_forward_subnet2.updateValue(newval, forKey: k)    
            } else {
                print("Error")
            }
        }

        print("Backward goes wrong")
        print(dic_backward_subnet1)
        // set map from backward
        for (k, v) in dic_backward_subnet1 {
            if let newval = map_backward_sub1[v] {
                dic_backward_subnet1.updateValue(newval, forKey: k)    
            } else {
                print("Error")
            }
        }
        print("Backward sub2 goes wrong")
        print(dic_backward_subnet2)
        for (k, v) in dic_backward_subnet2 {
            if let newval = map_backward_sub2[v] {
                dic_backward_subnet2.updateValue(newval, forKey: k)    
            } else {
                print("Error")
            }
        }

        print("Dic forward 1")
        print(dic_forward_subnet1)
        print("Dic backward 1")
        print(dic_backward_subnet1)

        let pre_destination = [0: 0, 1: 4, 2: 1, 3: 5, 4: 2, 5: 6, 6: 3, 7: 7]
        var dic_subnet1 = [Int: Int]()
        for (k, v) in dic_forward_subnet1 {
            dic_subnet1[pre_destination[v]!] = dic_backward_subnet1[dic_new_destination[k]!]
        }

        

        var des_subnet1 = [Int]()
        print("Dic subnet 1: \(dic_subnet1)")
        // for i in 0..<Array(dic_subnet1.keys).sort(<)
        for i in 0..<networkSize/2 {
            des_subnet1.append(dic_subnet1[i]!)
        }

        print("Array dic subnet 1: \(des_subnet1)")
        // routing algorithm to 2 subnetwork with sizebase 3
        // copy subnetwork into new network sizebase 3
        var subnet1 = Network(sizeBase: 3, topology: SHUFFLE_EXCHANGE)
        // set predestination, inverse first stage

        subnet1.setRoutingAlgorithm(des_subnet1)
        subnet1.routing(des_subnet1)
        // print(subnetwork1/)
        // Set SE matrix back to original network

        var dic_subnet2 = [Int: Int]()
        for (k, v) in dic_forward_subnet2 {
            dic_subnet2[pre_destination[v]!] = dic_backward_subnet2[dic_new_destination[k]!]
        }
        var des_subnet2 = [Int]()
        print("Dic subnet 2: \(dic_subnet2)")
        // for i in 0..<Array(dic_subnet1.keys).sort(<)
        for i in 0..<networkSize/2 {
            des_subnet2.append(dic_subnet2[i]!)
        }
        var subnet2 = Network(sizeBase: 3, topology: SHUFFLE_EXCHANGE)
        subnet2.setRoutingAlgorithm(des_subnet2)
        subnet2.routing(des_subnet2)
        // set destination

        // Set SE matrix back to original network
        // First stage:
        var ts1 = [0: 0, 1: 2, 2: 4, 3: 6]
        var ts2 = [0: 1, 1: 3, 2: 5, 3: 7]

        func setStateOriginal(stageOriginal: Int, stageSubnet: Int) {
            let sub1 = subnet1.net
            let sub2 = subnet2.net
            for i in 0..<elemNum/2 {
                net[stageOriginal][ts1[i]!].type = sub1[stageSubnet][i].type
            }
            for i in 0..<elemNum/2 {
                net[stageOriginal][ts2[i]!].type = sub2[stageSubnet][i].type
            }    
        }
        setStateOriginal(1, stageSubnet: 0)
        // Second stage
        ts1 = [0: 0, 1: 1, 2: 4, 3: 5]
        ts2 = [0: 2, 1: 3, 2: 6, 3: 7]
        setStateOriginal(2, stageSubnet: 1)
        // Third stage
        ts1 = [0: 0, 1: 1, 2: 2, 3: 3]
        ts2 = [0: 4, 1: 5, 2: 6, 3: 7]
        setStateOriginal(3, stageSubnet: 2)
        // Fifth stage
        ts1 = [0: 0, 1: 3, 2: 4, 3: 7]
        ts2 = [0: 1, 1: 2, 2: 5, 3: 6]
        setStateOriginal(5, stageSubnet: 3)
        // Sixth stage
        ts1 = [0: 0, 1: 1, 2: 6, 3: 7]
        ts2 = [0: 2, 1: 3, 2: 4, 3: 5]
        setStateOriginal(6, stageSubnet: 4)

        print("Original matrix")
        print(net)

        // for i in 0..<elemNum/2 {
        //     net[1][ts1[i]!].type = subnet1[0][i]
        // }
        // for i in 0..<elemNum/2 {
        //     net[1][ts2[i]!].type = subnet2[0][i]
        // }
        // Second stage:
        // net[1][0].type = subnet1[0][0]
    }

    // func algShuffleGeneral(destination: [Int]) {

    // }
    func algShuffleThirtyTwo(destination: [Int]) {
        
    }

    func algShuffleEight(destination: [Int]) {
        var X = [Set<Int>]([Set<Int>(), Set<Int>()])
        var Xa = [Set<Int>]([Set<Int>(), Set<Int>()])
        var C = [Set<Int>]([Set<Int>(), Set<Int>(), Set<Int>(), Set<Int>()])
        var Y = [Set<Int>]([Set<Int>(), Set<Int>()])
        var visitedP = [false, false, false, false]
        var visitedR = [false, false, false, false]
        var P = [Set<Int>]([Set<Int>(), Set<Int>(), Set<Int>(), Set<Int>()])
        var O = [Set<Int>]([Set<Int>(), Set<Int>(), Set<Int>(), Set<Int>()])
//        var O = [Set<Int>]([Set([0, 1]), Set([2, 3]), Set([4, 5]), Set([6, 7])])
        var R = [Set<Int>]([Set<Int>(), Set<Int>(), Set<Int>(), Set<Int>()])
        var I = [Set<Int>]([Set([0, 2, 4, 6]), Set([1, 3, 5, 7])])
        var pI = [Set<Int>]([Set([destination[0], destination[2], destination[4], destination[6]]), Set([destination[1], destination[3], destination[5], destination[7]])])

        // // Step 1
        for i in 0..<4 {
            P[i].insert(destination[i])
            P[i].insert(destination[i + 4])
        }
        print("P: \(P)")
        
        P[0].insert(0)
        P[0].insert(1)
        P[1].insert(2)
        P[1].insert(3)
        P[2].insert(4)
        P[2].insert(5)
        P[3].insert(6)
        P[3].insert(7)

        // Step 2
        let step2 = 0, step4 = 1
        // print(P)
        // print(O)
        func loop_constructX(start_array: Int, start_element: Int, start_node: Int, option: Int) -> Int {
            var nei = 0
            var curr_array = [Set<Int>]()
            if option == step2 {
                if start_array == 0 {
                    curr_array = O
                } else if start_array == 1 {
                    curr_array = P
                }    
            } else if option == step4 {
                if start_array == 0 {
                    curr_array = O
                } else if start_array == 1 {
                    curr_array = R
                }
            }
            // Check if the start_element already in X
            if option == step2 {
                if X[start_array].contains(start_element) {
                    // print("\(start_element) is exist")
                    return 0
                }    
            } else if option == step4 {
                if Y[start_array].contains(start_element) {
                    return 0
                }
            }
            
            if option == step2 {
                X[start_array].insert(start_element)
                if start_array == 0 {
                    visitedP[start_node] = true
                    // print("Visit \(start_node)")
                }
            } else if option == step4 {
                Y[start_array].insert(start_element)
                if start_array == 0 {
                    visitedR[start_node] = true
                }
            }
            
            
            for i in 0...3 {
                if curr_array[i].contains(start_element) {
                    curr_array[i].remove(start_element)
                    for i in curr_array[i] {
                        nei = i
                    }
                    // print("Neighbor: \(nei)")
                    loop_constructX(start_array^1, start_element: nei, start_node: i, option: option)
                    break
                }     
            }
            return 0
        }

        var vi = 0
        while vi < 4 {
//            if !visitedP[vi], let val = P[vi].min(){
            if !visitedP[vi], let val = P[vi].minElement(){
                // print("Start")
                loop_constructX(0, start_element: val, start_node: vi, option: step2)
                // vi+=1
            } else {
                vi+=1
            }
        }
        print("X: \(X)")
        // print(P)
        // print(O)
        // print(X)
        // // Step 3
        // Generate R0
        R[0] = X[0].intersect(pI[0])
        // Generate R1
        R[1] = X[0].intersect(pI[1])
        // Generate R2
        R[2] = X[1].intersect(pI[0])
        // Generate R3
        R[3] = X[1].intersect(pI[1])
        print("R: \(R)")
        /* Step 4 */
        vi = 0
        while vi < 4 {
            if !visitedR[vi], let val = R[vi].minElement(){
                loop_constructX(0, start_element: val, start_node: vi, option: step4)
            } else {
                vi+=1
            }
        }
        print("Y: \(Y)")
        // /* Step 5 */
        var tmpI = [Set<Int>]([Set([0, 1, 2, 3]), Set([4, 5, 6, 7])])
        let tmpX0 = X[0].intersect(Y[0])
        // print(tmpX0)
        // print(tmpX0.intersect(tmpI[0]).count)
        // if tmpX0.intersect(tmpI[0]).isEmpty {
        //     print("not in I0")
        // }
        if tmpX0.intersect(tmpI[0]).count > 0 && tmpX0.intersect(tmpI[1]).count > 0 {
            Xa[0] = X[0]
            Xa[1] = X[1]
        } else {
            Xa[0] = R[0].union(R[3])
            Xa[1] = R[1].union(R[2])
        }
        print("Xa: \(Xa)")
        // /* Step 6 */
        C[0] = Xa[0].intersect(Y[0])
        C[1] = Xa[0].intersect(Y[1])
        C[2] = Xa[1].intersect(Y[0])
        C[3] = Xa[1].intersect(Y[1])
        // print(C)
        for i in 0..<8 {
            print(String(destination[i], radix: 2).pad(self.sizeBase))
            // set state matrix of SE by follow the routing path
            // use probe packet
            let p = Packet(id: i, input: i, output: destination[i])
            let des = String(destination[i], radix: 2).pad(self.sizeBase)
            var routingPath = ""
            switch destination[i] {
            case let x where C[0].contains(x):
                routingPath = "00" + des
            case let x where C[1].contains(x):
                routingPath = "01" + des
            case let x where C[2].contains(x):
                routingPath = "10" + des
            case let x where C[3].contains(x):
                routingPath = "11" + des
            default:
                break
            }

            setFirstInputStageShuffleExchange(p, i: i)

            // start probe routing
            func probe(packet: Packet) {
                // let strState = String(routingPath.characters.first!)
                // let currState = Int(strState)!
                // print("currentState: \(currState)")
                
                if let port = packet.curr_se_port, let currSe = packet.curr_se, let strState = routingPath.characters.first, let currState = Int(String(strState)) {
                    routingPath = String(routingPath.characters.dropFirst())
                    switch (port, currState) {
                    case (0, 0):
                        currSe.type = STRAIGHT
                        // go to next stage
                        if routingPath.characters.count > 0 {
                            packet.curr_se = currSe.out0
                            packet.curr_se_port = currSe.out0_port
                            probe(packet)    
                        }
                    case (1, 0):
                        currSe.type = CROSS
                        // go to next stage
                        if routingPath.characters.count > 0 {
                            packet.curr_se = currSe.out0
                            packet.curr_se_port = currSe.out0_port    
                            probe(packet)
                        }
                    case (0, 1):
                        currSe.type = CROSS
                        // go to next stage
                        if routingPath.characters.count > 0 {
                            packet.curr_se = currSe.out1
                            packet.curr_se_port = currSe.out1_port    
                            probe(packet)
                        }
                    case (1, 1):
                        currSe.type = STRAIGHT
                        // go to next stage
                        if routingPath.characters.count > 0 {
                            packet.curr_se = currSe.out1
                            packet.curr_se_port = currSe.out1_port    
                            probe(packet)
                        }
                    default:
                        break
                    } 
                } else {
                    print("Error")
                }
            }
            probe(p)
        }
        print(self)
    }

    func routing(destination: [Int]) {
        for i in 0..<destination.count {
            var p = Packet(id: i, input: i, output: destination[i], type: RUN)

            // set first input stage
            setFirstInputStageShuffleExchange(p, i: i)
            setOutputStageShuffleExchange()

            func route(packet: Packet) {
                if let port = packet.curr_se_port, let currSe = packet.curr_se, let type = currSe.type {
                    // if let next = currSe.out0 {

                    // } else {  // reach the final stage

                    // }
                    print("-->\(currSe.id)", terminator: "")
                    switch (port, type) {
                    case (0, STRAIGHT):
                        // move to next stage
                        if let nextSe = currSe.out0 {
                            packet.curr_se = nextSe
                            packet.curr_se_port = currSe.out0_port
                            route(packet)
                        } else {  // reach the final stage
                            if packet.output == currSe.out0_port {
                                print("Route successful!")
                            } else {
                                print("Route incorrect: output at \(currSe.out0_port) compared with \(packet.output)")
                            }
                        }
                    case (1, STRAIGHT):
                        // move to next stage
                        if let nextSe = currSe.out1 {
                            packet.curr_se = nextSe
                            packet.curr_se_port = currSe.out1_port
                            route(packet)
                        } else {  // reach the final stage
                            if packet.output == currSe.out1_port {
                                print("Route successful!")
                            } else {
                                print("Route incorrect: output at \(currSe.out1_port) compared with \(packet.output)")
                            }
                        }
                    case (0, CROSS):
                        // move to next stage
                        if let nextSe = currSe.out1 {
                            packet.curr_se = nextSe
                            packet.curr_se_port = currSe.out1_port
                            route(packet)
                        } else {  // reach the final stage
                            if packet.output == currSe.out1_port {
                                print("Route successful!")
                            } else {
                                print("Route incorrect: output at \(currSe.out1_port) compared with \(packet.output)")
                            }
                        }
                    case (1, CROSS):
                        // move to next stage
                        if let nextSe = currSe.out0 {
                            packet.curr_se = nextSe
                            packet.curr_se_port = currSe.out0_port
                            route(packet)
                        } else {  // reach the final stage
                            if packet.output == currSe.out0_port {
                                print("Route successful!")
                            } else {
                                print("Route incorrect: output at \(currSe.out0_port) compared with \(packet.output)")
                            }
                        }
                    default:
                        break
                    }
                }
            }
            route(p)
        }
    }

    func setFirstInputStageShuffleExchange(p: Packet, i: Int) {
        let inputFirst = (2*i + 2*i / networkSize) % networkSize

        // go to port 0
        if inputFirst % 2 == 0 {
            p.curr_se = net[0][inputFirst / 2]
            p.curr_se_port = 0
            if let tmp = p.curr_se {
                print(tmp)
            }
        } else { // go to port 1
            p.curr_se = net[0][inputFirst / 2]
            p.curr_se_port = 1
            if let tmp = p.curr_se {
                print(tmp)
            }
        }
    }

    func setOutputStageShuffleExchange() {
        for i in 0..<elemNum {
            let currSe = net[stages-1][i]
            if currSe.type != nil {
                currSe.out0_port = 2*i
                currSe.out1_port = 2*i + 1
            } else {
                print("Error!")
            }
        }
    }

    func printMatrixStateTopology() -> String {
        var out = ""
        for i in 0..<elemNum {
            for j in 0..<stages {
                out += "\(net[j][i].typeDescription())  "
            }
            out += "\n"
        }
        return out
    }
}