object ProjectEuler3 {
	def main(args: Array[String]) {
		println(findGreatestPrime(600851475143L))
	}
	def findGreatestPrime(n : Long) : Long = {
		val max = Math.sqrt(n)
		println(max)
		def tail(largest : Long, i:Long) : Long = i match {
			case _ if(i <= max) =>
				tail(if(n%i == 0 && isPrime(i)) i else largest, i+1)
			case _ => largest
		}
		return tail(0, 2)
	}
	def isPrime(n: Long) : Boolean = {
		val max = n/2
		def tail(i : Long) : Boolean = i match {
			case _ if(i <= max) => if(n%i == 0) false else tail(i+1)
			case _ => true
		}
		return tail(2)
	}
}