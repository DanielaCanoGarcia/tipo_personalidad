import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

class ModelPage extends StatelessWidget {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController cpController = TextEditingController();
  final TextEditingController trestbpsController = TextEditingController();
  final TextEditingController cholController = TextEditingController();
  final TextEditingController fbsController = TextEditingController();
  final TextEditingController restecgController = TextEditingController();
  final TextEditingController thalachController = TextEditingController();
  final TextEditingController exangController = TextEditingController();
  final TextEditingController oldpeakController = TextEditingController();
  final TextEditingController slopeController = TextEditingController();
  final TextEditingController caController = TextEditingController();
  final TextEditingController thalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'age'),
            ),
            TextField(
              controller: sexController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'sex'),
            ),
            TextField(
              controller: cpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'cp'),
            ),
            TextField(
              controller: trestbpsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'trestbps'),
            ),
            TextField(
              controller: cholController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'chol'),
            ),
            TextField(
              controller: fbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'fbs'),
            ),
            TextField(
              controller: restecgController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'restecg'),
            ),
            TextField(
              controller: thalachController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'thalach'),
            ),
            TextField(
              controller: exangController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'exang'),
            ),
            TextField(
              controller: oldpeakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'oldpeak'),
            ),
            TextField(
              controller: slopeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'slope'),
            ),
            TextField(
              controller: caController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'ca'),
            ),
            TextField(
              controller: thalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'thal'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.callModel(
                  age: int.parse(ageController.text),
                  sex: int.parse(sexController.text),
                  cp: int.parse(cpController.text),
                  trestbps: int.parse(trestbpsController.text),
                  chol: int.parse(cholController.text),
                  fbs: int.parse(fbsController.text),
                  restecg: int.parse(restecgController.text),
                  thalach: int.parse(thalachController.text),
                  exang: int.parse(exangController.text),
                  oldpeak: double.parse(oldpeakController.text),
                  slope: int.parse(slopeController.text),
                  ca: int.parse(caController.text),
                  thal: int.parse(thalController.text),
                );
              },
              child: Text('Predict'),
            ),
            Consumer<MyAppState>(
              builder: (context, appState, child) {
                return Text(appState.predictionResult ?? '');
              },
            ),
          ],
        ),
      ),
    );
  }
}
