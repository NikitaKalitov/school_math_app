import 'package:flutter/material.dart';
import './logic/main_cubit.dart';
import './ui/pages/app_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>(
          create: (context) => MainCubit(),
        ),
      ],
      child: const MyApp(),
    )
  );
}
