import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:namer_app/main.dart';
import 'package:provider/provider.dart';

final TextEditingController userNameController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController CreateUserNameController = TextEditingController();
final TextEditingController createPasswordController = TextEditingController();
final TextEditingController emailController    = TextEditingController();
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
              controller: userNameController,
              decoration:
                  InputDecoration(hintText: 'Ingrese su nombre de usuario'),
            ),
            TextField(
              controller: passwordController,
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
                     appState.username = userNameController.text;
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
                   runMutation({ "username": userNameController.text,
                                  "password": passwordController.text

                                 });
                 },
                 child: const Text('Login'),
                  );
               }          
           ),

           Text(" "),
           Text("Crear nuevo usuario"),

           TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Ingrese su correo electronico'),
            ),
           TextField(
              controller: CreateUserNameController,
              decoration:
                  InputDecoration(hintText: 'Ingrese su nombre de usuario'),
            ),
            TextField(
              controller: createPasswordController,
              decoration: InputDecoration(hintText: 'Ingrese su contraseña'),
            ),
            Mutation(
               options: MutationOptions(
                 document: gql(createUserPostMutation),
                 // ignore: void_checks
                 update: (cache, result) {
                     return cache;
                 },
                 onCompleted: (result) {
                 if (result == null) {
                      print('Completed with errors ');
                   }  else {
                     print('ok ...');
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
                   runMutation({  
                                  "email": emailController.text,
                                  "username": CreateUserNameController.text,
                                  "password": createPasswordController.text

                                 });
                 },
                 child: const Text('create user'),
                  );
               }          
           ),

          ],
        ),
      ),
    );
  }
}
