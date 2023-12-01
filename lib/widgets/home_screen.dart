import 'package:flutter/material.dart';
import 'package:caloriecalc/widgets/food_list.dart';
import 'package:caloriecalc/widgets/logged_foods_list.dart';
import 'package:caloriecalc/models/food.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../util/database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<Food> _loggedFoods = [];
  int targetCalories = 0;
  static DateTime selectedDate = DateTime.now();
  int consumedCalories = 0;
  TextEditingController calorieController = TextEditingController();

  static DatabaseUtil database = DatabaseUtil();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    await Future.delayed(Duration.zero);
    // await database.resetDatabase();
    try {
      String formattedDate = _formatDate(selectedDate);
      List<Food> foods = await database.getFoodsFromDate(formattedDate);
      int tcalories = await database.getTargetCalories(formattedDate);
      int calories = 0;
      for (Food food in foods) {
        calories += food.calories;
      }
      setState(() {
        _loggedFoods = foods;
        consumedCalories = calories;
        targetCalories = tcalories;
        if (tcalories == 0) {
          calorieController.text = '';
        } else {
          calorieController.text = '$tcalories';
        }
      });
    } catch (error) {
      // print(error);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadFoods();
    }
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _logFood(Food food) async {
    if (consumedCalories + food.calories > targetCalories) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Calorie Limit Exceeded"),
            content: const Text(
                "Adding this item will exceed your target calories. Are you sure you want to proceed?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
              TextButton(
                child: const Text("Proceed"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  _actuallyLogFood(food); // Proceed to add the food
                },
              ),
            ],
          );
        },
      );
    } else {
      _actuallyLogFood(food);
    }
  }

  Future<void> _deleteFood(Food food) async {
    database.deleteFood(food.id);
  }

  Future<void> _actuallyLogFood(Food food) async {
    database.logFood(food, _formatDate(selectedDate), targetCalories);
    Food foodWithUniqueKey = Food.withKey(
        id: food.id,
        name: food.name,
        calories: food.calories,
        uniqueKey: uuid.v4());

    setState(() {
      consumedCalories += foodWithUniqueKey.calories;
      _loggedFoods.add(foodWithUniqueKey);
    });
  }

  Future<void> _removeFood(Food food, int index) async {
    await database.deleteConsumedFood(food.id, _formatDate(selectedDate));
    setState(() {
      consumedCalories -= food.calories;
      _loggedFoods
          .removeWhere((listFood) => listFood.uniqueKey == food.uniqueKey);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Food deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              consumedCalories += food.calories;
              _loggedFoods.insert(index, food); // Reinsert at the same index
            });
          },
        ),
      ),
    );
  }

  void _showAddFoodDialog(
      BuildContext context, Function(Food) addFoodCallback) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                var newFood = Food(
                  id: 1,
                  name: nameController.text,
                  calories: int.parse(caloriesController.text),
                );
                addFoodCallback(newFood);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditFoodDialog(
      BuildContext context, Food food, Function(Food) editFoodCallback) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    // GlobalKey<FoodListState> logFoodsKey = key;
    print(food.calories);
    setState(() {
      nameController.text = food.name;
      caloriesController.text = '${food.calories}';
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${food.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                var editedFood = Food.withKey(
                    id: food.id,
                    name: nameController.text,
                    calories: int.parse(caloriesController.text),
                    uniqueKey: uuid.v4());
                await database.updateFood(editedFood);
                editFoodCallback(editedFood);
                if (!mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLogFoodOverlay() async {
    List<Food> foods = await database.getFoods();
    GlobalKey<FoodListState> logFoodsKey = GlobalKey();
    foods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (!mounted) return;

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      useSafeArea: true,
      isScrollControlled: false,
      context: context,
      builder: (ctx) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            FoodList(
              key: logFoodsKey,
              foods: foods,
              onAddFood: _logFood,
              onDeleteFood: _deleteFood,
              onUpdateFood: _showEditFoodDialog,
            ),
            Positioned(
              right: 16,
              bottom: 50,
              child: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  _showAddFoodDialog(context, (newFood) async {
                    newFood.id = await database.addFood(newFood);
                    logFoodsKey.currentState?.updateFoods(newFood);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget loggedFoodsList = const Center(
      child: Text('No foods logged. Start adding some!'),
    );

    if (_loggedFoods.isNotEmpty) {
      loggedFoodsList = LoggedFoodsList(
        loggedFoods: _loggedFoods,
        onRemoveFood: _removeFood,
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openLogFoodOverlay,
        child: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Calorie Counter'),
            Text(_formatDate(selectedDate))
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$consumedCalories',
                style: TextStyle(
                  fontSize: 40,
                  color: consumedCalories > targetCalories
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              const Text(
                '/',
                style: TextStyle(fontSize: 40),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: TextField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 40),
                  decoration: const InputDecoration.collapsed(
                      hintText: 'Target Cals',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: TextStyle(
                        fontSize: 20,
                      )),
                  onChanged: (value) async {
                    int newTargetCalories = int.parse(value);
                    await database.updateTargetCalories(
                        _formatDate(selectedDate), newTargetCalories);
                    setState(() {
                      targetCalories = newTargetCalories;
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: loggedFoodsList,
            ),
          )
        ],
      ),
    );
  }
}
