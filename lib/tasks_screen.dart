import 'package:flutter/material.dart';
import 'package:n1/task_storage.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final tasks = TaskStorage.getTasks(context);
    final categories = TaskStorage.getCategories(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crie uma categoria primeiro!'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            _showTaskDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma tarefa cadastrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final category = TaskStorage.getCategoryById(
                  task.categoryId,
                  context,
                );
                final isOverdue =
                    task.dueDate != null &&
                    task.dueDate!.isBefore(DateTime.now()) &&
                    !task.isCompleted;

                Color getPriorityColor(Priority priority) {
                  switch (priority) {
                    case Priority.low:
                      return Colors.green;
                    case Priority.normal:
                      return Colors.orange;
                    case Priority.high:
                      return Colors.red;
                  }
                }

                IconData getPriorityIcon(Priority priority) {
                  switch (priority) {
                    case Priority.low:
                      return Icons.arrow_downward;
                    case Priority.normal:
                      return Icons.remove;
                    case Priority.high:
                      return Icons.arrow_upward;
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  elevation: task.priority == Priority.high ? 4 : 2,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        category != null
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  category.iconData,
                                  color: category.color,
                                ),
                              )
                            : const Icon(Icons.task),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: getPriorityColor(task.priority),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              getPriorityIcon(task.priority),
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
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
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: category.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: isOverdue
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _dateFormat.format(task.dueDate!),
                                      style: TextStyle(
                                        color: isOverdue
                                            ? Colors.red
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            TaskStorage.toggleTaskCompletion(task.id!, context);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTaskDialog(context, task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(context, task.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTaskDialog(BuildContext context, [Task? task]) {
    final isEditing = task != null;
    final titleController = TextEditingController(text: task?.title);
    final descriptionController = TextEditingController(
      text: task?.description,
    );
    final categories = TaskStorage.getCategories(context);
    int selectedCategoryId = task?.categoryId ?? categories.first.id!;
    Priority selectedPriority = task?.priority ?? Priority.normal;
    DateTime? selectedDueDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Categoria:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.iconData, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prioridade:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: Priority.low,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Baixa'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: Priority.normal,
                      child: Row(
                        children: [
                          Icon(Icons.remove, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Normal'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: Priority.high,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Alta'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedPriority = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Data de vencimento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDueDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          selectedDueDate != null
                              ? _dateFormat.format(selectedDueDate!)
                              : 'Selecionar data',
                        ),
                        const Spacer(),
                        if (selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setDialogState(() => selectedDueDate = null);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (isEditing) {
                    TaskStorage.editTask(
                      task.id!,
                      context,
                      title: titleController.text,
                      description: descriptionController.text,
                      categoryId: selectedCategoryId,
                      priority: selectedPriority,
                      dueDate: selectedDueDate,
                    );
                  } else {
                    TaskStorage.addTask(
                      Task(
                        titleController.text,
                        selectedCategoryId,
                        description: descriptionController.text,
                        priority: selectedPriority,
                        dueDate: selectedDueDate,
                      ),
                      context,
                    );
                  }
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tarefa'),
        content: const Text('Deseja realmente excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              TaskStorage.removeTask(taskId, context);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarefa excluída com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
