import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_list.dart';
import 'dart:math';

class StaffFormPage extends StatefulWidget {
  const StaffFormPage({super.key});

  @override
  State<StaffFormPage> createState() => _StaffFormPageState();
}

class _StaffFormPageState extends State<StaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _ageController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('staffs').add({
          'name': _nameController.text.trim(),
          'staffId': _idController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'createdAt': FieldValue.serverTimestamp(),
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Staff profile added successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StaffListPage())),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      body: Stack(
        children: [
          const HeartBubbleAnimation(),
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFF176), Color(0xFFFFB74D)]),
                  border: Border(bottom: BorderSide(color: Colors.white, width: 4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Center(
                        child: Text(
                          '📋 Staff Form Page',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffListPage(),
                        ),
                      ),
                      child: const Text(
                        'View Staff List',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF9C4), Color(0xFFFFECB3)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200, width: 4),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Instructions
                            const Text(
                              '📝 Instructions:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Please fill out all fields. Name should be at least 3 characters. '
                              'Staff ID must be unique. Age must be a number above 0.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 24),

                            _buildInputBox('Name', _nameController, validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a name';
                              } else if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            }),

                            const SizedBox(height: 16),

                            _buildInputBox('Staff ID', _idController, validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter Staff ID';
                              }
                              return null;
                            }),

                            const SizedBox(height: 16),

                            _buildInputBox('Age', _ageController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter age';
                              }
                              final age = int.tryParse(value.trim());
                              if (age == null || age <= 0) {
                                return 'Age must be a valid number above 0';
                              }
                              return null;
                            }),

                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 24),
                                  side: const BorderSide(
                                      color: Colors.white, width: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.deepOrange),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class HeartBubbleAnimation extends StatelessWidget {
  const HeartBubbleAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HeartBubblePainter(),
      child: Container(),
    );
  }
}

class HeartBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.orange.withOpacity(0.08);
    final random = Random();

    for (int i = 0; i < 20; i++) {
      final radius = random.nextDouble() * 15 + 8;
      final offset = Offset(random.nextDouble() * size.width,
          random.nextDouble() * size.height);
      canvas.drawCircle(offset, radius, paint);
    }

    paint.color = Colors.pinkAccent.withOpacity(0.08);
    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final heartPath = Path()
        ..moveTo(x, y)
        ..cubicTo(x - 10, y - 10, x - 15, y + 10, x, y + 20)
        ..cubicTo(x + 15, y + 10, x + 10, y - 10, x, y);
      canvas.drawPath(heartPath, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
