.global main
main:
	li a4, 0
	li a3, 0
	li a2, 0
	li a2, 10
	add a4, a3, a4
	addi a3, a3, 1
	blt a3, a2, addloop
	bge a3, a2, exit

addloop:
	add a4, a3, a4
	addi a3, a3, 1
	blt a3, a2, addloop
	bge a3, a2, exit

exit:
	add a0, a4, x0
	ret
