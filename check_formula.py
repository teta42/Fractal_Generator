import math
import cmath
from typing import Union

def check_formula(expression: str) -> Union[str, bool]:
    try:
        # Ограничиваем доступ только к числовым операциям и математическим функциям
        allowed_globals = {
            '__builtins__': None,  # Отключаем встроенные функции
            'abs': abs,
            'sin': math.sin,
            'cos': math.cos,
            'tan': math.tan,
            'asin': math.asin,
            'acos': math.acos,
            'atan': math.atan,
            'sinh': math.sinh,
            'cosh': math.cosh,
            'tanh': math.tanh,
            'csin': cmath.sin,
            'ccos': cmath.cos,
            'ctan': cmath.tan,
            'casin': cmath.asin,
            'cacos': cmath.acos,
            'catan': cmath.atan,
            'csinh': cmath.sinh,
            'ccosh': cmath.cosh,
            'ctanh': cmath.tanh,
            'vec2': complex,
            'cExp': cmath.exp,
            'cPow': pow,
            'z': complex(1,1),
            'c': complex(1.5, 1.5)
        }
        
        # Вычисляем выражение
        result = eval(expression, allowed_globals)
        return expression
    except Exception as e:
        #print(f"Ошибка: {str(e)}")
        return False