import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'staff_form.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({Key? key}) : super(key: key);

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  String _sortOrder = 'newest';

  Future<void> _deleteStaff(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this profile?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('staffs').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff deleted')),
      );
    }
  }

  Future<void> _editStaff(DocumentSnapshot doc) async {
    final _nameController = TextEditingController(text: doc['name']);
    final _idController = TextEditingController(text: doc['staffId']);
    final _ageController = TextEditingController(text: doc['age'].toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Staff Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _styledTextField(_nameController, 'Name'),
              const SizedBox(height: 12),
              _styledTextField(_idController, 'Staff ID'),
              const SizedBox(height: 12),
              _styledTextField(_ageController, 'Age', isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('staffs').doc(doc.id).update({
                'name': _nameController.text.trim(),
                'staffId': _idController.text.trim(),
                'age': int.tryParse(_ageController.text.trim()) ?? 0,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _styledTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.yellow.shade50,
        labelText: label,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orangeAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFF176), Color(0xFFFFB74D)]),
                  border: Border(bottom: BorderSide(color: Colors.white, width: 4)),
                ),
                child: Center(
                  child: Text(
                    '👥 Staff List Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _sortOrder,
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Newest')),
                            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _sortOrder = val!;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffFormPage()));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Staff'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('staffs')
                      .orderBy('name', descending: _sortOrder == 'newest' ? true : false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching data.'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: docs.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final staff = docs[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8DC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange.shade300, width: 2),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                staff['name'][0].toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                            title: Text(
                              staff['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${staff['staffId']} | Age: ${staff['age']}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  onPressed: () => _editStaff(staff),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStaff(staff.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
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
    final paint = Paint()..color = Colors.orange.withOpacity(0.05);
    final random = Random();
    for (int i = 0; i < 20; i++) {
      final radius = random.nextDouble() * 10 + 8;
      final offset = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(offset, radius, paint);
    }
    paint.color = Colors.pinkAccent.withOpacity(0.05);
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
