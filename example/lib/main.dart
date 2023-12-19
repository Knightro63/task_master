import 'package:flutter/material.dart';
import 'board_viewer.dart';
import 'project_viewer.dart';
import 'database.dart';
import 'package:css/css.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CSS.darkTheme,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? managemntData;
  String selectedProject = '';
  String currentUID = 'person1';
  bool loading = false;

  dynamic users;
  dynamic labels;
  dynamic completeData;

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() async {
    firebaseReset();
    await Database.once('users').then((val) {
      users = val;
      setState(() {});
    });

    await Database.once('label').then((val) {
      labels = val;
      setState(() {});
    });

    await Database.once('complete').then((val) {
      completeData = val;
      setState(() {});
    });
  }

  // Resets variables and listeners
  void firebaseReset() {
    users = null;
    labels = null;
    completeData = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ProjectViewer(
            labels: labels == null ? null : labels['GitHub'],
            width: 300,
            height: MediaQuery.of(context).size.height,
            epic: 'GitHub',
            onTap: (val) async {
              setState(() {
                selectedProject = val;
              });
            }
          ),
          if (users != null) Align(
            alignment: Alignment.centerRight,
            child: BoardViewer(
              completedData: completeData,
              labels: labels == null ? null : labels['GitHub'],
              epic: 'GitHub',
              project: selectedProject,
              currentUID: currentUID,
              users: users!,
              width: MediaQuery.of(context).size.width - 300,
              height: MediaQuery.of(context).size.height
            )
          )
        ],
      )
    );
  }
}
