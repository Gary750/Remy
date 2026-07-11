import 'package:flutter/material.dart';
// import 'package:remy/controllers/class_controller.dart'; // TODO: Descomentar
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  // TODO: Inicializar ClassController
  // final ClassController classController = ClassController();
  
  String? selectedSemester;
  String? selectedSubject;
  String? selectedGroup;
  bool isLoading = false;
  
  final List<String> semesters = ['1°', '2°', '3°', '4°', '5°', '7°', '8°', '9°', '10°'];
  
  // TODO: Esto debería venir de la base de datos
  final Map<String, List<String>> subjectsBySemester = {
    '1°': ['Introducción a la Cocina', 'Seguridad e Higiene'],
    '2°': ['Técnicas Culinarias I', 'Cocina Internacional I'],
    '3°': ['Técnicas Culinarias II', 'Cocina Internacional II'],
    '4°': ['Repostería Básica', 'Panadería'],
    '5°': ['Cocina Mexicana I', 'Cocina Europea'],
    '7°': ['Cocina Mexicana I', 'Cocina Asiática'],
    '8°': ['Cocina Mexicana II', 'Cocina Europea Avanzada'],
    '9°': ['Repostería Avanzada', 'Cocina Internacional'],
    '10°': ['Administración de Restaurantes', 'Alta Cocina'],
  };
  
  final List<String> groups = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Clase'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crear Nueva Clase',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa los datos para crear una nueva clase',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  _buildSemesterDropdown(),
                  const SizedBox(height: 16),
                  _buildSubjectDropdown(),
                  const SizedBox(height: 16),
                  _buildGroupDropdown(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedSemester,
      decoration: const InputDecoration(
        labelText: 'Cuatrimestre *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      items: semesters.map((semester) {
        return DropdownMenuItem<String>(
          value: semester,
          child: Text('$semester Cuatrimestre'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSemester = value;
          selectedSubject = null; // Resetear materia al cambiar semestre
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un cuatrimestre';
        }
        return null;
      },
    );
  }

  Widget _buildSubjectDropdown() {
    final subjects = selectedSemester != null 
        ? subjectsBySemester[selectedSemester!] ?? []
        : [];
    
    return DropdownButtonFormField<String>(
      value: selectedSubject,
      decoration: const InputDecoration(
        labelText: 'Materia *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.book),
      ),
      items: subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject,
          child: Text(subject),
        );
      }).toList(),
      onChanged: selectedSemester == null ? null : (value) {
        setState(() {
          selectedSubject = value;
        });
      },
      hint: Text(
        selectedSemester == null 
            ? 'Primero selecciona un cuatrimestre' 
            : 'Selecciona una materia',
      ),
      validator: (value) {
        if (value == null) {
          return 'Selecciona una materia';
        }
        return null;
      },
    );
  }

  Widget _buildGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGroup,
      decoration: const InputDecoration(
        labelText: 'Grupo *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.group),
      ),
      items: groups.map((group) {
        return DropdownMenuItem<String>(
          value: group,
          child: Text('Grupo $group'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedGroup = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecciona un grupo';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Crear Clase',
            onPressed: _createClass,
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  void _createClass() async {
    // Validación
    if (selectedSemester == null || selectedSubject == null || selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // TODO: Conectar con Supabase
    /*
    try {
      final newClass = {
        'semester': selectedSemester,
        'subject': selectedSubject,
        'group': selectedGroup,
        'name': '$selectedSubject -- Grupo $selectedGroup',
        'code': _generateClassCode(),
      };
      await classController.createClass(newClass);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Clase creada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    */

    // Simulación (eliminar después)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Clase creada exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }

  // TODO: Implementar generación de código único con Supabase
  String _generateClassCode() {
    final String prefix = selectedSubject!.substring(0, 3).toUpperCase();
    final String semester = selectedSemester!.replaceAll('°', '');
    final String group = selectedGroup!;
    final String random = String.fromCharCodes(
      List.generate(2, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.codeUnitAt(
        DateTime.now().millisecondsSinceEpoch % 26,
      )),
    ) + (DateTime.now().millisecondsSinceEpoch % 9 + 1).toString();
    
    return '$prefix-$semester$group-$random';
  }
}