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
    final isOverdue =
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          // Parte principal da tarefa
          ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) => onToggleComplete(),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: _buildTaskInfo(category, isOverdue),
            trailing: _buildActionButtons(),
          ),
          // Subtasks
          if (task.subTasks.isNotEmpty) ..._buildSubTasks(),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(Category? category, bool isOverdue) {
    return Column(
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
        Wrap(
          spacing: 8,
          children: [
            if (category != null)
              Text(
                category.name,
                style: TextStyle(color: category.color, fontSize: 12),
              ),
            Text(
              _getPriorityLabel(task.priority),
              style: TextStyle(
                color: _getPriorityColor(task.priority),
                fontSize: 12,
              ),
            ),
          ],
        ),
        // Data de vencimento destacada
        if (task.dueDate != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isOverdue ? Colors.red : Colors.blue,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isOverdue ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Vence: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(Atrasada)',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          onPressed: onDelete,
        ),
      ],
    );
  }

  List<Widget> _buildSubTasks() {
    return task.subTasks.asMap().entries.map((entry) {
      final index = entry.key;
      final subTask = entry.value;

      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 4.0),
        child: ListTile(
          dense: true,
          leading: Checkbox(
            value: subTask.isCompleted,
            onChanged: (value) {
              onToggleSubTaskComplete?.call(task.id!, index);
            },
          ),
          title: Text(
            subTask.title,
            style: TextStyle(
              fontSize: 14,
              decoration: subTask.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: subTask.description.isNotEmpty
              ? Text(
                  subTask.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                )
              : null,
        ),
      );
    }).toList();
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
