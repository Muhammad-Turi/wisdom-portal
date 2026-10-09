import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/teacher_model.dart';
import 'package:wisdom_portal_1/providers/teacher_provider.dart';
import 'package:wisdom_portal_1/widgets/Custom_button.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  static const Duration _searchDebounce = Duration(milliseconds: 300);

  final TextEditingController searchController = TextEditingController();

  // Debounced search text. Only the list listens to this, so typing
  // no longer rebuilds the whole screen.
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>("");
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      _searchQuery.value = value;
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    _searchQuery.value = "";
  }

  void showAddTeacher() {
    showDialog(
      context: context,
      builder: (context) => const _AddTeacherDialog(),
    );
  }

  Future<void> _confirmDelete(TeacherModel teacher) async {
    final provider = context.read<TeacherProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Teacher"),
        content: Text("Delete ${teacher.teacherName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    provider.deleteTeacher(teacher.id);
    messenger.showSnackBar(
      const SnackBar(content: Text("Teacher deleted successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: no context.watch here anymore. The screen itself is built once;
    // only the list below listens to the provider and the search text.
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Teacher Screen"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomButton(
              icon: Icons.add,
              onPressed: showAddTeacher,
              text: "Add Teacher",
            ),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              // Only the search field rebuilds when the text changes
              // (to show/hide the clear button).
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  return TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search teacher by name...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: value.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQuery,
                builder: (context, query, child) {
                  return Consumer<TeacherProvider>(
                    builder: (context, provider, child) {
                      final teacherList = provider.searchTeacher(query);

                      if (teacherList.isEmpty) {
                        return Center(
                          child: Text(
                            query.isEmpty
                                ? "No Teachers Yet"
                                : "No teachers found",
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: teacherList.length,
                        itemBuilder: (context, index) {
                          final teacherItem = teacherList[index];
                          return _TeacherTile(
                            key: ValueKey(teacherItem.id),
                            teacher: teacherItem,
                            onDelete: () => _confirmDelete(teacherItem),
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

// =============================================================================
// Teacher tile
// =============================================================================

class _TeacherTile extends StatelessWidget {
  const _TeacherTile({
    super.key,
    required this.teacher,
    required this.onDelete,
  });

  final TeacherModel teacher;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = teacher.teacherName.trim();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColor.cardBorder,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: TextStyle(color: AppColor.textPrimary),
            ),
          ),
          title: Text(name),
          subtitle: Text(teacher.qualifications),
          trailing: IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever_sharp, color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _AddTeacherDialog extends StatefulWidget {
  const _AddTeacherDialog();

  @override
  State<_AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<_AddTeacherDialog> {
  static const Duration _submitTimeout = Duration(seconds: 2);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<TeacherProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Session expired. Please log in again.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    var timedOut = false;

    try {
      await provider
          .addTeacher(
            TeacherModel(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              userId: user.uid,
              teacherName: _nameController.text.trim(),
              qualifications: _qualificationController.text.trim(),
            ),
          )
          .timeout(
            _submitTimeout,
            onTimeout: () {
              timedOut = true;
            },
          );

      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            timedOut
                ? "Saved on this device. It will sync when you are online."
                : "Teacher added successfully!",
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Add teacher error: $e\n$st');
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Failed to add teacher. Please try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Teacher"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                textCapitalization: TextCapitalization.words,
                text: "enter teacher name",
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter teacher name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                textCapitalization: TextCapitalization.words,
                text: "enter Qualification",
                controller: _qualificationController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter qualifications";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Add"),
        ),
      ],
    );
  }
}
