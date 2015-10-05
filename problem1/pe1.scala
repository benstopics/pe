object ProjectEuler1 {
	def main(args: Array[String]) {
		/*val sum = 0
		for (i <- 0 until 1000 by 5) {
			sum += i +
		}*/
		println(isMultiple(5));
		println(isMultiple(10));
		println(isMultiple(15));
		println(isMultiple(3));
		println(isMultiple(6));
		println(isMultiple(9));
		println(isMultiple(2));
		println(isMultiple(4));
		println(isMultiple(7));
	}
	def isMultiple(n: Int): Boolean = n match {
		case _ if n % 3 == 0 || n % 5 == 0 => true
		case _ => false
	}
}