shader_type spatial;

//Color
uniform vec3 water_color : source_color;
uniform vec3 ground_color : source_color;
//Maps
uniform sampler2D watermap_image : source_color;
//Textures
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
//varying variables
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_pos.x /= 5632.0;
	world_pos.z /= 2112.0;
}

void fragment() {
	vec3 normal1 = texture(texture_normal, world_pos.xz*40.0 + (TIME * vec2(2.0, 0.1)) * 0.05).rgb; //direction and speed
	vec3 normal2 = texture(texture_normal2, world_pos.xz*40.0 + (TIME * vec2(0.0, 1.0)) * 0.05).rgb; //direction and speed
	vec3 normal_blend = mix(normal1 , normal2, 0.5);
	
	//Textures
	vec3 watermap = texture(watermap_image, world_pos.xz).rgb;
	vec3 watermap1 = mix(ground_color, watermap, 0.6);
	vec3 water = mix(water_color, watermap1, 0.2);
	ALBEDO = water;
	ROUGHNESS = 0.02;
	NORMAL_MAP = normal_blend;
}