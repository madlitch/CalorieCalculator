import 'package:caloriecalc/models/food.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:caloriecalc/widgets/food_item.dart';

class FoodList extends StatefulWidget {
  const FoodList({
    super.key,
    required this.foods,
    required this.onAddFood,
    required this.onDeleteFood,
    required this.onUpdateFood,
  });

  final void Function(Food food) onAddFood;
  final void Function(Food food) onDeleteFood;
  final void Function(
          BuildContext context, Food food, Function(Food) editFoodCallback)
      onUpdateFood;
  final List<Food> foods;

  @override
  State<FoodList> createState() => FoodListState();
}

class FoodListState extends State<FoodList> {
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _foods = widget.foods;
  }

  void updateFoods(Food newFood) {
    setState(() {
      _foods.insert(0, newFood);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      return ListView.builder(
        itemCount: _foods.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: Key(_foods[index].uniqueKey!),
          background: const Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DismissibleLabel(
                text: 'Update',
                color: Colors.orange,
                alignment: Alignment.centerLeft,
              ),
              DismissibleLabel(
                text: 'Delete',
                color: Colors.red,
                alignment: Alignment.centerRight,
              ),
            ],
          ),
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              widget.onDeleteFood(_foods[index]);
            } else {
              widget.onUpdateFood(context, _foods[index], (editedFood) async {
                setState(() {
                  replaceFoodInList(_foods, editedFood);
                });
              });
            }
          },
          child: FoodItem(
            food: widget.foods[index],
            onAddFood: widget.onAddFood,
          ),
        ),
      );
    });
  }
}

void replaceFoodInList(List<Food> foods, Food newFood) {
  for (int i = 0; i < foods.length; i++) {
    if (foods[i].id == newFood.id) {
      foods[i] = newFood;
      break; // Stop the loop once the food item is replaced
    }
  }
}

class DismissibleLabel extends StatelessWidget {
  const DismissibleLabel({
    super.key,
    required this.text,
    required this.color,
    required this.alignment,
  });

  final String text;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: alignment,
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
