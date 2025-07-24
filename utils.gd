extends Node

# Formats a number into a string with metric suffixes (K, M, B, T)
func format_number(num):
	if num < 1000:
		return str(num)
	
	var suffixes = ["", "K", "M", "B", "T"] # Kilo, Mega, Giga(Billion), Tera
	var i = 0
	var num_float = float(num)
	
	while num_float >= 1000.0 and i < suffixes.size() - 1:
		num_float /= 1000.0
		i += 1
	
	# Format to one decimal place if it's not a whole number
	if fmod(num_float, 1.0) == 0:
		return str(int(num_float)) + suffixes[i]
	else:
		return "%.1f" % num_float + suffixes[i]
