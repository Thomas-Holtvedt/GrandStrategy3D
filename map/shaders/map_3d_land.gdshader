shader_type spatial;

// Maps
uniform sampler2D heightmap_image : source_color;
uniform sampler2D terrainmap_image : source_color;
uniform sampler2D normalmap_image : hint_normal;
uniform sampler2D provincemap_image : source_color, filter_nearest;

// Province selector
uniform vec4 province_selected_color : source_color; // Region ID color
uniform vec4 province_highlight_color : source_color; // Color when province selected
uniform vec4 state_selected_color[40] : source_color; // Array of all provinces in state
uniform vec4 state_highlight_color : source_color; // Color when state selected

// Varying variables
varying float height;
varying vec3 world_pos;

// Vertex function, used to adjust the mesh to the heightmap
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_pos.x /= 5632.0; // Same size as mesh
    world_pos.z /= 2112.0; // Same size as mesh
    height = texture(heightmap_image, world_pos.xz).r;
    VERTEX.y += height * 1.0;
    NORMAL = texture(normalmap_image, world_pos.xy).rgb;
}

bool is_state_selected(vec3 provincemap_color) {
    for (int i = 0; i < state_selected_color.length(); i++) {
        if (distance(provincemap_color, state_selected_color[i].rgb) < 0.005) {
            return true;
        }
    }
    return false;
}

void fragment() {
    // Textures
    vec3 terrainmap = texture(terrainmap_image, world_pos.xz).rgb;
    vec3 normalmap = texture(normalmap_image, world_pos.xz).rgb;
    vec3 provincemap = texture(provincemap_image, world_pos.xz).rgb;

    vec3 final_color = terrainmap;

    // Check if the province or territory is selected
    if (distance(provincemap, province_selected_color.rgb) < 0.005) {
        final_color = mix(province_highlight_color.rgb, terrainmap, 0.5);
    } else if (is_state_selected(provincemap)) {
        final_color = mix(state_highlight_color.rgb, terrainmap, 0.5);
    }
 
    
	ALBEDO = final_color;
    NORMAL_MAP = normalmap;
}