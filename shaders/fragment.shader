#version 330 core

// Выходной цвет пикселя
out vec4 FragColor;

// Uniform-переменные
uniform float time; // Время в секундах

// Параметры фрактала
const vec2 u_center = vec2(-1.5, 0.0); // Центр окна (cx, cy)
float u_zoom = exp(time * -0.5);       // Масштаб (чем меньше, тем больше увеличение)
const int u_maxIter = 500;             // Максимальное количество итераций
const float u_scale = 1e6;             // Масштаб для фиксированной точки
const float ESCAPE_RADIUS = 4.0;       // Радиус выхода из множества

// Преобразование в фиксированную точку
vec2 to_fixed_point(vec2 value, float scale) {
    return value * scale;
}

// Преобразование из фиксированной точки
vec2 from_fixed_point(vec2 value, float scale) {
    return value / scale;
}

// Функция для вычисления множества Мандельброта с линейной интерполяцией
float mandelbrot(vec2 c) {
    vec2 z = vec2(0.0, 0.0); // Начальное значение z = 0
    int iteration = 0;

    // Итерации: z = z^2 + c
    while (dot(z, z) <= ESCAPE_RADIUS && iteration < u_maxIter) {
        // z^2 = (x + yi)^2 = (x^2 - y^2) + 2xyi
        float x = z.x * z.x - z.y * z.y + c.x;
        float y = 2.0 * z.x * z.y + c.y;
        z = vec2(x, y);
        iteration++;
    }

    // Линейная интерполяция для сглаживания цвета
    float magnitude = dot(z, z); // Квадрат модуля z
    float minVal = 0.0;          // Минимальное значение для интерполяции
    float maxVal = ESCAPE_RADIUS; // Максимальное значение для интерполяции

    // Линейная интерполяция
    float smoothColor = float(iteration) - mix(0.0, 1.0, clamp((magnitude - minVal) / (maxVal - minVal), 0.0, 1.0)) + 4.0;

    return smoothColor;
}

void main() {
    // Преобразование координат пикселя в локальную систему координат
    vec2 fragCoord = gl_FragCoord.xy; // Координаты текущего пикселя
    vec2 resolution = vec2(800.0, 600.0); // Разрешение экрана (замените на ваше)
    vec2 localCoord = (fragCoord / resolution - 0.5) * u_zoom;

    // Преобразование в глобальные координаты фрактала
    vec2 c = u_center + localCoord;

    // Применение фиксированной точки
    vec2 c_fixed = to_fixed_point(c, u_scale);
    c = from_fixed_point(c_fixed, u_scale);

    // Вычисление множества Мандельброта с интерполяцией
    float smoothColor = mandelbrot(c);

    // Нормализация сглаженного цвета
    float color = smoothColor / float(u_maxIter);
    FragColor = vec4(vec3(color), 1.0); // Градиент от черного к белому
}