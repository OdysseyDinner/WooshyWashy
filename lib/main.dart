import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wooshy_washy/report_page.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class WashingMachine {
  final String id;
  String? status;

  WashingMachine(this.id, this.status);
}

class MyApp extends StatelessWidget {
  final List<WashingMachine> washingMachines = [
    WashingMachine('W1', null),
    WashingMachine('W2', null),
  ];

  final List<WashingMachine> dryingMachines = [
    WashingMachine('D1', null),
    WashingMachine('D2', null),
  ];

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Washing Machine App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WashingMachineStatusPage(washingMachines, dryingMachines),
    );
  }
}

class WashingMachineStatusPage extends StatelessWidget {
  final List<WashingMachine> washingMachines;
  final List<WashingMachine> dryingMachines;

  const WashingMachineStatusPage(this.washingMachines, this.dryingMachines,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines Status'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var machine in washingMachines) ...[
                          const SizedBox(height: 16),
                          WashingMachineButton(machine),
                        ],
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var machine in dryingMachines) ...[
                          const SizedBox(height: 16),
                          WashingMachineButton(machine),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Status containers docked at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Colors.green,
                padding: const EdgeInsets.all(8),
                child: const Text('Available: Green'),
              ),
              Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: const Text('In Use: Red'),
              ),
              Container(
                color: Colors.yellow,
                padding: const EdgeInsets.all(8),
                child: const Text('Finished: Yellow'),
              ),
              Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(8),
                child: const Text('Faulty: Grey'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WashingMachineButton extends StatefulWidget {
  final WashingMachine machine;

  const WashingMachineButton(this.machine, {super.key});

  @override
  State<WashingMachineButton> createState() => _WashingMachineButtonState();
}

class _WashingMachineButtonState extends State<WashingMachineButton> {
  Color _buttonColor = Colors.grey;
  String _endTime = "";
  late String _id;

  @override
  void initState() {
    super.initState();
    _id = widget.machine.id;
    _fetchDataFromFirebase();
  }

  void _fetchDataFromFirebase() {
    DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref('machines/$_id');

    databaseRef.onValue.listen((DatabaseEvent event) {
      final machineData = event.snapshot.value as Map;

      String status = machineData["status"];
      String endTime = machineData["end_time"];

      setState(() {
        if (status == 'Available') {
          _buttonColor = Colors.green;
          _endTime = "";
        } else if (status == 'In Use') {
          _buttonColor = Colors.red;
          _endTime = endTime;
        } else if (status == 'Finished') {
          _buttonColor = Colors.yellow;
          _endTime = "";
        } else {
          _buttonColor = Colors.grey;
          _endTime = "";
        }
      });
    });
  }

  void _navigateToReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage(id: _id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                _navigateToReportPage();
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                minimumSize: const Size(100, 80)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  _id,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  _endTime,
                  style: const TextStyle(fontSize: 16),
                )
              ],
            )), // Display end time text below the button
      ],
    );
  }
}
