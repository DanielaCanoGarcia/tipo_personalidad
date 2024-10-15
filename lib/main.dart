import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'blog_row.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:rflutter_alert/rflutter_alert.dart';


final HttpLink httpLink = HttpLink(
  "https://mysite-hdva.onrender.com/graphql/");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);
const String query = """
query   Links {
  links{
    url
    description    
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

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

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
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = ModelPage();
        break;
      case 3:
        page = RetrainPage ();
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

    return Scaffold(
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
                        label: 'Favorites',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.heart_broken),
                        label: 'Model',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_box),
                        label: 'Retrain',
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
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.heart_broken),
                        label: Text('Model'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add_box),
                        label: Text('Retrain'),
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
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          // Make sure that the compound word wraps correctly when the window
          // is too narrow.
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
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
