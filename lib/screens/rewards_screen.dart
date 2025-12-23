import 'package:flutter/material.dart';
import '../utils/ui_utils.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[800]!, Colors.amber[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Rewards',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2,450',
                    style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.yellow[100], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Lifetime Earnings (Simulated)',
                        style: TextStyle(color: Colors.yellow[100], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Scratch Cards
            const Text(
              'Scratch & Win',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildScratchCard(context, Colors.purple[400]!),
                  _buildScratchCard(context, Colors.blue[400]!),
                  _buildScratchCard(context, Colors.teal[400]!),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Offers
            const Text(
              'Offers & Cashback',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildOfferTile(
                  context,
                  'Pay Electric Bill', 
                  'Get 50 points on your first bill payment',
                  Icons.lightbulb_outline,
                  Colors.yellow,
                ),
                _buildOfferTile(
                  context,
                  'Refer a Friend', 
                  'Earn 100 points for every referral',
                  Icons.people_outline,
                  Colors.green,
                ),
                _buildOfferTile(
                  context,
                  'Grocery Shopping', 
                  'Get 5% cashback stats on simulations',
                  Icons.shopping_cart_outlined,
                  Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 32),
            
            // Referral
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.withOpacity(0.5), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(16),
                color: Colors.indigo.withOpacity(0.1),
              ),
              child: Column(
                children: [
                  const Text(
                    'Refer & Earn',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite friends to Saldo Simulation',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => UiUtils.showSimulatedToast(context, 'Referral code copied!'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'SALDO2024',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.copy, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScratchCard(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => UiUtils.showSimulatedToast(context, 'You scratched a card!'),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
               color: color.withOpacity(0.4),
               blurRadius: 8,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Stack(
          children: [
             Center(
               child: Icon(Icons.celebration, color: Colors.white.withOpacity(0.2), size: 60),
             ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.touch_app, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        onTap: () => UiUtils.showSimulatedToast(context, 'Offer Activated!'),
      ),
    );
  }
}
