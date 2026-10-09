import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_portal_1/models/class_model.dart';
import 'package:wisdom_portal_1/providers/class_provider.dart';
import 'package:wisdom_portal_1/providers/student_provider.dart';
import 'package:wisdom_portal_1/screens/class_detail_screen.dart';
import 'package:wisdom_portal_1/screens/promote_class_screen.dart';
import 'package:wisdom_portal_1/widgets/Custom_button.dart';
import 'package:wisdom_portal_1/widgets/app_color.dart';
import 'package:wisdom_portal_1/widgets/classes_card.dart';
import 'package:wisdom_portal_1/widgets/custom_text_field.dart';
import 'package:wisdom_portal_1/widgets/responsive_wrapper.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController addClassController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();

  @override
  void dispose() {
    addClassController.dispose();
    super.dispose();
  }

  // Active students per class, counted in ONE pass over all students.
  // Same rule as getStudentsByClass(): graduated students are not counted.
  Map<String, int> _countByClass(StudentProvider p) {
    final counts = <String, int>{};
    for (final s in p.students) {
      if (s.isGraduated) continue;
      counts[s.className] = (counts[s.className] ?? 0) + 1;
    }
    return counts;
  }

  void showAddClassDiolog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Class"),
          content: Form(
            key: _key,
            child: CustomTextField(
              textCapitalization: TextCapitalization.words,
              text: "enter class name",
              controller: addClassController,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return " enter calss";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addClassController.clear();
              },
              child: const Text("cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_key.currentState!.validate()) {
                  String name = addClassController.text.trim();

                  bool exists = context.read<ClassProvider>().isClassExist(
                    name,
                  );
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "This class already exists!",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                    return;
                  }
                  context.read<ClassProvider>().addClass(
                    ClassModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      className: name,
                    ),
                  );
                  addClassController.clear();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Class add successfully!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteClass(
    BuildContext context,
    ClassModel classItem,
    int studentCount,
  ) {
    if (studentCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${classItem.className} has students. "
            "Move or delete them before deleting the class.",
          ),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete ${classItem.className} ?',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ClassProvider>().deleteClass(classItem.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${classItem.className} delete successfully"),
                  ),
                ); // Delete call
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassProvider>().classes;
    return Scaffold(
      backgroundColor: AppColor.background,

      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text("Classes Screen"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomButton(
              icon: Icons.trending_up,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromoteClassScreen(),
                  ),
                );
              },
              text: "Promote",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: CustomButton(
              icon: Icons.add,
              onPressed: () {
                showAddClassDiolog();
              },
              text: "Add Class",
            ),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        // One listener for the whole grid (before: one Consumer per card, and
        // each card filtered ALL students). The selector counts students once
        // and the grid rebuilds only when a class count really changes, so
        // marking a fee as paid no longer rebuilds this screen.
        child: Selector<StudentProvider, Map<String, int>>(
          selector: (_, p) => _countByClass(p),
          shouldRebuild: (prev, next) => !mapEquals(prev, next),
          builder: (context, counts, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width < 500 ? 1 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 150,
                    crossAxisCount: columns,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                  ),

                  itemCount: provider.length,
                  itemBuilder: (context, index) {
                    final classItem = provider[index];
                    final studentCount = counts[classItem.className] ?? 0;

                    return KeyedSubtree(
                      key: ValueKey(classItem.id),
                      child: ClassesCard(
                        icon: Icons.house,
                        label: classItem.className,
                        studentCount: "$studentCount Students",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClassDetailScreen(classItem: classItem),
                            ),
                          );
                        },
                        onDelete: () => _confirmDeleteClass(
                          context,
                          classItem,
                          studentCount,
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
    );
  }
}
