shader_type spatial;

// Colore scelto dal pool (es. Rosso, Blu)
uniform vec4 mask_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Pattern in scala di grigi (es. scacchi, damascato, righe)
// Hint_default_white --> Se manca la texture, usa il bianco
uniform sampler2D pattern_texture : hint_default_white, filter_linear_mipmap;

// Copricapo in sovraimpressione (es. cappello giullare, cilindro)
uniform sampler2D headgear_texture : hint_default_transparent, filter_linear_mipmap;
uniform float headgear_opacity : hint_range(0.0, 1.0) = 0.0;

// Accessorio in sovraimpressione (es. piuma, lacrima, simbolo)
uniform sampler2D accessory_texture : hint_default_transparent, filter_linear_mipmap;
uniform float accessory_opacity : hint_range(0.0, 1.0) = 0.0;


void fragment() {
	// --- FASE 1: LIVELLO BASE ---
	// Preleviamo il valore di grigio dal pattern
	vec4 pattern_val = texture(pattern_texture, UV);
	
	// Moltiplichiamo il colore scelto per il pattern.
	// Se il pattern è bianco -> Colore pieno.
	// Se il pattern è grigio scuro -> Colore scuro (ombreggiatura).
	vec3 base_layer = mask_color.rgb * pattern_val.rgb;
	
	// --- FASE 2: LIVELLO ACCESSORIO (Overlay) ---
	vec4 hat_val = texture(headgear_texture, UV);
	float hat_alpha = hat_val.a * headgear_opacity;
	// Mixiamo il cappello sopra la base
	vec3 layer_after_hat = mix(base_layer, hat_val.rgb, hat_alpha);
	
	// 3. ACCESSORY LAYER (Mix sopra il risultato precedente)
	vec4 acc_val = texture(accessory_texture, UV);
	float acc_alpha = acc_val.a * accessory_opacity;
	// Mixiamo l'accessorio sopra (base + cappello)
	
	// Dove acc_alpha è 0, vediamo il base_layer.
	// Dove acc_alpha è 1, vediamo accessory_val.rgb.
	vec3 final_color = mix(layer_after_hat, acc_val.rgb, acc_alpha);
	
	// --- FASE 3: COMPOSIZIONE ---
	ALBEDO = final_color;
	
	// Impostazioni standard materiale
	ROUGHNESS = 0.5;
	METALLIC = 0.0;
}