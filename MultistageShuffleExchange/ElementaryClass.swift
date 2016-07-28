// define global variable for SE stages
let SE_INTER = 0, SE_INPUT = 1, SE_OUTPUT = 2
let CROSS = 1, STRAIGHT = 0
// switching elements class
class SE: CustomStringConvertible {
	var id = 0
	var out0: SE!
	var in1: SE!
	var out1: SE!
	var in0: SE!
	var in0_port = 0
	var in1_port = 0
	var out0_port = 0
	var out1_port = 0
	var type: Int?
	var flag: Int?

	var description: String {
		return "SE id: \(id) with type " + self.typeDescription()
	}

	init (id: Int, flag: Int) {
		self.id = id
		// if flag
		self.flag = flag
	}
	init(){}

	func typeDescription() -> String {
		if let tmp = type {
			switch tmp {
			case CROSS:
				return "|X|"
			case STRAIGHT:	
				return "|=|"
			default:
				return ""
			}
		} else {
			return "undefined"			
		}
	}
}

// Packet class
let PROBE = 0, RUN = 1
class Packet: CustomStringConvertible {
	var id = 0
	var input: Int = 0
	var output: Int = 0
	var curr_se: SE?
	var prev_se: SE?
	var curr_se_port: Int?
	var duration: Int?
	var type = PROBE

	var description: String {
		return "Packet id: \(id) input: \(input) output: \(output)"
	}

	init(id: Int, input: Int, output: Int, type: Int = PROBE) {
		self.type = type
		self.id = id
		self.input = input
		self.output = output
	}
}

// typedef struct packet_t_ {
//     unsigned int id;
//     int input;
//     int output;
//     se* curr_se;
//     se* prev_se;
//     // int prev_se_port;
//     int curr_se_port;
//     int duration;
// } packet_t;

// #define SE_INTER   0
// #define SE_INPUT   1
// #define SE_OUTPUT  2

// typedef struct se_ {
//     int id;
//     struct se_ *out0;
//     struct se_ *out1;
//     struct se_ *in0;
//     struct se_ *in1;
//     int    out0_port;
//     int    out1_port;
//     int    in0_port;
//     int    in1_port;
//     int    flags;
//     void  *packet;
//     int    type;
//     int packet_in0;
//     int packet_in1;