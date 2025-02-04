import glfw

class Window:
    def __init__(self, height: int = 600, width: int = 800):
        # Инициализация GLFW
        if not glfw.init():
            raise Exception("Не удалось инициализировать GLFW")
        
        # Установка флага, запрещающего изменение размера окна
        glfw.window_hint(glfw.RESIZABLE, glfw.FALSE)
        
        self._create_window(height, width)
        
        # Установка текущего контекста окна
        glfw.make_context_current(self.window)
        
        self.glfw = glfw
        
    def _create_window(self, height, width):
        # Создание окна
        self.window = glfw.create_window(width, height, "Мое первое окно на GLFW", None, None)

        if not self.window:
            glfw.terminate()
            raise Exception("Не удалось создать окно GLFW")


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