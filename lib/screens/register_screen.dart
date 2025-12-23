import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ui_utils.dart';
import 'home_shell.dart';
import 'pin_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      UiUtils.showSimulatedToast(context, 'Please fill all fields');
      return;
    }

    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() => _isLoading = false);

    if (!mounted) return;

    // LOCAL STORAGE REGISTRATION
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_password', password);
    await prefs.setString('user_name', name);
    // Set initial simulation balance
    if (prefs.getDouble('user_balance') == null) {
      await prefs.setDouble('user_balance', 10000.00); // Default 10k
    }

    // Success
    final int simulatedUserId = 1001;
    await prefs.setInt('user_id', simulatedUserId);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PinScreen(
          isCreating: true,
          onSuccess: (ctx) {
             Navigator.of(ctx).pushReplacement(
               MaterialPageRoute(builder: (_) => HomeShell(userId: simulatedUserId)),
             );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 24),

              _buildInputLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: 'Enter your phone number',
                icon: Icons.phone_android,
                inputType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              _buildInputLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: 'Create a password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(icon, color: Colors.teal[300]),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
