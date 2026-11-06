// 背景の光の粒。粒の位置と大きさをすべて頂点シェーダーで求めるので、数万の粒が一斉に音へ反応できる
// MultiMesh の1つぶん：位置は変換の原点、INSTANCE_CUSTOM は r: 粒ごとの乱数、g: 大きさ、b: 2色のどちらに近いか
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled, skip_vertex_transform;

// プレイヤーの位置と、粒が流れた距離。粒は field_length ごとにくり返す
uniform float anchor_z = 0.0;
uniform float scroll = 0.0;
uniform float field_length = 240.0;
uniform float field_behind = 20.0;
// 音の値（MusicVisual）
uniform float kick_age = 1000.0;
uniform float snare = 0.0;
uniform float hihat = 0.0;
uniform float bass = 0.0;
uniform float energy = 0.5;
uniform float spread = 1.0;
uniform float burst = 0.0;
uniform vec3 color_a : source_color = vec3(0.1, 0.75, 1.0);
uniform vec3 color_b : source_color = vec3(0.25, 0.4, 1.0);

// キックのたびにプレイヤーから広がる光の輪の、速さ（m/秒）・太さ（m）・消える速さ
const float WAVE_SPEED = 70.0;
const float WAVE_WIDTH = 10.0;
const float WAVE_DECAY = 2.2;
// 遠くの粒が小さくなりすぎてちらつかないよう、距離に対するこの割合より小さくしない
const float MIN_APPARENT_SIZE = 0.0022;

varying vec3 v_color;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float seed = INSTANCE_CUSTOM.r;
	float size = INSTANCE_CUSTOM.g;
	float tint = INSTANCE_CUSTOM.b;
	float phase = seed * 6.2831;

	// 奥へくり返す位置。rel が 0 でプレイヤーの後ろ、field_length で最も奥
	float rel = mod(origin.z - scroll, field_length);
	vec3 place = origin;
	place.z = anchor_z + field_behind - rel;

	// ゆらぎ、ベースのうねり、セクションによる広がり
	place.x += sin(TIME * 0.2 + phase) * 0.6;
	place.y += cos(TIME * 0.17 + phase) * 0.4 + sin(origin.z * 0.05 + TIME * 0.5) * bass * 1.2;
	place.x *= spread;
	if (place.y < 0.0) {
		place.y *= spread;
	}

	// キックの光の輪
	float distance_to_player = length(vec2(place.x, place.z - anchor_z));
	float ring = (distance_to_player - kick_age * WAVE_SPEED) / WAVE_WIDTH;
	float wave = exp(-ring * ring) * exp(-kick_age * WAVE_DECAY);
	place.y += wave * 0.5;

	// 盛り上がるほど多くの粒が現れる
	float shown = mix(0.45, 1.05, energy);
	float density = 1.0 - smoothstep(shown - 0.1, shown, seed);
	// くり返しの端で粒が急に出たり消えたりしないよう、端で薄くする
	float edge_fade = smoothstep(0.0, 15.0, rel) * (1.0 - smoothstep(field_length - 60.0, field_length, rel));
	// ふだんのまたたき、スネアで光る粒、ハイハットできらめく粒
	float twinkle = 0.75 + 0.25 * sin(TIME * (1.0 + seed * 3.0) + phase);
	float snare_light = snare * step(0.55, fract(seed * 13.7)) * 1.6;
	float hihat_light = hihat * step(0.8, fract(seed * 37.3)) * 4.0;
	float brightness = twinkle * (0.55 + energy * 0.8) + wave * 3.0 + snare_light + hihat_light + burst * 2.0;

	vec3 tone = mix(color_a, color_b, tint);
	v_color = mix(tone, vec3(1.0), clamp(wave * 0.6 + burst * 0.3, 0.0, 0.8)) * brightness * density * edge_fade;

	// カメラのほうを向く四角にする
	vec4 view = VIEW_MATRIX * vec4(place, 1.0);
	float grown = size * (1.0 + bass * 0.5 + wave * 0.8 + burst * 0.5);
	float apparent = max(grown, -view.z * MIN_APPARENT_SIZE) * 2.0;
	VERTEX = view.xyz + vec3(VERTEX.xy * apparent, 0.0);
}

void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	float d2 = dot(centered, centered);
	// 明るい芯と、ぼんやりした光のにじみ
	float core = exp(-d2 * 16.0);
	float halo = exp(-d2 * 3.5) * 0.2;
	float edge = 1.0 - smoothstep(0.7, 1.0, d2);
	ALBEDO = v_color * (1.0 + core * 3.0);
	ALPHA = clamp((core + halo) * edge, 0.0, 1.0);
}
