import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'payments_screen.dart';
import 'rewards_screen.dart';
import 'transaction_history_screen.dart';
import 'account_screen.dart';

class HomeShell extends StatefulWidget {
  final int userId;
  const HomeShell({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId),
      PaymentsScreen(userId: widget.userId),
      const RewardsScreen(),
      TransactionHistoryScreen(userId: widget.userId),
      AccountScreen(userId: widget.userId, userName: 'User'), // Name will be loaded internally if needed or passed
    ];
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    setState(() {
      _screens[4] = AccountScreen(userId: widget.userId, userName: name);
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1E1E1E),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: const Color(0xFF5C6BC0), // Indigo
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              activeIcon: Icon(Icons.payment),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              activeIcon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
