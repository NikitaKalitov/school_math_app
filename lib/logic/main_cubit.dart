import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/storage_provider.dart';

/// -1 = пустой чекбокс
/// 0 = 9 + 3
/// 1 = 99 + 3
/// 2 = 99 + 33
/// 3 = 999 + 3
/// 4 = 999 + 33
/// 5 = 999 + 333
/// то же и с другими операциями
enum TestPageStatus {
  isLoading,
  loaded,
  sessionEnded,
}

enum TimerStatus {
  isRunning,
  isToReset,
}

enum SessionStatus {
  isRunning,
  ends,
}

enum AppStatus {
  isLoading,
  loaded,
}

const int secondsForTask = 30;
const int secondsForSession = 300;

class MainCubit extends Cubit<MainCubitState> {
  MainCubit()
      : super(MainCubitState(
          appStatus: AppStatus.isLoading,
          testPageStatus: TestPageStatus.loaded,
          initialSecondsForTask: secondsForTask,
          currentSecondsForTask: secondsForTask,
          currentSecondsForSession: secondsForSession,
          timerStatus: TimerStatus.isRunning,
        ));

  //публичные методы
  //инициализация кубита
  //вызывается только при запуске приложения
  void initCubit() async {
    //читаем уровни сложности из файла
    List<List<int>> listOfDifficulties =
        await SPrefProvider.readDifficultiesFromSPref();
    //прочитали, записали в стейт
    emit(state.copyWith(difficultyLevelsForSettings: listOfDifficulties));
    //генерируем мат операцию и уровень сложности
    //если настройки позволяют это сделать
    if (checkSettings()) {
      _generateOperationAndDifficulty();
    }
    //больше не работаем с файлом, только со стейтом, потому что стейт уже создан
  }

  //запускаем таймеры при инициализации экрана теста
  void startTimers() {
    _startTaskTimer();
    _startSessionTimer();
  }

  //для кнопки "Сохранить" в настройках
  //вызывается только там
  Future<void> changeDifficulties(List<List<int>> inputValue) async {
    //сохраняем новые уровни сложности в файл
    await _saveDataToSPref(inputValue);
    //записываем новые уровни сложности в стейт
    emit(state.copyWith(difficultyLevelsForSettings: inputValue));
    //генерируем мат операцию и уровень сложности
    if (checkSettings()) {
      _generateOperationAndDifficulty();
    }
  }

  //вызывается при нажатии на кнопку-цифру
  void addDigitToNumber(int digit) {
    //проверяем, чтобы число не было слишком большим
    if (state.currentNumber.toString().length < 10) {
      String string = state.currentNumber.toString() + digit.toString();
      int newNumber = int.parse(string);
      emit(state.copyWith(currentNumber: newNumber));
      //проверяем, совпадает ли значение на экране с правильным результатом
      _checkAnswer();
    }
  }

  //вызывается при нажатии на кнопку SKIP или DEL
  void skipOrDelete(String skipOrDelete) {
    switch (skipOrDelete) {
      case 'skip':
        //пропускаем - генерируем новую операцию и уровни сложности
        _generateOperationAndDifficulty();
        break;
      case 'delete':
        //проверяем, не пустое ли число
        //если пустое, но не отображаем его
        String string = state.currentNumber.toString();
        if (string.isNotEmpty) {
          string = string.substring(0, string.length - 1);
        }
        if (string.isEmpty) {
          string = '0';
        }
        int newNumber = int.parse(string);
        emit(state.copyWith(currentNumber: newNumber));
        //проверяем ответ
        _checkAnswer();
        break;
    }
  }

  //вызывается при долгом нажатии на кнопку DEL
  //полностью убирает введенные числа
  void clearInput() {
    emit(state.copyWith(currentNumber: 0));
  }

  //вызывается элементом, который отображает пример на экране
  String getMainWidgetText() {
    String getOperation() {
      switch (state.operation) {
        case 0:
          return '+';
        case 1:
          return '-';
        case 2:
          return '*';
        case 3:
          return '/';
        default:
          return '';
      }
    }

    String currentNumAsString = state.currentNumber.toString() == '0'
        ? ''
        : state.currentNumber.toString();
    String mainWidgetText =
        '${state.firstNum} ${getOperation()} ${state.secondNum} = $currentNumAsString';
    return mainWidgetText;
  }

  //вызывается при переходе на экран Тест (TestPage)
  //если в настройках ничего нет, мы не переходим на экран
  bool checkSettings() {
    for (int i = 0; i < state.difficultyLevelsForSettings!.length; i++) {
      if (state.difficultyLevelsForSettings![i]
          .any((element) => element != -1)) {
        return true;
      }
    }
    return false;
  }

  //скрытые методы
  //генерируем операцию и уровень сложности
  //вызывается, когда мы инициализируем кубит
  //вызывается, когда мы меняем сложность в настройках
  //вызывается, когда мы написали правильный ответ
  //вызывается, когда мы пропускам ответ
  void _generateOperationAndDifficulty() {
    //перед генерацией данных сбрасываем счетчик примера
    _resetTaskTimer();
    //получаем переменную для работы внутри кубита
    List<List<int>> difficultyLevels = [];
    for (int i = 0; i < state.difficultyLevelsForSettings!.length; i++) {
      List<int> difficultyList = [];
      for (int y = 0; y < state.difficultyLevelsForSettings![i].length; y++) {
        if (state.difficultyLevelsForSettings![i][y] != -1) {
          difficultyList.add(state.difficultyLevelsForSettings![i][y]);
        }
      }
      difficultyLevels.add(difficultyList);
    }
    //сохраняем эту переменную в стейт
    emit(state.copyWith(
      difficultyLevels: difficultyLevels,
    ));
    //генерируем операцию и уровни сложности для нее
    var [operation, firstNum, secondNum, result] =
        _Generator.generateValues(difficultyLevels);
    emit(state.copyWith(
      operation: operation,
      result: result,
      firstNum: firstNum,
      secondNum: secondNum,
      currentNumber: 0,
    ));
    //генерируем числа и ответ на основе полученных операции и уровней сложности
  }

  //записываем данные в файл
  //вызывается только при изменении сложности в настройках
  Future<void> _saveDataToSPref(List<List<int>> inputValue) async {
    await SPrefProvider.writeDifficultiesToSPref(inputValue);
  }

  //проверка ответа
  //вызывается при проверке ответа
  void _checkAnswer() async {
    if (state.currentNumber == state.result) {
      //если правильный ответ - меняем цвет текста на время
      await _changeTextColorOnCorrectAnswer();
      _generateOperationAndDifficulty();
    }
  }

  //меняем статус экрана с тестом, чтобы по значению статуса
  //управлять кнопками и цветом текста примера
  Future<void> _changeTextColorOnCorrectAnswer() async {
    emit(state.copyWith(testPageStatus: TestPageStatus.isLoading));
    await Future.delayed(const Duration(milliseconds: 800));
    emit(state.copyWith(testPageStatus: TestPageStatus.loaded));
  }

  //ТАЙМЕР
  //запускаем таймер примера
  void _startTaskTimer() async {
    while (state.currentSecondsForTask! >= 0) {
      //если время примера кончилось, мы запускаем реакцию на это
      if (state.currentSecondsForTask! == 0) {
        _outOfTaskTime();
        return;
      }
      //если еще есть, то ждем 1 секунду
      await Future.delayed(const Duration(seconds: 1));
      //и новое время записываем в стейт
      emit(state.copyWith(
          currentSecondsForTask: state.currentSecondsForTask! - 1));
    }
  }

  //сброс таймера примера
  //просто задаем начальное значение
  void _resetTaskTimer() {
    emit(state.copyWith(currentSecondsForTask: secondsForTask));
  }

  //реакция на окончание таймера примера
  void _outOfTaskTime() {
    //генерируем числа
    //там происходит сброс времени до начального значения
    _generateOperationAndDifficulty();
    //запускаем таймер заново, потому что у нас кончился цикл while
    _startTaskTimer();
  }

  //запускаем таймер сессии
  //логика аналогична таймеру примера
  void _startSessionTimer() async {
    while (state.currentSecondsForSession! >= 0) {
      if (state.currentSecondsForSession! == 0) {
        _outOfSessionTime();
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
          currentSecondsForSession: state.currentSecondsForSession! - 1));
    }
  }

  //реакция на окончание таймера сессии
  //здесь надо будет поставить статус, который замораживает приложение
  //чтобы пользователь не мог ничего ввести и т.д., только выйти из сессии
  //либо запустить ее заново
  //либо перейти в результаты
  void _outOfSessionTime() {}
}

class MainCubitState {
  AppStatus? appStatus;
  TestPageStatus? testPageStatus;
  int? currentNumber;
  int? firstNum;
  int? secondNum;
  int? result;
  int? operation;
  List<List<int>>? difficultyLevels;
  List<List<int>>? difficultyLevelsForSettings;
  int? initialSecondsForTask;
  int? currentSecondsForTask;
  int? currentSecondsForSession;
  TimerStatus? timerStatus;
  SessionStatus? sessionStatus;

  MainCubitState({
    this.appStatus,
    this.testPageStatus,
    this.currentNumber,
    this.firstNum,
    this.secondNum,
    this.result,
    this.operation,
    this.difficultyLevels,
    this.difficultyLevelsForSettings,
    this.initialSecondsForTask,
    this.currentSecondsForTask,
    this.currentSecondsForSession,
    this.timerStatus,
    this.sessionStatus,
  });

  MainCubitState copyWith({
    AppStatus? appStatus,
    TestPageStatus? testPageStatus,
    int? currentNumber,
    int? firstNum,
    int? secondNum,
    int? result,
    int? operation,
    List<List<int>>? difficultyLevels,
    List<List<int>>? difficultyLevelsForSettings,
    int? initialSecondsForTask,
    int? currentSecondsForTask,
    int? currentSecondsForSession,
    TimerStatus? timerStatus,
    SessionStatus? sessionStatus,
  }) {
    return MainCubitState(
      appStatus: appStatus ?? this.appStatus,
      testPageStatus: testPageStatus ?? this.testPageStatus,
      currentNumber: currentNumber ?? this.currentNumber,
      firstNum: firstNum ?? this.firstNum,
      secondNum: secondNum ?? this.secondNum,
      result: result ?? this.result,
      operation: operation ?? this.operation,
      difficultyLevels: difficultyLevels ?? this.difficultyLevels,
      difficultyLevelsForSettings:
          difficultyLevelsForSettings ?? this.difficultyLevelsForSettings,
      initialSecondsForTask:
          initialSecondsForTask ?? this.initialSecondsForTask,
      currentSecondsForTask:
          currentSecondsForTask ?? this.currentSecondsForTask,
      currentSecondsForSession:
          currentSecondsForSession ?? this.currentSecondsForSession,
      timerStatus: timerStatus ?? this.timerStatus,
      sessionStatus: sessionStatus ?? this.sessionStatus,
    );
  }
}

// класс, ответственный за генерацию чисел
class _Generator {
  static int operation = 0;
  static int firstNumber = 0;
  static int secondNumber = 0;
  static int result = 0;
  static int _firstNumMax = 0;
  static int _firstNumMin = 0;
  static int _secondNumMax = 0;
  static int _secondNumMin = 0;

  // метод, который запускается из кубита и который вызывает всё остальное
  // он возвращает операцию, первое число, второе число, правильный ответ
  static List<int> generateValues(List<List<int>> difficultyLevels) {
    _Generator._setOperationAndBothNumbers(difficultyLevels);
    return [
      _Generator.operation,
      _Generator.firstNumber,
      _Generator.secondNumber,
      _Generator.result
    ];
  }

  // записываем в переменные максимальное и минимальное значения чисел (в каком диапазоне мы их генерируем)
  // записываем в переменные тип операции и вызываем генерацию чисел
  static void _setOperationAndBothNumbers(List<List<int>> difficultyLevels) {
    List<int> listOfAvailableOperationTypes = [];
    for (int i = 0; i < difficultyLevels.length; i++) {
      if (difficultyLevels[i].isNotEmpty) {
        listOfAvailableOperationTypes.add(i);
      }
    }
    int operation = _generateAndReturnOperation(listOfAvailableOperationTypes);
    int difficultyLevel =
        _generateAndReturnDifficultyLevel(difficultyLevels[operation]);
    int firstNumMax = 0;
    int firstNumMin = 0;
    int secondNumMax = 0;
    int secondNumMin = 0;

    switch (difficultyLevel) {
      case 0:
        firstNumMax = 10;
        firstNumMin = 0;
        secondNumMax = 10;
        secondNumMin = 0;
        break;
      case 1:
        firstNumMax = 90;
        firstNumMin = 10;
        secondNumMax = 10;
        secondNumMin = 0;
        break;
      case 2:
        firstNumMax = 90;
        firstNumMin = 10;
        secondNumMax = 90;
        secondNumMin = 10;
        break;
      case 3:
        firstNumMax = 900;
        firstNumMin = 100;
        secondNumMax = 10;
        secondNumMin = 0;
        break;
      case 4:
        firstNumMax = 900;
        firstNumMin = 100;
        secondNumMax = 90;
        secondNumMin = 10;
        break;
      case 5:
        firstNumMax = 900;
        firstNumMin = 100;
        secondNumMax = 900;
        secondNumMin = 100;
        break;
    }
    _Generator.operation = operation;
    _Generator._firstNumMax = firstNumMax;
    _Generator._firstNumMin = firstNumMin;
    _Generator._secondNumMax = secondNumMax;
    _Generator._secondNumMin = secondNumMin;
    _Generator._setBothNumbers();
  }

  // генерируем и записываем в переменные наши сгенерированные числа и правильный ответ
  static void _setBothNumbers() {
    var rng = Random();
    int firstNumber;
    int secondNumber;
    firstNumber =
        rng.nextInt(_Generator._firstNumMax) + _Generator._firstNumMin;
    secondNumber =
        rng.nextInt(_Generator._secondNumMax) + _Generator._secondNumMin;
    if (firstNumber == 0 ||
        secondNumber == 0 ||
        firstNumber < secondNumber ||
        (_Generator.operation == 3 && firstNumber % secondNumber != 0)) {
      _Generator._setBothNumbers();
      return;
    } else {
      _Generator.firstNumber = firstNumber;
      _Generator.secondNumber = secondNumber;
      _Generator.result = _returnResult();
    }
  }

  // вычисляем результат (правильный ответ), основываясь на операции и числах
  static int _returnResult() {
    switch (_Generator.operation) {
      case 0:
        return _Generator.firstNumber + _Generator.secondNumber;
      case 1:
        return _Generator.firstNumber - _Generator.secondNumber;
      case 2:
        return _Generator.firstNumber * _Generator.secondNumber;
      case 3:
        return (_Generator.firstNumber / _Generator.secondNumber).round();
      default:
        return 0;
    }
  }

  // генерируем операцию (сложение, вычитание, умножение, деление)
  static int _generateAndReturnOperation(
      List<int> listOfAvailableOperationTypes) {
    int randomIndex = Random().nextInt(listOfAvailableOperationTypes.length);
    int operation = listOfAvailableOperationTypes[randomIndex];
    return operation;
  }

  // генерируем уровень сложности (0, 1, 2, 3, 4, 5)
  static int _generateAndReturnDifficultyLevel(
      List<int> listOfAvailableDifficultyLevels) {
    int randomIndex = Random().nextInt(listOfAvailableDifficultyLevels.length);
    int difficultyLevel = listOfAvailableDifficultyLevels[randomIndex];
    return difficultyLevel;
  }
}
