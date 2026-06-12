shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness = 8.0;

uniform vec4 fill_color : source_color = vec4(1.0);
uniform float fill_opacity = 1.0;

uniform float alpha_threshold = 0.1;

// --------------------
// GLOW
// --------------------
uniform vec4 glow_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform float glow_radius = 12.0;
uniform float glow_strength = 1.5;

// качество glow
uniform int glow_directions = 32;
uniform int glow_quality = 8;

// Функция правильного смешивания слоев (Alpha Compositing)
// Устраняет "грязные" края и засветы на стыке обводки и свечения
vec4 blend_layers(vec4 top, vec4 bottom) {
    float out_a = top.a + bottom.a * (1.0 - top.a);
    if (out_a == 0.0) {
        return vec4(0.0);
    }
    vec3 out_rgb = (top.rgb * top.a + bottom.rgb * bottom.a * (1.0 - top.a)) / out_a;
    return vec4(out_rgb, out_a);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec2 texel = TEXTURE_PIXEL_SIZE;
    float alpha = tex.a;

    // ==================================================
    // FILL
    // ==================================================
    float fill_mask = step(alpha_threshold, alpha);
    vec4 fill = fill_color;
    fill.a *= alpha * fill_opacity;

    // ==================================================
    // OUTLINE
    // ==================================================
    float outline = 0.0;
    vec2 o = texel * outline_thickness;
    
    // Прямые направления
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2( o.x, 0.0)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2(-o.x, 0.0)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2(0.0,  o.y)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2(0.0, -o.y)).a));

    // Диагональные направления
    vec2 d = o * 0.707106; 
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2( d.x,  d.y)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2(-d.x,  d.y)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2( d.x, -d.y)).a));
    outline = max(outline, step(alpha_threshold, texture(TEXTURE, UV + vec2(-d.x, -d.y)).a));

    float outline_only = outline * (1.0 - fill_mask);
    vec4 out_col = vec4(outline_color.rgb, outline_color.a * outline_only);

    // ==================================================
    // PREMIUM SOFT GLOW
    // ==================================================
    float glow = 0.0;
    float total_weight = 0.0;

    for (int i_dir = 0; i_dir < glow_directions; i_dir++) {
        float angle = float(i_dir) * 6.28318530718 / float(glow_directions);
        vec2 dir = vec2(cos(angle), sin(angle));

        for (int i_qual = 1; i_qual <= glow_quality; i_qual++) {
            float t = float(i_qual) / float(glow_quality);
            float dist = glow_radius * t;
            vec2 offset = dir * dist * texel;
            float sample_alpha = texture(TEXTURE, UV + offset).a;

            // Истинное Гауссово затухание (Bell Curve)
            // Квадрат `t * t` делает свечение густым у основания и мягко растворяющимся на концах
            float weight = exp(-(t * t) * 5.0);

            glow += sample_alpha * weight;
            total_weight += weight;
        }
    }

    glow /= total_weight;
    
    // Мягкая интерполяция, предотвращающая резкие обрывы пикселей
    glow = smoothstep(0.0, 1.0, glow);
    
    glow *= glow_strength;
    glow = clamp(glow, 0.0, 1.0);

    // Убираем свечение внутри объекта
    glow *= (1.0 - fill_mask);

    vec4 glow_layer = vec4(glow_color.rgb, glow_color.a * glow);

    // ==================================================
    // FINAL COMPOSITION
    // ==================================================
    // Собираем слои как в Photoshop: Свечение -> Обводка -> Заливка
    vec4 base_layer = glow_layer;
    vec4 outline_layer = blend_layers(out_col, base_layer);
    vec4 final_color = blend_layers(fill, outline_layer);

    COLOR = final_color;
}