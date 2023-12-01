import 'package:flutter/material.dart';
import 'package:caloriecalc/models/food.dart';

class FoodItem extends StatelessWidget {
  const FoodItem({super.key, required this.food, required this.onAddFood});

  final Food food;
  final void Function(Food food) onAddFood;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      color: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: () {
          onAddFood(food);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                food.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${food.calories}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
