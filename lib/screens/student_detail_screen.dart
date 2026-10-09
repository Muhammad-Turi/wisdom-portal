import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/purchase_model.dart';
import 'package:wisdom_portal_1/models/student_model.dart';
import 'package:wisdom_portal_1/providers/purchase_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/utils/responsive.dart';
import 'package:wisdom_portal_1/widgets/Custom_button.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

final List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

final List<BoxShadow> _profileShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  ),
];

class StudentDetailScreen extends StatefulWidget {
  final StudentModel student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  void _disposeLater(List<TextEditingController> controllers) {
    Future.delayed(const Duration(milliseconds: 500), () {
      for (final c in controllers) {
        c.dispose();
      }
    });
  }

  Future<void> _showEditStudentDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: widget.student.studentName,
    );
    final fatherController = TextEditingController(
      text: widget.student.fatherName,
    );
    final rollController = TextEditingController(
      text: widget.student.rollNumber,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Student"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  text: "Student name",
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "enter student name"
                      : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  text: "Father name",
                  controller: fatherController,
                  keyboardType: TextInputType.text,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "enter father name"
                      : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  text: "Roll number",
                  controller: rollController,
                  keyboardType: TextInputType.text,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? "enter roll number"
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    final newName = nameController.text.trim();
    final newFather = fatherController.text.trim();
    final newRoll = rollController.text.trim();
    _disposeLater([nameController, fatherController, rollController]);

    if (saved != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<StudentProvider>();

    final oldName = widget.student.studentName;
    final oldFather = widget.student.fatherName;
    final oldRoll = widget.student.rollNumber;

    widget.student.studentName = newName;
    widget.student.fatherName = newFather;
    widget.student.rollNumber = newRoll;
    setState(() {});

    try {
      await provider
          .updateStudent(widget.student)
          .timeout(const Duration(seconds: 2), onTimeout: () {});
      messenger.showSnackBar(
        const SnackBar(content: Text("Student updated successfully!")),
      );
    } catch (e) {
      widget.student.studentName = oldName;
      widget.student.fatherName = oldFather;
      widget.student.rollNumber = oldRoll;
      if (mounted) setState(() {});
      messenger.showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  Future<void> _confirmDeleteStudent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text(
          "Are you sure you want to delete ${widget.student.studentName}? "
          "This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final studentProvider = context.read<StudentProvider>();
    final purchaseProvider = context.read<PurchaseProvider>();
    final id = widget.student.id;
    final name = widget.student.studentName;

    try {
      await studentProvider
          .deleteStudent(id)
          .timeout(const Duration(seconds: 2), onTimeout: () {});
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
      return;
    }

    String message = "$name deleted";
    try {
      await purchaseProvider
          .deletePurchasesByStudent(id)
          .timeout(const Duration(seconds: 2), onTimeout: () {});
    } catch (e) {
      message = "$name deleted, but some dues could not be removed";
    }

    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void showAddPurchaseDialog() {
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Dues"),
              content: Form(
                key: _key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      text: "enter items...",
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.text,
                      controller: _itemController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "enter item name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      text: "enter amount",
                      textCapitalization: TextCapitalization.words,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return " enter amount";
                        }
                        if (double.tryParse(value) == null) {
                          return " enter a valid number";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          _amountController.clear();
                          _itemController.clear();
                          Navigator.pop(context);
                        },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_key.currentState!.validate()) {
                            double amount = double.parse(
                              _amountController.text.trim(),
                            );

                            setDialogState(() => isSubmitting = true);

                            try {
                              await context
                                  .read<PurchaseProvider>()
                                  .addPurchase(
                                    PurchaseModel(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      userId: FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .uid,
                                      amount: amount,
                                      studentId: widget.student.id,
                                      itemName: _itemController.text.trim(),
                                      purchaseDate: DateTime.now(),
                                      classAtTime: widget.student.className,
                                    ),
                                  )
                                  .timeout(
                                    const Duration(seconds: 2),
                                    onTimeout: () {},
                                  );

                              _amountController.clear();
                              _itemController.clear();

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Due added successfully!"),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to add due: $e"),
                                ),
                              );
                            } finally {
                              if (context.mounted) {
                                setDialogState(() => isSubmitting = false);
                              }
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Add Dues"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(" Student Detail"),
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomButton(
              icon: Icons.add,
              onPressed: showAddPurchaseDialog,
              text: "Add Dues",
            ),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<StudentProvider>(
                  builder: (context, studentProvider, child) {
                    final feeStatus = widget.student.getFeeStatus();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(context, feeStatus),
                        const SizedBox(height: 20),
                        const Text(
                          "Fee Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FeeDetailsSection(
                          student: widget.student,
                          feeStatus: feeStatus,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                const Divider(thickness: 2),

                const Text(
                  "Purchases / Dues",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                _DuesSection(student: widget.student),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    List<MonthFeeStatus> feeStatus,
  ) {
    int paidCount = 0;
    int unpaidCount = 0;
    for (final m in feeStatus) {
      if (m.isPaid) {
        paidCount++;
      } else {
        unpaidCount++;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobile(constraints.maxWidth);

        final leftSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade50,
                  ),
                  child: const Icon(Icons.person, size: 60),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.student.studentName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.person_outline,
                    label: "Father Name",
                    value: widget.student.fatherName,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.school_outlined,
                    label: "Class",
                    value: widget.student.className,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.tag,
                    label: "Roll number",
                    value: widget.student.rollNumber,
                  ),
                ),
                const Expanded(
                  child: _InfoTile(
                    icon: Icons.group_outlined,
                    label: "Section",
                    value: "A",
                  ),
                ),
              ],
            ),
          ],
        );

        final rightSection = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            widget.student.isGraduated
                ? ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("Undo Graduation"),
                          content: Text(
                            "Move ${widget.student.studentName} back to "
                            "${widget.student.className} as an active student? "
                            "Fee months after the graduation month will appear again.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Undo"),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true || !context.mounted) return;

                      context.read<StudentProvider>().undoGraduation(
                        widget.student.id,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${widget.student.studentName} is active again in ${widget.student.className}",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.undo, size: 18),
                    label: const Text("Undo Graduation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade800,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: Colors.green.shade100),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: "Options",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') _showEditStudentDialog();
                      if (value == 'delete') _confirmDeleteStudent();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Fee Status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FeeStat(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        count: paidCount.toString(),
                        label: "Paid",
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 20),
                      _FeeStat(
                        icon: Icons.error,
                        iconColor: Colors.red,
                        count: unpaidCount.toString(),
                        label: "Unpaid",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _profileShadow,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftSection,
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      rightSection,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: leftSection),
                      const SizedBox(width: 20),
                      const VerticalDivider(
                        thickness: 1,
                        color: Colors.black12,
                      ),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: rightSection),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _FeeGroup {
  final List<MonthFeeStatus> unpaid = [];
  final List<MonthFeeStatus> paid = [];
}

class _FeeDetailsSection extends StatefulWidget {
  final StudentModel student;
  final List<MonthFeeStatus> feeStatus;

  const _FeeDetailsSection({required this.student, required this.feeStatus});

  @override
  State<_FeeDetailsSection> createState() => _FeeDetailsSectionState();
}

class _FeeDetailsSectionState extends State<_FeeDetailsSection> {
  final Set<String> _expandedFeeGroups = {};

  @override
  Widget build(BuildContext context) {
    final Map<String, _FeeGroup> groups = {};
    for (final month in widget.feeStatus) {
      final group = groups.putIfAbsent(month.className, () => _FeeGroup());
      if (month.isPaid) {
        group.paid.add(month);
      } else {
        group.unpaid.add(month);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.entries
          .map((entry) => _buildGroup(context, entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildGroup(BuildContext context, String className, _FeeGroup group) {
    final unpaid = group.unpaid;
    final paid = group.paid;
    final isExpanded = _expandedFeeGroups.contains(className);
    final student = widget.student;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            className.isEmpty ? "Unknown Class" : className,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        if (unpaid.isEmpty && paid.isNotEmpty)
          const Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "All fees paid for this class",
              style: TextStyle(
                color: Colors.green,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ...unpaid.map(
          (month) => _StatusCard(
            leadingIcon: Icons.calendar_today_outlined,
            title: student.formatMonth(month.month),
            subtitle: null,
            isPaid: false,
            onMarkPaid: () {
              student.paidMonths.add(month.month);
              context.read<StudentProvider>().updateStudent(student);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${student.formatMonth(month.month)} marked as paid!",
                  ),
                ),
              );
            },
          ),
        ),

        if (paid.isNotEmpty)
          Align(
            alignment: Alignment.bottomLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  isExpanded
                      ? _expandedFeeGroups.remove(className)
                      : _expandedFeeGroups.add(className);
                });
              },
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              label: Text(
                isExpanded ? "Hide Paid" : "Show Paid (${paid.length})",
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),

        if (isExpanded)
          ...paid.map(
            (month) => _StatusCard(
              leadingIcon: Icons.check_circle_outline,
              title: student.formatMonth(month.month),
              subtitle: null,
              isPaid: true,
              onMarkPaid: () {},
            ),
          ),
      ],
    );
  }
}

class _DueGroup {
  final List<PurchaseModel> unpaid = [];
  final List<PurchaseModel> paid = [];
}

class _DuesSection extends StatefulWidget {
  final StudentModel student;
  const _DuesSection({required this.student});

  @override
  State<_DuesSection> createState() => _DuesSectionState();
}

class _DuesSectionState extends State<_DuesSection> {
  final Set<String> _expandedDuesGroups = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        final purchases = purchaseProvider.getPurchasesByStudent(
          widget.student.id,
        );

        if (purchases.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text("No purchases yet"),
          );
        }

        // Totals AND grouping in a single pass over the list.
        double totalAmount = 0;
        double paidAmount = 0;
        double remainingAmount = 0;
        final Map<String, _DueGroup> grouped = {};

        for (final p in purchases) {
          totalAmount += p.amount;
          final group = grouped.putIfAbsent(p.classAtTime, () => _DueGroup());
          if (p.isPaid) {
            paidAmount += p.amount;
            group.paid.add(p);
          } else {
            remainingAmount += p.amount;
            group.unpaid.add(p);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 184, 204, 240),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      "Total: Rs: $totalAmount",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Paid: Rs: $paidAmount",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 25, 139, 28),
                      ),
                    ),
                    Text(
                      "Due: Rs: $remainingAmount",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 247, 21, 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: grouped.entries
                  .map(
                    (entry) => _buildGroup(
                      context,
                      purchaseProvider,
                      entry.key,
                      entry.value,
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroup(
    BuildContext context,
    PurchaseProvider purchaseProvider,
    String className,
    _DueGroup group,
  ) {
    final unpaid = group.unpaid;
    final paid = group.paid;
    final isExpanded = _expandedDuesGroups.contains(className);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            className.isEmpty ? "Unknown Class" : className,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        if (unpaid.isEmpty && paid.isNotEmpty)
          const Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "All dues paid for this class",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

        ...unpaid.map(
          (purchase) => _StatusCard(
            leadingIcon: Icons.shopping_bag_outlined,
            title: purchase.itemName,
            subtitle: "Rs. ${purchase.amount}",
            isPaid: false,
            onMarkPaid: () {
              purchaseProvider.updatePurchase(
                PurchaseModel(
                  id: purchase.id,
                  userId: purchase.userId,
                  amount: purchase.amount,
                  studentId: purchase.studentId,
                  itemName: purchase.itemName,
                  purchaseDate: purchase.purchaseDate,
                  classAtTime: purchase.classAtTime,
                  isPaid: true,
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${purchase.itemName} marked as paid!")),
              );
            },
          ),
        ),

        if (paid.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              setState(() {
                isExpanded
                    ? _expandedDuesGroups.remove(className)
                    : _expandedDuesGroups.add(className);
              });
            },
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            label: Text(
              isExpanded ? "Hide Paid" : "Show Paid (${paid.length})",
              style: const TextStyle(fontSize: 15),
            ),
          ),

        if (isExpanded)
          ...paid.map(
            (purchase) => _StatusCard(
              leadingIcon: Icons.check_circle_outline,
              title: purchase.itemName,
              subtitle: "Rs. ${purchase.amount}",
              isPaid: true,
              onMarkPaid: () {},
            ),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final bool isPaid;
  final VoidCallback onMarkPaid;

  const _StatusCard({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.isPaid,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                leadingIcon,
                color: isPaid ? Colors.green : Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            isPaid
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Paid",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    onPressed: onMarkPaid,
                    child: const Text(
                      "Mark as Paid",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF475569), size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeeStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;

  const _FeeStat({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: iconColor == Colors.green
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
