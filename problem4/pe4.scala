import util.control.Breaks._

object ProjectEuler4 {
	def main(args: Array[String]) {
		var largest = 0
		for (i <- 100 to 999) for (j <- 100 to 999)
			if(isPalindrome(i*j) && i*j > largest) {
				largest = i*j
			}
		println(largest)
	}
	def isPalindrome(n : Int) : Boolean = {
		val list1 = n.toString.map(_.asDigit).toList
		val halfLen = list1.length/2
		val left = list1.take(halfLen)
		val right = list1.reverse.take(halfLen)
		if(left == right) return true else return false
	}
}