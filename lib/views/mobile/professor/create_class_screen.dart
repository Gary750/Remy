import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remy/providers/auth_provider.dart';
import 'package:remy/providers/class_provider.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/loading_widget.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTerm;
  String? _selectedSubject;
  String? _selectedGroup;

  final List<String> _terms = [
    '1er Cuatrimestre',
    '2do Cuatrimestre',
    '3er Cuatrimestre',
    '4to Cuatrimestre',
    '5to Cuatrimestre',
    '6to Cuatrimestre',
    '7mo Cuatrimestre',
    '8vo Cuatrimestre',
    '9no Cuatrimestre',
    '10mo Cuatrimestre',
  ];

  final List<String> _groups = ['A', 'B', 'C', 'D', 'E'];

  final Map<String, List<String>> _subjectsByTerm = {
    '7mo Cuatrimestre': ['Cocina Mexicana I', 'Cocina Asiática'],
    '8vo Cuatrimestre': ['Cocina Mexicana II', 'Cocina Europea'],
    '9no Cuatrimestre': ['Cocina de Fusión', 'Cocina Mediterránea'],
    '10mo Cuatrimestre': ['Cocina Internacional', 'Repostería Avanzada'],
    '6to Cuatrimestre': ['Cocina Internacional', 'Repostería'],
    '5to Cuatrimestre': ['Cocina Internacional', 'Repostería'],
    '4to Cuatrimestre': ['Cocina Mediterránea', 'Panadería'],
    '3er Cuatrimestre': ['Técnicas Culinarias', 'Seguridad e Higiene'],
    '2do Cuatrimestre': ['Cocina Básica', 'Manejo de Alimentos'],
    '1er Cuatrimestre': ['Introducción a la Cocina', 'Higiene y Seguridad'],
  };

  List<String> get _availableSubjects {
    if (_selectedTerm == null) return [];
    return _subjectsByTerm[_selectedTerm!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Clase'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: classProvider.isLoading
          ? const LoadingWidget(message: 'Creando clase...')
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nueva Clase',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa los datos para crear una nueva clase',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Cuatrimestre',
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
                      value: _selectedTerm,
                      items: _terms.map((term) {
                        return DropdownMenuItem(
                          value: term,
                          child: Text(term),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTerm = value;
                          _selectedSubject = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un cuatrimestre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Materia',
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
                      value: _selectedSubject,
                      items: _availableSubjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubject = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona una materia';
                        }
                        return null;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Grupo',
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
                      value: _selectedGroup,
                      items: _groups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text('Grupo $group'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un grupo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    if (classProvider.error != null)
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
                                classProvider.error!,
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
                            text: 'Crear Clase',
                            onPressed: _createClass,
                            isLoading: classProvider.isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _createClass() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await Provider.of<ClassProvider>(context, listen: false)
        .createClass(
          professorId: authProvider.currentUser!.id,
          subject: _selectedSubject!,
          term: _selectedTerm!,
          groupName: _selectedGroup!,
        );

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }
}