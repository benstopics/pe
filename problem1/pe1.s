#################################################################
#	Author: Benjamin Ward					#
#	Date:	26 Sep 2014					#
#	Purpose:						#
#	Solution to Project Euler 1				#
#								#
#	Overview:						#
#	If we list all the natural numbers below 10 that are	#
#	multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of	#
#	these multiples is 23.					#
#								#
#	Find the sum of all the multiples of 3 or 5 below 1000.	#
#################################################################
.data
sum:
	.long	0		# sum variable
count:
	.long	2		# counter variable, start at 2
				# because first increment will
				# make it 3, which is the first
				# evenly divisible number

.text
.globl _start
_start:
startloop:
	incl	count		# increment count
	cmpl	$1000,count	# if (count >= 1000)
	jge	startloopend	#	break;
	
	movl	count,%eax	# first argument: dividend
	movl	$3,%ebx		# second argument: divisor
	call	mod_ebx		# eax %= ebx, (return: quotient eax, remainder edx)

	cmpl	$0,%edx		# if 3 divides evenly into count (remainder 0),
	je	addcounttosum	# add count to sum

	movl	$5,%ebx		# else, change divisor to 5
	movl	count,%eax	# reset dividend to count
	call	mod_ebx		# eax %= ebx, (return: quotient eax, remainder edx)
	cmpl	$0,%edx		# if 5 divides evenly into count (remainder 0),
	je	addcounttosum	# add count to sum

	jmp	startloop	# else, next iteration
addcounttosum:
	movl	count,%eax	# reduce memory references
	addl	%eax,sum	# add count to sum
	call	startloop	# next iteration

startloopend:
	movl	sum,%eax	# prepare eax to print sum
	call	printeax	# prints eax decimal value
	
	call	_exit		# calls sys_exit, returns top of stack

#################################################################
#	Author: Benjamin Ward					#
#	Date:	26 Sep 2014					#
#	Purpose:						#
#	Includes basic functions for programming Project	#
#	Euler solutions in Assembly using the GAS		#
#	assembler provided by GNU/Linux OS.			#
#								#
#	All functions self contained.				#
#	.data section not used.					#
#								#
#	Tested on Debian 6.0.6 x86				#
#								#
#	Functions include:					#
#	_exit(exit_code popl) basic sys_exit call		#
#								#
#	printeax(value eax) prints eax value			#
#								#
#	mod_ebx(dividend eax, divisor dbx) eax %= ebx; function	#
#		ret: quotient eax, remainder edx		#
#################################################################

#########################################
#	Basic Sys_Exit Call		#
#########################################
.type _exit, @function
_exit:
	movl	$0,%ebx		# first argument: exit code
	movl    $0x01,%eax	# system call number (sys_exit)
	int     $0x80		# call kernel

#########################################
#	Print EAX Decimal Value		#
#########################################
.type printeax, @function
printeax:
	movl	$2,%ecx		# result digit length
				# default value 2,
				# one char for minimum of 1 digit (0)
				# one char for new line byte

	pushl	$10		# push new line char first because
				# bytes will be printed in reverse
pushchars_while:
	cmpl	$10,%eax	# while (eax > 10) {
	jle	pushchars_end	#

	incl	%ecx		# ecx++;

	movl	$10,%ebx	# mod_ebx function
	call	mod_ebx		# eax %= ebx

	addl	$0x30,%edx	# set remainder byte to numeric char
	pushl	%edx		# push
	
	jmp	pushchars_while	# }
pushchars_end:
	addl	$0x30,%eax	# set quotient byte to numeric char
	pushl	%eax		# push last digit

print_loop: # print char
	cmpl	$0,%ecx		# while (ecx > 0) {
	jle	print_end	#

	pushl	%ecx		# save ecx
	addl	$4,%esp		# point esp to preceding dword

	movl    $4,%edx		# third argument: message length
	movl	%esp,%ecx	# second argument: pointer to dword below %ecx dword
	movl    $1,%ebx		# first argument: file handle (stdout)
	movl    $0x04,%eax	# system call number (sys_write)
	int     $0x80		# call kernel
	
	subl	$4,%esp		# point esp back at old ecx dword
	popl	%ecx		# restore ecx
	decl	%ecx		# ecx--;
	addl	$4,%esp		# deallocate dword of char that was just printed
	
	jmp	print_loop	# }
print_end:
	ret

#########################################
#	EAX Modulo EBX Funtion		#
#########################################
.type printeax, @function
mod_ebx:
	movl	$0,%edx		# eax %= edx;
	divl	%ebx		#
	ret
