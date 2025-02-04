#version 330 core

out vec4 fragColor; // Выходной цвет фрагмента

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

void main() {
    // Нормализуем координаты пикселя (от 0 до 1)
    vec2 uv = gl_FragCoord.xy / resolution;

    // Цвет пикселя, изменяющийся со временем
    vec3 col = 0.5 + 0.5 * cos(time + uv.xyx + vec3(0, 2, 4));

    // Вывод цвета на экран
    fragColor = vec4(col, 1.0);
}
