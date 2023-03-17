import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student {
  @HiveField(1)
  String name;
  @HiveField(2)
  String rollNumber;
  @HiveField(3)
  double gpa;
  @HiveField(4)
  String id;

  Student(this.name, this.rollNumber, this.gpa, this.id);
}
