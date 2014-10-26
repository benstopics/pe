#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	4 Oct 2014					
#	Purpose:						
#	Solution to Project Euler 9				
#								
#	Overview:
#	A Pythagorean triplet is a set of three natural numbers,
#	a < b < c, for which,
#
#	a^2 + b^2 = c^2
#	For example, 3^2 + 4^2 = 9 + 16 = 25 = 5^2.
#
#	There exists exactly one Pythagorean triplet for which
#	a + b + c = 1000.
#	Find the product abc.
#-------------------- -  -    -        -                	
.data
c:	.quad 1000		# c
b:	.quad 0
a:	.quad 0
.global _start
.text     
_start:	
cloop:
	decq	c		# c--;
	cmpq	$0,c		# if(c == 0), end program
	jle	startend	#
	movq	c,%rax
	movq	%rax,b		# b=c
	bloop:
		decq	b		# b--;
		cmpq	$0,b		# if(b == 0), break
		jle	cloop		#
		movq	b,%rax
		movq	%rax,a		# a=b
		aloop:
			decq	a		# a--;
			cmpq	$0,a		# if(a == 0), break
			jle	bloop		#
			movq	a,%rax		# else, rax = a+b+c
			addq	b,%rax
			addq	c,%rax
			cmpq	$1000,%rax	# if(a+b+c != 1000)
			jne	aloop		# next iteration
			movq	a,%rax
			mulq	a		# rax = a*a
			movq	%rax,%rbx	# rbx = rax
			movq	b,%rax
			mulq	b		# rax = b*b
			addq	%rax,%rbx	# rax = (a*a)+(b*b)
			movq	c,%rax
			mulq	c		# rax = c*c
			cmpq	%rax,%rbx	# if((a*a)+(b*b) != c*c)
			jne	aloop		# next iteration
			movq	a,%rax
			mulq	b
			mulq	c		# else, found it, calculate abc and end program
			jmp	startend		
startend:
	call	printrax	# prints rax unsigned integer value
	call	_exit		# calls sys_exit

#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	4 Oct 2014					
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
	pushq	%rax
	pushq	%rbx
	pushq	%rcx
	pushq	%rdx
	
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
	popq	%rdx
	popq	%rcx
	popq	%rbx
	popq	%rax
	ret

#-------------------- -  -    -        -   
#	rax Modulo rbx Funtion		
#------------ -  -    -        - 
.type mod_rbx, @function
mod_rbx:
	xor	%rdx,%rdx	# rax %= rdx;
	divq	%rbx		#
	ret
