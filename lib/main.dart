import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/student.dart';
import 'package:uuid/uuid.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(StudentAdapter());
  await Hive.openBox('students');
  // final studentBox = Hive.box('students');
  // studentBox.clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();

  TextEditingController rollNumberController = TextEditingController();

  TextEditingController gpaController = TextEditingController();

  String id = "";

  void editStudent(String id) {
    final student = Student(nameController.text, rollNumberController.text,
        double.parse(gpaController.text.trim()), id);
    addStudent(student, id);
  }

  void addStudent(Student student, String id) {
    final studentBox = Hive.box('students');
    studentBox.put(id, student);
  }

  void deleteStudent(String id) {
    final studentBox = Hive.box('students');
    studentBox.delete(id);
  }

  void clear() {
    nameController.clear();
    rollNumberController.clear();
    gpaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Name'),
                SizedBox(
                    width: 300,
                    height: 40,
                    child: TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 40),
                const Text('Roll Number'),
                SizedBox(
                    width: 300,
                    height: 40,
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: rollNumberController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 40),
                const Text('GPA'),
                SizedBox(
                    width: 300,
                    height: 40,
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d{0,1}\.?\d{0,1})'))
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: gpaController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    )),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    id == ""
                        ? MaterialButton(
                            color: Colors.greenAccent,
                            highlightColor: Colors.green,
                            onPressed: () {
                              if (nameController.text != '' &&
                                  rollNumberController.text != '' &&
                                  gpaController.text != '') {
                                final student = Student(
                                    nameController.text,
                                    rollNumberController.text,
                                    double.parse(gpaController.text.trim()),
                                    const Uuid().v4());
                                addStudent(student, student.id);
                                clear();
                                setState(() {});
                              }
                            },
                            child: const Text('Add'),
                          )
                        : Container(),
                    id != ''
                        ? MaterialButton(
                            color: Colors.greenAccent,
                            highlightColor: Colors.green,
                            onPressed: () {
                              if (nameController.text != '' &&
                                  rollNumberController.text != '' &&
                                  gpaController.text != '') {
                                editStudent(id);
                                id = '';
                                clear();
                                setState(() {});
                              }
                            },
                            child: const Text('Edit'),
                          )
                        : Container(),
                    id != ''
                        ? MaterialButton(
                            color: Colors.greenAccent,
                            highlightColor: Colors.green,
                            onPressed: () {
                              id = '';
                              clear();
                              setState(() {});
                            },
                            child: const Text('Cancel'),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  height: 270,
                  child: ValueListenableBuilder<Box>(
                      valueListenable: Hive.box('students').listenable(),
                      builder: (context, box, widget) {
                        return ListView.builder(
                            itemCount: box.values.length,
                            itemBuilder: (context, index) {
                              final student = box.getAt(index) as Student;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(25)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Name: ${student.name}"),
                                          Text(
                                              "Roll No: ${student.rollNumber}"),
                                          Text("GPA: ${student.gpa}")
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                nameController.text =
                                                    student.name;
                                                rollNumberController.text =
                                                    student.rollNumber;
                                                gpaController.text =
                                                    student.gpa.toString();
                                                id = student.id;
                                                setState(() {});
                                              },
                                              child: const Icon(Icons.edit)),
                                          const SizedBox(width: 20),
                                          InkWell(
                                              onTap: () {
                                                deleteStudent(student.id);
                                                id = '';
                                                clear();
                                                setState(() {});
                                              },
                                              child: const Icon(Icons.delete))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
