shader_type spatial;

uniform sampler2D height_map;
uniform float height_scale = 10.0;

vec3 getNormal(vec2 uv, float texelSize) {
	float t = texture(height_map, uv + vec2(texelSize * vec2(0.0, -1.0))).r * height_scale;
	float r = texture(height_map, uv + vec2(texelSize * vec2(1.0, 0.0))).r * height_scale;
	float l = texture(height_map, uv + vec2(texelSize * vec2(-1.0, 0.0))).r * height_scale;
	float b = texture(height_map, uv + vec2(texelSize * vec2(0.0, 1.0))).r * height_scale;

	return -normalize(vec3(2.0 * (r - l), 2.0 * (b - t), -4.0));
}

void vertex() {
	float height = texture(height_map, UV).x * height_scale;
	VERTEX.y += height;
	NORMAL = getNormal(UV, 1.0 / float(textureSize(height_map, 0).x));
}

void fragment() {
	ALBEDO = vec3(.5, 0, 0);
}
