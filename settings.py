import os

ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 200
ESCAPE_RADIUS = 4.0

vertex_path = os.path.join(os.getcwd(), 'shaders', 'vertex.shader')
fragment_path = os.path.join(os.getcwd(), 'shaders', 'fragment.shader')

Accuracy = 2 # 2(double) 1(float)
Version_OpenGL = 430 # Accuracy = 2, Version_OpenGL > 400; Accuracy = 1, Version_OpenGL < 400
Formula = 'complexPow(z+complexPow(c,3),2)+c'

# width, height = 800, 600

# ZOOM_SPEED = 1.0 # чем ближе к 1 тем быстрее 