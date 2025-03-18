import glfw
from OpenGL.GL import glViewport
from settings import RESIZABLE_WINDOW, HEIGHT, WIDTH

class Window:
    def __init__(self):
        # Инициализация GLFW
        if not glfw.init():
            raise Exception("Не удалось инициализировать GLFW")
        
        # Настройки контекста OpenGL
        glfw.window_hint(glfw.RESIZABLE, RESIZABLE_WINDOW)
        
        self._create_window(HEIGHT, WIDTH)
        
        # Установка текущего контекста окна
        glfw.make_context_current(self.window)
        
        glfw.set_framebuffer_size_callback(self.window, self._framebuffer_size_callback)
        
        self.new_height = HEIGHT
        self.new_width = WIDTH
        
        self.glfw = glfw
        
    def _create_window(self, height, width):
        # Создание окна
        self.window = glfw.create_window(width, height, "Fractal Generator", None, None)

        if not self.window:
            glfw.terminate()
            raise Exception("Не удалось создать окно GLFW")
        
    @property
    def window_size(self):
        return self.new_width, self.new_height
        
    def _framebuffer_size_callback(self, window, width, height):
        self.new_height = height
        self.new_width = width
        # Обновляем область отображения OpenGL
        glViewport(0, 0, width, height)


if __name__ == "__main__":
    # Создание экземпляра GLFW
    glfw_instance = Window()

    # Основной цикл
    try:
        while not glfw.window_should_close(glfw_instance.window):
            # Очистка экрана
            glfw.swap_buffers(glfw_instance.window)
            glfw.poll_events()
    finally:
        # Завершение работы GLFW
        glfw.terminate()