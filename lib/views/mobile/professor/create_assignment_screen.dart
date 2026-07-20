import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/assignment_provider.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;

  const CreateAssignmentScreen({
    super.key,
    required this.classId,
  });

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  String? _selectedRecipeType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _recipeTypes = ['Comida', 'Bebida', 'Ambos'];

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime? get _dueDateTime {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Entrega'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: assignmentProvider.isLoading
          ? const LoadingWidget(message: 'Publicando entrega...')
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crear Entrega de Recetario',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Define los detalles de la nueva entrega',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Nombre de la entrega
                      CustomTextField(
                        controller: _titleController,
                        label: 'Nombre de la entrega',
                        hint: 'Ej. Recetario Unidad 3',
                        prefixIcon: Icons.book_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tipo de recetario
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Tipo de recetario',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: _selectedRecipeType,
                        items: _recipeTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRecipeType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona un tipo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fecha y Hora
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Fecha límite',
                              hint: 'Selecciona fecha',
                              prefixIcon: Icons.calendar_today_outlined,
                              readOnly: true,
                              onTap: _selectDate,
                              controller: TextEditingController(
                                text: _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : '',
                              ),
                              validator: (value) {
                                if (_selectedDate == null) {
                                  return 'Selecciona una fecha';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Hora límite',
                              hint: 'Selecciona hora',
                              prefixIcon: Icons.access_time_outlined,
                              readOnly: true,
                              onTap: _selectTime,
                              controller: TextEditingController(
                                text: _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : '',
                              ),
                              validator: (value) {
                                if (_selectedTime == null) {
                                  return 'Selecciona una hora';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instrucciones
                      CustomTextField(
                        controller: _instructionsController,
                        label: 'Instrucciones adicionales',
                        hint: 'Opcional',
                        prefixIcon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      if (assignmentProvider.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  assignmentProvider.error!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancelar',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: 'Publicar Entrega',
                              onPressed: _createAssignment,
                              isLoading: assignmentProvider.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    final dueDate = _dueDateTime;
    if (dueDate == null) return;

    print('📝 Creando entrega:');
    print('  - Título: ${_titleController.text.trim()}');
    print('  - Tipo: $_selectedRecipeType');
    print('  - Fecha límite: $dueDate');

    final success = await Provider.of<AssignmentProvider>(context, listen: false)
        .createAssignment(
          classId: widget.classId,
          title: _titleController.text.trim(),
          recipeType: _selectedRecipeType!, // 'Comida', 'Bebida' o 'Ambos'
          dueDate: dueDate,
          instructions: _instructionsController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Entrega creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}