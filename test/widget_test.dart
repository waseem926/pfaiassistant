import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfaiassistant/core/widgets/theme_toggle_button.dart';
import 'package:pfaiassistant/features/settings/presentation/bloc/theme_cubit.dart';

void main() {
  testWidgets('Theme toggle button renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ThemeCubit(),
          child: const Scaffold(
            body: ThemeToggleButton(),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}
