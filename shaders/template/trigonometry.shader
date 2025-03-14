// Тригонометрия и exp, sqrt для комплексных чисел

// Функция для вычисления синуса комплексного числа
vec2 complexSin(vec2 z) {
    float a = z.x; // действительная часть
    float b = z.y; // мнимая часть
    return vec2(sin(a) * cosh(b), cos(a) * sinh(b));
}

// Функция для вычисления косинуса комплексного числа
vec2 complexCos(vec2 z) {
    float a = z.x;
    float b = z.y;
    return vec2(cos(a) * cosh(b), -sin(a) * sinh(b));
}

// Функция для вычисления тангенса комплексного числа
vec2 complexTan(vec2 z) {
    return complexSin(z) / complexCos(z);
}

// Функция для вычисления котангенса комплексного числа
vec2 complexCtg(vec2 z) {
    return complexCos(z) / complexSin(z);
}

// Функция для вычисления арксинуса комплексного числа
vec2 complexAsin(vec2 z) {
    return -0.5 * log(vec2(z.y, -z.x) + sqrt(vec2(length(z), 0.0) - z * z));
}

// Функция для вычисления арккосинуса комплексного числа
vec2 complexAcos(vec2 z) {
    return -0.5 * log(z + sqrt(z * z - vec2(1.0, 0.0)));
}

// Функция для вычисления арктангенса комплексного числа
vec2 complexAtan(vec2 z) {
    return 0.5 * log((vec2(1.0, 0.0) - vec2(0.0, z.y) - vec2(z.x, 0.0)) / (vec2(1.0, 0.0) + vec2(0.0, z.y) + vec2(z.x, 0.0)));
}

// Функция для вычисления гиперболического синуса комплексного числа
vec2 complexSinh(vec2 z) {
    return vec2(sinh(z.x) * cos(z.y), cosh(z.x) * sin(z.y));
}

// Функция для вычисления гиперболического косинуса комплексного числа
vec2 complexCosh(vec2 z) {
    return vec2(cosh(z.x) * cos(z.y), sinh(z.x) * sin(z.y));
}

// Функция для вычисления гиперболического тангенса комплексного числа
vec2 complexTanh(vec2 z) {
    return complexSinh(z) / complexCosh(z);
}

// Функция для вычисления гиперболического котангенса комплексного числа
vec2 complexCtgH(vec2 z) {
    return complexCosh(z) / complexSinh(z);
}

// Функция для вычисления экспоненты комплексного числа
vec2 complexExp(vec2 z) {
    float expA = exp(z.x);
    return vec2(expA * cos(z.y), expA * sin(z.y));
}

// Функция для вычисления квадратного корня комплексного числа
vec2 complexSqrt(vec2 z) {
    float r = length(z);
    float theta = atan(z.y, z.x);
    return vec2(sqrt(r) * cos(theta / 2.0), sqrt(r) * sin(theta / 2.0));
}