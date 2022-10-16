extends Node2D

func _ready():
#	var test = create_pool()
	var a_list = [1,2,3,1,2,3]
	print(shuffle_two_blocks(a_list))

func shuffle_two_blocks(non_randomised_list):
	var block1 = non_randomised_list.slice(0,2)
	var block2 = non_randomised_list.slice(3,5)
	block1.shuffle()
	block2.shuffle()
	return block1+block2

func _process(delta):
	pass

func get_auto_idx(a_nb,limit):
	var result = 0
	for i in range(0,a_nb):
		result+=1
		if result > limit-1:
			result = 0
	return result

func create_pool():
	var pool = []
	var probability = 0.3
	var target = 72
	var amount_non_threat = int(target*probability)
	var amount_threat = int(target - amount_non_threat)
	for i in range(0,int(target*probability)):
		pool.append(false)
	for i in range(0,int(target - amount_non_threat)):
		pool.append(true)
	pool.shuffle()
	return pool
