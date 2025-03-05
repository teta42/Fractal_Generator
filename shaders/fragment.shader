#version [version] core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах
uniform [0] zoom;  // Экспоненциальный зум
// Центр комплексной плоскости (глобальные координаты)
uniform [1] center; // Точка, к которой приближаемся

// Соотношение сторон экрана
uniform float aspectRatio;

uniform float ESCAPE_RADIUS;
uniform int MAX_ITERATIONS;

// Выходной цвет
out vec4 FragColor;

[0] color([0] zSquared, int iteration) {
    // Линейная интерполяция вместо логарифмов
    [0] magnitude = zSquared;
    float minVal = 0.0; // Минимальное значение для интерполяции
    float maxVal = ESCAPE_RADIUS; // Максимальное значение для интерполяции (ESCAPE_RADIUS)

    [0] denominator = maxVal - minVal;
    if (denominator == 0.0) {
        denominator = 1.0;
    }

    [0] smoothColor = [0](iteration) - clamp((magnitude - minVal) / denominator, 0.0, 1.0) + 4.0;
    [0] color = smoothColor / [0](MAX_ITERATIONS);

    return color;
}

// Функция для умножения двух комплексных чисел
[1] complexMultiply([1] z1, [1] z2) {
    // Действительная часть: z1.x * z2.x - z1.y * z2.y
    [0] realPart = z1.x * z2.x - z1.y * z2.y;

    // Мнимая часть: z1.x * z2.y + z1.y * z2.x
    [0] imaginaryPart = z1.x * z2.y + z1.y * z2.x;

    // Возвращаем результат как [1]
    return [1](realPart, imaginaryPart);
}

// Функция для возведения комплексного числа в целую степень
[1] complexPow([1] z, int power) {
    // Начальное значение: z^0 = 1 + 0i
    [1] result = [1](1.0, 0.0);

    // Если степень равна 0, возвращаем 1 + 0i
    if (power == 0) {
        return result;
    }

    // Если степень отрицательная, инвертируем число
    if (power < 0) {
        [0] denominator = z.x * z.x + z.y * z.y; // |z|^2
        z = [1](z.x / denominator, -z.y / denominator); // z = 1 / z
        power = -power; // Делаем степень положительной
    }

    // Итеративное возведение в степень с использованием complexMultiply
    for (int i = 0; i < power; i++) {
        result = complexMultiply(result, z); // Умножаем результат на z
    }

    return result;
}

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    [1] pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Преобразование координат пикселя в относительные координаты
    [1] scaledCoord = ([1](pixelCoord - 0.5) * [1](3.0 / zoom * aspectRatio, 3.0 / zoom));

    // Локальные координаты точки на комплексной плоскости
    [1] c = center + scaledCoord;

    // Начальное значение z = 0 + 0i
    [1] z = [1](0.0, 0.0);

    int iteration = 0;

    [0] zSquared = 0.0; // Квадрат модуля z
    while (iteration < MAX_ITERATIONS) {
        // Вычисление z^2 + c
        z = [Formula];

        // Обновление квадрата модуля z
        zSquared = z.x * z.x + z.y * z.y;

        // Проверка на "уход в бесконечность"
        if (zSquared > ESCAPE_RADIUS) {
            break;
        }

        iteration++;
    }

    [0] color = color(zSquared, iteration);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}