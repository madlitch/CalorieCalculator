import 'package:flutter/material.dart';
import 'package:caloriecalc/widgets/food_item.dart';
import 'package:caloriecalc/models/food.dart';

class LoggedFoodsList extends StatelessWidget {
  const LoggedFoodsList({
    super.key,
    required this.loggedFoods,
    required this.onRemoveFood,
  });

  final List<Food> loggedFoods;
  final void Function(Food food, int index) onRemoveFood;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: loggedFoods.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: Key(loggedFoods[index].uniqueKey!),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        onDismissed: (direction) {
          onRemoveFood(loggedFoods[index], index);
        },
        child: FoodItem(
          food: loggedFoods[index],
          onAddFood: (f) {
          },
        ),
      ),
    );
  }
}
