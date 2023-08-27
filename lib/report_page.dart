import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  final String id;
  const ReportPage({super.key, required this.id});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final db = FirebaseFirestore.instance;
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void submit() {
    final reportData = {
      "data": myController.text,
      "datetime": DateTime.now().toString(),
    };

    db
        .collection("machines")
        .doc(widget.id)
        .collection("reports")
        .doc(UniqueKey().toString())
        .set(reportData)
        .onError((e, _) => print("Error sending report: $e"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit a Report for Machine ${widget.id}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
                controller: myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  submit();
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
