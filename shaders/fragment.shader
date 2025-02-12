#version 430 core

uniform vec2 resolution; // Разрешение окна (ширина, высота)
uniform float time;      // Время в секундах

const float ESCAPE_RADIUS = 4.0;
const float ZOOM_SPEED = 0.15;
const int MAX_ITERATIONS = 200;
const int MULTIPLE_PRECISION = 10;

// Выходной цвет
out vec4 FragColor;

// Структура для пятикратной точности
struct QuintupleDouble {
    dvec2 parts[MULTIPLE_PRECISION];
};

QuintupleDouble makeQuintupleDouble(double value) {
    QuintupleDouble q;
    q.parts[0] = dvec2(value, 0.0);
    for (int i = 1; i < MULTIPLE_PRECISION; i++) {
        q.parts[i] = dvec2(0.0, 0.0);
    }
    return q;
}

// Сложение двух чисел с пятикратной точностью
QuintupleDouble addQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    QuintupleDouble result;
    for (int i = 0; i < MULTIPLE_PRECISION; i++) {
        result.parts[i] = a.parts[i] + b.parts[i];
    }
    return result;
}

// Умножение двух чисел с пятикратной точностью
QuintupleDouble mulQuintupleDouble(QuintupleDouble a, QuintupleDouble b) {
    QuintupleDouble result;
    for (int i = 0; i < MULTIPLE_PRECISION; i++) {
        result.parts[i] = a.parts[i] * b.parts[i];
    }
    return result;
}


// Преобразование QuintupleDouble в dvec2 для вычислений
dvec2 toDvec2(QuintupleDouble q) {
    dvec2 result = dvec2(0.0, 0.0);
    for (int i = 0; i < MULTIPLE_PRECISION; i++) {
        result += q.parts[i];
    }
    return result;
}

void main() {
    // Нормализованные координаты пикселя в диапазоне [0, 1]
    vec2 pixelCoord = gl_FragCoord.xy / resolution.xy;

    // Центр комплексной плоскости (глобальные координаты)
    QuintupleDouble centerX = makeQuintupleDouble(-1.55);
    QuintupleDouble centerY = makeQuintupleDouble(0.0);

    // Экспоненциальный зум 
    QuintupleDouble zoom = makeQuintupleDouble(exp(time * ZOOM_SPEED));

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

    int iteration = 0;

    // Итерации: z = z^2 + c
    while (iteration < MAX_ITERATIONS) {
        // Вычисление z^2: z^2 = (z.x + i*z.y)^2 = z.x^2 - z.y^2 + 2*z.x*z.y*i
        QuintupleDouble zX2 = mulQuintupleDouble(zX, zX);
        QuintupleDouble zY2 = mulQuintupleDouble(zY, zY);
        QuintupleDouble zXY = mulQuintupleDouble(zX, zY);

        QuintupleDouble z2X = addQuintupleDouble(zX2, makeQuintupleDouble(-toDvec2(zY2).x));
        QuintupleDouble z2Y = makeQuintupleDouble(2.0 * toDvec2(zXY).x);

        // Обновление z: z = z^2 + c
        zX = addQuintupleDouble(z2X, cX);
        zY = addQuintupleDouble(z2Y, cY);

        // Единичное преобразование а не так - (toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x > 4.0)
        // dvec2 zX_dvec2 = toDvec2(zX);
        // dvec2 zY_dvec2 = toDvec2(zY);

        if (toDvec2(zX2).x + toDvec2(zY2).x > ESCAPE_RADIUS) {
            break;
        }

        iteration++;
    }

    // Линейная интерполяция вместо логарифмов
    float magnitude = float(toDvec2(zX).x * toDvec2(zX).x + toDvec2(zY).x * toDvec2(zY).x);
    float minVal = 0.0; // Минимальное значение для интерполяции
    float maxVal = ESCAPE_RADIUS; // Максимальное значение для интерполяции

    // Линейная интерполяция
    float smoothColor = float(iteration) - mix(0.0, 1.0, clamp((magnitude - minVal) / (maxVal - minVal), 0.0, 1.0)) + 4.0;
    float color = smoothColor / float(MAX_ITERATIONS);

    // Преобразование цвета в RGB
    FragColor = vec4(vec3(color), 1.0);
}