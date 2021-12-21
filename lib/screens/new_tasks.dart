import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_tasks/cubit/cubit.dart';
import 'package:first_tasks/cubit/states.dart';
import 'package:first_tasks/components.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var tasks = AppCubit.get(context).newTasks;
        var status = 'new';
        return taskBuilder(tasks, status);
      },
    );
  }
}
