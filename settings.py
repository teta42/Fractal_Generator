import os
import glfw

'''
Доступные всегда
abs, cExp, cPow, vec2(Задать комплексное число: vec2(real, imaginary))

Доступные только при accuracy = 1
csin, ccos, ctan, casin, cacos, catan, csinh, ccosh, ctanh, (Комплексные тригонометрические функции)
sin, cos, tan, asin, acos, atan, sinh, cosh, tanh
'''

Formula = 'cPow(z,2)+vec2(1,1)'

Accuracy = 1 # 2(double) 1(float)
Version_OpenGL = 460 # Accuracy = 2, Version_OpenGL > 400

RESIZABLE_WINDOW = glfw.TRUE # glfw.FALSE
HEIGHT = 600
WIDTH = 800


ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 500
ESCAPE_RADIUS = 4.0

# Formula1 = input('Введите формулу для генерации фрактала: ')

# if Formula == False:
#     raise SyntaxError(f'В вашей формуле {Formula1} ошибка')

vertex_path = os.path.join(os.getcwd(), 'shaders', 'vertex.shader')
fragment_path = os.path.join(os.getcwd(), 'shaders', 'fragment.shader')
template_shader = os.path.join(os.getcwd(), 'shaders', 'template')