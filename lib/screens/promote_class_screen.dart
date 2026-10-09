import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/providers/class_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrappper.dart';

class PromoteClassScreen extends StatefulWidget {
  const PromoteClassScreen({super.key});

  @override
  State<PromoteClassScreen> createState() => _PromoteClassScreenState();
}

class _PromoteClassScreenState extends State<PromoteClassScreen> {
  static const Duration _submitTimeout = Duration(seconds: 2);

  // These change rarely -> normal setState is fine.
  String? sourceClass;
  String? targetClass;
  bool isGraduateMode = false;

  // These change often -> ValueNotifier, so only the widgets that listen
  // to them rebuild (NOT the whole screen).
  final ValueNotifier<Set<String>> _selected = ValueNotifier<Set<String>>({});
  final ValueNotifier<bool> _isSubmitting = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _selected.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Selection helpers
  // ---------------------------------------------------------------------------

  void _toggle(String id, bool on) {
    final next = Set<String>.of(_selected.value);
    on ? next.add(id) : next.remove(id);
    _selected.value = next; // new Set so listeners fire
  }

  void _selectAll(Iterable<String> ids) {
    _selected.value = Set<String>.of(ids);
  }

  void _clearSelection() {
    _selected.value = <String>{};
  }

  bool get _isSameClass =>
      !isGraduateMode && targetClass != null && targetClass == sourceClass;

  // ---------------------------------------------------------------------------
  // Submit (one shared method instead of two copies)
  // ---------------------------------------------------------------------------

  Future<void> _run({
    required Future<void> Function() action,
    required String successMessage,
    required String errorMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    _isSubmitting.value = true;
    var timedOut = false;

    try {
      await action().timeout(
        _submitTimeout,
        onTimeout: () {
          // Probably offline: saved on the device, syncs later.
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
                : successMessage,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('PromoteClassScreen error: $e\n$st');
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  Future<void> _confirmAndRun() async {
    final ids = _selected.value.toList();
    final count = ids.length;
    final target = targetClass;
    final studentProvider = context.read<StudentProvider>();

    if (isGraduateMode) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Graduate Students"),
          content: Text(
            "Graduate $count students? Their fee stops after this month. "
            "Old fee and dues stay on their record.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                "Graduate",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      await _run(
        action: () => studentProvider.graduateMultipleStudents(ids),
        successMessage: "$count students graduated!",
        errorMessage: "Failed to graduate students. Please try again.",
      );
    } else {
      if (target == null) return;

      await _run(
        action: () => studentProvider.promoteMultipleStudents(ids, target),
        successMessage: "$count students promoted to $target!",
        errorMessage: "Failed to promote students. Please try again.",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(isGraduateMode ? "Graduate Students" : "Promote Students"),
      ),
      // Blocks touches while submitting. `child` is passed in so it is NOT
      // rebuilt when _isSubmitting changes, only the AbsorbPointer is.
      body: ValueListenableBuilder<bool>(
        valueListenable: _isSubmitting,
        child: ResponsiveWrapper(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildClassSelectors(),
              ),

              if (isGraduateMode) const _GraduateBanner(),

              const SizedBox(height: 12),
              const Divider(height: 1),

              Expanded(child: _buildStudentArea()),

              _buildSubmitButton(),
            ],
          ),
        ),
        builder: (context, submitting, child) =>
            AbsorbPointer(absorbing: submitting, child: child),
      ),
    );
  }

  Widget _buildClassSelectors() {
    return Selector<ClassProvider, List<String>>(
      selector: (_, p) => p.classes.map((c) => c.className).toList(),
      shouldRebuild: (previous, next) => !listEquals(previous, next),
      builder: (context, classNames, child) {
        final items = classNames
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList();

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey('source_$sourceClass'),
                isExpanded: true,
                initialValue: sourceClass,
                decoration: const InputDecoration(
                  labelText: "From Class",
                  border: OutlineInputBorder(),
                ),
                items: items,
                onChanged: (value) {
                  final classProvider = context.read<ClassProvider>();
                  _clearSelection();
                  setState(() {
                    sourceClass = value;
                    isGraduateMode =
                        value != null && classProvider.isLastClass(value);
                    targetClass = (value == null || isGraduateMode)
                        ? null
                        : classProvider.getNextClassName(value);
                  });
                },
              ),
            ),
            if (!isGraduateMode) ...[
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('target_$targetClass'),
                  isExpanded: true,
                  initialValue: targetClass,
                  decoration: InputDecoration(
                    labelText: "To Class",
                    border: const OutlineInputBorder(),
                    errorText: _isSameClass ? "Choose a different class" : null,
                  ),
                  items: items,
                  onChanged: (value) {
                    setState(() => targetClass = value);
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStudentArea() {
    if (sourceClass == null) {
      return const Center(child: Text("Select a class to promote"));
    }

    // Rebuilds only when StudentProvider changes, NOT on checkbox taps.
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        final students = studentProvider.getStudentsByClass(sourceClass!);

        if (students.isEmpty) {
          return const Center(child: Text("No students in this class"));
        }

        return Column(
          children: [
            _SelectAllRow(
              selected: _selected,
              students: students,
              onSelectAll: _selectAll,
              onClear: _clearSelection,
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];
                  return _StudentTile(
                    key: ValueKey(s.id),
                    id: s.id,
                    name: s.studentName,
                    rollNumber: '${s.rollNumber}',
                    selected: _selected,
                    onToggle: _toggle,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
        child: SizedBox(
          width: double.infinity,
          child: ListenableBuilder(
            listenable: Listenable.merge([_selected, _isSubmitting]),
            builder: (context, child) {
              final count = _selected.value.length;
              final submitting = _isSubmitting.value;

              final disabled =
                  count == 0 ||
                  (!isGraduateMode && targetClass == null) ||
                  _isSameClass ||
                  submitting;

              return ElevatedButton(
                onPressed: disabled ? null : _confirmAndRun,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGraduateMode ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        count == 0
                            ? "Select students"
                            : isGraduateMode
                            ? "Graduate $count Students"
                            : "Promote $count Students",
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GraduateBanner extends StatelessWidget {
  const _GraduateBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.green.shade700),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "This is the last class. Selected students will be "
              "moved to Graduated.",
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectAllRow extends StatelessWidget {
  const _SelectAllRow({
    required this.selected,
    required this.students,
    required this.onSelectAll,
    required this.onClear,
  });

  final ValueNotifier<Set<String>> selected;
  final List<dynamic> students; // List<Student>
  final void Function(Iterable<String> ids) onSelectAll;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ValueListenableBuilder<Set<String>>(
        valueListenable: selected,
        builder: (context, ids, child) {
          final allSelected =
              students.isNotEmpty && students.every((s) => ids.contains(s.id));
          final selectedCount = students
              .where((s) => ids.contains(s.id))
              .length;

          return Row(
            children: [
              Checkbox(
                value: allSelected,
                onChanged: (checked) {
                  if (checked == true) {
                    onSelectAll(students.map<String>((s) => s.id as String));
                  } else {
                    onClear();
                  }
                },
              ),
              Text(
                allSelected ? "Deselect All" : "Select All",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "$selectedCount / ${students.length} selected",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    super.key,
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.selected,
    required this.onToggle,
  });

  final String id;
  final String name;
  final String rollNumber;
  final ValueNotifier<Set<String>> selected;
  final void Function(String id, bool on) onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ValueListenableBuilder<Set<String>>(
        valueListenable: selected,
        builder: (context, ids, child) {
          return CheckboxListTile(
            secondary: child,
            title: Text(name),
            subtitle: Text("Roll no: $rollNumber"),
            value: ids.contains(id),
            onChanged: (checked) => onToggle(id, checked == true),
          );
        },
        child: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
      ),
    );
  }
}
