import 'package:flutter/material.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_tasks/cubit/cubit.dart';
import 'package:first_tasks/cubit/states.dart';

var scaffoldKey = GlobalKey<ScaffoldState>(); //to showBottomSheet
var formKey = GlobalKey<FormState>(); //to form validate
var titleController = TextEditingController();
var timeController = TextEditingController();
var dateController = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      //to create database first time & once .. (initState)
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
              centerTitle: true,
            ),
            body: ConditionalBuilder(
              //conditional_builder pubspec
              condition: state is! AppDatabaseLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.grey)),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);
                  }
                } else {
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) {
                          return Container(
                            padding: const EdgeInsets.only(
                                bottom: 20.0,
                                left: 20.0,
                                right: 20.0,
                                top: 5.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard_arrow_down_sharp,
                                      color: Colors.indigo, size: 30.0),
                                  const SizedBox(height: 5.0),
                                  TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Task Title',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.title,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      controller: titleController,
                                      keyboardType: TextInputType.text,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Task Title is Empty';
                                        } else {
                                          return null;
                                        }
                                      }),
                                  const SizedBox(height: 15.0),
                                  TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Time',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.alarm,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) {
                                          timeController.text =
                                              value.format(context).toString();
                                        });
                                      },
                                      controller: timeController,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Time is Empty';
                                        } else {
                                          return null;
                                        }
                                      }),
                                  const SizedBox(height: 15.0),
                                  TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Date',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(
                                          Icons.date_range,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate:
                                              DateTime.parse('2025-01-01'),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd()
                                                  .format(value); //intl pubspec
                                        });
                                      },
                                      controller: dateController,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Date is Empty';
                                        } else {
                                          return null;
                                        }
                                      }),
                                ],
                              ),
                            ),
                          );
                        },
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                        cubit.changeBottomSheetState(
                            isShow: false, icon: Icons.edit);
                      });
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 20.0,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                {
                  cubit.changeIndex(index);
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'done'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archived')
              ],
            ),
          );
        },
      ),
    );
  }
}
