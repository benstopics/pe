#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	28 Sep 2014					
#	Purpose:						
#	Solution to Project Euler 5				
#								
#	Overview:						
#	The sum of the squares of the first ten natural numbers is,
#
#	1^2 + 2^2 + ... + 10^2 = 385
#	The square of the sum of the first ten natural numbers is,
#
#	(1 + 2 + ... + 10)^2 = 55^2 = 3025
#	Hence the difference between the sum of the squares of the
#	first ten natural numbers and the square of the sum is
#	3025 − 385 = 2640.
#
#	Find the difference between the sum of the squares of the
#	first one hundred natural numbers and the square of the sum.		
#-------------------- -  -    -        -                	
.data		
.global _start
.text      
_start:	# first, find sum of squares of first 100 numbers
	movq	$0,%rcx		# i, number
	xor	%rbx,%rbx	# sum of squares
	push	$0		# square of sum // (%rsp)
loopi:	cmpq	$100,%rcx	# if (i == 100) // added 100^2
	je	end		# exit
	incq	%rcx		# i++
	addq	%rcx,(%rsp)	# sum for square of sum += i;
	movq	(%rsp),%rax
	movq	%rcx,%rax	# rax = i;
	mulq	%rcx		# rax *= i;
	addq	%rax,%rbx	# sum of squares += rax;
	jmp	loopi		# else, next dividend
end:	movq	(%rsp),%rax	# rax = square of sum
	mulq	(%rsp)		# rax *= sum of square of sum
	subq	%rbx,%rax	# reverse subtract to get absolute value of negative number
	call	printrax	# prints rax decimal value, which is actually negative
	call	_exit		# calls sys_exit

#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	27 Sep 2014					
#	Purpose:						
#	Includes basic functions for programming Project	
#	Euler solutions in Assembly using the GAS		
#	assembler provided by GNU/Linux OS.			
#								
#	Tested on Ubuntu 14.04.1 x64				
#								
#	Functions include:					
#	_exit(exit_code popq) basic sys_exit call		
#								
#	printrax(value rax) prints rax value			
#								
#	mod_rbx(dividend rax, divisor dbx) rax %= rbx; function	
#		ret: quotient rax, remainder rdx		
#-------------------- -  -    -        -                	

#-------------------- -  -    -        -                
#	Basic Sys_Exit Call		
#------------ -  -    -        -                
.type _exit, @function
_exit:
	mov     $60,%rax       	# system call 60 is exit
        xor     %rdi,%rdi      	# we want return code 0
	syscall			# call kernel
#-------------------- -  -    -        -    
#	Print rax Decimal Value		
#------------ -  -    -        - 
.type printrax, @function
printrax:
	# save pertinent register's states
	movq	%rax,oldrax
	movq	%rbx,oldrbx
	movq	%rcx,oldrcx
	movq	%rdx,oldrdx
	
	movq	$2,%rcx		# result digit length
				# default value 2,
				# one char for minimum of 1 digit ("0")
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

#-------------------- -  -    -        -   
#	rax Modulo rbx Funtion		
#------------ -  -    -        - 
.type mod_rbx, @function
mod_rbx:
	xor	%rdx,%rdx	# rax %= rdx;
	divq	%rbx		#
	ret
