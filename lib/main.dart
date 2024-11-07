import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/generator_page.dart';
import 'package:namer_app/login_page.dart';
import 'package:namer_app/logs_pages.dart';
import 'package:namer_app/model_page.dart';
import 'package:namer_app/retrain_page.dart';
import 'package:namer_app/seguimiento_page.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_row.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:rflutter_alert/rflutter_alert.dart';

const String query = """
query{
  links{
    url
    description
    postedBy {
      username
    }
  }
}
""";

const String loginPostMutation = """
mutation{
  tokenAuth(username:"DaniCG",password:"CAGD020425"){
    token
  }
}
""";

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  var username = "";
  var token = "";
  var error = "";

  GlobalKey? historyListKey;
  String? predictionResult;
  String? retrainResult;

  void retrainModel({
    required String datasetUrl,
    required String sha,
    required String githubToken,
  }) async {
    final url = Uri.parse("https://api.github.com/repos/DanielaCanoGarcia/heart-model/dispatches");
    final headers = {
      'Authorization': 'Bearer $githubToken',
      'Accept': 'application/vnd.github.v3+json',
      'Content-type': 'application/json',
    };
    final body = jsonEncode({
      'event_type': 'ml_ci_cd',
      'client_payload': {
        'dataseturl': datasetUrl,
        'sha': sha,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 204) {
        retrainResult = 'Reentrenamiento del modelo desencadenado exitosamente.';
      } else {
        retrainResult = 'Error al desencadenar el reentrenamiento del modelo: ${response.body}';
      }
    } catch (e) {
      retrainResult = 'Exception: $e';
    }
    notifyListeners();
  }

  void callModel({
    required int age,
    required int sex,
    required int cp,
    required int trestbps,
    required int chol,
    required int fbs,
    required int restecg,
    required int thalach,
    required int exang,
    required double oldpeak,
    required int slope,
    required int ca,
    required int thal,
  }) async {
    final url = Uri.parse("https://fastapiml-latest.onrender.com/score");
    final headers = {"Content-Type": "application/json;charset=UTF-8"};
    final predictionInstance = {
      "age": age,
      "sex": sex,
      "cp": cp,
      "trestbps": trestbps,
      "chol": chol,
      "fbs": fbs,
      "restecg": restecg,
      "thalach": thalach,
      "exang": exang,
      "oldpeak": oldpeak,
      "slope": slope,
      "ca": ca,
      "thal": thal,
    };

    try {
      final res = await http.post(url, headers: headers, body: jsonEncode(predictionInstance));
      if (res.statusCode == 200) {
        final jsonPrediction = res.body;
        print(jsonPrediction);
        predictionResult = res.body;
      } else {
        print('Error: ${res.statusCode}');
        predictionResult = 'Error: ${res.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      predictionResult = 'Exception: $e';
    }
    notifyListeners();
  }


  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    final AuthLink authLink = AuthLink(
      getToken: () async{
        print('token ${appState.token}');
        return 'JWT ${appState.token}';
      },
    );

    final Link httpLink = authLink.concat(HttpLink("https://hackernews-r8vt.onrender.com/graphql/"));
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(),
      ),
    );
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = LogsPage();
        break;
      case 2:
        page = ModelPage();
        break;
      case 3:
        page = SeguimientoPage();
        break;
      case 4:
        page = LoginPage ();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return GraphQLProvider (
      client: client, 
      child : Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Use a more mobile-friendly layout with BottomNavigationBar
            // on narrow screens.
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'logs',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.heart_broken),
                        label: 'Model',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box),
                        label: 'SeguimientoPage',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.login_sharp),
                        label: 'Login',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('logs'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.heart_broken),
                        label: Text('Model'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('SeguimientoPage'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('Login'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
     ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  /// Needed so that [MyAppState] can tell [AnimatedList] below to animate
  /// new items.
  final _key = GlobalKey();

  /// Used to "fade out" the history items at the top, to suggest continuation.
  static const Gradient _maskingGradient = LinearGradient(
    // This gradient goes from fully transparent to fully opaque black...
    colors: [Colors.transparent, Colors.black],
    // ... from the top (transparent) to half (0.5) of the way to the bottom.
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      // This blend mode takes the opacity of the shader (i.e. our gradient)
      // and applies it to the destination (i.e. our animated list).
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  pair.asLowerCase,
                  semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
