import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => PersonsBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final PersonUrl url;

  const LoadPersonAction({required this.url}) : super();
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({
    required this.name,
    required this.age,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        name: json['name'] as String,
        age: json['age'] as int,
      );
}

Future<Iterable<Person>> getPersons(String url) async {
  final response = await http.get(Uri.parse(url));
  final List<dynamic> people = json.decode(response.body);
  return people.map((e) => Person.fromJson(e));
}

// Future<Iterable<Person>> getPersons(String url) => HttpClient()
//     .getUrl(Uri.parse(url))
//     .then((req) => req.close())
//     .then((resp) => resp.transform(utf8.decoder).join())
//     .then((str) => json.decode(str) as List<dynamic>)
//     .then((list) => list.map((e) => Person.fromJson(e)));
//

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() {
    return 'FetchResult (isRetrievedFromCache =$isRetrievedFromCache, persons = $persons)';
  }
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //caching mechanism
  final Map<PersonUrl, Iterable<Person>> _cache = {};

  PersonsBloc() : super(null) {
    on<LoadPersonAction>(
      (event, emit) async {
        final url = event.url;
        if (_cache.containsKey(url)) {
          // we have the value in the cache
          final cachedPersons = _cache[url]!;
          final result = FetchResult(
            persons: cachedPersons,
            isRetrievedFromCache: true,
          );
          emit(result);
        } else {
          final persons = await getPersons(url.urlString);
          _cache[url] = persons;
          final result = FetchResult(
            persons: persons,
            isRetrievedFromCache: false,
          );
          emit(result);
        }
      },
    );
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

enum PersonUrl {
  person1,
  person2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return "http://127.0.0.1:5500/api/person1.json";
      case PersonUrl.person2:
        return "http://127.0.0.1:5500/api/people2.json";
    }
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                        const LoadPersonAction(
                          url: PersonUrl.person1,
                        ),
                      );
                },
                child: const Text('Load json 1'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                        const LoadPersonAction(
                          url: PersonUrl.person2,
                        ),
                      );
                },
                child: const Text('Load json 2'),
              ),
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previous, current) {
              return previous?.persons != current?.persons;
            },
            builder: (context, fetchResult) {
              final persons = fetchResult?.persons;
              if (persons == null) {
                return const SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final person = persons.elementAt(index);
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text(
                        person.age.toString(),
                      ),
                    );
                  },
                  itemCount: persons.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
