/*
    電子的十字背景シェーダー by あるる（きのもと 結衣） @arlez80
    Electric Hatch Background Shader by KINOMOTO Yui @arlez80
    MIT License

    Портировано на Godot 4.x — исправлен синтаксис, оптимизирована логика.
*/
shader_type canvas_item;


uniform float speed        = 0.05;
uniform vec2  scale        = vec2(8.0, 4.5);
uniform float rotate_speed = 1.1;
uniform float line_width   : hint_range(0.0, 1.0) = 0.1;
uniform float line_size    = 0.1;

// hint_color → source_color (Godot 4)
uniform vec4 back_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);

// Вычисляет «яркость» одной линии в точке p
float scan_line(float p) {
    float t = mod(p, line_size) / line_size;
    // -sin даёт пик в середине периода; обрезаем ниже нуля и нормируем
    return max(-sin(t * PI) + line_width, 0.0) / line_width;
}

// Штриховка в направлении dir (±1), вращающаяся со временем
float hatch(vec2 uv, float time, float dir) {
    float angle = time * rotate_speed * dir;
    float c = cos(angle);
    float s = sin(angle);

    // mat2 в Godot 4 принимает столбцы по отдельным vec2
    // column-major: mat2(col0, col1)
    mat2 rot = mat2(vec2(c, s), vec2(-s, c));

    // Центрируем UV, масштабируем и вращаем
    vec2 fuv = rot * ((uv - 0.5) * scale * time * 0.5);

    // Сумма линий по X и Y, модулированная синусом фазы
    float lines = (scan_line(fuv.x) + scan_line(fuv.y)) * sin(time * PI) * 4.0;
    return clamp(lines, 0.0, 1.0);
}

void fragment() {
    // Нормированное время в диапазоне [0, 1) с периодом 0.3 сек
    float time = mod(TIME * speed, 0.3) / 0.3;

    // Два слоя штриховки со сдвигом по фазе и обратным вращением
    float f = clamp(
        hatch(SCREEN_UV, time,                   1.0) +
        hatch(SCREEN_UV, mod(time + 0.5, 1.0),  -1.0),
        0.0, 1.0
    );

    COLOR = mix(back_color, line_color, f);
}