import streamlit as st

st.title('Конфигуратор Настроек')

st.markdown('---')

st.header("Настройки окна")

# Создаем 3 колонки
resizable_window, height, width = st.columns(3)

with resizable_window:
    is_resizable_window = st.checkbox('Динамическое изменение размеров окна')

with height:
    height_window = st.number_input('Высота окна', min_value=100, step=1)

with width:
    width_window = st.number_input('Ширина окна', min_value=100, step=1)
    
st.markdown('---')

st.header("Общие настройки")

st.warning('Accuracy = 2, Version_OpenGL > 400')

max_iteration_col, escape_radius_col, accuracy_col, version_opengl_col = st.columns(4)

with max_iteration_col:
    max_iteration = st.number_input('Максемальное кол-во итераций', min_value=1, step=1, value=200)
    
with escape_radius_col:
    escape_radius = st.number_input('Граница множества', step=0.1, value=4.0)

with accuracy_col:
    accuracy = st.radio('Точность генерации', ['1', '2'], index=1)
    
with version_opengl_col:
    version_opengl = st.radio('Версия OpenGL', ['330', '430'], index=1)
    
st.markdown('---')

st.header("Формула")

st.write('Доступные всегда:')
st.write('abs, sin, cos, tan, asin, acos, atan, sinh, cosh, tanh, cExp, cPow, vec2(Задать комплексное число: vec2(real, imaginary))')
st.write('Доступные только при accuracy = 1')
st.write('csin, ccos, ctan, casin, cacos, catan, csinh, ccosh, ctanh')


formula = st.text_input('Пользовательская формула', value="cPow(z,2)+c")

st.markdown('---')

# if st.button('Запустить генерацию'):
#     stream = MainStream()