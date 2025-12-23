import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/audio/payment_audio_service.dart';

class ResultScreen extends StatefulWidget {
  final bool success;
  final String message;
  final double amount;
  final String receiverName;
  final String? formattedDate;

  const ResultScreen({
    Key? key,
    required this.success,
    required this.message,
    required this.amount,
    required this.receiverName,
    this.formattedDate,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
    @override
  void initState() {
    super.initState();
    if (!widget.success) {
      HapticFeedback.vibrate();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark theme background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated Checkmark or Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.success ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                ),
                child: Icon(
                  widget.success ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: widget.success ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                widget.success ? 'Payment Successful!' : 'Payment Failed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.success ? Colors.white : Colors.red[200],
                ),
              ),
              const SizedBox(height: 12),
              
              // Date Display (Feature 1)
              if (widget.formattedDate != null)
                Text(
                  widget.formattedDate!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    letterSpacing: 0.5,
                  ),
                ),

              const SizedBox(height: 24),
              
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Sent to ${widget.receiverName}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
              ),
               
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
              ),

              const Spacer(),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
