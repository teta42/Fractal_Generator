import os
import glfw

'''
Доступные всегда
abs, sin, cos, tan, asin, acos, atan, sinh, cosh, 
tanh, cExp, cPow, vec2(Задать комплексное число: vec2(real, imaginary))

Доступные только при accuracy = 1
csin, ccos, ctan, casin, cacos, catan, csinh, ccosh, ctanh
'''

Formula = 'cPow(z,2)+c'

RESIZABLE_WINDOW = glfw.TRUE # glfw.FALSE
HEIGHT = 600
WIDTH = 800


ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 500
ESCAPE_RADIUS = 4.0

Accuracy = 2 # 2(double) 1(float)
Version_OpenGL = 430 # Accuracy = 2, Version_OpenGL > 400

# Formula1 = input('Введите формулу для генерации фрактала: ')

# if Formula == False:
#     raise SyntaxError(f'В вашей формуле {Formula1} ошибка')

vertex_path = os.path.join(os.getcwd(), 'shaders', 'vertex.shader')
fragment_path = os.path.join(os.getcwd(), 'shaders', 'fragment.shader')
template_shader = os.path.join(os.getcwd(), 'shaders', 'template')