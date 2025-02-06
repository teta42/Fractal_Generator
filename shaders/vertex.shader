#version 330 core

in vec2 position;

void main()
{
    // Устанавливаем позицию вершины в пространстве клиппинга
    gl_Position = vec4(position.xy, 0.0, 1.0);
}
