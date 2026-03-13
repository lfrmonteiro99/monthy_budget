import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/grocery_data.dart';
import '../models/product.dart';
import '../models/purchase_record.dart';
import '../models/shopping_item.dart';
import '../services/barcode_scan_service.dart';
import '../theme/app_colors.dart';
import 'grocery_screen.dart';
import 'meal_planner_screen.dart';
import 'shopping_list_screen.dart';

class PlanAndShopScreen extends StatefulWidget {
  // Shopping List params
  final List<ShoppingItem> shoppingItems;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;
  final void Function(double? amount, List<ShoppingItem> checkedItems,
      {bool isMealPurchase}) onFinalize;
  final PurchaseHistory purchaseHistory;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;
  final ValueChanged<ShoppingItem>? onMarkAtHome;
  final BarcodeScanService? barcodeScanService;

  // Grocery params
  final List<Product> products;
  final GroceryData? groceryData;
  final bool groceryLoading;
  final Set<String> weeklyPantryIds;
  final ValueChanged<String>? onToggleWeeklyPantry;

  // Meal Planner params
  final AppSettings settings;
  final String apiKey;
  final List<String> favorites;
  final String householdId;
  final ValueChanged<AppSettings> onSaveSettings;
  final VoidCallback onOpenMealSettings;

  // Tour params
  final bool showShoppingTour;
  final VoidCallback? onShoppingTourComplete;
  final bool showGroceryTour;
  final VoidCallback? onGroceryTourComplete;
  final bool showMealsTour;
  final VoidCallback? onMealsTourComplete;

  // Premium gate
  final bool canAccessMeals;

  const PlanAndShopScreen({
    super.key,
    required this.shoppingItems,
    required this.onToggleChecked,
    required this.onRemove,
    required this.onClearChecked,
    required this.onFinalize,
    required this.purchaseHistory,
    this.onAddToShoppingList,
    this.onMarkAtHome,
    this.barcodeScanService,
    required this.products,
    this.groceryData,
    this.groceryLoading = false,
    this.weeklyPantryIds = const {},
    this.onToggleWeeklyPantry,
    required this.settings,
    required this.apiKey,
    required this.favorites,
    required this.householdId,
    required this.onSaveSettings,
    required this.onOpenMealSettings,
    this.showShoppingTour = false,
    this.onShoppingTourComplete,
    this.showGroceryTour = false,
    this.onGroceryTourComplete,
    this.showMealsTour = false,
    this.onMealsTourComplete,
    this.canAccessMeals = true,
  });

  @override
  State<PlanAndShopScreen> createState() => _PlanAndShopScreenState();
}

class _PlanAndShopScreenState extends State<PlanAndShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.navPlanAndShop,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: _buildActions(context, l10n),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary(context),
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary(context),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              icon: const Icon(Icons.shopping_basket_outlined, size: 20),
              text: l10n.planShoppingList,
            ),
            Tab(
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              text: l10n.groceryTitle,
            ),
            Tab(
              icon: widget.canAccessMeals
                  ? const Icon(Icons.restaurant_outlined, size: 20)
                  : Badge(
                      label: Text(
                        l10n.planMealsProBadge,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                      ),
                      child: const Icon(Icons.restaurant_outlined, size: 20),
                    ),
              text: l10n.mealPlannerTitle,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ShoppingListScreen(
            embedded: true,
            items: widget.shoppingItems,
            onToggleChecked: widget.onToggleChecked,
            onRemove: widget.onRemove,
            onClearChecked: widget.onClearChecked,
            onFinalize: widget.onFinalize,
            purchaseHistory: widget.purchaseHistory,
            onAddToShoppingList: widget.onAddToShoppingList,
            barcodeScanService: widget.barcodeScanService,
            onMarkAtHome: widget.onMarkAtHome,
            showTour: widget.showShoppingTour,
            onTourComplete: widget.onShoppingTourComplete,
          ),
          GroceryScreen(
            embedded: true,
            products: widget.products,
            groceryData: widget.groceryData,
            isLoading: widget.groceryLoading,
            onAddToShoppingList: widget.onAddToShoppingList,
            weeklyPantryIds: widget.weeklyPantryIds,
            onToggleWeeklyPantry: widget.onToggleWeeklyPantry,
            showTour: widget.showGroceryTour,
            onTourComplete: widget.onGroceryTourComplete,
          ),
          MealPlannerScreen(
            embedded: true,
            settings: widget.settings,
            apiKey: widget.apiKey,
            favorites: widget.favorites,
            onAddToShoppingList: widget.onAddToShoppingList ?? (_) {},
            householdId: widget.householdId,
            onSaveSettings: widget.onSaveSettings,
            onOpenMealSettings: widget.onOpenMealSettings,
            purchaseHistory: widget.purchaseHistory,
            showTour: widget.showMealsTour,
            onTourComplete: widget.onMealsTourComplete,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, S l10n) {
    switch (_tabController.index) {
      case 0:
        // Shopping list actions
        return [
          IconButton(
            icon: Icon(Icons.document_scanner,
                color: AppColors.textSecondary(context)),
            tooltip: l10n.quickScanReceipt,
            onPressed: () {
              // Delegate to receipt scan - handled by parent
            },
          ),
        ];
      case 1:
        // Grocery actions
        return [
          if (widget.onAddToShoppingList != null)
            IconButton(
              icon: Icon(Icons.qr_code_scanner,
                  color: AppColors.textSecondary(context)),
              tooltip: l10n.barcodeScanTooltip,
              onPressed: () {
                // Delegate to barcode scan - handled by child
              },
            ),
        ];
      case 2:
        // Meals actions
        return [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: AppColors.textSecondary(context)),
            tooltip: l10n.settingsTitle,
            onPressed: widget.onOpenMealSettings,
          ),
        ];
      default:
        return [];
    }
  }
}
