import 'package:calendar_scheduler/database/drift_database.dart';
import 'package:calendar_scheduler/screen/home_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

const DEFAULT_COLORS = [
  'F44336',
  'FF9800',
  'FFEB3B',
  'FCAF50',
  '2196F3',
  '3F51B5',
  '9C27B0',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 플러터 준비 됫는지 확인하는 함수, runApp만 있을경우엔 runApp에서 알아서 차리함
  // runApp 이전에 함수가 있을경우 검사해줘야함.

  await initializeDateFormatting();

  final database = LocalDatabase();
  GetIt.I.registerSingleton<LocalDatabase>(database);

  final colors = await database.getCategoryColors();

  if (colors.isEmpty) {
    for (String hexCode in DEFAULT_COLORS) {
      await database.createCategotyColor(CategoryColorsCompanion(
        hexCode: Value(hexCode),
      ));
    }
  }

  print(await database.getCategoryColors());

  runApp(
    MaterialApp(
      home: HomeScreen(),
    ),
  );
}
