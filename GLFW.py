import glfw

class GLFW:
    def __init__(self):
        # Инициализация GLFW
        if not glfw.init():
            raise Exception("Не удалось инициализировать GLFW")
        
        self._create_window()
        
        # Установка текущего контекста окна
        glfw.make_context_current(self.window)
        
    def _create_window(self):
        # Создание окна
        self.window = glfw.create_window(800, 600, "Мое первое окно на GLFW", None, None)

        if not self.window:
            glfw.terminate()
            raise Exception("Не удалось создать окно GLFW")


if __name__ == "__main__":
    # Создание экземпляра GLFW
    glfw_instance = GLFW()

    # Основной цикл
    try:
        while not glfw.window_should_close(glfw_instance.window):
            # Очистка экрана
            glfw.swap_buffers(glfw_instance.window)
            glfw.poll_events()
    finally:
        # Завершение работы GLFW
        glfw.terminate()