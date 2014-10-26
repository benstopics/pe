as ./$1.s -o ./$1.o
ld $1.o -o $1
chmod +x $1
./$1
