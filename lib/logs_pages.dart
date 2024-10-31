import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_row.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:rflutter_alert/rflutter_alert.dart';

class LogsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return  Query(
                options: QueryOptions(
                    document: gql(query),
                    variables: const <String, dynamic>{"variableName": "value"}),
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
                  final posts = result.data!['links'];
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final url = post['url'];
                      final description = post['description'];
                      return BlogRow(
                        url: url,
                        description: description,
                      );
                    },
                  );
});
}
}
