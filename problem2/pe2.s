#################################################################
#	Author: Benjamin Ward					#
#	Date:	26 Sep 2014					#
#	Purpose:						#
#	Solution to Project Euler 2				#
#								#
#	Overview:						#
#	Each new term in the Fibonacci sequence is generated by	#
#	adding the previous two terms. By starting with 1 and 2,#
#	the first 10 terms will be:				#
#								#
#	1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...			#
#								#
#	By considering the terms in the Fibonacci sequence whose#
#	values do not exceed four million, find the sum of the	#
#	even-valued terms.					#
#################################################################
.data

.text
.globl _start
_start:
	xorl	%eax,%eax	# sum
	movl	$0,%ebx		# prev
	movl	$1,%ecx		# next
startloop:
	xorl	%edx,%edx	# sum of prev and next
	addl	%ebx,%edx	#
	addl	%ecx,%edx	#

	cmpl	$4000000,%edx	# if (count >= 4,000,000)
	jge	startloopend	#	break;

	movl	%ecx,%ebx	# set next as new prev
	movl	%edx,%ecx	# set sum of prev and next to new next,
				# edx is now free to use

	andl	$1,%edx		# exclude all bits except least sig bit
	cmpl	$1,%edx		# if least sig bit is 1 (therefore odd),
	je	startloop	# next iteration
	addl	%ecx,%eax	# else, add new next to sum
	jmp	startloop	# next iteration

startloopend:
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
