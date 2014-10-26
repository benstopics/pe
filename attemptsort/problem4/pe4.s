#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	28 Sep 2014					
#	Purpose:						
#	Solution to Project Euler 4				
#								
#	Overview:						
#	A palindromic number reads the same both ways. The	
#	largest palindrome made from the product of two 2-digit	
#	numbers is 9009 = 91 × 99.				
#								
#	Find the largest palindrome made from the product of	
#	two 3-digit numbers.					
#-------------------- -  -    -        -                	
.data		

.global _start

.text

#-------------------- -  -    -        -                
#	Although it would have been easier to use global
#	variables, I wanted to write the code so that it
#	could be directly converted into a function.
#	This is to emphasize a reusable coding standard.
#------------ -  -    -        -                
_start:
	# start func proc
	pushq	%rbp		# save rbp
	movq	%rsp,%rbp	# save rsp

	# declare local variables
	subq	$64,%rsp	# alloc 8 quads
	movq	$0,-8(%rbp)	# largest palindrome	//  -8(%rbp) 8*1
	movq	$100,-16(%rbp)	# i			// -16(%rbp) 8*2
	movq	$0,-24(%rbp)	# j			// -24(%rbp) 8*3
	movq	$1,-32(%rbp)	# strlen (num of digits)// -32(%rbp) 8*4
				# 1 for minimum of 1 digit ("0")
	movq	$0,-40(%rbp)	# str pointer and rsp	// -40(%rbp) 8*5
	movq	$0,-48(%rbp)	# stack index mul	// -48(%rbp) 8*6
	#movq	$0,-56(%rbp)	# product AND comparator	// -56(%rbp) 8*7
	movq	$0,-64(%rbp)	# halflen		// -64(%rbp) 8*8

	# loop through products of 3-digit factors
	iloop:
		cmpq	$1000,-16(%rbp)	# if (i >= 1000)
		jge	iloopend

		movq	-16(%rbp),%rax	# copy i,
		movq	%rax,-24(%rbp)	# into j
		jloop:
			cmpq	$1000,-24(%rbp)	# if (j >= 1000)
			jge	iloopnext
			
			# calculate product
			movq	-16(%rbp),%rax	# multiply i,
			imulq	-24(%rbp),%rax	# by j and store in rax
			movq	%rax,-56(%rbp)	# product = newproduct;
			
			# generate digits string for lexical analysis
			movq	$1,-32(%rbp)	# reset strlen
			movq	%rsp,-40(%rbp)	# str* = current top of stack
			subq	$8,-40(%rbp)	# first char will actually be
						# the NEXT quad pushed
			getdigitsloop:
				cmpq	$10,%rax	# while (rax > 10) {
				jl	getdigitsloopend#

				incq	-32(%rbp)	# strlen++;

				movq	$10,%rbx	# mod_rbx function
				xor	%rdx,%rdx	# rax %= rdx;
				divq	%rbx		#

				pushq	%rdx		# push to top of stack
	
				jmp	getdigitsloop	# }
		getdigitsloopend:
			pushq	%rax		# push last digit

			# check for palindrome
			movq	-32(%rbp),%rax	# halflen = len / 2;
			shrq	$1,%rax		#
			movq	%rax,-64(%rbp)	# halflen = newhalflen

			xor	%rcx,%rcx	# strindex
			checkloop:
				cmpq	-64(%rbp),%rcx	# if ( strindex > halflen)
				jg	islargest	# lexical symmetry, check if largest
				
				movq	-40(%rbp),%rbx	# rbx = str* // rbp offset
				movq	%rcx,%rax	# rax = strindex
				shlq	$3,%rax		# rax *= 8 // size of quad register
				subq	%rax,%rbx	# rbx = str[rax]*

				movq	-32(%rbp),%rax	# rax = strlen
				shlq	$3,%rax		# rax *= 8 // size of quad register
				subq	$8,%rax		# rdx = (strlen-(1*8)-strindex // (index of last char) - index
				movq	%rcx,-48(%rbp)	# stack index mul = strindex
				shlq	$3,-48(%rbp)	# stack index mul *= 8 // size of quad register
				subq	-48(%rbp),%rax	#
				movq	-40(%rbp),%rdx	# rdx = str* // rbp offset
				subq	%rax,%rdx	# rdx = str[rax]*

				movq	(%rbx),%rax	# rax = rbx&
				cmpq	(%rdx),%rax	# if (str[strindex] == str[strlen-(index+1)])
							# 	// strlen-1 == last char
				je	checkloopnext	# still could be palindrome, check next two chars

				jmp	jloopnext	# mismatch found, can't be palindrome, break
				
			checkloopnext:
				incq	%rcx		# strindex++;
				jmp	checkloop	# compare next two chars
			islargest:
				movq	-56(%rbp),%rax	# if (product
				cmpq	-8(%rbp),%rax	#	<= largest)
				jle	jloopnext	# not larger, check next product

				movq	%rax,-8(%rbp)	# else, replace largest
				jmp	jloopnext	# check next product
		jloopnext:
			incq	-24(%rbp)	# j++;
			movq	-40(%rbp),%rsp	# restore rsp after first char was allocated
			addq	$8,%rsp		# deallocate first char
			
			jmp	jloop		# check next product
	iloopnext:
		incq	-16(%rbp)	# i++;
		jmp	iloop		# check next 3-digit combo
iloopend:
	movq	-8(%rbp),%rax	# save largest palindrome found in rax
	addq	$64,%rsp	# dealloc 8 local variable quads
	movq	%rbp,%rsp	# restore rsp
	popq	%rbp		# restore rbp	
	
	call	printrax	# prints rax decimal value
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
