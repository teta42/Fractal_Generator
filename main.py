from Window import Window
from OpenGL.GL import *
from OpenGL.GLUT import *
from Shader import Shader_manager
import numpy as np

width, height = 800, 600

# Создание экземпляра GLFW
this_window = Window(height=height, width=width)
glfw = this_window.glfw

shader = Shader_manager()

# Используем шейдерную программу
glUseProgram(shader.shader_program)

# Координаты четырёх углов окна (в нормализованных координатах)
vertices = np.array([
    [-1.0, -1.0],  # Нижний левый угол
    [ 1.0, -1.0],  # Нижний правый угол
    [ 1.0,  1.0],  # Верхний правый угол
    [-1.0,  1.0],  # Верхний левый угол
], dtype=np.float32)

# Создание VBO (Vertex Buffer Object)
vbo = glGenBuffers(1)
glBindBuffer(GL_ARRAY_BUFFER, vbo)
glBufferData(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW)

# Настройка атрибутов вершин
glEnableVertexAttribArray(0)
glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * 4, None)

# Основной цикл
try:
    while not glfw.window_should_close(this_window.window):
        glClearColor(0.0, 0.0, 0.0, 1.0)  # Устанавливаем черный цвет фона
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        resolution = glGetUniformLocation(shader.shader_program, "resolution")
        glUniform2f(resolution, width, height)

        time_s = glGetUniformLocation(shader.shader_program, "time")
        glUniform1f(time_s, glfw.get_time())

        # Рисование четырёхугольника
        glDrawArrays(GL_TRIANGLE_FAN, 0, 6)

        # Обновление окна
        glfw.swap_buffers(this_window.window)
        glfw.poll_events()
finally:
    shader.delete_shaders_program()
    # Завершение работы GLFW
    glfw.terminate()