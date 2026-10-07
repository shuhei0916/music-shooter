extends GutTest

const NoteScheduler = preload("res://scripts/note_scheduler.gd")


func _note_on(tick: int, velocity: int = 100) -> SMF.MIDIEventChunk:
	return SMF.MIDIEventChunk.new(tick, 0, SMF.MIDIEventNoteOn.new(60, velocity))


func _scheduler(chunks: Array) -> NoteScheduler:
	var events: Array[SMF.MIDIEventChunk] = []
	events.assign(chunks)
	return NoteScheduler.new(events)


func test_指定tick以下のノートを返す():
	var scheduler := _scheduler([_note_on(100)])
	assert_eq(1, scheduler.pop_due(100).size())


func test_指定tickより後のノートを返さない():
	var scheduler := _scheduler([_note_on(100), _note_on(200)])
	assert_eq(1, scheduler.pop_due(150).size())
