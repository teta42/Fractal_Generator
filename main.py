from Window import Window
from OpenGL.GL import *
from OpenGL.GLUT import *
from Shader import Shader_manager
import time

width, height = 1280, 650

# Создание экземпляра GLFW
this_window = Window(height=height, width=width)
glfw = this_window.glfw

shader = Shader_manager()

# Используем шейдерную программу
glUseProgram(shader.shader_program)

# Основной цикл
try:
    while not glfw.window_should_close(this_window.window):
        glClearColor(0.0, 0.0, 0.0, 1.0)  # Устанавливаем черный цвет фона
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        resolution = glGetUniformLocation(shader.shader_program, "resolution")
        if resolution != -1:
            glUniform2f(resolution, width, height)

        time_uniform_location = glGetUniformLocation(shader.shader_program, "time")
        if time_uniform_location != -1:
            glUniform1f(time_uniform_location, time.time())


        # Отрисовка прямоугольника
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        # Обновление окна
        glfw.swap_buffers(this_window.window)
        glfw.poll_events()
finally:
    shader.delete_shaders_program()
    # Завершение работы GLFW
    glfw.terminate()