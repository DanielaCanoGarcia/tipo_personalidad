import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/main.dart'; // Asegúrate de importar MyAppState correctamente
import 'package:http/http.dart' as http;
import 'dart:convert';

final TextEditingController instanceController = TextEditingController();

class LinearPages extends StatefulWidget {
  @override
  _LinearPagesState createState() => _LinearPagesState();
}

class _LinearPagesState extends State<LinearPages> {
  final TextEditingController instanciaController = TextEditingController();
  String predictionResult = "";

  Future<void> linearModelPredict(BuildContext context, String instancia) async {
    const String serverUrl =
        'https://tensorflow-linear-model-hapw.onrender.com/v1/models/linear-model:predict';

    // Dividir la entrada en una lista de instancias
    List<double> instances = instancia.split(',').map((e) => double.parse(e.trim())).toList();

    final Map<String, dynamic> payload = {
      "instances": instances.map((value) => [value]).toList()
    };

    try {
      print("Enviando petición al servidor...");
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      final appState = Provider.of<MyAppState>(context, listen: false);
      final user = appState.username;

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          predictionResult = jsonResponse['predictions'].map((prediction) => prediction.toString()).join(", ");
        });

        // Registro en GraphQL
        await saveLogToServer(
          context,
          user: user,
          requestData: payload.toString(),
          responseData: jsonResponse.toString(),
        );
      } else {
        setState(() {
          predictionResult = "Error: ${response.body}";
        });

        // Registro del error
        await saveLogToServer(
          context,
          user: user,
          requestData: payload.toString(),
          responseData: "Error: ${response.body}",
        );
      }
    } catch (e) {
      print("Excepción: $e");
      setState(() {
        predictionResult = "Excepción: $e";
      });

      // Registro de la excepción
      final appState = Provider.of<MyAppState>(context, listen: false);
      final user = appState.username;

      await saveLogToServer(
        context,
        user: user,
        requestData: payload.toString(),
        responseData: "Excepción: $e",
      );
    }
  }

  Future<void> saveLogToServer(
    BuildContext context, {
    required String user,
    required String requestData,
    required String responseData,
  }) async {
    const String createLogMutation = """
      mutation CreateLog(\$user: String!, \$requestData: String!, \$responseData: String!) {
        createLog(user: \$user, requestData: \$requestData, responseData: \$responseData) {
          log {
            id
            user
            requestData
            responseData
            timestamp
          }
        }
      }
    """;

    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(createLogMutation),
          variables: {
            "user": user,
            "requestData": requestData,
            "responseData": responseData,
          },
        ),
      );

      if (result.hasException) {
        print("Error al guardar el log: ${result.exception}");
      } else {
        print("Log guardado exitosamente: ${result.data}");
      }
    } catch (e) {
      print("Error inesperado al guardar el log: $e");
    }
  }

  @override
  void dispose() {
    instanciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.token.isEmpty) {
      return Center(
        child: Text("No login yet"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Linear Model Predictor'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: instanceController,
                keyboardType: TextInputType.text, // Permitir texto completo
                decoration: InputDecoration(hintText: 'Ingrese instancias separadas por comas (ej. 3.0, 8.0, 10.0)'),
              ),
              ElevatedButton(
                onPressed: () {
                  final instancia = instanceController.text;
                  if (instancia.isNotEmpty) {
                    linearModelPredict(context, instancia);
                    instanceController.clear();
                  } else {
                    setState(() {
                      predictionResult = "Por favor ingrese un valor.";
                    });
                  }
                },
                child: const Text('Hacer Predicción'),
              ),
              SizedBox(height: 20),
              Text(
                "Resultado: $predictionResult",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
