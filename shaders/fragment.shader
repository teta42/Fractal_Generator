#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

// Выходной цвет
out vec4 FragColor;

// Структура для тройной точности
struct TripleDouble {
    dvec2 high; // Старшая часть числа
    dvec2 low;  // Младшая часть числа
};

// Функция для создания числа с тройной точностью
TripleDouble makeTripleDouble(double value) {
    return TripleDouble(dvec2(value, 0.0), dvec2(0.0, 0.0));
}

// Сложение двух чисел с тройной точностью
TripleDouble addTripleDouble(TripleDouble a, TripleDouble b) {
    dvec2 sumHigh = a.high + b.high;
    dvec2 sumLow = a.low + b.low;
    return TripleDouble(sumHigh, sumLow);
}

// Умножение двух чисел с тройной точностью
TripleDouble mulTripleDouble(TripleDouble a, TripleDouble b) {
    dvec2 prodHigh = a.high * b.high;
    dvec2 prodLow = a.low * b.low;
    return TripleDouble(prodHigh, prodLow);
}

// Преобразование TripleDouble в dvec2 для вычислений
dvec2 toDvec2(TripleDouble t) {
    return t.high + t.low;
}

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    vec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Центр комплексной плоскости (глобальные координаты)
    TripleDouble centerX = makeTripleDouble(-1.80);
    TripleDouble centerY = makeTripleDouble(0.0);

    // Экспоненциальный зум
    TripleDouble zoom = makeTripleDouble(exp(time * 0.45));

    // Соотношение сторон экрана
    TripleDouble aspectRatio = makeTripleDouble(resolution.x / resolution.y);

    // Преобразование координат пикселя в относительные координаты
    TripleDouble scaledX = mulTripleDouble(makeTripleDouble(pixelCoord.x - 0.5), makeTripleDouble(3.0 / toDvec2(zoom).x * toDvec2(aspectRatio).x));
    TripleDouble scaledY = mulTripleDouble(makeTripleDouble(pixelCoord.y - 0.5), makeTripleDouble(3.0 / toDvec2(zoom).x));

    // Локальные координаты точки на комплексной плоскости
    TripleDouble cX = addTripleDouble(centerX, scaledX);
    TripleDouble cY = addTripleDouble(centerY, scaledY);

    // Начальное значение z = 0 + 0i
    TripleDouble zX = makeTripleDouble(0.0);
    TripleDouble zY = makeTripleDouble(0.0);

    int maxIterations = 500;
    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < maxIterations) {
        // Вычисление z^2: z^2 = (z.x + i*z.y)^2 = z.x^2 - z.y^2 + 2*z.x*z.y*i
        TripleDouble zX2 = mulTripleDouble(zX, zX);
        TripleDouble zY2 = mulTripleDouble(zY, zY);
        TripleDouble zXY = mulTripleDouble(zX, zY);

        TripleDouble z2X = addTripleDouble(zX2, makeTripleDouble(-toDvec2(zY2).x));
        TripleDouble z2Y = makeTripleDouble(2.0 * toDvec2(zXY).x);

        // Обновление z: z = z^2 + c
        zX = addTripleDouble(z2X, cX);
        zY = addTripleDouble(z2Y, cY);

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