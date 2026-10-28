class_name Judge
extends RefCounted

enum Result { PLAYING, CLEARED, GAME_OVER }


static func result(course: Course, health: Health) -> Result:
	if health.is_dead():
		return Result.GAME_OVER
	if course.is_finished():
		return Result.CLEARED
	return Result.PLAYING
