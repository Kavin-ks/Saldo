import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';
import '../widgets/shimmer_loading.dart';
import 'account_screen.dart';
import 'pin_screen.dart';
import 'qr_scanner_screen.dart';
import 'payments_screen.dart';
import 'transaction_history_screen.dart'; // For navigating to history

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _userName = '';
  bool _isBalanceVisible = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'User';

    // Simulate network delay for shimmer effect
    await Future.delayed(const Duration(milliseconds: 500));

    final balance = prefs.getDouble('user_balance') ?? 0.0;
    final transactions = await ApiService.getTransactions(widget.userId);

    if (!mounted) return;
    setState(() {
      _balance = balance;
      _transactions = transactions;
      _isLoading = false;
    });
  }

  void _toggleBalanceVisibility() {
    if (_isBalanceVisible) {
      setState(() => _isBalanceVisible = false);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PinScreen(
            onSuccess: (ctx) {
              Navigator.pop(ctx); // Close PinScreen using proper context
              setState(() => _isBalanceVisible = true);
              
              // Auto-hide after 60 seconds
              Future.delayed(const Duration(seconds: 60), () {
                if (mounted) setState(() => _isBalanceVisible = false);
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            // Stylish 'S' Logo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[400]!, Colors.teal[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Saldo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccountScreen(
                      userId: widget.userId,
                      userName: _userName,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[800],
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.indigo[400],
              backgroundColor: Colors.grey[900],
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildOffersMethods(),
                  const SizedBox(height: 32),
                  _buildRecentTransactions(),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: double.infinity, height: 180, borderRadius: 24),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerLoading(width: 70, height: 90, borderRadius: 16),
              ShimmerLoading(width: 70, height: 90, borderRadius: 16),
              ShimmerLoading(width: 70, height: 90, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 32),
          const ShimmerLoading(width: double.infinity, height: 100, borderRadius: 20),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF283593), // Deep Indigo
            Colors.black.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, 
                         color: Colors.teal[200], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Virtual Balance',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: _toggleBalanceVisibility,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _isBalanceVisible ? _balance.toStringAsFixed(2) : '••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Credits',
                      style: TextStyle(
                        color: Colors.teal[200],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Simulation Mode • No Real Money',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.qr_code_scanner,
          label: 'Scan QR',
          color: Colors.orange[400]!,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QRScannerScreen(userId: widget.userId)),
            );
            _loadData();
          },
        ),
        _buildActionButton(
          icon: Icons.send_rounded,
          label: 'Pay',
          color: const Color(0xFF5C6BC0), // Primary Indigo
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentsScreen(userId: widget.userId),
              ),
            );
            _loadData();
          },
        ),
        _buildActionButton(
          icon: Icons.bolt,
          label: 'Recharge',
          color: Colors.teal[300]!,
          onTap: () => UiUtils.showFeatureDialog(context, 'Recharge Simulation'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersMethods() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildOfferCard(
            title: 'Invite & Earn',
            subtitle: 'Get 500 Pts',
            gradient: LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFD81B60)]),
            icon: Icons.card_giftcard,
          ),
          _buildOfferCard(
            title: 'Unlock Pro',
            subtitle: 'New Features',
            gradient: LinearGradient(colors: [Color(0xFF00897B), Color(0xFF4DB6AC)]),
            icon: Icons.star,
          ),
          _buildOfferCard(
            title: 'Safety Tips',
            subtitle: 'Read Now',
            gradient: LinearGradient(colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)]),
            icon: Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PinScreen(
                      onSuccess: (ctx) {
                         Navigator.pop(ctx); // Close PIN
                         Navigator.push(
                           ctx,
                           MaterialPageRoute(
                             builder: (_) => TransactionHistoryScreen(userId: widget.userId),
                           ),
                         );
                      }
                    ),
                  ),
                );
              },
              child: const Text(
                'View all',
                style: TextStyle(color: Color(0xFF5C6BC0), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 40, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text(
                  'No activity yet',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          ..._transactions.take(3).map((txn) {
            final isSent = txn['type'] == 'sent';
            final user = txn['other_user'] ?? 'Unknown';
            final amount = double.tryParse(txn['amount'].toString()) ?? 0.0;
            final date = txn['created_at'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.02)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: isSent ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                  child: Icon(
                    isSent ? Icons.arrow_outward : Icons.arrow_downward,
                    color: isSent ? Colors.orange[400] : Colors.teal[300],
                    size: 20,
                  ),
                ),
                title: Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Text(
                  '${isSent ? '-' : '+'} $amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSent ? Colors.white : Colors.teal[300],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
