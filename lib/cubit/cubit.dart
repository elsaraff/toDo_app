import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:first_tasks/cubit/states.dart';
import 'package:first_tasks/screens/archived_tasks.dart';
import 'package:first_tasks/screens/done_tasks.dart';
import 'package:first_tasks/screens/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppIntialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  List<Widget> screens = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen()
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database database;

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      debugPrint('Database Created');
      database
          .execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY,'
              ' title TEXT , date TEXT , time TEXT , status TEXT)')
          .then((value) {
        debugPrint('Table Created');
      }).catchError((error) {
        debugPrint('Error when creating table ${error.toString()}');
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      debugPrint('Database Opened');
    }).then((value) {
      database = value;
      emit(AppCreatDatabaseState());
    });
  }

  insertToDatabase({
    @required String title,
    @required String date,
    @required String time,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
        'INSERT INTO tasks (title, date, time, status) VALUES ("$title", "$date", "$time", "new")',
      )
          .then((value) {
        debugPrint('$value Inserted Done');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {
        debugPrint('Error when inserted ${error.toString()}');
      });
      return null;
    });
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });

      emit(AppGetDatabaseState());
      debugPrint('New Tasks ' + newTasks.toString());
      debugPrint('Done Tasks ' + doneTasks.toString());
      debugPrint('Archived Tasks ' + archivedTasks.toString());
    });
  }

  void updateData({
    @required String status,
    @required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status =? WHERE id =?',
      [status, id],
    ).then((value) {
      emit(AppUpdateDatabaseState());
      getDataFromDatabase(database);
    });
  }

  void deleteData({
    @required int id,
  }) async {
    database.rawDelete(
      'DELETE FROM tasks WHERE id =?',
      [id],
    ).then((value) {
      emit(AppDeleteDatabaseState());
      getDataFromDatabase(database);
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}
