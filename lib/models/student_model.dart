class StudentModel {
  final String id;
  final String userId;
  String studentName;
  String fatherName;
  String rollNumber;
  String className;
  final DateTime admissionDate;
  List<String> paidMonths;
  List<ClassPeriod> classPeriods;
  bool isGraduated;
  DateTime? graduationDate;

  StudentModel({
    this.id = "",
    required this.studentName,
    required this.userId,
    this.fatherName = "",
    required this.rollNumber,
    required this.className,
    required this.admissionDate,
    List<String>? paidMonths,
    List<ClassPeriod>? classPeriods,
    this.isGraduated = false,
    this.graduationDate,
  }) : paidMonths = paidMonths ?? [],
       classPeriods =
           classPeriods ??
           [ClassPeriod(className: className, startDate: admissionDate)];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'studentName': studentName,
      'fatherName': fatherName,
      'rollNumber': rollNumber,
      'className': className,
      'admissionDate': admissionDate,
      'paidMonths': paidMonths,
      'classPeriods': classPeriods.map((c) => c.toMap()).toList(),
      'isGraduated': isGraduated,
      'graduationDate': graduationDate,
    };
  }

  factory StudentModel.fromMap(String id, Map<String, dynamic> map) {
    return StudentModel(
      id: id,
      userId: map['userId'] ?? '',
      studentName: map['studentName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      className: map['className'] ?? '',
      admissionDate: (map['admissionDate']).toDate(),
      paidMonths: List<String>.from(map['paidMonths'] ?? []),
      classPeriods: (map['classPeriods'] as List<dynamic>?)
          ?.map((c) => ClassPeriod.fromMap(c as Map<String, dynamic>))
          .toList(),
      isGraduated: map['isGraduated'] ?? false,
      graduationDate: map['graduationDate'] == null
          ? null
          : (map['graduationDate']).toDate(),
    );
  }

  void promoteToClass(String newClassName) {
    classPeriods.add(
      ClassPeriod(className: newClassName, startDate: DateTime.now()),
    );
    className = newClassName;
  }

  void graduate() {
    isGraduated = true;
    graduationDate = DateTime.now();
  }

  void undoGraduation() {
    isGraduated = false;
    graduationDate = null;
  }

  List<MonthFeeStatus> getFeeStatus() {
    List<MonthFeeStatus> statusList = [];

    DateTime endSource = (isGraduated && graduationDate != null)
        ? graduationDate!
        : DateTime.now();

    DateTime current = DateTime(admissionDate.year, admissionDate.month);
    DateTime end = DateTime(endSource.year, endSource.month);

    while (!current.isAfter(end)) {
      String monthKey =
          "${current.year}-${current.month.toString().padLeft(2, '0')}";

      bool isPaid = paidMonths.contains(monthKey);

      String classForMonth = classPeriods.first.className;
      for (final period in classPeriods) {
        final periodMonth = DateTime(
          period.startDate.year,
          period.startDate.month,
        );
        if (!periodMonth.isAfter(current)) {
          classForMonth = period.className;
        }
      }

      statusList.add(
        MonthFeeStatus(
          month: monthKey,
          isPaid: isPaid,
          className: classForMonth,
        ),
      );

      current = DateTime(current.year, current.month + 1);
    }

    return statusList;
  }

  String formatMonth(String monthKey) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    List<String> parts = monthKey.split("-");
    int year = int.parse(parts[0]);
    int monthNum = int.parse(parts[1]);

    return "${monthNames[monthNum - 1]} $year";
  }
}

class ClassPeriod {
  final String className;
  final DateTime startDate;

  ClassPeriod({required this.className, required this.startDate});

  Map<String, dynamic> toMap() {
    return {'className': className, 'startDate': startDate};
  }

  factory ClassPeriod.fromMap(Map<String, dynamic> map) {
    return ClassPeriod(
      className: map['className'] ?? '',
      startDate: (map['startDate']).toDate(),
    );
  }
}

class MonthFeeStatus {
  final String month;
  final bool isPaid;
  final String className;

  MonthFeeStatus({
    required this.month,
    required this.isPaid,
    required this.className,
  });
}
