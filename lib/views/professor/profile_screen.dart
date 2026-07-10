import 'package:flutter/material.dart';
// import 'package:remy/controllers/profile_controller.dart'; // TODO: Descomentar
import 'package:remy/config/app_routes.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TODO: Inicializar ProfileController
  // final ProfileController profileController = ProfileController();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _showChangePassword = false;
  bool _isEditing = false;
  bool isLoading = false;
  
  // Datos de ejemplo
  final Map<String, dynamic> mockUser = {
    'name': 'Dr. Juan Pérez',
    'email': 'juan.perez@utvm.edu.mx',
    'avatar': null,
    'role': 'Profesor',
  };

  @override
  void initState() {
    super.initState();
    nameController.text = mockUser['name'];
    // TODO: Cargar datos del usuario desde Supabase
    // _loadUserData();
  }

  /*
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = await profileController.getUser();
      setState(() {
        mockUser = user;
        nameController.text = user['name'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mi Perfil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Administra tu información personal',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    _buildAvatarSection(),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: nameController,
                      label: 'Nombre completo',
                      prefixIcon: Icons.person,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildRoleField(),
                    const SizedBox(height: 16),
                    _buildPasswordSection(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'REMY',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.dashboard),
          tooltip: 'Mis Clases',
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: mockUser['avatar'] != null
                    ? NetworkImage(mockUser['avatar'])
                    : null,
                child: mockUser['avatar'] == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    onPressed: _changeAvatar,
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Toca para cambiar foto',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.email, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Correo institucional',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  mockUser['email'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            'No editable',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge, color: Colors.orange),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rol',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                mockUser['role'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showChangePassword = !_showChangePassword;
            });
          },
          child: Row(
            children: [
              const Icon(Icons.lock, color: Colors.orange),
              const SizedBox(width: 12),
              const Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _showChangePassword ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        if (_showChangePassword) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: currentPasswordController,
            label: 'Contraseña actual *',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: newPasswordController,
            label: 'Contraseña nueva *',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: confirmPasswordController,
            label: 'Confirmar contraseña nueva *',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: _isEditing ? 'Guardar cambios' : 'Editar perfil',
                onPressed: _isEditing ? _saveProfile : () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Cancelar',
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    nameController.text = mockUser['name'];
                    _showChangePassword = false;
                    currentPasswordController.clear();
                    newPasswordController.clear();
                    confirmPasswordController.clear();
                  });
                  Navigator.pop(context);
                },
                isOutlined: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Cerrar sesión',
          onPressed: _logout,
          backgroundColor: Colors.red,
          width: double.infinity,
        ),
      ],
    );
  }

  void _changeAvatar() {
    // TODO: Implementar selección de imagen
    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // await profileController.updateAvatar(image);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función de cambio de foto en desarrollo')),
    );
  }

  void _saveProfile() async {
    if (_showChangePassword) {
      if (currentPasswordController.text.isEmpty ||
          newPasswordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa todos los campos de contraseña'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    // TODO: Guardar cambios en Supabase
    /*
    try {
      await profileController.updateProfile({
        'name': nameController.text,
        'currentPassword': currentPasswordController.text,
        'newPassword': newPasswordController.text,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _isEditing = false;
        _showChangePassword = false;
      });
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
      _isEditing = false;
      _showChangePassword = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Perfil actualizado exitosamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    // TODO: Llamar a authController.logout()
    // await authController.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}