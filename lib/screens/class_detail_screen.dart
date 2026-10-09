import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/class_model.dart';
import 'package:wisdom_portal_1/models/student_model.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/screens/student_detail_screen.dart';
import 'package:wisdom_portal_1/widgets/Custom_button.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

final BoxDecoration _cardDecoration = BoxDecoration(
  border: Border.all(color: Colors.blue.shade900, width: 1),
  borderRadius: BorderRadius.circular(12),
  color: const Color.fromARGB(255, 198, 223, 234),
  boxShadow: [
    BoxShadow(
      blurRadius: 6,
      color: Colors.black.withAlpha(35),
      offset: const Offset(0, 8),
    ),
  ],
);

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classItem;
  const ClassDetailScreen({super.key, required this.classItem});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _searchController = TextEditingController();

  final _searchQuery = ValueNotifier<String>("");
  final _isSubmitting = ValueNotifier<bool>(false);

  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _rollNumberController.dispose();
    _searchController.dispose();
    _searchQuery.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _studentNameController.clear();
    _fatherNameController.clear();
    _rollNumberController.clear();
  }

  String? _required(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  Future<void> _submitStudent(BuildContext dialogContext) async {
    if (!_key.currentState!.validate()) return;

    final navigator = Navigator.of(dialogContext);
    final messenger = ScaffoldMessenger.of(dialogContext);
    final provider = dialogContext.read<StudentProvider>();

    _isSubmitting.value = true;
    try {
      await provider
          .addStudent(
            StudentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: FirebaseAuth.instance.currentUser!.uid,
              studentName: _studentNameController.text.trim(),
              fatherName: _fatherNameController.text.trim(),
              rollNumber: _rollNumberController.text.trim(),
              className: widget.classItem.className,
              admissionDate: DateTime.now(),
            ),
          )
          .timeout(const Duration(seconds: 2), onTimeout: () {});

      _clearControllers();
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text("Student detail added successfully!")),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Failed to add student: $e")),
      );
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  void showAddStudent() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Student"),
          content: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  text: "enter student name ...",
                  textCapitalization: TextCapitalization.words,
                  controller: _studentNameController,
                  validator: (value) => _required(value, "add student name"),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  text: "enter father name...",
                  textCapitalization: TextCapitalization.words,
                  controller: _fatherNameController,
                  validator: (value) => _required(value, "add father name"),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  text: "enter roll number...",
                  textCapitalization: TextCapitalization.words,
                  controller: _rollNumberController,
                  validator: (value) => _required(value, "add roll number"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _clearControllers();
                  },
                  child: const Text("Cancel"),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (_, isSubmitting, __) {
                    return TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => _submitStudent(dialogContext),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Add"),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Student Screen"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              icon: Icons.add,
              onPressed: showAddStudent,
              text: "Add Student",
            ),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (_, query, __) {
                  return TextField(
                    controller: _searchController,
                    onChanged: (value) => _searchQuery.value = value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "search name or roll no...",
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery.value = "";
                              },
                              icon: const Icon(Icons.cancel),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (_, query, __) {
                  return Consumer<StudentProvider>(
                    builder: (context, studentProvider, child) {
                      final students = studentProvider.searchStudent(
                        query,
                        widget.classItem.className,
                      );

                      if (students.isEmpty) {
                        return const Center(child: Text("No Students Yet "));
                      }

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final name = student.studentName;

                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDetailScreen(student: student),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: _cardDecoration,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    foregroundColor: Colors.blue.shade900,
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      169,
                                      220,
                                      245,
                                    ),
                                    child: Text(
                                      name.isEmpty
                                          ? "?"
                                          : name[0].toUpperCase(),
                                    ),
                                  ),
                                  title: Text(name),
                                  subtitle: Text(
                                    "Roll No: ${student.rollNumber}",
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
