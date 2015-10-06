object ProjectEuler1 {
	def main(args: Array[String]) {
		val multsOf3And5 = ((3 until 1000 by 3).toList ::: (5 until 1000 by 5).toList).distinct
		println(multsOf3And5.foldLeft(0)(_ + _))
	}
}