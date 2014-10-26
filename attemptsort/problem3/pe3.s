#################################################################
#	Author: Benjamin Ward					#
#	Date:	27 Sep 2014					#
#	Purpose:						#
#	Solution to Project Euler 3				#
#								#
#	Overview:						#
#	The prime factors of 13195 are 5, 7, 13 and 29.		#
#								#
#	What is the largest prime factor of the number		#
#	600851475143 ?						#
#################################################################
.data
bignum:
	.quad 600851475143	# the value of interest
numsqrt:
	.quad 775147		# approximate sqrt rounded up
largest:
	.quad 1			# largest prime factor

.global _start

.text

_start:
	#	setup program
	#------------------------
	movq	$1,%rbx		# factor
startloop:
	incq	%rbx		# factor++;
	#	if factor greater than sqrt(bignum)
	#	all probable factors have been accounted for
	#------------------------
	cmpq	numsqrt,%rbx	# if (factor > sqrt(bignum))
	jg	startend	# break;
	#	if composite, skip factor
	#	do first for speed, division takes longer
	#------------------------
	movq	%rbx,%rax	# exclude all bits but least sig bit
	andq	$1,%rax		# to detect even number
	cmpq	$0,%rax		# if least sig bit = 0 (factor is even),
	je	startloop	# composite, skip factor
	#	if not, check if factor
	#------------------------
	movq	bignum,%rax
	call	mod_rbx		# else, rbx already loaded with factor
	cmpq	$0,%rdx		# if (num%factor != 0) // if not a factor
	jne	startloop	#	skip factor
	#	if factor, check if prime
	#------------------------
	movq	%rbx,%rcx	# save current factor, rbx required for mod_rbx()
	movq	$1,%rbx		# counter (first inc makes it 2)
	checkprime:
		incq	%rbx		# counter++;
		cmpq	%rcx,%rbx	# if (factor >= maxfactor) // no factors found
		jge	isprime		# working backwards, must be largest prime!
		# if still checking,
		movq	%rcx,%rax	# rax = current factor
		call	mod_rbx		# factor %= counter;
		cmpq	$0,%rdx		# if (factor%counter != 0) // if not a factor
		jne	checkprime	#	keep checking
		
		movq	%rcx,%rbx	# restore current factor
		jmp	startloop	# factor found, not prime, skip factor
	isprime:
		movq	%rcx,%rbx	# restore current factor
		cmpq	largest,%rbx	# if (factor <= largest) // not greatest
		jle	startloop	#	skip factor
		movq	%rbx,largest	# else, replace largest prime factor
		jmp	startloop	# check next factor
startend:
	movq	largest,%rax
	call	printrax	# prints rax decimal value
	
	call	_exit		# calls sys_exit

#################################################################
#	Author: Benjamin Ward					#
#	Date:	27 Sep 2014					#
#	Purpose:						#
#	Includes basic functions for programming Project	#
#	Euler solutions in Assembly using the GAS		#
#	assembler provided by GNU/Linux OS.			#
#								#
#	Tested on Ubuntu 14.04.1 x64				#
#								#
#	Functions include:					#
#	_exit(exit_code popq) basic sys_exit call		#
#								#
#	printrax(value rax) prints rax value			#
#								#
#	mod_rbx(dividend rax, divisor dbx) rax %= rbx; function	#
#		ret: quotient rax, remainder rdx		#
#################################################################

#########################################
#	Basic Sys_Exit Call		#
#########################################
.type _exit, @function
_exit:
	mov     $60,%rax       	# system call 60 is exit
        xor     %rdi,%rdi      	# we want return code 0
	syscall			# call kernel
#########################################
#	Print rax Decimal Value		#
#########################################
.type printrax, @function
printrax:
	# save pertinent register's states
	movq	%rax,oldrax
	movq	%rbx,oldrbx
	movq	%rcx,oldrcx
	movq	%rdx,oldrdx
	
	movq	$2,%rcx		# result digit length
				# default value 2,
				# one char for minimum of 1 digit (0)
				# one char for new line byte

	pushq	$10		# push new line char first because
				# bytes will be printed in reverse
pushchars_while:
	cmpq	$10,%rax	# while (rax > 10) {
	jl	pushchars_end	#

	incq	%rcx		# rcx++;

	movq	$10,%rbx	# mod_rbx function
	call	mod_rbx		# rax %= rbx

	addq	$0x30,%rdx	# set remainder byte to numeric char
	pushq	%rdx		# push
	
	jmp	pushchars_while	# }
pushchars_end:
	addq	$0x30,%rax	# set quotient byte to numeric char
	pushq	%rax		# push last digit

print_loop:
	cmpq	$0,%rcx		# while (rcx > 0) {
	jle	print_end	#

	pushq	%rcx		# save rcx
	addq	$8,%rsp		# point rsp to preceding quad

	movq     $1,%rax        # system call 1 is write
        movq     $1,%rdi        # file handle 1 is stdout
        movq     %rsp,%rsi  	# address of string to output
        movq     $1,%rdx       	# number of bytes
        syscall                 # invoke operating system to do the write
	
	subq	$8,%rsp		# point rsp back at old rcx dword
	popq	%rcx		# restore rcx
	decq	%rcx		# rcx--;
	addq	$8,%rsp		# deallocate quad of char that was just printed
	
	jmp	print_loop	# }
print_end:
	# restore pertinent register's states
	movq	oldrax,%rax
	movq	oldrbx,%rbx
	movq	oldrcx,%rcx
	movq	oldrdx,%rdx
	ret
.data
oldrax:
	.quad 0
oldrbx:
	.quad 0
oldrcx:
	.quad 0
oldrdx:
	.quad 0

#########################################
#	rax Modulo rbx Funtion		#
#########################################
.type mod_rbx, @function
mod_rbx:
	xor	%rdx,%rdx	# rax %= rdx;
	divq	%rbx		#
	ret
