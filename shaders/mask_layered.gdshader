shader_type spatial;

uniform vec4 mask_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D pattern_texture : hint_default_white, filter_linear_mipmap;

void fragment() {
    vec4 pattern_val = texture(pattern_texture, UV);
    vec3 final_color = mask_color.rgb * pattern_val.rgb;
    
    ALBEDO = final_color;
    EMISSION = final_color * 0.5; 
    ROUGHNESS = 0.5;
    METALLIC = 0.0;
}