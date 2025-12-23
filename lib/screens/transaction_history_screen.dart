import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final int userId;
  const TransactionHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> _allTransactions = [];
  List<dynamic> _filteredTransactions = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  
  // Filter state
  String _currentFilter = 'All'; // All, Sent, Received, Failed
  final List<String> _filters = ['All', 'Sent', 'Received', 'Failed'];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final transactions = await ApiService.getTransactions(widget.userId);
    if (!mounted) return;
    setState(() {
      _allTransactions = transactions;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }
  
  void _onFilterChanged(String filter) {
    setState(() {
      _currentFilter = filter;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTransactions = _allTransactions.where((txn) {
        // 1. Search Filter
        final name = (txn['other_user'] ?? '').toString().toLowerCase();
        final phone = (txn['other_phone'] ?? '').toString().toLowerCase();
        final note = (txn['note'] ?? '').toString().toLowerCase();
        final matchesSearch = name.contains(query) || note.contains(query) || phone.contains(query);
        
        if (!matchesSearch) return false;

        // 2. Type Filter
        if (_currentFilter == 'All') return true;
        
        final type = txn['type']; // 'sent' or 'received'
        if (_currentFilter == 'Sent') return type == 'sent';
        if (_currentFilter == 'Received') return type == 'received';
        if (_currentFilter == 'Failed') return (txn['status'] ?? '').toString().toUpperCase() == 'FAILED'; 
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _onFilterChanged(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo[600] : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.indigo[600]! : Colors.grey[800]!,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Transaction List
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 6,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerLoading(width: double.infinity, height: 80, borderRadius: 16),
                    ),
                  )
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[800]),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final txn = _filteredTransactions[index];
                          return _buildTransactionCard(txn);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(dynamic txn) {
    final bool isSent = txn['type'] == 'sent';
    final user = txn['other_user'] ?? 'Unknown';
    final amount = double.tryParse(txn['amount'].toString()) ?? 0.0;
    final date = txn['created_at'];
    final status = (txn['status'] ?? '').toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSent ? Colors.orange.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSent ? Icons.arrow_outward : Icons.arrow_downward,
            color: isSent ? Colors.orange[400] : Colors.teal[400],
            size: 20,
          ),
        ),
        title: Text(
          user,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${status == 'FAILED' ? 'Failed' : 'Success'} • $date',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (txn['note'] != null && txn['note'].isNotEmpty)
               Padding(
                 padding: const EdgeInsets.only(top: 4),
                 child: Text(
                   '"${txn['note']}"',
                   style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.indigo[200]),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isSent ? '-' : '+'} $amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSent ? Colors.white : Colors.green[400],
              ),
            ),
            Text(
              'Credits',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
