import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_1/logic/main_cubit.dart';
import 'results_page.dart';
import 'settings_page.dart';
import 'test_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Устный счет'),
      ),
      body: Center(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MainPageButton(
                text: 'Настройки',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
                },
              ),
              _MainPageButton(
                text: 'Тест',
                onPressed: () {
                  if (context.read<MainCubit>().checkSettings()) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TestPage()));
                  }
                },
              ),
              _MainPageButton(
                text: 'Результаты',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ResultsPage()));
                },
              ),
            ],
          ),
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

class _MainPageButton extends StatelessWidget {
  const _MainPageButton(
      {super.key, required this.onPressed, required this.text});

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
