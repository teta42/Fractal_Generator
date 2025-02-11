#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    vec2 pixelCoord = vec2(gl_FragCoord.xy) / resolution;

    // Центр комплексной плоскости
    vec2 center = vec2(-1.5, 0.0);

    // Экспоненциальный зум
    double zoom = exp(time * 0.55);

    // Соотношение сторон экрана
    double aspectRatio = resolution.x / resolution.y;

    // Преобразование координат пикселя в относительные координаты
    vec2 scaledCoord = (pixelCoord - 0.5) * vec2(3.0 / zoom * aspectRatio, 3.0 / zoom);

    // Комплексное число c
    vec2 c = center + scaledCoord;

    // Начальное значение z = 0 + 0i
    vec2 z = vec2(0.0);

    int maxIterations = 300;
    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < maxIterations) {
        // Вычисление z^2: z^2 = (z.x + i*z.y)^2 = z.x^2 - z.y^2 + 2*z.x*z.y*i
        vec2 z2 = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);

        // Обновление z: z = z^2 + c
        z = z2 + c;

        // Проверка на "уход в бесконечность" (если |z| > 2, точка не принадлежит множеству)
        if (dot(z, z) > 4.0) {
            break;
        }

        iteration++;
    }

    double smoothColor = double(iteration) - log2(log2(dot(z, z))) + 4.0;
    double color = smoothColor / double(maxIterations);
    FragColor = vec4(vec3(float(color)), 1.0);
}