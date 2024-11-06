import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

class RetrainPage extends StatelessWidget {
  final TextEditingController datasetUrlController = TextEditingController();
  final TextEditingController shaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: datasetUrlController,
              decoration: InputDecoration(hintText: 'Ingrese URL del dataset'),
            ),
            TextField(
              controller: shaController,
              decoration: InputDecoration(hintText: 'Ingrese el SHA'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.retrainModel(
                  datasetUrl: datasetUrlController.text,
                  sha: shaController.text,
                  githubToken: "token",
                );
              },
              child: Text('Reentrenar'),
            ),
            Consumer<MyAppState>(
              builder: (context, appState, child) {
                return Text(appState.retrainResult ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}