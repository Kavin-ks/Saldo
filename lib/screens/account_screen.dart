import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/ui_utils.dart';
import 'legal_screen.dart';
import 'login_screen.dart'; // Will be created

class AccountScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const AccountScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editBalance(BuildContext context) async {
     final prefs = await SharedPreferences.getInstance();
     final currentBal = prefs.getDouble('user_balance') ?? 0.0;
     final controller = TextEditingController(text: currentBal.toString());
     
     await showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Edit Virtual Balance', style: TextStyle(color: Colors.white)),
          content: TextField(
             controller: controller,
             keyboardType: const TextInputType.numberWithOptions(decimal: true),
             style: const TextStyle(color: Colors.white),
             decoration: const InputDecoration(
               prefixText: '₹ ',
               hintText: 'Enter new balance',
               hintStyle: TextStyle(color: Colors.grey),
             ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('Cancel')
            ),
            TextButton(
              onPressed: () async {
                 final newBal = double.tryParse(controller.text);
                 if (newBal != null) {
                   await prefs.setDouble('user_balance', newBal);
                   Navigator.pop(ctx);
                   UiUtils.showSimulatedToast(ctx, 'Balance updated!');
                 }
              }, 
              child: const Text('Update')
            ),
          ],
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    final logoName = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo[600],
                    child: Text(
                      logoName,
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[900]!.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Simulation Account',
                      style: TextStyle(color: Colors.amber[100], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Settings Group 1
            _buildSettingsGroup([
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => UiUtils.showFeatureDialog(context, 'Change Password'),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Edit Virtual Balance',
                onTap: () => _editBalance(context),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                trailing: Switch(
                  value: true, 
                  onChanged: (val) {}, 
                  activeColor: Colors.teal[400],
                  activeTrackColor: Colors.teal[800],
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.shield_outlined,
                title: 'Data Privacy',
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => const LegalScreen(title: 'Data Privacy', content: PRIVACY_TEXT),
                     ),
                   );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Settings Group 2
            _buildSettingsGroup([
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'About Saldo',
                subtitle: 'Version 1.0.0 (Sim)',
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => const LegalScreen(title: 'Terms & Conditions', content: TERMS_TEXT),
                     ),
                   );
                },
              ),
            ]),


            const SizedBox(height: 40),

            // Logout
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _logout(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[900]!.withOpacity(0.2),
                  foregroundColor: Colors.red[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey[400], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: onTap,
    );
  }
}
