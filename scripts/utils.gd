extends Node

# Formats a number into a string with metric suffixes (K, M, B, T)
func format_number(num):
	var value = int(num)

	if value < 1000:
		return str(value)

	var suffixes = ["", "K", "M", "B", "T"] # Kilo, Mega, Giga(Billion), Tera
	var i = 0
	var num_float = float(value)

	while num_float >= 1000.0 and i < suffixes.size() - 1:
		num_float /= 1000.0
		i += 1
	
	return "%.1f" % num_float + suffixes[i]
