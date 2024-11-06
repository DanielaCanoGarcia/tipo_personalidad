import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration:
                  InputDecoration(hintText: 'Ingrese su correo electronico'),
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Ingrese su contraseña'),
            ),
            Mutation(
               options: MutationOptions(
                 document: gql(loginPostMutation),
                 // ignore: void_checks
                 update: (cache, result) {
                     return cache;
                 },
                 onCompleted: (result) {
                 if (result == null) {
                      print('Completed with errors ');
                   }  else {
                     print('ok ...');
                     appState.username = 'DaniCG';
                     appState.token = result["tokenAuth"]["token"].toString();
                     print(result["tokenAuth"]["token"]);
                   }
                 },
                 onError: (error)  {
                   print('error :');
                   appState.error = error!.graphqlErrors[0].message.toString();
                   print(error?.graphqlErrors[0].message);
                 },

               ),
               builder: ( runMutation,  result) {

                 return ElevatedButton(
                 onPressed: ()  {
                   // ignore: await_only_futures
                   runMutation({ "username": 'DaniCG',
                                  "password": 'CAGD020425'
                                 });
                 },
                 child: const Text('Login'),
                  );
               }          
           ),

          ],
        ),
      ),
    );
  }
}
