from Window import Window
from OpenGL.GL import *
from OpenGL.GLUT import *
from Shader import Shader_manager
import numpy as np
from math import exp
import glfw

# width, height = 800, 600

# ZOOM_SPEED = 1.0 # чем ближе к 1 тем быстрее
ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 500
ESCAPE_RADIUS = 4.0

WINDOW = None


# Функция обратного вызова для обработки событий мыши
def mouse_callback(window, button, action, mods):
    if button == glfw.MOUSE_BUTTON_LEFT and action == glfw.PRESS:
        # Получаем координаты курсора в пикселях
        x, y = glfw.get_cursor_pos(window)
        width, height = WINDOW.window_size

        CENTER['x'] = CENTER['x'] + (x / width - 0.5) * (3.0 * (width/height) / ZOOM)
        CENTER['y'] = CENTER['y'] + (0.5 - y / height) * (3.0 / ZOOM)

        print(f"Новый центр комплексной плоскости: x={CENTER['x']}, y={CENTER['y']}")

# Функция обратного вызова для обработки прокрутки
def scroll_callback(window, xoffset, yoffset):
    global ZOOM
    # Нормализуем значение прокрутки
    ZOOM += yoffset * 0.3 * ZOOM  # Умножаем на коэффициент для уменьшения шага
    # ZOOM_SPEED = max(-1.0, min(1.0, ZOOM_SPEED))  # Ограничиваем значения между 0 и 1
    print(f"Текущее значение прокрутки: {ZOOM}")

class MainStream():
    def __init__(self):
        # Создание экземпляра GLFW
        self.this_window = Window()
        
        global WINDOW
        WINDOW = self.this_window

        self.shader = Shader_manager()
        
        # Настройка
        self._setting_opengl(self._vertices())
        
        # Запуск
        self._flow()
       
    def _check_gl_error(self):
        error = glGetError()
        if error != GL_NO_ERROR:
            raise RuntimeError(f"OpenGL error: {error}")
     
    def _vertices(self) -> np.ndarray:
        # Координаты четырёх углов окна (в нормализованных координатах)
        vertices = np.array([
            [-1.0, -1.0],  # Нижний левый угол
            [ 1.0, -1.0],  # Нижний правый угол
            [ 1.0,  1.0],  # Верхний правый угол
            [-1.0,  1.0],  # Верхний левый угол
        ], dtype=np.float32)
        
        return vertices

    def _setting_opengl(self, vertices):
        # Создание VAO
        self.vao = glGenVertexArrays(1)
        glBindVertexArray(self.vao)

        # Создание VBO
        self.vbo = glGenBuffers(1)
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBufferData(GL_ARRAY_BUFFER, vertices.tobytes(), GL_STATIC_DRAW)

        # Создание EBO
        indices = np.array([0, 1, 2, 2, 3, 0], dtype=np.uint32)
        self.ebo = glGenBuffers(1)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ebo)
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.tobytes(), GL_STATIC_DRAW)

        # Настройка атрибутов вершин
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * 4, None)

        # Отвязка VAO
        glBindVertexArray(0)
        
    def _flow(self):
        window = self.this_window.window
        # Получение локаций uniform-переменных
        resolution = glGetUniformLocation(self.shader.shader_program, "resolution")
        zoom = glGetUniformLocation(self.shader.shader_program, "zoom")
        center = glGetUniformLocation(self.shader.shader_program, "center")
        max_itr = glGetUniformLocation(self.shader.shader_program, "MAX_ITERATIONS")
        escape_radius = glGetUniformLocation(self.shader.shader_program, "ESCAPE_RADIUS")
        # time_s = glGetUniformLocation(self.shader.shader_program, "time")
        
        # Регистрация функции обратного вызова
        glfw.set_mouse_button_callback(window, mouse_callback)
        # Установка функции обратного вызова для прокрутки
        glfw.set_scroll_callback(window, scroll_callback)

        # Основной цикл
        while not glfw.window_should_close(window):
            # Очистка экрана
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

            global ZOOM
            # ZOOM = ZOOM_SPEED  # exp(glfw.get_time()*ZOOM_SPEED)

            width, height = self.this_window.window_size

            # Установка значений uniform-переменных
            glUniform2f(resolution, width, height)
            glUniform1d(zoom, ZOOM)
            glUniform2d(center, CENTER['x'], CENTER['y'])
            glUniform1i(max_itr, MAX_ITERATIONS)
            glUniform1f(escape_radius, ESCAPE_RADIUS)
            # glUniform1f(time_s, glfw.get_time())

            # Привязка VAO
            glBindVertexArray(self.vao)

            # Отрисовка четырёхугольника
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, None)

            # Отвязка VAO
            glBindVertexArray(0)

            # Проверка ошибок OpenGL
            self._check_gl_error()

            # Обновление окна
            glfw.swap_buffers(window)
            glfw.poll_events()
         
    def __del__(self):
        # Очистка
        glDeleteBuffers(1, np.array([self.vbo], dtype=np.uint32))
        glDeleteVertexArrays(1, np.array([self.vao], dtype=np.uint32))
        glDeleteBuffers(1, np.array([self.ebo], dtype=np.uint32))
        self.shader.delete_program()
        print(f"Программа работала {glfw.get_time()}")
        glfw.terminate()
            
if __name__ == '__main__':
    stream = MainStream()