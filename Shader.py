from OpenGL.GL import *
from settings import vertex_path, template_shader, fragment_path, Accuracy, Version_OpenGL, Formula
import os

class Shader_manager():
    def __init__(self):
        
        com = Composer()
        
        self.vertex_shader = self._compile_shader(com.vertex_shader, GL_VERTEX_SHADER)
        self.fragment_shader = self._compile_shader(com.fragment_shader, GL_FRAGMENT_SHADER)
        
        self.shader_program = self._create_shader_program(self.vertex_shader, self.fragment_shader)
        
        # Используем шейдерную программу
        glUseProgram(self.shader_program)
    
    def _create_shader_program(self, vertex_shader_id, fragment_shader_id):
        program = glCreateProgram()
        if not program:
            raise RuntimeError("Ошибка создания шейдерной программы")

        # Привязываем шейдеры к программе
        glAttachShader(program, vertex_shader_id)
        glAttachShader(program, fragment_shader_id)

        glLinkProgram(program)

        # Проверяем статус линковки
        link_status = glGetProgramiv(program, GL_LINK_STATUS)
        if not link_status:
            # Получаем лог ошибок
            error_log = glGetProgramInfoLog(program).decode()
            glDeleteProgram(program)
            raise RuntimeError(f"Ошибка линковки шейдерной программы: {error_log}")

        # Удаляем шейдеры после линковки
        glDeleteShader(vertex_shader_id)
        glDeleteShader(fragment_shader_id)

        return program
    
    def _compile_shader(self, source, shader_type):
        shader = glCreateShader(shader_type)
        if not shader:
            raise RuntimeError("Ошибка создания шейдера")

        glShaderSource(shader, source)
        
        glCompileShader(shader)
        
        # Проверяем статус компиляции
        compile_status = glGetShaderiv(shader, GL_COMPILE_STATUS)
        if not compile_status:
            # Получаем лог ошибок
            error_log = glGetShaderInfoLog(shader).decode()
            glDeleteShader(shader)
            raise RuntimeError(f"Ошибка компиляции шейдера: {error_log}")
        
        return shader
    
    def get_uniform(self):
        # Получение локаций uniform-переменных
        self.resolution = glGetUniformLocation(self.shader_program, "resolution")
        self.zoom = glGetUniformLocation(self.shader_program, "zoom")
        self.center = glGetUniformLocation(self.shader_program, "center")
        self.max_itr = glGetUniformLocation(self.shader_program, "MAX_ITERATIONS")
        self.escape_radius = glGetUniformLocation(self.shader_program, "ESCAPE_RADIUS")
        # time_s = glGetUniformLocation(self.shader_program, "time")
        self.aspectRatio = glGetUniformLocation(self.shader_program, "aspectRatio")

    def push_uniform(self, ZOOM, CENTER, MAX_ITERATIONS, ESCAPE_RADIUS, width, height):
        # Установка значений uniform-переменных
        glUniform2f(self.resolution, width, height)
        glUniform1i(self.max_itr, MAX_ITERATIONS)
        glUniform1f(self.escape_radius, ESCAPE_RADIUS)
        glUniform1f(self.aspectRatio, width/height)
        # glUniform1f(time_s, glfw.get_time())
        
        if Accuracy == 2:
            glUniform1d(self.zoom, ZOOM)
            glUniform2d(self.center, CENTER['x'], CENTER['y'])
        elif Accuracy == 1:
            glUniform1f(self.zoom, ZOOM)
            glUniform2f(self.center, CENTER['x'], CENTER['y'])
        else:
            raise ValueError("Accuracy = 1 and 2")
    
    def delete_program(self):
        if self.vertex_shader:
            glDeleteShader(self.vertex_shader)
        if self.fragment_shader:
            glDeleteShader(self.fragment_shader)
        if self.shader_program:
            glDeleteProgram(self.shader_program)
            
class Composer():
    def __init__(self):
        self._read_shader()
        
        if Accuracy == 2:
            self.fragment_shader = self._changer(self.fragment_shader, ['double', 'dvec2'])
        elif Accuracy == 1:
            self.fragment_shader = self._changer(self.fragment_shader, ['float', 'vec2'])
        else:
            raise ValueError('Accuracy = 1 and 2')
    
    def _changer(self, shader_source: str, accuracy: list) -> str:
        shader_source = shader_source.replace("[version]", str(Version_OpenGL))
        shader_source = shader_source.replace("[0]", accuracy[0])
        shader_source = shader_source.replace("[1]", accuracy[1])
        shader_source = shader_source.replace("[Formula]", Formula)
        if Accuracy == 1:
            shader_source = shader_source.replace("[trigonometry]", self._read_template('trigonometry'))
        elif Accuracy == 2:
            shader_source = shader_source.replace("[trigonometry]", '')
        return shader_source
    
    def _read_shader(self):
        try:
            with open(vertex_path, encoding='utf-8') as file:
                self.vertex_shader = file.read()
        
            with open(fragment_path, encoding='utf-8') as file:
                self.fragment_shader = file.read()
        except FileNotFoundError as e:
            raise RuntimeError(f"Файл шейдера не найден: {e.filename}")
    
    def _read_template(self, name: str) -> str:
        path = os.path.join(template_shader, f'{name}.shader')
        try:
            with open(path, encoding='utf-8') as file:
                return file.read()
        except FileNotFoundError as e:
            raise RuntimeError(f"Файл шаблона не найден: {e.filename}")