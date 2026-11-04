extends GutTest
## 右上の円の下に、曲のパートの項目ごとに、鳴っている大きさの棒と、鳴った瞬間に光るランプを並べる

const JSON_TEXT := (
	'{"frame_rate": 10, "parts": {'
	+ '"vocals": {"level": [0.0, 0.5, 1.0], "onsets": []},'
	+ '"kick": {"level": [0.0, 0.0, 0.0], "onsets": [0.1]}}}'
)


func _make_hud() -> PartHud:
	var hud := PartHud.new()
	hud.track = PartTrack.from_json(JSON_TEXT)
	return add_child_autofree(hud)


func test_項目ごとに名前の行を並べる():
	var hud := _make_hud()
	var labels := ["vocals", "kick"].map(func(p): return hud.get_node("Rows/%s/Name" % p).text)
	assert_eq(labels, ["VOCAL", "KICK"])


func test_棒の長さは鳴っている大きさ():
	var hud := _make_hud()
	hud.show_at(0.15)
	assert_almost_eq(hud.get_node("Rows/vocals/Bar").value, 0.75, 0.001)


func test_鳴った瞬間にランプが光りしばらくすると消える():
	var hud := _make_hud()
	var lamp: ColorRect = hud.get_node("Rows/kick/Lamp")
	hud.show_at(0.1)
	assert_almost_eq(lamp.color.a, 1.0, 0.001)
	hud.show_at(0.1 + PartHud.FLASH_SECONDS)
	assert_almost_eq(lamp.color.a, PartHud.LAMP_OFF_ALPHA, 0.001)


func test_まだ鳴っていない項目のランプは消えている():
	var hud := _make_hud()
	hud.show_at(0.05)
	var lamp: ColorRect = hud.get_node("Rows/kick/Lamp")
	assert_almost_eq(lamp.color.a, PartHud.LAMP_OFF_ALPHA, 0.001)


func test_解析が無ければ行を並べない():
	var hud := PartHud.new()
	hud.track = PartTrack.from_json("")
	add_child_autofree(hud)
	hud.show_at(1.0)
	assert_eq(hud.get_node("Rows").get_child_count(), 0)
