#include <stdio.h>

int main() {
	int i = 1;
	int triangle = i;
	int topdivs = 0;
	while(1) {
		int divs = 0;
		int j = 1;
		for(; j <= triangle; j++) {
			divs += (triangle%j == 0) ? 1 : 0;
		}
		if(divs > topdivs) {
			printf("%d => %d\n", triangle, divs);
			topdivs = divs;
		}
		if (divs > 500) {
			printf("%d", triangle);
			return 0;
		}
		i++;
		triangle += i;
	}
}