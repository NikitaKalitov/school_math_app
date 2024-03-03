import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/main_cubit.dart';

List<List<int>> localList = [];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    localList = context.read<MainCubit>().state.difficultyLevelsForSettings!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Настройки'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _SettingsPageOperationSection(textToShow: 'Сложение', children: [
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 0, textToShow: '9+3'),
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 1, textToShow: '99+3'),
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 2, textToShow: '99+33'),
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 3, textToShow: '999+3'),
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 4, textToShow: '999+33'),
              _SettingsPageCheckbox(
                  operationIndex: 0, difficultyIndex: 5, textToShow: '999+333'),
            ]),
            _SettingsPageOperationSection(textToShow: 'Вычитание', children: [
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 0, textToShow: '9-3'),
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 1, textToShow: '99-3'),
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 2, textToShow: '99-33'),
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 3, textToShow: '999-3'),
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 4, textToShow: '999-33'),
              _SettingsPageCheckbox(
                  operationIndex: 1, difficultyIndex: 5, textToShow: '999-333'),
            ]),
            _SettingsPageOperationSection(textToShow: 'Умножение', children: [
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 0, textToShow: '9*3'),
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 1, textToShow: '99*3'),
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 2, textToShow: '99*33'),
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 3, textToShow: '999*3'),
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 4, textToShow: '999*33'),
              _SettingsPageCheckbox(
                  operationIndex: 2, difficultyIndex: 5, textToShow: '999*333'),
            ]),
            _SettingsPageOperationSection(textToShow: 'Деление', children: [
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 0, textToShow: '9/3'),
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 1, textToShow: '99/3'),
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 2, textToShow: '99/33'),
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 3, textToShow: '999/3'),
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 4, textToShow: '999/33'),
              _SettingsPageCheckbox(
                  operationIndex: 3, difficultyIndex: 5, textToShow: '999/333'),
            ]),
            _SettingsPageSaveButton(),
          ],
        ),
      ),
    );
  }
}

//
//
// Widgets
//
//

class _SettingsPageOperationSection extends StatefulWidget {
  const _SettingsPageOperationSection({
    super.key,
    required this.children,
    required this.textToShow,
  });

  final List<Widget> children;
  final String textToShow;

  @override
  State<_SettingsPageOperationSection> createState() =>
      _SettingsPageOperationSectionState();
}

class _SettingsPageOperationSectionState
    extends State<_SettingsPageOperationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.textToShow),
        ...widget.children,
      ],
    );
  }
}

class _SettingsPageCheckbox extends StatefulWidget {
  const _SettingsPageCheckbox({
    super.key,
    required this.operationIndex,
    required this.difficultyIndex,
    required this.textToShow,
  });

  final int operationIndex;
  final int difficultyIndex;
  final String textToShow;

  @override
  State<_SettingsPageCheckbox> createState() => _SettingsPageCheckboxState();
}

class _SettingsPageCheckboxState extends State<_SettingsPageCheckbox> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = localList[widget.operationIndex][widget.difficultyIndex] == -1
        ? false
        : true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        value = !value;
        value
            ? localList[widget.operationIndex][widget.difficultyIndex] =
            widget.difficultyIndex
            : localList[widget.operationIndex][widget.difficultyIndex] =
        -1;
        setState(() {});
      },
      child: SizedBox(
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (value) {
                this.value = value!;
                value
                    ? localList[widget.operationIndex][widget.difficultyIndex] =
                        widget.difficultyIndex
                    : localList[widget.operationIndex][widget.difficultyIndex] =
                        -1;
                setState(() {});
              },
            ),
            Text(widget.textToShow),
          ],
        ),
      ),
    );
  }
}

class _SettingsPageSaveButton extends StatelessWidget {
  const _SettingsPageSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<MainCubit>().changeDifficulties(localList).then((value) {
          Navigator.of(context).pop();
        });
      },
      child: const Text('Сохранить'),
    );
  }
}
