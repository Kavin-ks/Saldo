import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.amber[900]!.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.amber.withOpacity(0.5)),
               ),
               child: Row(
                 children: [
                   Icon(Icons.warning_amber_rounded, color: Colors.amber[200]),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Text(
                       'This is a simulation. Saldo is not a real bank.',
                       style: TextStyle(color: Colors.amber[100], fontWeight: FontWeight.bold),
                     ),
                   ),
                 ],
               ),
            ),
            const SizedBox(height: 32),
            Text(
              content,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last Updated: December 2025',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SIMULATION LEGAL TEXT CONSTANTS
const String TERMS_TEXT = """
1. ACCEPTANCE OF TERMS
By accessing the Saldo simulation app, you agree that this application is strictly for educational and demonstration purposes.

2. VIRTUAL CURRENCY
All "funds", "credits", "balances", and "rewards" displayed within Saldo are entirely virtual. They have:
- No monetary value.
- No convertibility to real currency (USD, EUR, etc.).
- No external utility outside this simulation.

3. NO FINANCIAL SERVICES
Saldo is NOT a bank, financial institution, payment processor, or money transmitter. No real banking infrastructure is connected to this application.

4. USER RESPONSIBILITY
You acknowledge that any "payments" made within this app are simulated. Do not attempt to use Saldo to pay for real goods or services.

5. SIMULATED IDENTITIES
Any merchants, businesses, or utility providers listed in the app are simulated entities or used fictitiously for demonstration.
""";

const String PRIVACY_TEXT = """
1. DATA COLLECTION
We respect your privacy. As a simulation app:
- We do not collect your real government ID or financial credentials.
- Any name or phone number you enter is stored either locally on your device or on a temporary demonstration server.

2. DATA USAGE
Your data is used solely to maintain the state of your simulated session (e.g., your virtual balance). We do not sell, trade, or analyze your data for marketing.

3. LOCAL STORAGE
We use local storage (SharedPreferences) to remember your simulated session. Clearing your app data will reset your simulation progress.

4. NO REAL SECURITY
While we simulate security features like PIN and Biometrics, please be aware this is a demo environment. Do not use your real banking passwords as your simulation PIN.
""";
