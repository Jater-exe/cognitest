extends Node

# --- Configuration ---
const MIN_VALUE: int = 1
const MAX_VALUE: int = 20
const LIST_SIZE: int = 10 # Change this to the number of random values you need

func _ready():
	# 1. Initialize the random number generator
	initialize_random_seed()

	# 2. Generate the list
	var random_numbers: Array[int] = generate_random_list(MIN_VALUE, MAX_VALUE, LIST_SIZE)

	# 3. Print the result
	print("Generated Random Numbers:")
	print(random_numbers)
	# Example Output: [18, 5, 20, 1, 14, 8, 10, 19, 3, 16]

	# Another example of generating 5 numbers
	var five_numbers: Array[int] = generate_random_list(1, 20, 5)
	print("Generated 5 Random Numbers:")
	print(five_numbers)


# Function to call once at the start of your game or scene
func initialize_random_seed() -> void:
	# This is crucial! It seeds the random number generator
	# using the current system time, ensuring the sequence of 
	# 'random' numbers is different every time the game runs.
	randomize() 

# Function to generate the list of random integers
func generate_random_list(min_val: int, max_val: int, count: int) -> Array[int]:
	var result_list: Array[int] = []
	
	for i in range(count):
		# randi_range(from, to) is the function that generates a random
		# integer, and importantly, it includes BOTH the 'from' and 'to'
		# values (1 and 20 in your case).
		var number: int = randi_range(min_val, max_val)
		result_list.append(number)
		
	return result_list
