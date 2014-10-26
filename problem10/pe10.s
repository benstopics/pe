#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	5 Oct 2014					
#	Purpose:						
#	Solution to Project Euler 10			
#								
#	Overview:
#	The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.
#
#	Find the sum of all the primes below two million.
#-------------------- -  -    -        -                	
.data
sum:
	.quad 	0	# sum
.global _start
.text      
_start:
	movq	$1,%rbx		# i, current number, first inc makes it 2
startloop:
	cmpq	$1999999,%rbx	# if (nthprime >= 1999999) // break if greater than two million
	jge	startend	# break;

	incq	%rbx		# i++;

	# Borrowed code from pe3.s solution
	pushq	%rbx		# save i, rbx required for mod_rbx()
	movq	%rbx,%rcx	# rcx = half_i, maxfactor
	shrq	$1,%rcx		# rcx = i/2
	movq	$1,%rbx		# counter (first inc makes it 2)
	checkprime:
		incq	%rbx		# i++;
		cmpq	%rcx,%rbx	# if (factor > maxfactor) // no factors found
		jg	isprime		# working backwards, must be largest prime!
		# if still checking,
		movq	(%rsp),%rax	# rax = i
		call	mod_rbx		# factor %= i;
		cmpq	$0,%rdx		# if (factor%i != 0) // if not a factor
		jne	checkprime	#	keep checking
		
		popq	%rbx		# restore i
		jmp	startloop	# factor found, not prime, skip factor
	isprime:
		popq	%rbx		# restore i
		addq	%rbx,sum	# sum += i;
		jmp	startloop	# check next factor
startend:
	movq	sum,%rax
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
