import 'package:flutter/material.dart';
import 'package:n1/auth_provider.dart';
import 'package:provider/provider.dart';

enum Priority { low, normal, high }

class Category {
  int? id;
  String name;
  Color color;
  IconData iconData;

  Category(this.name, this.color, this.iconData, {this.id});

  Icon get icon => Icon(iconData, color: color);
}

class Task {
  int? id;
  String title;
  String description;
  int categoryId;
  DateTime createdAt;
  DateTime? dueDate;
  Priority priority;
  bool isCompleted;
  List<Task> subTasks = [];

  Task(
    this.title,
    this.categoryId, {
    this.description = '',
    this.priority = Priority.normal,
    this.dueDate,
    this.isCompleted = false,
  }) : createdAt = DateTime.now();
}

class TaskStorage {
  static final Map<String, List<Task>> _tasks = {};
  static final Map<String, List<Category>> _categories = {};
  static int _taskCounter = 0;
  static int _categoryCounter = 0;

  static String _getUsername(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) throw Exception('Usuário não autenticado');
    return auth.authenticatedUser!;
  }

  static List<Task> _getUserTasks(BuildContext context) {
    return _tasks[_getUsername(context)] ?? [];
  }

  static List<Category> _getUserCategories(BuildContext context) {
    return _categories[_getUsername(context)] ?? [];
  }

  static void addTask(Task task, BuildContext context) {
    final username = _getUsername(context);
    _tasks.putIfAbsent(username, () => []);
    task.id = _taskCounter++;
    _tasks[username]!.add(task);
  }

  static List<Task> getTasks(BuildContext context) => _getUserTasks(context);

  static void removeTask(int id, BuildContext context) {
    _getUserTasks(context).removeWhere((task) => task.id == id);
  }

  static void editTask(
    int id,
    BuildContext context, {
    String? title,
    String? description,
    Priority? priority,
    int? categoryId,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    final task = getTaskById(id, context);
    if (task == null) return;

    if (title != null) task.title = title;
    if (description != null) task.description = description;
    if (priority != null) task.priority = priority;
    if (categoryId != null) task.categoryId = categoryId;
    if (dueDate != null) task.dueDate = dueDate;
    if (isCompleted != null) task.isCompleted = isCompleted;
  }

  static Task? getTaskById(int id, BuildContext context) {
    try {
      return _getUserTasks(context).firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  static void toggleTaskCompletion(int id, BuildContext context) {
    final task = getTaskById(id, context);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
    }
  }

  static void addSubTask(int parentTaskId, Task subTask, BuildContext context) {
    final parentTask = getTaskById(parentTaskId, context);
    if (parentTask != null) {
      subTask.id = _taskCounter++;
      parentTask.subTasks.add(subTask);
    }
  }

  static void removeSubTask(
    int parentTaskId,
    int subTaskId,
    BuildContext context,
  ) {
    final parentTask = getTaskById(parentTaskId, context);
    parentTask?.subTasks.removeWhere((subTask) => subTask.id == subTaskId);
  }

  static List<Task> getSubTasks(int parentTaskId, BuildContext context) {
    return getTaskById(parentTaskId, context)?.subTasks ?? [];
  }

  static List<Category> getCategories(BuildContext context) {
    return _getUserCategories(context);
  }

  static void addCategory(Category category, BuildContext context) {
    final username = _getUsername(context);
    _categories.putIfAbsent(username, () => []);
    category.id = _categoryCounter++;
    _categories[username]!.add(category);
  }

  static void editCategory(
    int id,
    BuildContext context, {
    String? name,
    Color? color,
    IconData? iconData,
  }) {
    final category = getCategoryById(id, context);
    if (category == null) return;

    if (name != null) category.name = name;
    if (color != null) category.color = color;
    if (iconData != null) category.iconData = iconData;
  }

  static bool removeCategory(int id, BuildContext context) {
    if (isCategoryInUse(id, context)) return false;

    _getUserCategories(context).removeWhere((cat) => cat.id == id);
    return true;
  }

  static Category? getCategoryById(int id, BuildContext context) {
    try {
      return _getUserCategories(context).firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static bool isCategoryInUse(int id, BuildContext context) {
    return _getUserTasks(context).any(
      (task) =>
          task.categoryId == id ||
          task.subTasks.any((subTask) => subTask.categoryId == id),
    );
  }

  static List<Task> getTasksByCategory(int categoryId, BuildContext context) {
    return _getUserTasks(
      context,
    ).where((task) => task.categoryId == categoryId).toList();
  }

  static List<Task> getCompletedTasks(BuildContext context) {
    return _getUserTasks(context).where((task) => task.isCompleted).toList();
  }

  static List<Task> getPendingTasks(BuildContext context) {
    return _getUserTasks(context).where((task) => !task.isCompleted).toList();
  }

  static List<Task> getTasksByPriority(
    Priority priority,
    BuildContext context,
  ) {
    return _getUserTasks(
      context,
    ).where((task) => task.priority == priority).toList();
  }

  static List<Task> getOverdueTasks(BuildContext context) {
    final now = DateTime.now();
    return _getUserTasks(context)
        .where(
          (task) =>
              task.dueDate != null &&
              task.dueDate!.isBefore(now) &&
              !task.isCompleted,
        )
        .toList();
  }
}
