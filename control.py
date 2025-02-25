import settings
import glfw

WINDOW = None

# Функция обратного вызова для обработки событий мыши
def mouse_callback(window, button, action, mods):
    if button == glfw.MOUSE_BUTTON_LEFT and action == glfw.PRESS:
        # Получаем координаты курсора в пикселях
        x, y = glfw.get_cursor_pos(window)
        width, height = WINDOW.window_size

        CENTER = settings.CENTER
        ZOOM = settings.ZOOM

        CENTER['x'] = CENTER['x'] + (x / width - 0.5) * (3.0 * (width/height) / ZOOM)
        CENTER['y'] = CENTER['y'] + (0.5 - y / height) * (3.0 / ZOOM)

        print(f"Новый центр комплексной плоскости: x={CENTER['x']}, y={CENTER['y']}")

# Функция обратного вызова для обработки прокрутки
def scroll_callback(window, xoffset, yoffset):
    # global ZOOM
    # Нормализуем значение прокрутки
    settings.ZOOM += yoffset * 0.3 * settings.ZOOM  # Умножаем на коэффициент для уменьшения шага
    # ZOOM_SPEED = max(-1.0, min(1.0, ZOOM_SPEED))  # Ограничиваем значения между 0 и 1
    print(f"Текущее значение прокрутки: {settings.ZOOM}")
    

def callback_registration(this_window):
    window = this_window.window
    global WINDOW
    WINDOW = this_window

    # Регистрация функции обратного вызова
    glfw.set_mouse_button_callback(window, mouse_callback)
    # Установка функции обратного вызова для прокрутки
    glfw.set_scroll_callback(window, scroll_callback)