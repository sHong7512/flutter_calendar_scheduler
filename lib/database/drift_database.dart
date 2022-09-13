import 'dart:io';

import 'package:calendar_scheduler/model/category_color.dart';
import 'package:calendar_scheduler/model/schedule.dart';
import 'package:calendar_scheduler/model/schedule_with_color.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

// import는 private 값들은 불러올 수 없다.
// part는 private 값까지 불러올 수 있다.
// 현재 파일.g.dart 는 generated로써 특정 커맨드를 실행해서 자동으로 생성되게 함

@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  // _$LocalDatabase 는 'drift_database.g.dart'이 파일에 _$LocalDatabase이 클래스가 들어감
  LocalDatabase() : super(_openContection());

  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> createCategotyColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  removeAllSchedule() => delete(schedules).go();

  Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle();

      // stream은 get이 아니고 watch를 쓴다
  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    // (a..toString()) 는 a.apply{ toString() }와 같음
    // int number = 3;
    // final resp = number.toString();
    // final resp2 = number..toString();

    // 정석
    // final query = select(schedules);
    // query.where((tbl) => tbl.date.equals(date));
    // return query.watch();

    // 단순화
    // (select(schedules)..where((tbl) => tbl.date.equals(date))).watch();

    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);

    query.where(schedules.date.equals(date));
    query.orderBy([
      OrderingTerm.asc(schedules.startTime),
    ]);

    return query.watch().map(
          (rows) =>
          rows
              .map(
                (row) =>
                ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
          )
              .toList(),
    );
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openContection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase(file);
  });
}
