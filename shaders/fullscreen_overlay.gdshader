shader_type canvas_item;

// --- УПРАВЛЕНИЕ ИЗ КОДА ---
uniform vec3 light_color : source_color = vec3(0.8, 0.7, 0.2);// Только цвет (RGB)
uniform float global_alpha : hint_range(0.0, 1.0) = 0.4;          // Главный ползунок прозрачности

// --- НАСТРОЙКИ РАССЕИВАНИЯ (СВЕТА) ---
uniform float base_glow : hint_range(0.0, 1.0) = 0.4;       // Плотность "тумана" (фоновый свет)
uniform float ray_intensity : hint_range(0.0, 3.0) = 1.2;   // Яркость самих лучей
uniform float ray_smoothness : hint_range(0.1, 10.0) = 3.5; // Насколько сильно размыты лучи (больше = мягче)
uniform float speed : hint_range(0.0, 2.0) = 0.15;          // Плавная скорость течения

// --- ГЕОМЕТРИЯ СВЕТА ---
uniform vec2 light_pos = vec2(0.5, -0.2); // Точка излучения (0.5 - центр, -0.2 - чуть выше экрана)
uniform float falloff_radius : hint_range(0.1, 3.0) = 1.5;  // Радиус затухания света от источника
uniform float depth_fade_power : hint_range(0.1, 5.0) = 1.5;// Как быстро темнота сгущается на дне

// Качественный псевдорандом для шума и дизеринга
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Плавный 2D шум
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // Smoothstep интерполяция
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Многослойный шум (FBM) - 5 октав для "дорогой" детализации
float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    // Вращение матрицы для устранения артефактов сетки шума
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < 5; ++i) { 
        v += a * noise(p);
        p = rot * p * 2.0;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV;
    vec2 delta = uv - light_pos;
    float dist = length(delta);
    float angle = atan(delta.x, delta.y); // Переход в полярные координаты

    // 1. Органичное искажение: лучи слегка изгибаются, имитируя толщу воды
    float wave = sin(dist * 2.0 - TIME * speed * 0.5) * 0.05;
    angle += wave;

    // 2. Генерация мягких лучей
    vec2 ray_uv = vec2(angle * ray_smoothness, dist * 0.6 - TIME * speed);
    float rays = fbm(ray_uv * 2.5);
    
    // Срезаем жесткие края, оставляем только самые мягкие градиенты
    rays = smoothstep(0.2, 0.8, rays);

    // 3. Микро-взвесь (пыль/планктон), которая делает среду объемной
    vec2 dust_uv = uv * 3.0 + vec2(sin(TIME * speed * 0.3) * 0.5, TIME * speed);
    float dust = fbm(dust_uv) * 0.15; // Очень легкий эффект

    // 4. Формируем тело света
    float light_volume = base_glow + (rays * ray_intensity) + dust;

    // 5. Правильное физическое затухание (Falloff)
    // Свет теряет силу по радиусу от источника
    float radial_fade = 1.0 - smoothstep(0.0, falloff_radius, dist);
    // Свет поглощается толщей воды (уходит в тень к низу)
    float depth_fade = 1.0 - pow(uv.y, depth_fade_power);
    // Мягкая виньетка по краям, чтобы свет не обрывался экраном
    float vignette = smoothstep(1.5, 0.2, dist);

    float final_intensity = light_volume * radial_fade * depth_fade * vignette;

    // 6. Дизеринг (Dithering) - СЕКРЕТ "ДОРОГОГО" ШЕЙДЕРА
    // Добавляет микроскопический шум на пиксельном уровне, чтобы убить "бандинг" (полосы на градиентах)
    float dither = (hash(FRAGCOORD.xy) - 0.5) * 0.03;
    final_intensity = clamp(final_intensity + dither, 0.0, 1.0);

    // 7. Вывод: Применяем чистый цвет и управляем общей прозрачностью
    COLOR = vec4(light_color, final_intensity * global_alpha);
}