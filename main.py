from Window import Window
from OpenGL.GL import *
from OpenGL.GLUT import *
from Shader import Shader_manager
import numpy as np
import glfw
from settings import *
import settings
from control import callback_registration


class MainStream():
    def __init__(self):
        # Создание экземпляра GLFW
        self.this_window = Window()

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
        
        self.shader.get_uniform()

        callback_registration(self.this_window)

        # Основной цикл
        while not glfw.window_should_close(window):
            # Очистка экрана
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

            #global ZOOM
            # ZOOM = ZOOM_SPEED  # exp(glfw.get_time()*ZOOM_SPEED)

            width, height = self.this_window.window_size

            self.shader.push_uniform(settings.ZOOM, CENTER, MAX_ITERATIONS, ESCAPE_RADIUS, width, height)

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