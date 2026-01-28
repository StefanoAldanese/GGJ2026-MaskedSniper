shader_type canvas_item;

// Parametri modificabili da script o inspector
uniform float scope_radius : hint_range(0.0, 1.0) = 0.4; // Dimensione del buco
uniform float softness : hint_range(0.0, 1.0) = 0.05;    // Sfumatura bordi
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Colore nero

void fragment() {
    // Troviamo il centro dello schermo (UV 0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    
    // Calcoliamo la distanza del pixel attuale dal centro
    // Correggiamo l'aspect ratio se necessario, ma per un cerchio semplice questo basta
    float dist = distance(UV, center);
    
    // Creiamo la maschera: 
    // smoothstep crea una transizione morbida tra il raggio e il raggio+sfumatura
    float alpha = smoothstep(scope_radius, scope_radius + softness, dist);
    
    // Applichiamo il colore nero con l'alpha calcolato
    // Se siamo "dentro" il raggio, alpha è 0 (trasparente)
    // Se siamo "fuori", alpha diventa 1 (nero)
    COLOR = vec4(border_color.rgb, alpha);
}