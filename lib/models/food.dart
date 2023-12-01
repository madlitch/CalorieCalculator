import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

const uuid = Uuid();

class Food {
  int id;
  final String name;
  final int calories;
  late String? uniqueKey;

  // uniqueKeys are necessary if we have multiple of instances of a food in
  // a list - there is no differentiator in the widget tree if we want to remove
  // a specific one, so every food instance has a uniqueKey (uuid) created for
  // it when it's put into a listview builder, which is why we need two
  // constructors

  Food({
    required this.id,
    required this.name,
    required this.calories,
  });

  Food.withKey({
    required this.id,
    required this.name,
    required this.calories,
    required this.uniqueKey,
  });

  // helps create food instances when returning from database
  factory Food.fromMap(Map<String, dynamic> map) {
    int id =
        map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0;
    return Food.withKey(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] is int
          ? map['calories']
          : int.tryParse(map['calories'].toString()) ?? 0,
      uniqueKey: uuid.v4(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'calories': calories};
  }
}
