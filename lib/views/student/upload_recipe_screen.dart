import 'package:flutter/material.dart';
// import 'package:remy/controllers/recipe_controller.dart'; // TODO: Descomentar
// import 'package:remy/services/storage_service.dart'; // TODO: Descomentar (subida a bucket recipes_images)
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class UploadRecipeScreen extends StatefulWidget {
  final String assignmentId;
  final String classId;
  /// Tipo forzado por la entrega ('Comida', 'Bebida' o 'Ambos').
  /// Si es 'Ambos', el alumno elige entre los dos.
  final String recipeType;

  const UploadRecipeScreen({
    super.key,
    required this.assignmentId,
    required this.classId,
    required this.recipeType,
  });

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  // TODO: Inicializar RecipeController
  // final RecipeController recipeController = RecipeController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController miseEnPlaceController = TextEditingController();
  final TextEditingController sauceController = TextEditingController();
  final TextEditingController procedureController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController portionsController = TextEditingController();

  String? selectedType;
  String? selectedCookingStyle;
  bool isLoading = false;

  // TODO: Reemplazar por File/Uint8List real desde ImagePicker
  String? pickedImagePath;

  final List<String> cookingStyles = [
    'Horneado',
    'Frito',
    'Hervido',
    'Al vapor',
    'A la plancha',
    'Crudo',
    'Asado',
  ];

  // Lista dinámica de ingredientes -- se guarda como JSONB
  // Cada item: {'name': ..., 'quantity': ...}
  final List<Map<String, TextEditingController>> ingredientControllers = [];

  @override
  void initState() {
    super.initState();
    selectedType = widget.recipeType == 'Ambos' ? null : widget.recipeType;
    _addIngredientRow(); // Empieza con un ingrediente vacío
  }

  void _addIngredientRow() {
    setState(() {
      ingredientControllers.add({
        'name': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeIngredientRow(int index) {
    setState(() {
      ingredientControllers[index]['name']!.dispose();
      ingredientControllers[index]['quantity']!.dispose();
      ingredientControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    regionController.dispose();
    miseEnPlaceController.dispose();
    sauceController.dispose();
    procedureController.dispose();
    prepTimeController.dispose();
    portionsController.dispose();
    for (final row in ingredientControllers) {
      row['name']!.dispose();
      row['quantity']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Receta'),
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
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Nueva Receta',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Completa los datos de tu receta',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: nameController,
                      label: 'Nombre de la receta *',
                      hint: 'Ej. Mole Poblano',
                      prefixIcon: Icons.restaurant_menu,
                    ),
                    const SizedBox(height: 16),

                    if (widget.recipeType == 'Ambos') ...[
                      _buildTypeDropdown(),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: countryController,
                            label: 'País *',
                            hint: 'Ej. México',
                            prefixIcon: Icons.public,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: regionController,
                            label: 'Región',
                            hint: 'Ej. Puebla',
                            prefixIcon: Icons.map,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildCookingStyleDropdown(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: prepTimeController,
                            label: 'Tiempo de preparación',
                            hint: 'Ej. 45 min',
                            prefixIcon: Icons.timer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: portionsController,
                            label: 'Porciones',
                            hint: 'Ej. 4',
                            prefixIcon: Icons.people,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: miseEnPlaceController,
                      label: 'Mise en place',
                      hint: 'Preparación previa de ingredientes...',
                      prefixIcon: Icons.checklist,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    _buildIngredientsSection(),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: procedureController,
                      label: 'Procedimiento *',
                      hint: 'Describe paso a paso la preparación...',
                      prefixIcon: Icons.menu_book,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: sauceController,
                      label: 'Salsa / acompañamiento (opcional)',
                      hint: 'Ej. Salsa verde',
                      prefixIcon: Icons.water_drop,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: pickedImagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Toca para agregar una foto',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 48)),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white),
                            onPressed: () => setState(() => pickedImagePath = null),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Tipo de receta *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'Comida', child: Text('Comida')),
        DropdownMenuItem(value: 'Bebida', child: Text('Bebida')),
      ],
      onChanged: (value) => setState(() => selectedType = value),
    );
  }

  Widget _buildCookingStyleDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCookingStyle,
      decoration: const InputDecoration(
        labelText: 'Estilo de cocción',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_fire_department),
      ),
      items: cookingStyles.map((style) {
        return DropdownMenuItem(value: style, child: Text(style));
      }).toList(),
      onChanged: (value) => setState(() => selectedCookingStyle = value),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredientes *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: _addIngredientRow,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        ...List.generate(ingredientControllers.length, (index) {
          final row = ingredientControllers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: row['name'],
                    label: 'Ingrediente',
                    hint: 'Ej. Chile ancho',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: row['quantity'],
                    label: 'Cantidad',
                    hint: 'Ej. 3 piezas',
                  ),
                ),
                if (ingredientControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeIngredientRow(index),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Publicar Receta',
            onPressed: _submitRecipe,
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

  void _pickImage() async {
    // TODO: Implementar con image_picker
    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (image != null) setState(() => pickedImagePath = image.path);
    setState(() {
      pickedImagePath = 'placeholder';
    });
  }

  void _submitRecipe() async {
    // Validación de campos obligatorios
    final hasIngredients = ingredientControllers.any(
      (row) => row['name']!.text.trim().isNotEmpty,
    );

    if (nameController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        procedureController.text.trim().isEmpty ||
        !hasIngredients ||
        (widget.recipeType == 'Ambos' && selectedType == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa los campos obligatorios (*) y al menos un ingrediente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // Construimos el JSONB de ingredientes
    final ingredients = ingredientControllers
        .where((row) => row['name']!.text.trim().isNotEmpty)
        .map((row) => {
              'name': row['name']!.text.trim(),
              'quantity': row['quantity']!.text.trim(),
            })
        .toList();

    // TODO: Conectar con Supabase
    /*
    try {
      String? imageUrl;
      if (pickedImagePath != null) {
        imageUrl = await storageService.uploadRecipeImage(pickedImagePath!);
      }

      final recipe = {
        'assignment_id': widget.assignmentId,
        'name': nameController.text.trim(),
        'type': selectedType ?? widget.recipeType,
        'country': countryController.text.trim(),
        'region': regionController.text.trim(),
        'cooking_style': selectedCookingStyle,
        'mise_en_place': miseEnPlaceController.text.trim(),
        'ingredients': ingredients, // jsonb
        'sauce': sauceController.text.trim(),
        'procedure': procedureController.text.trim(),
        'prep_time': prepTimeController.text.trim(),
        'portions': portionsController.text.trim(),
        'image_url': imageUrl,
      };

      await recipeController.createRecipe(recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Receta publicada exitosamente!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
    */

    // Simulación (eliminar después)
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Receta publicada exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true);
  }
}