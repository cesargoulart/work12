import 'package:flutter/material.dart';
import 'database_helper.dart';

class TaskService {
  static Future<void> addTask(String title, String description, String status) async {
    final task = {
      'title': title,
      'description': description,
      'status': status,
    };
    await DatabaseHelper().insertTask(task);
  }

  static Future<List<Map<String, dynamic>>> fetchTasks() async {
    return await DatabaseHelper().getTasks();
  }

  static Future<void> updateTask(int id, String title, String description, String status) async {
    final task = {
      'title': title,
      'description': description,
      'status': status,
    };
    await DatabaseHelper().updateTask(task, id);
  }

  static Future<void> deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
  }
}
