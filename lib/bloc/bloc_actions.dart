import 'package:bloc_testing/bloc/person_class.dart';
import 'package:flutter/cupertino.dart';

extension IsEqualToIgnoringOrdering<T> on Iterable<T> {
  bool isEqualToIgnoringOrdering(Iterable<T> other) =>
      length == other.length && {...this}.intersection({...other}).length == length;
}

typedef PersonsLoader = Future<Iterable<Person>> Function(String url);


@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction implements LoadAction {
  final String url;
  final PersonsLoader loader;

  const LoadPersonAction({
    required this.url,
    required this.loader,
  }) : super();
}
