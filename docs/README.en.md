# Fractal_Generator
Fractal generator in Python and GLSL

---

## About the Project

Fractal Generator is a tool for generating and exploring fractals using Python and GLSL. The project includes potential for expanding functionality.

---

## Features

1. **Graphical Interface**: Utilizing OpenGL for fractal visualization.
2. **GLSL for Rendering**: Fast visualization of fractals on the GPU.
3. **Planned Features**:
   - **UI**: A user interface for configuring settings.
   - **Rust CPU Implementation**: High precision and performance on the CPU.
   - **Almagest**: A mechanism for saving and sharing interesting locations within fractals.
   - **Video Generation**: Immersing into fractals by creating videos.

---

## Ideas

### 1. UI
A user-friendly interface will be added to allow configuration of generator settings.

### 2. Rust CPU Implementation
For users who need high precision or work on devices without GPU support, an extension in Rust will be implemented. This will enable computations on the CPU with high speed and precision.

### 3. Almagest
Almagest is a system for storing and sharing interesting locations within fractals. Users will be able to share their discoveries and explore others' findings.

### 4. Video Generation
The ability to create videos to capture the beauty of fractals will be added.

---

## How to Run the Project

0. Clone the repository:
    ```bash
    git clone https://github.com/teta42/Fractal_Generator.git
    ```

1. Ensure you have the necessary dependencies installed:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure the project in `settings.py`.

3. Start the program:
   ```bash
   python main.py
   ```

4. For testing features:
   - Use LMB to change the center of the viewed area.
   - Use the mouse wheel for zoom control.

---

## Development Plan

1. Add UI for easy configuration.
2. Develop a Rust module for CPU calculations.
3. Implement the Almagest system for storing and sharing fractal locations.
4. Create a tool for generating fractal videos.

---

## License

This project is licensed under the [MIT](LICENSE) license.

---

If you have ideas or suggestions for improving the project, contact me via Issues or Pull Requests!