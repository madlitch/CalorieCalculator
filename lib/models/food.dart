import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

const uuid = Uuid();

class Food {
  int id;
  final String name;
  final int calories;
  late String? uniqueKey;

  Food({required this.id, required this.name, required this.calories});
  Food.withKey({required this.id, required this.name, required this.calories, required this.uniqueKey});

  factory Food.fromMap(Map<String, dynamic> map) {
    int id = map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0;
    return Food.withKey(
      id: id,
      name: map['name'] ?? '',
      calories: map['calories'] is int ? map['calories'] : int.tryParse(map['calories'].toString()) ?? 0,
      uniqueKey: uuid.v4()
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'calories': calories};
  }
}
