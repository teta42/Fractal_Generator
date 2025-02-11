#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

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
    return QuintupleDouble(dvec2(value, 0.0), dvec2(0.0, 0.0), dvec2(0.0, 0.0), dvec2(0.0, 0.0), dvec2(0.0, 0.0));
}

// Сложение двух чисел с пятикратной точностью
QuintupleDouble addQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    dvec2 sum1 = a.part1 + b.part1;
    dvec2 sum2 = a.part2 + b.part2;
    dvec2 sum3 = a.part3 + b.part3;
    dvec2 sum4 = a.part4 + b.part4;
    dvec2 sum5 = a.part5 + b.part5;
    return QuintupleDouble(sum1, sum2, sum3, sum4, sum5);
}

// Умножение двух чисел с пятикратной точностью
QuintupleDouble mulQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    dvec2 prod1 = a.part1 * b.part1;
    dvec2 prod2 = a.part2 * b.part2;
    dvec2 prod3 = a.part3 * b.part3;
    dvec2 prod4 = a.part4 * b.part4;
    dvec2 prod5 = a.part5 * b.part5;
    return QuintupleDouble(prod1, prod2, prod3, prod4, prod5);
}

// Преобразование QuintupleDouble в dvec2 для вычислений
dvec2 toDvec2(QuintupleDouble q) {
    return q.part1 + q.part2 + q.part3 + q.part4 + q.part5;
}

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    vec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Центр комплексной плоскости (глобальные координаты)
    QuintupleDouble centerX = makeQuintupleDouble(-0.25);
    QuintupleDouble centerY = makeQuintupleDouble(0.75);

    // Экспоненциальный зум 
    QuintupleDouble zoom = makeQuintupleDouble(exp(time * 0.25));

    // Соотношение сторон экрана
    QuintupleDouble aspectRatio = makeQuintupleDouble(resolution.x / resolution.y);

    // Преобразование координат пикселя в относительные координаты
    QuintupleDouble scaledX = mulQuintupleDouble(makeQuintupleDouble(pixelCoord.x - 0.5), makeQuintupleDouble(3.0 / toDvec2(zoom).x * toDvec2(aspectRatio).x));
    QuintupleDouble scaledY = mulQuintupleDouble(makeQuintupleDouble(pixelCoord.y - 0.5), makeQuintupleDouble(3.0 / toDvec2(zoom).x));

    // Локальные координаты точки на комплексной плоскости
    QuintupleDouble cX = addQuintupleDouble(centerX, scaledX);
    QuintupleDouble cY = addQuintupleDouble(centerY, scaledY);

    // Начальное значение z = 0 + 0i
    QuintupleDouble zX = makeQuintupleDouble(0.0);
    QuintupleDouble zY = makeQuintupleDouble(0.0);

    int maxIterations = 200;
    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < maxIterations) {
        // Вычисление z^2: z^2 = (z.x + i*z.y)^2 = z.x^2 - z.y^2 + 2*z.x*z.y*i
        QuintupleDouble zX2 = mulQuintupleDouble(zX, zX);
        QuintupleDouble zY2 = mulQuintupleDouble(zY, zY);
        QuintupleDouble zXY = mulQuintupleDouble(zX, zY);

        QuintupleDouble z2X = addQuintupleDouble(zX2, makeQuintupleDouble(-toDvec2(zY2).x));
        QuintupleDouble z2Y = makeQuintupleDouble(2.0 * toDvec2(zXY).x);

        // Обновление z: z = z^2 + c
        zX = addQuintupleDouble(z2X, cX);
        zY = addQuintupleDouble(z2Y, cY);

        // Проверка на "уход в бесконечность" (если |z| > 2, точка не принадлежит множеству)
        if (toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x > 4.0) {
            break;
        }

        iteration++;
    }

    // Плавное окрашивание для более красивого результата
    float smoothColor = float(iteration) - log2(log2(float(toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x))) + 4.0;
    float color = smoothColor / float(maxIterations);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}