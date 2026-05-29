import '../models/campus_menu_item.dart';

class MenuRepository {
  Future<List<CampusMenuItem>> getMenuItems() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate network delay :3

    return const [
      CampusMenuItem(
        id: 'meal_001',
        name: 'Chicken Rice',
        description: 'Campus favorite meal with soup and vegetables.',
        price: 45000,
        category: 'Meal',
        available: true,
      ),
      CampusMenuItem(
        id: 'meal_002',
        name: 'Beef Bento',
        description: 'Rice box with beef, egg, and salad.',
        price: 65000,
        category: 'Meal',
        available: true,
      ),
      CampusMenuItem(
        id: 'drink_001',
        name: 'Iced Coffee',
        description: 'Vietnamese iced milk coffee.',
        price: 25000,
        category: 'Drink',
        available: true,
      ),
      CampusMenuItem(
        id: 'drink_002',
        name: 'Matcha Latte',
        description: 'Cold matcha latte with fresh milk.',
        price: 35000,
        category: 'Drink',
        available: false,
      ),
      CampusMenuItem(
        id: 'snack_001',
        name: 'Egg Sandwich',
        description: 'Quick snack for morning classes.',
        price: 30000,
        category: 'Snack',
        available: true,
      ),
    ];
  }
}