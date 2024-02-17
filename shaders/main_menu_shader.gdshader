shader_type canvas_item;
uniform sampler2D clouds;
uniform vec4 sep_col: hint_color;

void fragment(){
	float noise_strength = texture(clouds, UV).g;
	
	if (noise_strength > 0.2 && noise_strength < 0.5) {
		COLOR += sep_col;
		COLOR /= 2.0;
	}

}