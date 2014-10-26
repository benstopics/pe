#---------------------------- -  -    -        -                
#	Author: Benjamin Ward					
#	Date:	4 Oct 2014					
#	Purpose:						
#	Solution to Project Euler 8				
#								
#	Overview:
#	The four adjacent digits in the 1000-digit number that have the
#	greatest product are 9 × 9 × 8 × 9 = 5832.
#
#	Find the thirteen adjacent digits in the 1000-digit number that
#	have the greatest product. What is the value of this product?
#-------------------- -  -    -        -                	
.data
digitStr:
	.ascii "7316717653133062491922511967442657474235534919493496983520312774506326239578318016984801869478851843858615607891129494954595017379583319528532088055111254069874715852386305071569329096329522744304355766896648950445244523161731856403098711121722383113622298934233803081353362766142828064444866452387493035890729629049156044077239071381051585930796086670172427121883998797908792274921901699720888093776657273330010533678812202354218097512545405947522435258490771167055601360483958644670632441572215539753697817977846174064955149290862569321978468622482839722413756570560574902614079729686524145351004748216637048440319989000889524345065854122758866688116427171479924442928230863465674813919123162824586178664583591245665294765456828489128831426076900422421902267105562632111110937054421750694165896040807198403850962455444362981230987879927244284909188845801561660979191338754992005240636899125607176060588611646710940507754100225698315520005593572972571636269561882670428252483600823257530420752963450"
	len = . - digitStr	# length of the digit string in bytes
largest:
	.quad 0			# symbol to hold largest product found
.global _start
.text     
_start:
	xorq %rcx,%rcx	# i, string index
startloop:
	movq 	%rcx,%rax	# rax = i
	addq	$13,%rax	# rax = i+13
	cmpq	$len,%rax	# if (i+13 > len)
	jg	startend	# break;
	movq	$digitStr,%rbx	# j = *digit
	addq	%rcx,%rbx	# j = *digit + i
	
	# digitStr[0] *= digitStr[1 ... 12]
	xorq	%rax,%rax
	movb	(%rbx),%al	# rax = digitStr[0]
	subq	$0x30,%rax	# rax = rax.toInt()
	pushq	%rcx		# save i
	mulloop:	# multiply loop
		incq	%rcx		# i++;
		movq	$digitStr,%rbx	# j = *digit
		addq	%rcx,%rbx	# j = *digit + i
		movb	(%rbx),%dl	# rdx = digitStr[i+j] // needs fixing
		subq	$0x30,%rdx	# convert digitStr[i+j] to integer

		mulq	%rdx		# multiply rax by rdx
		subq	$digitStr,%rbx	# rbx = i

		movq	%rcx,%rbx	# rbx = i
		subq	(%rsp),%rbx	# rbx = i-oldi

		cmpq	$12,%rbx	# if(j >= 12) // 13th digit for iteration
		jge	mulend		# stop multiply numbers
		jmp	mulloop		# else, multiply next item
	mulend:
		popq	%rcx		# restore i
		cmpq	largest,%rax	# if (product <= largest)
		jle	startnext	# break;
		movq	%rax,largest	# else, replace largest with product
		jmp	startnext	# next iteration
startnext:
	incq	%rcx		# i++;
	jmp	startloop	# next iteration
startend:
	movq	largest,%rax
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
