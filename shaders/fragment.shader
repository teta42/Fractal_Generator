#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

// Константы
const float ESCAPE_RADIUS = 4.0;
const float ZOOM_SPEED = 0.25;
const int MAX_ITERATIONS = 500;

// Структура для пятикратной точности
struct QuintupleDouble {
    dvec2 part1; // Самая старшая часть числа
    dvec2 part2;
    dvec2 part3;
    dvec2 part4;
    dvec2 part5; // Самая младшая часть числа
};

// Функция для создания числа с пятикратной точностью
QuintupleDouble makeQuintupleDouble(double value) {
    return QuintupleDouble(dvec2(value, 0.0), dvec2(0.0), dvec2(0.0), dvec2(0.0), dvec2(0.0));
}

// Сложение с учетом переноса
QuintupleDouble addQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    dvec2 sum1 = a.part1 + b.part1;
    dvec2 carry1 = dvec2(0.0);

    // Упрощение обработки переноса
    if (abs(sum1.y) > abs(sum1.x)) {
        carry1 = dvec2(sum1.y, 0.0);
        sum1.y = 0.0;
    }

    dvec2 sum2 = a.part2 + b.part2 + carry1;
    dvec2 carry2 = dvec2(0.0);

    if (abs(sum2.y) > abs(sum2.x)) {
        carry2 = dvec2(sum2.y, 0.0);
        sum2.y = 0.0;
    }

    dvec2 sum3 = a.part3 + b.part3 + carry2;
    dvec2 carry3 = dvec2(0.0);

    if (abs(sum3.y) > abs(sum3.x)) {
        carry3 = dvec2(sum3.y, 0.0);
        sum3.y = 0.0;
    }

    dvec2 sum4 = a.part4 + b.part4 + carry3;
    dvec2 carry4 = dvec2(0.0);

    if (abs(sum4.y) > abs(sum4.x)) {
        carry4 = dvec2(sum4.y, 0.0);
        sum4.y = 0.0;
    }

    dvec2 sum5 = a.part5 + b.part5 + carry4;

    return QuintupleDouble(sum1, sum2, sum3, sum4, sum5);
}

// Умножение с учетом переноса
QuintupleDouble mulQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    dvec2 prod1 = a.part1 * b.part1;
    dvec2 prod2 = a.part1 * b.part2 + a.part2 * b.part1;
    dvec2 prod3 = a.part1 * b.part3 + a.part2 * b.part2 + a.part3 * b.part1;
    dvec2 prod4 = a.part1 * b.part4 + a.part2 * b.part3 + a.part3 * b.part2 + a.part4 * b.part1;
    dvec2 prod5 = a.part1 * b.part5 + a.part2 * b.part4 + a.part3 * b.part3 + a.part4 * b.part2 + a.part5 * b.part1;

    // Упрощение нормализации и переноса
    dvec2 carry1 = dvec2(0.0);
    if (abs(prod1.y) > abs(prod1.x)) {
        carry1 = dvec2(prod1.y, 0.0);
        prod1.y = 0.0;
    }

    prod2 += carry1;
    dvec2 carry2 = dvec2(0.0);
    if (abs(prod2.y) > abs(prod2.x)) {
        carry2 = dvec2(prod2.y, 0.0);
        prod2.y = 0.0;
    }

    prod3 += carry2;
    dvec2 carry3 = dvec2(0.0);
    if (abs(prod3.y) > abs(prod3.x)) {
        carry3 = dvec2(prod3.y, 0.0);
        prod3.y = 0.0;
    }

    prod4 += carry3;
    dvec2 carry4 = dvec2(0.0);
    if (abs(prod4.y) > abs(prod4.x)) {
        carry4 = dvec2(prod4.y, 0.0);
        prod4.y = 0.0;
    }

    prod5 += carry4;

    return QuintupleDouble(prod1, prod2, prod3, prod4, prod5);
}

// Преобразование QuintupleDouble в dvec2
dvec2 toDvec2(QuintupleDouble q) {
    return q.part1 + q.part2 + q.part3 + q.part4 + q.part5;
}

void main() {
    // Нормализованные координаты пикселя
    vec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Центр комплексной плоскости
    QuintupleDouble centerX = makeQuintupleDouble(-1.45);
    QuintupleDouble centerY = makeQuintupleDouble(0.0);

    // Экспоненциальный зум
    QuintupleDouble zoom = makeQuintupleDouble(exp(time * ZOOM_SPEED));

    // Соотношение сторон экрана
    QuintupleDouble aspectRatio = makeQuintupleDouble(resolution.x / resolution.y);

    // Преобразование координат пикселя
    QuintupleDouble scaledX = mulQuintupleDouble(makeQuintupleDouble(pixelCoord.x - 0.5), makeQuintupleDouble(3.0 / toDvec2(zoom).x * toDvec2(aspectRatio).x));
    QuintupleDouble scaledY = mulQuintupleDouble(makeQuintupleDouble(pixelCoord.y - 0.5), makeQuintupleDouble(3.0 / toDvec2(zoom).x));

    // Локальные координаты точки
    QuintupleDouble cX = addQuintupleDouble(centerX, scaledX);
    QuintupleDouble cY = addQuintupleDouble(centerY, scaledY);

    // Начальное значение z = 0 + 0i
    QuintupleDouble zX = makeQuintupleDouble(0.0);
    QuintupleDouble zY = makeQuintupleDouble(0.0);

    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < MAX_ITERATIONS) {
        QuintupleDouble zX2 = mulQuintupleDouble(zX, zX);
        QuintupleDouble zY2 = mulQuintupleDouble(zY, zY);
        QuintupleDouble zXY = mulQuintupleDouble(zX, zY);

        QuintupleDouble z2X = addQuintupleDouble(zX2, makeQuintupleDouble(-toDvec2(zY2).x));
        QuintupleDouble z2Y = makeQuintupleDouble(2.0 * toDvec2(zXY).x);

        zX = addQuintupleDouble(z2X, cX);
        zY = addQuintupleDouble(z2Y, cY);

        if (toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x > ESCAPE_RADIUS) {
            break;
        }

        iteration++;
    }

    // Линейная интерполяция
    float magnitude = float(toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x);
    float smoothColor = float(iteration) - clamp((magnitude - 0.0) / (ESCAPE_RADIUS - 0.0), 0.0, 1.0) + 4.0;
    float color = smoothColor / float(MAX_ITERATIONS);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}