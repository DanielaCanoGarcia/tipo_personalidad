import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

class LogsPage extends StatelessWidget {
  final String fetchLogsQuery = """
    query {
      allLogs {
        id
        user
        requestData
        responseData
        timestamp
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Query(
      options: QueryOptions(
        document: gql(fetchLogsQuery),
        pollInterval: Duration(seconds: 10),
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        print(result);
        if (result.data == null) {
          return const Center(
            child: Text("No logs found!"),
          );
        }
        final logs = result.data!['allLogs'];
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final user = log['user'];
            final requestData = log['requestData'];
            final responseData = log['responseData'];
            final timestamp = log['timestamp'];
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text("Usuario: $user"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Solicitud: $requestData"),
                    Text("Respuesta: $responseData"),
                    Text("Fecha: $timestamp"),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
