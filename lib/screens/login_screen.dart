import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import 'home_shell.dart';
import 'pin_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPhone();
  }

  Future<void> _loadSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('user_phone');
    if (savedPhone != null) {
      setState(() => _phoneController.text = savedPhone);
    }
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      UiUtils.showSimulatedToast(context, 'Please enter phone and password');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Verify Credentials Locally
    final prefs = await SharedPreferences.getInstance();
    final storedPhone = prefs.getString('user_phone');
    final storedPass = prefs.getString('user_password');
    final storedName = prefs.getString('user_name') ?? "Simulated User";
    
    // In simulation, if no user exists, we might let them in as specific 'demo' user 
    // OR strict check. Requirement says "Pre-fill or auto-recognize".
    // Let's enforce strict matching IF registered, else fallback to demo.
    
    bool isValid = false;
    if (storedPhone != null && storedPhone == phone) {
      if (storedPass == password) {
        isValid = true;
      } else {
        UiUtils.showSimulatedToast(context, 'Incorrect password');
        return;
      }
    } else {
      // Allow generic login for simulation if not strictly registered
      isValid = true;
      // Auto-register session
      await prefs.setString('user_name', "Demo User");
    }

    if (isValid) {
        final int userId = prefs.getInt('user_id') ?? 12345;
        await prefs.setInt('user_id', userId);
        _handleSubmit(userId);
    }
  }

  void _handleSubmit(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final hasPin = prefs.getString('user_pin') != null;

    if (!mounted) return;

    if (!hasPin) {
       // First time setup - force CREATE PIN
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (_) => PinScreen(
             isCreating: true,
             onSuccess: (ctx) {
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomeShell(userId: userId)),
                );
             },
           ),
         ),
       );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeShell(userId: userId)),
      );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Need Help?', style: TextStyle(color: Colors.white)),
        content: Text(
          'For this simulation, you can create a new account by calling the API or contact the developer for test credentials.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo[600]!, Colors.teal[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.indigo.withOpacity(0.3),
                             blurRadius: 16,
                             offset: const Offset(0, 8),
                           ),
                        ],
                      ),
                      child: const Icon(Icons.account_balance_wallet, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                     const Text(
                      'Welcome to Saldo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure Simulated Payments',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Inputs
              _buildInputLabel('Phone Number'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hint: 'Enter your simulated phone',
                icon: Icons.phone_android,
                inputType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              _buildInputLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hint: 'Enter your password',
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

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0), // Indigo
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: Colors.indigo.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Secure Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: Colors.grey[500])),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (_) => const RegisterScreen()),
                         );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.teal[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Simulation Notice
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   decoration: BoxDecoration(
                     color: Colors.white.withOpacity(0.05),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: const Text(
                    'Simulation Environment • Not Real Money',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
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
          prefixIcon: Icon(icon, color: Colors.indigo[300]),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
