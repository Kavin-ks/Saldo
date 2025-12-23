import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinScreen extends StatefulWidget {
  final bool isCreating;
  final Function(BuildContext) onSuccess; // Changed to accept context

  const PinScreen({
    Key? key,
    this.isCreating = false,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String _confirmedPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  // Ensure robust state on load
  Future<void> _checkExistingPin() async {
    if (!widget.isCreating) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('user_pin') == null) {
        // Fallback or error if verify mode but no PIN
        debugPrint("Warning: Verify mode but no PIN found.");
      }
    }
  }

  void _handleKeyPress(String key) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = ''; // Clear error
    });

    if (key == 'BACK') {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    } else if (key.isNotEmpty) {
      if (_pin.length < 4) {
        setState(() => _pin += key);
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _submitPin() async {
    if (_pin.length != 4) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final prefs = await SharedPreferences.getInstance();

    if (widget.isCreating) {
      if (!_isConfirming) {
        setState(() {
          _confirmedPin = _pin;
          _pin = '';
          _isConfirming = true;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        if (_pin == _confirmedPin) {
          await prefs.setString('user_pin', _pin);
          if (mounted) {
            debugPrint("Pin Created. Navigating...");
            widget.onSuccess(context); // Pass current context
          }
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _pin = '';
            _confirmedPin = '';
            _isConfirming = false;
            _errorMessage = 'PINs do not match. Try again.';
            _isLoading = false;
          });
        }
      }
    } else {
      final storedPin = prefs.getString('user_pin');
      final validPin = storedPin ?? '1234'; 

      if (_pin == validPin) {
        if (mounted) {
            debugPrint("Pin Verified. Navigating...");
            widget.onSuccess(context); // Pass current context
        }
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _pin = '';
          _errorMessage = 'Incorrect PIN';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCreating
        ? (_isConfirming ? 'Confirm PIN' : 'Create a PIN')
        : 'Enter PIN';
    
    final subtitle = widget.isCreating && _isConfirming
        ? 'Re-enter to verify'
        : 'Secure your payments';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Security', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _pin.length
                              ? Colors.teal[400]
                              : Colors.grey[800],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 20,
                    alignment: Alignment.center,
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Button inside Expanded area to avoid being pushed off
                  if (_pin.length == 4 && !_isLoading)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: ElevatedButton(
                            onPressed: _submitPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: Text(
                              widget.isCreating && !_isConfirming ? 'Continue' : 'Confirm',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                    ),
                ],
              ),
            ),
            
            // Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF252525),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // shrink wrap
                children: [
                  _buildKeyRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildKeyRow(['', '0', 'BACK']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) return const SizedBox(width: 80, height: 80);
        return _buildKey(key);
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isBack = key == 'BACK';
    return InkWell(
      onTap: () => _handleKeyPress(key),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBack ? Colors.transparent : Colors.grey[800],
        ),
        child: isBack
            ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 28)
            : Text(
                key,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
