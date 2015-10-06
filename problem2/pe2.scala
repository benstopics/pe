object ProjectEuler2 {
	def main(args: Array[String]) {
		println(fibbSumEven(4000000))
	}
	def fibbSumEven(untilNum : Int) : Int = {
		def tail(goingSum : Int, a:Int, b:Int) : Int = a match {
			case _ if(a < untilNum) => tail(goingSum+(if(a%2 == 0) a else 0), b, a+b)
			case _ => goingSum
		}
		return tail(0, 0, 1)
	}
}