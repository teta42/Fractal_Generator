from OpenGL.GL import *

class Shader_manager():
    def __init__(self):
        
        self._read_shader()
        
        self.vertex_shader = self._compile_shader(self._vertex_shader, GL_VERTEX_SHADER)
        self.fragment_shader = self._compile_shader(self._fragment_shader, GL_FRAGMENT_SHADER)
        
        self.shader_program = self._create_shader_program(self.vertex_shader, self.fragment_shader)

        
    def _read_shader(self):
        vertex_path = '../Fractal_Generator/shaders/vertex.shader'
        fragment_path = '../Fractal_Generator/shaders/fragment.shader'
        try:
            with open(vertex_path, encoding='utf-8') as file:
                self._vertex_shader = file.read()
        
            with open(fragment_path, encoding='utf-8') as file:
                self._fragment_shader = file.read()
        except FileNotFoundError as e:
            raise RuntimeError(f"Файл шейдера не найден: {e.filename}")
    
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
    
    def delete_shaders_program(self):
        if self.vertex_shader:
            glDeleteShader(self.vertex_shader)
        if self.fragment_shader:
            glDeleteShader(self.fragment_shader)
        if self.shader_program:
            glDeleteProgram(self.shader_program)