import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../models/custom_category.dart';
import '../utils/category_icons.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Result returned by the expense form, containing the expense and any new
/// attachment files that still need to be uploaded.
class ExpenseFormResult {
  final ActualExpense expense;
  final List<File> newAttachmentFiles;
  ExpenseFormResult({required this.expense, this.newAttachmentFiles = const []});
}

Future<ExpenseFormResult?> showAddExpenseSheet({
  required BuildContext context,
  required List<ExpenseItem> budgetExpenses,
  required List<ActualExpense> currentExpenses,
  List<CustomCategory> customCategories = const [],
  ActualExpense? existing,
  Future<void> Function(ActualExpense)? onDelete,
  String? householdId,
}) {
  return showModalBottomSheet<ExpenseFormResult>(
    showDragHandle: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddExpenseSheet(
      budgetExpenses: budgetExpenses,
      currentExpenses: currentExpenses,
      customCategories: customCategories,
      existing: existing,
      onDelete: onDelete,
      householdId: householdId,
    ),
  );
}

class _AddExpenseSheet extends StatefulWidget {
  final List<ExpenseItem> budgetExpenses;
  final List<ActualExpense> currentExpenses;
  final List<CustomCategory> customCategories;
  final ActualExpense? existing;
  final Future<void> Function(ActualExpense)? onDelete;
  final String? householdId;

  const _AddExpenseSheet({
    required this.budgetExpenses,
    required this.currentExpenses,
    this.customCategories = const [],
    this.existing,
    this.onDelete,
    this.householdId,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  String? _selectedCategory;
  bool _isCustom = false;
  final _customCategoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  bool _showDescription = false;

  // Location & attachment state
  double? _locationLat;
  double? _locationLng;
  String? _locationAddress;
  final List<File> _attachmentFiles = [];
  List<String> _existingAttachmentUrls = [];
  bool _showExtras = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _selectedDate = e.date;
      _amountController.text = e.amount.toStringAsFixed(2);
      _descriptionController.text = e.description ?? '';

      // Check if existing category is a known enum value
      final isKnown = ExpenseCategory.values.any((c) => c.name == e.category);
      // Check if it's a custom category from the list
      final isCustomCat = widget.customCategories.any((c) => c.name == e.category);

      if (isKnown) {
        _selectedCategory = e.category;
        _isCustom = false;
      } else if (isCustomCat) {
        _selectedCategory = e.category;
        _isCustom = false;
      } else {
        // Freeform custom category
        _isCustom = true;
        _customCategoryController.text = e.category;
      }
      _showDescription = _descriptionController.text.isNotEmpty;
      _locationLat = e.locationLat;
      _locationLng = e.locationLng;
      _locationAddress = e.locationAddress;
      _existingAttachmentUrls = List.from(e.attachmentUrls ?? []);
      _showExtras =
          _locationAddress != null || _existingAttachmentUrls.isNotEmpty;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  IconData _categoryIcon(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.telecomunicacoes:
        return Icons.phone;
      case ExpenseCategory.energia:
        return Icons.bolt;
      case ExpenseCategory.agua:
        return Icons.water_drop;
      case ExpenseCategory.alimentacao:
        return Icons.restaurant;
      case ExpenseCategory.educacao:
        return Icons.school;
      case ExpenseCategory.habitacao:
        return Icons.home;
      case ExpenseCategory.transportes:
        return Icons.directions_car;
      case ExpenseCategory.saude:
        return Icons.local_hospital;
      case ExpenseCategory.lazer:
        return Icons.sports_esports;
      case ExpenseCategory.outros:
        return Icons.more_horiz;
    }
  }

  Color? _customCategoryColor(CustomCategory cat) {
    if (cat.colorHex == null) return null;
    try {
      return Color(
          int.parse('FF${cat.colorHex!.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return null;
    }
  }

  Future<void> _detectLocation() async {
    final l10n = S.of(context);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.expenseLocationPermissionDenied),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.expenseLocationPermissionDenied),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ));
        }
        return;
      }
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = [p.street, p.locality, p.country]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _locationLat = position.latitude;
          _locationLng = position.longitude;
          _locationAddress = address ??
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.expenseLocationPermissionDenied),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _removeLocation() {
    setState(() {
      _locationLat = null;
      _locationLng = null;
      _locationAddress = null;
    });
  }

  Future<void> _pickPhoto() async {
    final l10n = S.of(context);
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.expenseAttachPhoto),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: Row(children: [
              const Icon(Icons.camera_alt, size: 20),
              const SizedBox(width: 12),
              Text(l10n.expenseAttachCamera),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: Row(children: [
              const Icon(Icons.photo_library, size: 20),
              const SizedBox(width: 12),
              Text(l10n.expenseAttachGallery),
            ]),
          ),
        ],
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _attachmentFiles.add(File(picked.path)));
    }
  }

  void _removeNewAttachment(int index) =>
      setState(() => _attachmentFiles.removeAt(index));

  void _removeExistingAttachment(int index) =>
      setState(() => _existingAttachmentUrls.removeAt(index));

  void _save() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).addExpenseInvalidAmount),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    final String? category;
    if (_isCustom) {
      category = _customCategoryController.text.trim();
    } else {
      category = _selectedCategory;
    }
    if (category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.of(context).addExpenseCategory),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    final description = _descriptionController.text.trim();
    final allUrls = List<String>.from(_existingAttachmentUrls);

    ActualExpense expense;
    if (widget.existing != null) {
      expense = widget.existing!.copyWith(
        category: category,
        amount: amount,
        date: _selectedDate,
        description: description.isEmpty ? null : description,
        locationLat: _locationLat,
        locationLng: _locationLng,
        locationAddress: _locationAddress,
        attachmentUrls: allUrls.isEmpty ? null : allUrls,
      );
    } else {
      expense = ActualExpense.create(
        category: category,
        amount: amount,
        date: _selectedDate,
        description: description.isEmpty ? null : description,
        locationLat: _locationLat,
        locationLng: _locationLng,
        locationAddress: _locationAddress,
        attachmentUrls: allUrls.isEmpty ? null : allUrls,
      );
    }
    Navigator.of(context).pop(ExpenseFormResult(
      expense: expense,
      newAttachmentFiles: List.from(_attachmentFiles),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEdit = widget.existing != null;

    // Build category choices: predefined ExpenseCategory values + custom categories
    final allChoices = <_CategoryChoice>[
      ...ExpenseCategory.values.map((cat) => _CategoryChoice(
            label: cat.localizedLabel(l10n),
            categoryKey: cat.name,
            icon: _categoryIcon(cat),
          )),
      ...widget.customCategories.map((cat) => _CategoryChoice(
            label: cat.name,
            categoryKey: cat.name,
            icon: getCategoryIcon(cat.iconName),
            color: _customCategoryColor(cat),
          )),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEdit ? l10n.editExpenseTitle : l10n.addExpenseTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.addExpenseAmount,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                autofocus: !isEdit,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: currencySymbol(),
                  hintText: '0.00',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                validator: (v) {
                  final val =
                      double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (val == null || val <= 0) {
                    return l10n.addExpenseInvalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(l10n.addExpenseCategory,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...allChoices.map((choice) {
                    final selected =
                        !_isCustom && _selectedCategory == choice.categoryKey;
                    final chipColor = choice.color;
                    return ChoiceChip(
                      avatar: Icon(choice.icon, size: 16,
                          color: selected
                              ? (chipColor ?? AppColors.primary(context))
                              : AppColors.textSecondary(context)),
                      label: Text(choice.label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = choice.categoryKey;
                          _isCustom = false;
                          _customCategoryController.clear();
                        });
                      },
                      selectedColor: chipColor != null
                          ? chipColor.withValues(alpha: 0.15)
                          : AppColors.primaryLight(context),
                      side: BorderSide(
                        color: selected
                            ? (chipColor ?? const Color(0xFF93C5FD))
                            : const Color(0xFFE2E8F0),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? (chipColor ?? AppColors.primary(context))
                            : AppColors.textSecondary(context),
                      ),
                    );
                  }),
                  ChoiceChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addExpenseCustomCategory),
                    selected: _isCustom,
                    onSelected: (_) => setState(() {
                      _isCustom = true;
                      _selectedCategory = null;
                      _customCategoryController.clear();
                    }),
                    selectedColor: AppColors.primaryLight(context),
                    side: BorderSide(
                      color: _isCustom
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFE2E8F0),
                    ),
                    labelStyle: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              if (_isCustom) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: l10n.addExpenseCustomCategory,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
              const SizedBox(height: 20),
              Tooltip(
                message: l10n.addExpenseDate,
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now()
                          .subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.borderMuted(context)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today,
                          size: 18,
                          color: AppColors.textSecondary(context)),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary(context)),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setState(
                            () => _showDescription = !_showDescription),
                        icon: Icon(
                          _showDescription
                              ? Icons.expand_less
                              : Icons.note_add,
                          size: 18,
                          color: _showDescription
                              ? AppColors.primary(context)
                              : AppColors.textSecondary(context),
                        ),
                        label: Text(l10n.addExpenseDescription,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _showDescription
                                  ? AppColors.primary(context)
                                  : AppColors.textSecondary(context),
                            )),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          backgroundColor: _showDescription
                              ? AppColors.primaryLight(context)
                              : null,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              if (_showDescription) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: l10n.addExpenseDescription,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
              const SizedBox(height: 12),
              Row(children: [
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showExtras = !_showExtras),
                  icon: Icon(
                    _showExtras ? Icons.expand_less : Icons.more_horiz,
                    size: 18,
                    color: _showExtras
                        ? AppColors.primary(context)
                        : AppColors.textSecondary(context),
                  ),
                  label: Text(l10n.expenseExtras,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _showExtras
                            ? AppColors.primary(context)
                            : AppColors.textSecondary(context),
                      )),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    backgroundColor: _showExtras
                        ? AppColors.primaryLight(context)
                        : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
              if (_showExtras) ...[
                const SizedBox(height: 12),
                if (_locationLat != null && _locationLng != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: latlong.LatLng(
                              _locationLat!, _locationLng!),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: latlong.LatLng(
                                  _locationLat!, _locationLng!),
                              child: const Icon(Icons.location_pin,
                                  color: Colors.red, size: 40),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(children: [
                  Icon(Icons.location_on,
                      size: 18,
                      color: AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  if (_locationAddress != null) ...[
                    Expanded(
                      child: Chip(
                        label: Text(_locationAddress!,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: _removeLocation,
                      ),
                    ),
                  ] else ...[
                    TextButton.icon(
                      onPressed: _detectLocation,
                      icon: const Icon(Icons.my_location, size: 16),
                      label: Text(l10n.expenseLocationDetect,
                          style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.camera_alt,
                      size: 18,
                      color: AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.add_a_photo, size: 16),
                    label: Text(l10n.expenseAttachPhoto,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ]),
                if (_existingAttachmentUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingAttachmentUrls.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.borderMuted(context),
                          ),
                          child: const Icon(Icons.image, size: 32),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeExistingAttachment(i),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
                if (_attachmentFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachmentFiles.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_attachmentFiles[i],
                              width: 64, height: 64, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeNewAttachment(i),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.onPrimary(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(l10n.save,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.delete),
                          content:
                              Text(l10n.expenseTrackerDeleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child: Text(l10n.delete,
                                  style: TextStyle(
                                      color:
                                          AppColors.error(context))),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await widget.onDelete!(widget.existing!);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error(context)),
                    label: Text(l10n.delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error(context),
                      side:
                          BorderSide(color: AppColors.error(context)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChoice {
  final String label;
  final String categoryKey;
  final IconData icon;
  final Color? color;

  const _CategoryChoice({
    required this.label,
    required this.categoryKey,
    required this.icon,
    this.color,
  });
}
