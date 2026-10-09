import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/student_model.dart';
import 'package:wisdom_portal_1/providers/purchase_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/screens/student_detail_screen.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

final BoxDecoration _cardDecoration = BoxDecoration(
  border: Border.all(color: Colors.blue.shade900, width: 1),
  borderRadius: BorderRadius.circular(12),
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha(35),
      blurRadius: 6,
      offset: const Offset(0, 8),
    ),
  ],
);

class _StudentFee {
  final StudentModel student;
  final int months;
  const _StudentFee(this.student, this.months);
}

class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchStudent = TextEditingController();
  String searchQuery = "";
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    searchStudent.dispose();
    tabController.dispose();
    super.dispose();
  }

  int _unpaidMonths(StudentModel s) {
    int count = 0;
    for (final m in s.getFeeStatus()) {
      if (!m.isPaid) count++;
    }
    return count;
  }

  double _unpaidDues(StudentModel s, PurchaseProvider p) {
    double sum = 0;
    for (final d in p.getPurchasesByStudent(s.id)) {
      if (!d.isPaid) sum += d.amount;
    }
    return sum;
  }

  Widget buildStudentList(List<_StudentFee> list, PurchaseProvider purchases) {
    if (list.isEmpty) {
      return const Center(child: Text("No Student Found"));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final student = item.student;
          final months = item.months;
          final dues = _unpaidDues(student, purchases);
          final pending = months > 0 || dues > 0;

          return Container(
            margin: const EdgeInsets.all(12),
            decoration: _cardDecoration,
            child: ListTile(
              title: Text(student.studentName),
              subtitle: Text(
                "${student.className} • Roll no: ${student.rollNumber}",
              ),
              trailing: pending
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (months > 0)
                          Text(
                            "$months fee unpaid",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        if (dues > 0)
                          Text(
                            "Dues Rs. $dues",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )
                  : const Text(
                      "All Paid",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentDetailScreen(student: student),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().searchAllStudent(
      searchQuery,
    );
    final purchases = context.watch<PurchaseProvider>();

    final all = <_StudentFee>[];
    final paidStudent = <_StudentFee>[];
    final unpaidStudent = <_StudentFee>[];
    for (final s in students) {
      final item = _StudentFee(s, _unpaidMonths(s));
      all.add(item);
      if (item.months > 0) {
        unpaidStudent.add(item);
      } else {
        paidStudent.add(item);
      }
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Fee Screen"),
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          controller: tabController,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Paid"),
            Tab(text: "Unpaid"),
          ],
        ),
      ),
      backgroundColor: AppColor.background,
      body: ResponsiveWrapper(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchStudent,
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: "enter student name or class...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              searchStudent.clear();
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
              child: TabBarView(
                controller: tabController,
                children: [
                  buildStudentList(all, purchases),
                  buildStudentList(paidStudent, purchases),
                  buildStudentList(unpaidStudent, purchases),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
