#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах
uniform double zoom;  // Экспоненциальный зум
// Центр комплексной плоскости (глобальные координаты)
uniform dvec2 center; // Точка, к которой приближаемся

// Соотношение сторон экрана
uniform double aspectRatio;

uniform float ESCAPE_RADIUS;
uniform int MAX_ITERATIONS;

// Выходной цвет
out vec4 FragColor;

double color(double zSquared, int iteration) {
    // Линейная интерполяция вместо логарифмов
    double magnitude = zSquared;
    float minVal = 0.0; // Минимальное значение для интерполяции
    float maxVal = ESCAPE_RADIUS; // Максимальное значение для интерполяции (ESCAPE_RADIUS)

    double denominator = maxVal - minVal;
    if (denominator == 0.0) {
        denominator = 1.0;
    }

    double smoothColor = double(iteration) - clamp((magnitude - minVal) / denominator, 0.0, 1.0) + 4.0;
    double color = smoothColor / double(MAX_ITERATIONS);

    return color;
}

// Функция для умножения двух комплексных чисел
dvec2 complexMultiply(dvec2 z1, dvec2 z2) {
    // Действительная часть: z1.x * z2.x - z1.y * z2.y
    double realPart = z1.x * z2.x - z1.y * z2.y;

    // Мнимая часть: z1.x * z2.y + z1.y * z2.x
    double imaginaryPart = z1.x * z2.y + z1.y * z2.x;

    // Возвращаем результат как dvec2
    return dvec2(realPart, imaginaryPart);
}

// Функция для возведения комплексного числа в целую степень
dvec2 complexPow(dvec2 z, int power) {
    // Начальное значение: z^0 = 1 + 0i
    dvec2 result = dvec2(1.0, 0.0);

    // Если степень равна 0, возвращаем 1 + 0i
    if (power == 0) {
        return result;
    }

    // Если степень отрицательная, инвертируем число
    if (power < 0) {
        double denominator = z.x * z.x + z.y * z.y; // |z|^2
        z = dvec2(z.x / denominator, -z.y / denominator); // z = 1 / z
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
    dvec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

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
        z = complexPow(z,2) + c;

        // Обновление квадрата модуля z
        zSquared = z.x * z.x + z.y * z.y;

        // Проверка на "уход в бесконечность"
        if (zSquared > ESCAPE_RADIUS) {
            break;
        }

        iteration++;
    }

    double color = color(zSquared, iteration);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}