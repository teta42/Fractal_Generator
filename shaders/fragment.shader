#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

// Центр комплексной плоскости (глобальные координаты)
dvec2 center = dvec2(-1.55, 0.0); // Точка, к которой приближаемся

const float ESCAPE_RADIUS = 4.0;
const float ZOOM_SPEED = 0.25;
const int MAX_ITERATIONS = 200;

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    dvec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Экспоненциальный зум
    double zoom = exp(time * ZOOM_SPEED);

    // Соотношение сторон экрана
    double aspectRatio = resolution.x / resolution.y;

    // Преобразование координат пикселя в относительные координаты
    dvec2 scaledCoord = (dvec2(pixelCoord - 0.5) * dvec2(3.0 / zoom * aspectRatio, 3.0 / zoom));

    // Локальные координаты точки на комплексной плоскости
    dvec2 c = center + scaledCoord;

    // Начальное значение z = 0 + 0i
    dvec2 z = dvec2(0.0, 0.0);

    int iteration = 0;

    double zSquared = 0.0; // Квадрат модуля z
    while (iteration < MAX_ITERATIONS) {
        // Вычисление z^2 + c
        z = dvec2(z.x * z.x - z.y * z.y + c.x, 2.0 * z.x * z.y + c.y);

        // Обновление квадрата модуля z
        zSquared = z.x * z.x + z.y * z.y;

        // Проверка на "уход в бесконечность"
        if (zSquared > ESCAPE_RADIUS) {
            break;
        }

        iteration++;
    }

    // Линейная интерполяция вместо логарифмов
    double magnitude = zSquared;
    float minVal = 0.0; // Минимальное значение для интерполяции
    float maxVal = ESCAPE_RADIUS; // Максимальное значение для интерполяции (ESCAPE_RADIUS)

    // Линейная интерполяция
    double smoothColor = double(iteration) - clamp((magnitude - minVal) / (maxVal - minVal), 0.0, 1.0) + 4.0;
    double color = smoothColor / double(MAX_ITERATIONS);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}