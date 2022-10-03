

import 'package:bloc/bloc.dart';
import 'package:bloc_testing/bloc/person_class.dart';
import 'package:flutter/cupertino.dart';


import 'bloc_actions.dart';

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  //caching mechanism
  final Map<String, Iterable<Person>> _cache = {};

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
          final loader = event.loader;
          final persons = await loader(url);
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

  @override
  bool operator ==(covariant FetchResult other) =>
      persons.isEqualToIgnoringOrdering(other.persons) &&
      isRetrievedFromCache == other.isRetrievedFromCache;

  @override
  int get hashCode => Object.hash(persons, isRetrievedFromCache);

}
