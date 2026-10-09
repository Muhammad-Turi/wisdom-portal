import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/student_model.dart';
import 'package:wisdom_portal_1/providers/purchase_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/screens/student_detail_screen.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

final BoxDecoration _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

class GraduatedStudentsScreen extends StatefulWidget {
  const GraduatedStudentsScreen({super.key});

  @override
  State<GraduatedStudentsScreen> createState() =>
      _GraduatedStudentsScreenState();
}

class _GraduatedStudentsScreenState extends State<GraduatedStudentsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Graduated Students"),
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: searchController,
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "search name or roll no...",
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = "";
                            });
                          },
                          icon: const Icon(Icons.cancel),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  final students = studentProvider.searchGraduated(searchQuery);

                  if (students.isEmpty) {
                    return const Center(child: Text("No graduated students"));
                  }

                  final Map<int, List<StudentModel>> byYear = {};
                  for (final s in students) {
                    final year = s.graduationDate?.year ?? 0;
                    byYear.putIfAbsent(year, () => []).add(s);
                  }
                  final years = byYear.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  final items = <Object>[];
                  for (final year in years) {
                    items.add(year);
                    items.addAll(byYear[year]!);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (item is int) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            item == 0 ? "Graduated" : "Graduated $item",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }

                      final s = item as StudentModel;
                      return _GraduatedCard(
                        student: s,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentDetailScreen(student: s),
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

class _GraduatedCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _GraduatedCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    int unpaidMonths = 0;
    for (final m in student.getFeeStatus()) {
      if (!m.isPaid) unpaidMonths++;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration,
      child: Consumer<PurchaseProvider>(
        builder: (context, purchaseProvider, child) {
          // One loop gives both the count and the total of unpaid dues.
          int unpaidDuesCount = 0;
          double unpaidDuesAmount = 0;
          for (final p in purchaseProvider.getPurchasesByStudent(student.id)) {
            if (!p.isPaid) {
              unpaidDuesCount++;
              unpaidDuesAmount += p.amount;
            }
          }

          final hasPending = unpaidMonths > 0 || unpaidDuesCount > 0;

          return ListTile(
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: CircleAvatar(
              backgroundColor: hasPending
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              child: Icon(
                Icons.school,
                color: hasPending ? Colors.red.shade800 : Colors.green.shade800,
              ),
            ),
            title: Text(
              student.studentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "${student.className} · Roll no: ${student.rollNumber}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (unpaidMonths > 0) _badge("$unpaidMonths fee unpaid"),
                    if (unpaidDuesCount > 0) ...[
                      if (unpaidMonths > 0) const SizedBox(height: 4),
                      _badge("Dues Rs. $unpaidDuesAmount"),
                    ],
                    if (!hasPending)
                      Text(
                        "All clear",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
