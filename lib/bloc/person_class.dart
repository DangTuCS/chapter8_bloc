import 'package:flutter/cupertino.dart';

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