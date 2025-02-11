#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    vec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Центр комплексной плоскости (глобальные координаты)
    dvec2 center = dvec2(-1.45, 0.0); // Точка, к которой приближаемся

    // Экспоненциальный зум
    double zoom = exp(time * 0.35);

    // Соотношение сторон экрана
    double aspectRatio = resolution.x / resolution.y;

    // Преобразование координат пикселя в относительные координаты
    dvec2 scaledCoord = (dvec2(pixelCoord - 0.5) * dvec2(3.0 / zoom * aspectRatio, 3.0 / zoom));

    // Локальные координаты точки на комплексной плоскости
    dvec2 c = center + scaledCoord;

    // Начальное значение z = 0 + 0i
    dvec2 z = dvec2(0.0, 0.0);

    int maxIterations = 300;
    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < maxIterations) {
        // Вычисление z^2: z^2 = (z.x + i*z.y)^2 = z.x^2 - z.y^2 + 2*z.x*z.y*i
        dvec2 z2 = dvec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);

        // Обновление z: z = z^2 + c
        z = z2 + c;

        // Проверка на "уход в бесконечность" (если |z| > 2, точка не принадлежит множеству)
        if (z.x * z.x + z.y * z.y > 4.0) {
            break;
        }

        iteration++;
    }

    // Плавное окрашивание для более красивого результата
    float smoothColor = float(iteration) - log2(log2(float(z.x * z.x + z.y * z.y))) + 4.0;
    float color = smoothColor / float(maxIterations);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}