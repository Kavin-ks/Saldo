import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';
import 'qr_scanner_screen.dart';
import 'pay_screen.dart';

class PaymentsScreen extends StatelessWidget {
  final int userId;
  const PaymentsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Background
      appBar: AppBar(
        title: const Text('Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulation Banner
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[900]!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[200], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All utility & merchant payments are simulated for educational purposes.',
                      style: TextStyle(color: Colors.amber[100], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader('Transfer Money'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickActionItem(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  color: Colors.orange[400]!,
                  onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (_) => QRScannerScreen(userId: userId)),
                     );
                  },
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.phone_iphone,
                  label: 'To Mobile',
                  color: const Color(0xFF5C6BC0), // Indigo
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PayScreen(userId: userId),
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.account_circle_outlined,
                  label: 'Pay Anyone',
                  color: Colors.teal[300]!,
                  onTap: () => UiUtils.showFeatureDialog(context, 'User Directory'),
                ),
                _buildQuickActionItem(
                  context,
                  icon: Icons.account_balance,
                  label: 'To Bank',
                  color: Colors.purple[300]!,
                  onTap: () => UiUtils.showFeatureDialog(context, 'Bank Transfer'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildSectionHeader('Recharge & Pay Bills'),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                   _buildBillItem(context, Icons.phone_android, 'Mobile', Colors.blue[400]!),
                   _buildBillItem(context, Icons.lightbulb_outline, 'Electricity', Colors.yellow[700]!),
                   _buildBillItem(context, Icons.water_drop_outlined, 'Water', Colors.blue[300]!),
                   _buildBillItem(context, Icons.router, 'Internet', Colors.pink[300]!),
                   _buildBillItem(context, Icons.tv, 'DTH', Colors.deepPurple[300]!),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _buildSectionHeader('Businesses'),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildMerchantTile(
                   context, 
                   'Fresh Mart Grocery', 
                   'Groceries', 
                   Icons.shopping_cart, 
                   Colors.green,
                   '9000000001' // Receiver ID/Phone for simulation
                ),
                _buildMerchantTile(context, 'Zippy Food Delivery', 'Food', Icons.fastfood, Colors.red),
                _buildMerchantTile(context, 'City Cabs', 'Travel', Icons.local_taxi, Colors.yellow),
                _buildMerchantTile(context, 'Style Store', 'Shopping', Icons.checkroom, Colors.purple),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Gift Cards & More'),
            const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: _buildGiftCardItem(context, 'Streaming', Colors.red[900]!, Icons.play_arrow)),
                 const SizedBox(width: 16),
                 Expanded(child: _buildGiftCardItem(context, 'Shopping', Colors.blue[900]!, Icons.shopping_bag)),
               ],
             ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                 BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                 ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => UiUtils.showSimulatedToast(context, '$label Payment Expected'),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantTile(BuildContext context, String name, String category, IconData icon, Color color, [String? phone]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
        subtitle: Text(category, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () {
             if (phone != null) {
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (_) => PayScreen(userId: userId, initialReceiverPhone: phone),
                 ),
               );
             } else {
               UiUtils.showSimulatedToast(context, 'Paying $name...');
             }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            minimumSize: const Size(60, 32),
          ),
          child: const Text('Pay', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildGiftCardItem(BuildContext context, String title, Color color, IconData icon) {
    return GestureDetector(
      onTap: () => UiUtils.showSimulatedToast(context, '$title Gift Card'),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.2),
               blurRadius: 8,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
