import os

ZOOM = 1.0
CENTER = {'x': 0.0, 'y': 0.0}
MAX_ITERATIONS = 200
ESCAPE_RADIUS = 4.0

vertex_path = os.path.join(os.getcwd(), 'shaders', 'vertex.shader')
fragment_path = os.path.join(os.getcwd(), 'shaders', 'fragment.shader')

# width, height = 800, 600

# ZOOM_SPEED = 1.0 # чем ближе к 1 тем быстрее