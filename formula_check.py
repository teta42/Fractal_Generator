class FormulaValidator:
    allowed_functions = ['sin', 'cos', 'tan', 'ctg']
    allowed_vars = ['z', 'c']
    allowed_operations = ['+', '-', '*', '/', '^']
    
    def __init__(self):
        self.patterns = {
            "start_end": self._compile_start_end_pattern(),
            "functions_have_args": self._compile_functions_have_args_pattern(),
            "functions_with_ops": self._compile_functions_with_ops_pattern(),
            "operations": self._compile_operations_pattern(),
            "variables_with_ops": self._compile_variables_with_ops_pattern(),
            "var_num": self._compile_var_num_pattern(),
            "vars_as_functions": self._compile_vars_as_functions_pattern(),
            "var_func_ops": self._compile_var_func_ops_pattern(),  # Новая проверка
        }
    
    def _compile_start_end_pattern(self):
        vars_part = '|'.join(self.allowed_vars)
        functions_part = '|'.join(self.allowed_functions)
        start_part = rf"(?:\d+|\b(?:{vars_part})\b|(?:{functions_part})\([^)]+\))"
        return re.compile(rf"^\s*{start_part}[\s\S]*?{start_part}\s*$")
    
    def _compile_functions_have_args_pattern(self):
        functions = '|'.join(self.allowed_functions)
        return re.compile(rf"\b({functions})\b(?!\()|\b({functions})\(\s*\)", re.IGNORECASE)
    
    def _compile_functions_with_ops_pattern(self):
        functions = '|'.join(self.allowed_functions)
        ops = ''.join(re.escape(op) for op in self.allowed_operations)
        pattern = rf"""
            \b(?P<func1>{functions})\([^)]+\)\s*  # Первая функция
            (?!([{ops}]))                         # Следующий символ не операция
            \s*                                  # Пробелы
            (?:                                  # Следующий элемент
                (?P<var>{'|'.join(self.allowed_vars)})|
                (?P<func2>{functions})\([^)]+\)|
                \d+
            )
        """
        return re.compile(pattern, re.VERBOSE)
    
    def _compile_operations_pattern(self):
        ops = ''.join(re.escape(op) for op in self.allowed_operations)
        return re.compile(rf"([{ops}])\s*([{ops}])")
    
    def _compile_variables_with_ops_pattern(self):
        vars_part = '|'.join(self.allowed_vars)
        ops = ''.join(re.escape(op) for op in self.allowed_operations)
        pattern = rf"""
            \b({vars_part})\b  # Первая переменная
            (?!                # Отрицательный просмотр вперед:
                \s*            # Пробелы
                [{ops}]        # Операция
            )
            \s*                # Пробелы между переменными
            \b({vars_part})\b  # Вторая переменная
        """
        return re.compile(pattern, re.VERBOSE)
    
    def _compile_var_num_pattern(self):
        vars_part = '|'.join(self.allowed_vars)
        pattern = rf"""
            \b({vars_part})\b  # Переменная
            (?!\()             # Убедиться, что это не функция (например, z(5))
            (?!\d*\.\d*)       # Исключить числа с точкой (например, 1.5)
            (?=\d)             # Следующий символ — цифра
        """
        return re.compile(pattern, re.VERBOSE)
    
    def _compile_vars_as_functions_pattern(self):
        vars_part = '|'.join(self.allowed_vars)
        return re.compile(rf"\b({vars_part})\([^)]+\)", re.IGNORECASE)
    
    def _compile_var_func_ops_pattern(self):
        vars_part = '|'.join(self.allowed_vars)
        functions_part = '|'.join(self.allowed_functions)
        ops = ''.join(re.escape(op) for op in self.allowed_operations)
        pattern = rf"""
            \b(?P<var>{vars_part})\b  # Переменная
            (?!                       # Отрицательный просмотр вперед:
                \s*                   # Пробелы
                [{ops}]               # Операция
            )
            \s*                       # Пробелы
            (?P<func>{functions_part})\([^)]+\)  # Функция с аргументами
        |
            \b(?P<func2>{functions_part})\([^)]+\)\s*  # Функция с аргументами
            (?!                       # Отрицательный просмотр вперед:
                \s*                   # Пробелы
                [{ops}]               # Операция
            )
            \s*                       # Пробелы
            (?P<var2>{vars_part})\b   # Переменная
        """
        return re.compile(pattern, re.VERBOSE)
    
    def validate(self, formula):
        errors = []
        
        # Проверка начала и конца
        if not self.patterns["start_end"].fullmatch(formula):
            errors.append("Формула должна начинаться и заканчиваться на число, переменную (z/c) или функцию с аргументами")
        
        # Проверка функций на аргументы
        if self.patterns["functions_have_args"].search(formula):
            errors.append("Функции должны иметь аргументы (например: sin(3), cos(z))")
        
        # Проверка операций между функциями
        if self.patterns["functions_with_ops"].search(formula):
            errors.append("Между функциями должна быть операция (+, -, *, /, ^)")
        
        # Проверка на две операции подряд
        if self.patterns["operations"].search(formula):
            errors.append("Две операции не должны стоять подряд (например: ++, **)")
        
        # Проверка операций между переменными
        if self.patterns["variables_with_ops"].search(formula):
            errors.append("Между переменными (z/c) должна быть операция (+, -, *, /, ^)")
        
        # Проверка операций между переменной и числом
        if self.patterns["var_num"].search(formula):
            errors.append("Между переменной (z/c) и числом должна быть операция (+, -, *, /, ^)")
        
        # Проверка использования переменных как функций
        if self.patterns["vars_as_functions"].search(formula):
            errors.append("Переменные (z/c) не могут использоваться как функции (например: z(5))")
        
        # Проверка операций между переменной и функцией
        if self.patterns["var_func_ops"].search(formula):
            errors.append("Между переменной (z/c) и функцией должна быть операция (+, -, *, /, ^)")
        
        # Проверка на сбалансированность скобок
        if formula.count('(') != formula.count(')'):
            errors.append("Несбалансированное количество скобок")
        
        return errors