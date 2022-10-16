extends Node # useful functions used by other scripts # MIGHT BE USELESS NOW

func distance_btw_vec(vec1,vec2):
	# input: vector 1, vector2
	# output: distance (here in pixels) between those vectors
	var distance_x = pow((vec1[0]-vec2[0]),2)
	var distance_y = pow((vec1[1]-vec2[1]),2)
	var distance_vec1_vec2 = sqrt(distance_x + distance_y)
	return distance_vec1_vec2

func get_vector_difference(ref_vec,vec):
	var get_diff_x = vec.x - ref_vec.x
	var get_diff_y = vec.y - ref_vec.y
	return Vector2(get_diff_x,get_diff_y)

func get_next_position(a_position,a_speed,a_rotation,a_delta):
	var next_x = a_position.x + a_speed * a_delta * cos(a_rotation)
	var next_y = a_position.y + a_speed * a_delta * sin(a_rotation)
	return Vector2(next_x,next_y)

func time_to_target(vec1,vec2,object_speed):
#	return distance_btw_vec(vec1,vec2) / object_speed
#	prints(vec1.distance_to(vec2),"div by",object_speed,"=",(vec1.distance_to(vec2))/object_speed)
#	print("before:",distance_btw_vec(vec1,vec2) / object_speed)
	return (vec1.distance_to(vec2))/object_speed

func sanitize_str(string):
	var new_str = string.replace("\n"," ")
	new_str = new_str.replace(","," ")
	return new_str

func find_in_nested(array,element):
	var i = 0
	for n in array:
#		for v in n:
		if element in n:
			return i
		i += 1
	return null

#func shuffleList(list):
#	var shuffledList = []
#	var indexList = range(list.size())
#	for i in range(list.size()):
#		# randomize()
#		var x = randi()%indexList.size()
#		shuffledList.append(list[x])
#		indexList.remove(x)
#		list.remove(x)
#	return shuffledList
