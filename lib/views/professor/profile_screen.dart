import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remy/controllers/profile_controller.dart';
import 'package:remy/config/app_routes.dart';
import 'package:remy/controllers/auth_controller.dart';
import 'package:remy/views/shared/widgets/custom_button.dart';
import 'package:remy/views/shared/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = ProfileController();
  final AuthController authController = AuthController();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _showChangePassword = false;
  bool _isEditing = false;
  bool isLoading = false;
  bool isUploadingAvatar = false;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final data = await profileController.getProfile();
      if (!mounted) return;
      setState(() {
        user = data;
        nameController.text = data['full_name'] ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
    );
  }

  Widget _buildAvatarSection() {
    final avatarUrl = user?['avatar_url'];

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              ),
              if (isUploadingAvatar)
                const Positioned.fill(
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    onPressed: isUploadingAvatar ? null : _changeAvatar,
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
                  user?['email'] ?? '',
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
    final role = user?['role'] ?? '';
    final displayRole = role == 'profesor' ? 'Profesor' : 'Alumno';

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
                displayRole,
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
                onPressed: _isEditing
                    ? _saveProfile
                    : () {
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
                    nameController.text = user?['full_name'] ?? '';
                    _showChangePassword = false;
                    currentPasswordController.clear();
                    newPasswordController.clear();
                    confirmPasswordController.clear();
                  });
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

  Future<void> _changeAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => isUploadingAvatar = true);

      final Uint8List bytes = await image.readAsBytes();
      final newUrl = await profileController.updateAvatar(bytes, image.name);

      if (!mounted) return;
      setState(() {
        user = {...?user, 'avatar_url': newUrl};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Foto de perfil actualizada!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isUploadingAvatar = false);
    }
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

      if (newPasswordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña nueva debe tener al menos 6 caracteres'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (nameController.text.trim().isNotEmpty &&
          nameController.text.trim() != user?['full_name']) {
        await profileController.updateName(nameController.text.trim());
      }

      if (_showChangePassword) {
        await profileController.changePassword(
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );
      }

      if (!mounted) return;
      setState(() {
        user = {...?user, 'full_name': nameController.text.trim()};
        _isEditing = false;
        _showChangePassword = false;
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Perfil actualizado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _logout() async {
    await authController.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}