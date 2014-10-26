#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	29 Sep 2014					
#	Purpose:						
#	Solution to Project Euler 7				
#								
#	Overview:
#	By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13,
#	we can see that the 6th prime is 13.
#
#	What is the 10 001st prime number?		
#-------------------- -  -    -        -                	
.data
nthprime:
	.quad	0	# n'th prime, start at 1 because i starts at 2, which is the first prime
.global _start
.text      
_start:
	movq	$1,%rbx		# i, current number, first inc makes it 2
startloop:
	cmpq	$10001,nthprime	# if (nthprime == 6)
	je	startend	# break;

	incq	%rbx		# i++;

	# Borrowed code from pe3.s solution
	movq	%rbx,%rcx	# save i, rbx required for mod_rbx()
	movq	$1,%rbx		# counter (first inc makes it 2)
	checkprime:
		incq	%rbx		# i++;
		cmpq	%rcx,%rbx	# if (factor >= maxfactor) // no factors found
		jge	isprime		# working backwards, must be largest prime!
		# if still checking,
		movq	%rcx,%rax	# rax = i
		call	mod_rbx		# factor %= i;
		cmpq	$0,%rdx		# if (factor%i != 0) // if not a factor
		jne	checkprime	#	keep checking
		
		movq	%rcx,%rbx	# restore i
		jmp	startloop	# factor found, not prime, skip factor
	isprime:
		movq	%rcx,%rbx	# restore i
		incq	nthprime	# nthprime++;
		jmp	startloop	# check next factor
startend:
	movq	%rbx,%rax
	call	printrax	# prints rax unsigned integer value
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
