import os
from check_formula import check_formula
import glfw

RESIZABLE_WINDOW = glfw.TRUE # glfw.FALSE
HEIGHT = 600
WIDTH = 800


ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 500
ESCAPE_RADIUS = 4.0

vertex_path = os.path.join(os.getcwd(), 'shaders', 'vertex.shader')
fragment_path = os.path.join(os.getcwd(), 'shaders', 'fragment.shader')
template_shader = os.path.join(os.getcwd(), 'shaders', 'template')

Accuracy = 2 # 2(double) 1(float)
Version_OpenGL = 430 # Accuracy = 2, Version_OpenGL > 400; Accuracy = 1, Version_OpenGL < 400

Formula1 = input('Введите формулу для генерации фрактала: ')
Formula = check_formula(Formula1)

if Formula == False:
    raise SyntaxError(f'В вашей формуле {Formula1} ошибка')