import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:first_tasks/cubit/cubit.dart';

Widget buildTaskItem(Map model, context, status) {
  return Dismissible(
    key: Key(model['id'].toString()), //required Key could be any String
    onDismissed: (direction) {
      AppCubit.get(context).deleteData(id: model['id']);
    },
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text('${model['time']}'),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${model['title']}',
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5.0),
                Text('${model['date']}',
                    style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          ConditionalBuilder(
            condition: status == 'new',
            builder: (context) {
              return Expanded(
                flex: 1,
                child: MaterialButton(
                    onPressed: () {
                      AppCubit.get(context)
                          .updateData(status: 'done', id: model['id']);
                    },
                    child: const Icon(
                      Icons.check_box_outlined,
                      color: Colors.deepPurpleAccent,
                    )),
              );
            },
            fallback: (context) => ConditionalBuilder(
              condition: status == 'done',
              builder: (context) {
                return Expanded(
                  flex: 1,
                  child: MaterialButton(
                      onPressed: () {
                        AppCubit.get(context)
                            .updateData(status: 'archived', id: model['id']);
                      },
                      child: const Icon(
                        Icons.archive_outlined,
                        color: Colors.deepPurpleAccent,
                      )),
                );
              },
              fallback: (context) => Expanded(
                flex: 1,
                child: MaterialButton(
                    onPressed: () {
                      AppCubit.get(context)
                          .updateData(status: 'done', id: model['id']);
                    },
                    child: const Icon(
                      Icons.check_box_outlined,
                      color: Colors.deepPurpleAccent,
                    )),
              ),
            ),
          ),
          ConditionalBuilder(
            condition: status == 'new',
            builder: (context) {
              return Expanded(
                flex: 1,
                child: MaterialButton(
                    onPressed: () {
                      AppCubit.get(context)
                          .updateData(status: 'archived', id: model['id']);
                    },
                    child: const Icon(
                      Icons.archive_outlined,
                      color: Colors.deepPurpleAccent,
                    )),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget taskBuilder(List<Map> tasks, var status) => ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) =>
              buildTaskItem(tasks[index], context, status),
          separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
              child: Container(
                  width: double.infinity,
                  height: 2.5,
                  color: Colors.grey[300])), //_____
          itemCount: tasks.length),
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu, size: 150, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Tasks yet.',
              style: TextStyle(fontSize: 25, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
