import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bloc/bloc_actions.dart';
import 'bloc/person_class.dart';
import 'bloc/persons_bloc.dart';

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

const persons1Url = 'http://127.0.0.1:5500/api/person1.json';
const persons2Url = 'http://127.0.0.1:5500/api/people2.json';

Future<Iterable<Person>> getPersons(String url) async {
  final response = await http.get(Uri.parse(url));
  final List<dynamic> people = json.decode(response.body);
  return people.map((e) => Person.fromJson(e));
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
                          url: persons1Url,
                          loader: getPersons,
                        ),
                      );
                },
                child: const Text('Load json 1'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PersonsBloc>().add(
                        const LoadPersonAction(
                          url: persons2Url,
                          loader: getPersons,
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
