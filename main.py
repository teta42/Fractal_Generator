from GLFW import GLFW
from OpenGL.GL import *
from OpenGL.GLUT import *


# Создание экземпляра GLFW
glfw_instance = GLFW(height=650, width=1280)
glfw = glfw_instance.glfw

# Настройка OpenGL
glClearColor(0.1, 0.2, 0.3, 1.0)  # Установка цвета фона (RGBA)
glEnable(GL_DEPTH_TEST)           # Включение теста глубины

# Основной цикл
try:
    while not glfw.window_should_close(glfw_instance.window):
        # Очистка экрана
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        # Здесь можно добавить код для рендеринга объектов
        # Например, нарисовать треугольник:
        glBegin(GL_TRIANGLES)
        glColor3f(0.231, 0.654, 0)  # Красный цвет
        glVertex3f(-1, -1, 0)
        glColor3f(0, 1, 0)  # Зеленый цвет
        glVertex3f(1, -1, 0)
        glColor3f(0, 0, 1)  # Синий цвет
        glVertex3f(0, 1, 0)
        glEnd()

        # Обновление окна
        glfw.swap_buffers(glfw_instance.window)
        glfw.poll_events()
finally:
    # Завершение работы GLFW
    glfw.terminate()