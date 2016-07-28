// pad some zeros before the string if necessary to display binary number in proper way
extension String {
	func pad(length: Int) -> String {
		let tmp = String(repeating: Character("0"), count: length - self.characters.count) + self
		return tmp
	}
}