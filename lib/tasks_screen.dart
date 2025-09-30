import 'package:flutter/material.dart';
import 'package:n1/task_storage.dart';
import 'package:n1/task_card.dart';
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
                return TaskCard(
                  task: tasks[index],
                  onToggleComplete: () {
                    TaskStorage.toggleTaskCompletion(tasks[index].id!, context);
                    setState(() {});
                  },
                  onEdit: () => _showTaskDialog(context, tasks[index]),
                  onDelete: () => _confirmDelete(context, tasks[index].id!),
                  onToggleSubTaskComplete: (parentTaskId, subTaskIndex) {
                    TaskStorage.toggleSubTaskCompletion(parentTaskId, subTaskIndex, context);
                    setState(() {});
                  },
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
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.iconData, color: cat.color, size: 20),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Priority.low,
                      child: Text('Baixa'),
                    ),
                    DropdownMenuItem(
                      value: Priority.normal,
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: Priority.high,
                      child: Text('Alta'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedPriority = value!);
                  },
                ),
                const SizedBox(height: 16),
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
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de vencimento',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          selectedDueDate != null
                              ? _dateFormat.format(selectedDueDate!)
                              : 'Selecionar data',
                        ),
                      ],
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSubTaskDialog(context, task!);
                    },
                    child: const Text('Adicionar Subtarefa'),
                  ),
                ],
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

  void _showSubTaskDialog(BuildContext context, Task parentTask) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categories = TaskStorage.getCategories(context);
    int selectedCategoryId = categories.first.id!;
    Priority selectedPriority = Priority.normal;
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nova Subtarefa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategoryId = value!);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Priority.low,
                      child: Text('Baixa'),
                    ),
                    DropdownMenuItem(
                      value: Priority.normal,
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: Priority.high,
                      child: Text('Alta'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedPriority = value!);
                  },
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
                  TaskStorage.addSubTask(
                    parentTask.id!,
                    Task(
                      titleController.text,
                      selectedCategoryId,
                      description: descriptionController.text,
                      priority: selectedPriority,
                      dueDate: selectedDueDate,
                    ),
                    context,
                  );
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int taskId) {
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Tarefa excluída!')));
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
