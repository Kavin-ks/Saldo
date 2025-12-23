import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'result_screen.dart';
import 'pin_screen.dart';

import 'package:audioplayers/audioplayers.dart'; // Add import
import '../services/api_service.dart';

class PayScreen extends StatefulWidget {
  final int userId;
  final String? initialReceiverPhone;
  final String? initialReceiverName; // Added field
  final String? initialNote;
  final String paymentMethod;
  
  const PayScreen({
    Key? key, 
    required this.userId,
    this.initialReceiverPhone,
    this.initialReceiverName, // Added to constructor
    this.initialNote,
    this.paymentMethod = 'PHONE',
  }) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Single AudioPlayer instance as requested
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isLookingUp = false;
  bool _isValidReceiver = false;

  // Colors
  final Color _primaryColor = const Color(0xFF5C6BC0);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    
    // Feature 3: Check storage for initial receiver
    if (widget.initialReceiverPhone != null) {
      _phoneController.text = widget.initialReceiverPhone!;
      // FIX: Immediate validation for passed data
      setState(() {
         _isValidReceiver = true;
      });
      _performUserLookup();
    }
    
    // Set initial name if provided (e.g. from UPI QR)
    if (widget.initialReceiverName != null && widget.initialReceiverName!.isNotEmpty) {
      _nameController.text = widget.initialReceiverName!;
    }

    if (widget.initialNote != null && widget.initialNote!.isNotEmpty) {
      _noteController.text = widget.initialNote!;
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _nameController.dispose();
    _audioPlayer.dispose(); // Dispose player
    super.dispose();
  }

  void _onPhoneChanged() {
    // FIX: Removed strict length check
    if (_phoneController.text.isNotEmpty) {
      _performUserLookup();
    } else {
      setState(() {
        _isValidReceiver = false;
      });
    }
  }

  bool get _canPay {
    final phone = _phoneController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final name = _nameController.text.trim();
    // FIX: Relaxed validation
    return phone.isNotEmpty && amount > 0 && name.isNotEmpty;
  }

  Future<void> _performUserLookup() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Only skip lookup if we are ALREADY typing a name (avoids flashing)
    if (_nameController.text.isNotEmpty) return;

    setState(() => _isLookingUp = true);

    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('contact_$phone');

    if (storedName != null) {
      _nameController.text = storedName;
      setState(() {
        _isValidReceiver = true;
        _isLookingUp = false;
      });
    } else {
      // If manually typing, maybe give it a moment, but if it's a long ID/QR, just show field
      if (phone.length >= 3) {
         await Future.delayed(const Duration(milliseconds: 600));
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLookingUp = false;
        _isValidReceiver = true;
        // Don't auto-fill generic generic name if it looks like a long ID
        // if (_nameController.text.isEmpty) {
        //    _nameController.text = "User ${phone.substring(6)}"; 
        // }
      });
    }
  }

  Future<void> _sendMoney() async {
    if (!_canPay) return;

    final phone = _phoneController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();
    final name = _nameController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinScreen(
          isCreating: false,
          onSuccess: (ctx) async {
             // FIX: Play Audio here on user PIN confirmation
             try {
                await _audioPlayer.play(AssetSource('sounds/payment_success.wav'));
             } catch (e) {
                debugPrint("Audio Error: $e");
             }
             
             Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(
                builder: (_) => ProcessingScreen(
                  userId: widget.userId,
                  toPhone: phone,
                  amount: amount,
                  note: note,
                  receiverName: name, 
                  paymentMethod: widget.paymentMethod,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionLabel('To Whom?'),
            const SizedBox(height: 12),
            _buildPhoneInput(),
            
            const SizedBox(height: 24),
            
            // FIX: Show name input if valid OR phone is not empty
            if (_isValidReceiver || _phoneController.text.isNotEmpty) 
              _buildNameInput(),

            const SizedBox(height: 32),

            _buildSectionLabel('How Much?'),
            const SizedBox(height: 12),
            _buildAmountInput(),

            const SizedBox(height: 24),

            _buildNoteInput(),

            const SizedBox(height: 48),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                   if (_canPay) {
                     HapticFeedback.mediumImpact();
                     _sendMoney();
                   } else {
                     HapticFeedback.vibrate();
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: _inputDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _phoneController,
        // FIX: Changed to text to support UPI IDs/Generic QR data
        keyboardType: TextInputType.text,
        // FIX: Removed maxLength restriction
        // maxLength: 10,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          icon: const Icon(Icons.qr_code, color: Colors.grey), // Changed icon to represent generic input
          hintText: 'Phone number or UPI ID',
          suffixIcon: _isLookingUp
              ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
              : null,
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recipient Name", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: _inputDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              icon: Icon(Icons.person_outline, color: Colors.indigo),
              hintText: 'Enter Name',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: _inputDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount to send', style: TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: '₹ ',
              prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              hintText: '0.00',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: 'Add a note (Optional)',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }
}

class ProcessingScreen extends StatefulWidget {
  final int userId;
  final String toPhone;
  final double amount;
  final String note;
  final String receiverName;
  final String paymentMethod;

  const ProcessingScreen({
    Key? key,
    required this.userId,
    required this.toPhone,
    required this.amount,
    required this.note,
    required this.receiverName,
    this.paymentMethod = 'PHONE',
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    // Call the actual API
    final response = await ApiService.sendMoney(
      widget.userId,
      widget.toPhone,
      widget.amount,
      widget.note,
      widget.receiverName,
      paymentMethod: widget.paymentMethod,
    );

    if (!mounted) return;

    final now = DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy \'at\' h:mm a').format(now);

    if (response['success'] == true) {
      // Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            success: true,
            message: 'Payment Successful',
            amount: widget.amount,
            receiverName: widget.receiverName,
            formattedDate: formattedDate,
          ),
        ),
      );
    } else {
      // Failure
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            success: false,
            message: response['message'] ?? 'Payment Failed',
            amount: widget.amount,
            receiverName: widget.receiverName,
            formattedDate: formattedDate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 24),
            Text('Processing Payment...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
