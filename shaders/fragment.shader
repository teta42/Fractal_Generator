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


double expDouble(double x) {
    bool isNegative = false;
    if (x < 0.0) {
        isNegative = true;
        x = -x;
    }

    // Разложение в ряд Тейлора: exp(x) ≈ 1 + x + x^2/2! + x^3/3! + ...
    double result = 1.0;
    double term = 1.0;
    const int MAX_ITERATIONS = 50;

    for (int i = 1; i < MAX_ITERATIONS; i++) {
        term *= x / double(i);
        result += term;
        if (term < 1e-15) {
            break;
        }
    }

    return isNegative ? 1.0 / result : result;
}

// Собственная оптимизированная реализация синуса для double
double sinDouble(double x) {
    const double PI = 3.141592653589793;
    const double TWO_PI = 6.283185307179586;
    const double HALF_PI = 1.5707963267948966;

    // Приведение x к диапазону [-π, π] через вычитание кратных 2π (быстрее mod)
    int q = int((x + PI) / TWO_PI);
    x -= q * TWO_PI;

    // Для x < -π или x > π корректируем диапазон
    if (x < -PI) x += TWO_PI;
    else if (x > PI) x -= TWO_PI;

    // Для x > π/2 используем тождество sin(x) = sin(π - x)
    if (x > HALF_PI) {
        x = PI - x;
    } else if (x < -HALF_PI) { // Для x < -π/2: sin(x) = -sin(π + x)
        x = -PI - x;
        x = (x > HALF_PI) ? PI - x : x;
    }

    // Оптимизированное разложение Тейлора (меньше умножений)
    double x2 = x * x;
    double x3 = x2 * x;
    double x5 = x3 * x2;
    double x7 = x5 * x2;

    // sin(x) ≈ x - x^3/6 + x^5/120 - x^7/5040
    return x - x3/6.0 + x5/120.0 - x7/5040.0;
}

// Оптимизированный sinh и cosh с кешированием exp(x)
void sinhCosinhDouble(double x, out double sinh, out double cosh) {
    double ex = expDouble(x);
    double eNegX = 1.0 / ex;
    sinh = (ex - eNegX) * 0.5;
    cosh = (ex + eNegX) * 0.5;
}

// Оптимизированный комплексный синус
dvec2 complexSin(dvec2 z) {
    double sinhY, coshY;
    sinhCosinhDouble(z.y, sinhY, coshY); // Единый вычет для sinh и cosh

    double sinX = sinDouble(z.x);
    double cosX = sqrt(1.0 - sinX * sinX); // Из тождества sin² + cos² = 1

    return dvec2(
        sinX * coshY,     // real
        cosX * sinhY      // imaginary (знак сохраняется)
    );
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
        z = complexSin(complexPow(z,2)) + c;

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