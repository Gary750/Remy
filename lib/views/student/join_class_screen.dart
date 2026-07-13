import 'package:flutter/material.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_text_field.dart';

void showJoinClassModal(BuildContext context) {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // Usamos StatefulBuilder para poder actualizar el estado del botón de carga dentro del modal
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100], 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Icon(Icons.class_, color: Colors.orange[800]),
                ),
                const SizedBox(width: 12),
                const Text('Unirse a una clase', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingresa el código que te proporcionó tu profesor para unirte.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: codeController,
                  label: 'Código de clase',
                  hint: 'Ej. GAS-5B-7K2',
                  onChanged: (value) {
                    // Forzamos a mayúsculas como pide el requerimiento
                    codeController.value = TextEditingValue(
                      text: value.toUpperCase(),
                      selection: codeController.selection,
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'No distingue mayúsculas ni minúsculas',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              SizedBox(
                width: 140,
                child: CustomButton(
                  text: 'Unirse',
                  isLoading: isLoading,
                  onPressed: () async {
                    if (codeController.text.isEmpty) return;
                    
                    setState(() => isLoading = true);
                    
                    // TODO: Aquí conectaremos el student_controller.dart más adelante
                    await Future.delayed(const Duration(seconds: 1)); // Simulación
                    
                    setState(() => isLoading = false);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Te has unido a la clase exitosamente!'), 
                          backgroundColor: Colors.green
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
      );
    },
  );
}