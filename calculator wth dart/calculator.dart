import 'dart:io';

void main() {
  while (true) {
    print('\n🖩 \x1B[36mSimple Calculator\x1B[0m');
    print('1️⃣ Add (+)');
    print('2️⃣ Subtract (-)');
    print('3️⃣ Multiply (*)');
    print('4️⃣ Divide (/)');
    print('5️⃣ Exit');

    stdout.write('Enter your choice: ');
    String? choice = stdin.readLineSync()?.trim();

    if (choice == '5') {
      print('\x1B[32m🚪 Exiting... Thank you!\x1B[0m');
      break;
    }

    stdout.write('Enter first number: ');
    double? num1 = double.tryParse(stdin.readLineSync()?.trim() ?? '');

    stdout.write('Enter second number: ');
    double? num2 = double.tryParse(stdin.readLineSync()?.trim() ?? '');

    if (num1 == null || num2 == null) {
      print('\x1B[31m❌ Invalid input. Please enter valid numbers.\x1B[0m');
      continue;
    }

    double result;
    switch (choice) {
      case '1':
        result = num1 + num2;
        print('➕ \x1B[32mResult: $num1 + $num2 = $result\x1B[0m');
        break;
      case '2':
        result = num1 - num2;
        print('➖ \x1B[32mResult: $num1 - $num2 = $result\x1B[0m');
        break;
      case '3':
        result = num1 * num2;
        print('✖ \x1B[32mResult: $num1 × $num2 = $result\x1B[0m');
        break;
      case '4':
        if (num2 == 0) {
          print('\x1B[31m❌ Division by zero is not allowed.\x1B[0m');
        } else {
          result = num1 / num2;
          print('➗ \x1B[32mResult: $num1 ÷ $num2 = $result\x1B[0m');
        }
        break;
      default:
        print('\x1B[31m❌ Invalid choice. Please try again.\x1B[0m');
    }
  }
}
