import 'package:flutter/material.dart';
import 'package:n1/task_storage.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int, int)? onToggleSubTaskComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.onToggleSubTaskComplete,
  });

  @override
  Widget build(BuildContext context) {
    final category = TaskStorage.getCategoryById(task.categoryId, context);
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onToggleComplete(),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) 
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (category != null)
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontSize: 12,
                        ),
                      ),
                    if (category != null) const SizedBox(width: 8),
                    Text(
                      _getPriorityLabel(task.priority),
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontSize: 12,
                      ),
                    ),
                    if (task.dueDate != null) const SizedBox(width: 8),
                    if (task.dueDate != null)
                      Text(
                        DateFormat('dd/MM/yy').format(task.dueDate!),
                        style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ),
          // Exibir subtarefas
          if (task.subTasks.isNotEmpty)
            ...task.subTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subTask = entry.value;
              return Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 4.0),
                child: ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: subTask.isCompleted,
                    onChanged: (value) {
                      // Notificar o widget pai para reconstruir
                      if (onToggleSubTaskComplete != null) {
                        onToggleSubTaskComplete!(task.id!, index);
                      }
                    },
                  ),
                  title: Text(
                    subTask.title,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: subTask.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: subTask.description.isNotEmpty
                      ? Text(
                          subTask.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.normal:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Baixa';
      case Priority.normal:
        return 'Normal';
      case Priority.high:
        return 'Alta';
    }
  }
}
