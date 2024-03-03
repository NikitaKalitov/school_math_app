import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/main_cubit.dart';
import '../styles/styles.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Тест'),
      ),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(flex: 3, child: Center(child: _TestPageMainWidget())),
          _ExpandedRowWithFlex(children: [
            _NumberButton(number: 7),
            _NumberButton(number: 8),
            _NumberButton(number: 9),
          ]),
          _ExpandedRowWithFlex(children: [
            _NumberButton(number: 4),
            _NumberButton(number: 5),
            _NumberButton(number: 6),
          ]),
          _ExpandedRowWithFlex(children: [
            _NumberButton(number: 1),
            _NumberButton(number: 2),
            _NumberButton(number: 3),
          ]),
          _ExpandedRowWithFlex(children: [
            _FuncButton(func: 'delete'),
            _NumberButton(number: 0),
            _FuncButton(func: 'skip'),
          ]),
        ],
      ),
    );
  }
}

//
//
// Widgets
//
//

class _ExpandedRowWithFlex extends StatelessWidget {
  const _ExpandedRowWithFlex({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}

class _TestPageMainWidget extends StatefulWidget {
  const _TestPageMainWidget({super.key});

  @override
  State<_TestPageMainWidget> createState() => _TestPageMainWidgetState();
}

class _TestPageMainWidgetState extends State<_TestPageMainWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainCubitState>(
      builder: (context, state) {
        return Text(
          context.read<MainCubit>().getMainWidgetText(),
          style: const TextStyle(
            fontSize: taskTextSize,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class _NumberButton extends StatefulWidget {
  const _NumberButton({super.key, required this.number});

  final int number;

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        margin: const EdgeInsets.all(5),
        child: InkWell(
          child: Center(
            child: Text(
              widget.number.toString(),
              style: const TextStyle(
                fontSize: buttonTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            context.read<MainCubit>().addDigitToNumber(widget.number);
          },
        ),
      ),
    );
  }
}

class _FuncButton extends StatefulWidget {
  const _FuncButton({super.key, required this.func});

  final String func;

  @override
  State<_FuncButton> createState() => _FuncButtonState();
}

class _FuncButtonState extends State<_FuncButton> {
  String funcToText() {
    String text = '';
    switch (widget.func) {
      case 'delete':
        text = 'DEL';
        break;
      case 'skip':
        text = 'SKIP';
        break;
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        margin: const EdgeInsets.all(5),
        child: InkWell(
          child: Center(
            child: Text(
              funcToText(),
              style: const TextStyle(
                fontSize: buttonTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            context.read<MainCubit>().skipOrDelete(widget.func);
          },
          onLongPress: () {
            if (widget.func == 'delete') {
              context.read<MainCubit>().clearInput();
            }
          },
        ),
      ),
    );
  }
}
