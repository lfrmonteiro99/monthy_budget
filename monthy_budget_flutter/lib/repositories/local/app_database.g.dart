// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalShoppingItemsTable extends LocalShoppingItems
    with TableInfo<$LocalShoppingItemsTable, LocalShoppingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeMeta = const VerificationMeta('store');
  @override
  late final GeneratedColumn<String> store = GeneratedColumn<String>(
    'store',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<String> unitPrice = GeneratedColumn<String>(
    'unit_price',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  sourceMealLabels =
      GeneratedColumn<String>(
        'source_meal_labels',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>(
        $LocalShoppingItemsTable.$convertersourceMealLabels,
      );
  static const VerificationMeta _preferredStoreMeta = const VerificationMeta(
    'preferredStore',
  );
  @override
  late final GeneratedColumn<String> preferredStore = GeneratedColumn<String>(
    'preferred_store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cheapestKnownStoreMeta =
      const VerificationMeta('cheapestKnownStore');
  @override
  late final GeneratedColumn<String> cheapestKnownStore =
      GeneratedColumn<String>(
        'cheapest_known_store',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cheapestKnownPriceMeta =
      const VerificationMeta('cheapestKnownPrice');
  @override
  late final GeneratedColumn<double> cheapestKnownPrice =
      GeneratedColumn<double>(
        'cheapest_known_price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    productName,
    store,
    price,
    unitPrice,
    checked,
    sourceMealLabels,
    preferredStore,
    cheapestKnownStore,
    cheapestKnownPrice,
    quantity,
    unit,
    pendingSync,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalShoppingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('store')) {
      context.handle(
        _storeMeta,
        store.isAcceptableOrUnknown(data['store']!, _storeMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    }
    if (data.containsKey('preferred_store')) {
      context.handle(
        _preferredStoreMeta,
        preferredStore.isAcceptableOrUnknown(
          data['preferred_store']!,
          _preferredStoreMeta,
        ),
      );
    }
    if (data.containsKey('cheapest_known_store')) {
      context.handle(
        _cheapestKnownStoreMeta,
        cheapestKnownStore.isAcceptableOrUnknown(
          data['cheapest_known_store']!,
          _cheapestKnownStoreMeta,
        ),
      );
    }
    if (data.containsKey('cheapest_known_price')) {
      context.handle(
        _cheapestKnownPriceMeta,
        cheapestKnownPrice.isAcceptableOrUnknown(
          data['cheapest_known_price']!,
          _cheapestKnownPriceMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalShoppingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      store: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_price'],
      ),
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      sourceMealLabels: $LocalShoppingItemsTable.$convertersourceMealLabels
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}source_meal_labels'],
            )!,
          ),
      preferredStore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_store'],
      ),
      cheapestKnownStore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cheapest_known_store'],
      ),
      cheapestKnownPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cheapest_known_price'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalShoppingItemsTable createAlias(String alias) {
    return $LocalShoppingItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersourceMealLabels =
      const StringListConverter();
}

class LocalShoppingItem extends DataClass
    implements Insertable<LocalShoppingItem> {
  final String id;
  final String householdId;
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  final bool checked;
  final List<String> sourceMealLabels;
  final String? preferredStore;
  final String? cheapestKnownStore;
  final double? cheapestKnownPrice;
  final double? quantity;
  final String? unit;
  final bool pendingSync;
  final DateTime updatedAt;
  const LocalShoppingItem({
    required this.id,
    required this.householdId,
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    required this.checked,
    required this.sourceMealLabels,
    this.preferredStore,
    this.cheapestKnownStore,
    this.cheapestKnownPrice,
    this.quantity,
    this.unit,
    required this.pendingSync,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['product_name'] = Variable<String>(productName);
    map['store'] = Variable<String>(store);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || unitPrice != null) {
      map['unit_price'] = Variable<String>(unitPrice);
    }
    map['checked'] = Variable<bool>(checked);
    {
      map['source_meal_labels'] = Variable<String>(
        $LocalShoppingItemsTable.$convertersourceMealLabels.toSql(
          sourceMealLabels,
        ),
      );
    }
    if (!nullToAbsent || preferredStore != null) {
      map['preferred_store'] = Variable<String>(preferredStore);
    }
    if (!nullToAbsent || cheapestKnownStore != null) {
      map['cheapest_known_store'] = Variable<String>(cheapestKnownStore);
    }
    if (!nullToAbsent || cheapestKnownPrice != null) {
      map['cheapest_known_price'] = Variable<double>(cheapestKnownPrice);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingItemsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      productName: Value(productName),
      store: Value(store),
      price: Value(price),
      unitPrice: unitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPrice),
      checked: Value(checked),
      sourceMealLabels: Value(sourceMealLabels),
      preferredStore: preferredStore == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredStore),
      cheapestKnownStore: cheapestKnownStore == null && nullToAbsent
          ? const Value.absent()
          : Value(cheapestKnownStore),
      cheapestKnownPrice: cheapestKnownPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(cheapestKnownPrice),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      pendingSync: Value(pendingSync),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalShoppingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingItem(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      productName: serializer.fromJson<String>(json['productName']),
      store: serializer.fromJson<String>(json['store']),
      price: serializer.fromJson<double>(json['price']),
      unitPrice: serializer.fromJson<String?>(json['unitPrice']),
      checked: serializer.fromJson<bool>(json['checked']),
      sourceMealLabels: serializer.fromJson<List<String>>(
        json['sourceMealLabels'],
      ),
      preferredStore: serializer.fromJson<String?>(json['preferredStore']),
      cheapestKnownStore: serializer.fromJson<String?>(
        json['cheapestKnownStore'],
      ),
      cheapestKnownPrice: serializer.fromJson<double?>(
        json['cheapestKnownPrice'],
      ),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'productName': serializer.toJson<String>(productName),
      'store': serializer.toJson<String>(store),
      'price': serializer.toJson<double>(price),
      'unitPrice': serializer.toJson<String?>(unitPrice),
      'checked': serializer.toJson<bool>(checked),
      'sourceMealLabels': serializer.toJson<List<String>>(sourceMealLabels),
      'preferredStore': serializer.toJson<String?>(preferredStore),
      'cheapestKnownStore': serializer.toJson<String?>(cheapestKnownStore),
      'cheapestKnownPrice': serializer.toJson<double?>(cheapestKnownPrice),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalShoppingItem copyWith({
    String? id,
    String? householdId,
    String? productName,
    String? store,
    double? price,
    Value<String?> unitPrice = const Value.absent(),
    bool? checked,
    List<String>? sourceMealLabels,
    Value<String?> preferredStore = const Value.absent(),
    Value<String?> cheapestKnownStore = const Value.absent(),
    Value<double?> cheapestKnownPrice = const Value.absent(),
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    bool? pendingSync,
    DateTime? updatedAt,
  }) => LocalShoppingItem(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    productName: productName ?? this.productName,
    store: store ?? this.store,
    price: price ?? this.price,
    unitPrice: unitPrice.present ? unitPrice.value : this.unitPrice,
    checked: checked ?? this.checked,
    sourceMealLabels: sourceMealLabels ?? this.sourceMealLabels,
    preferredStore: preferredStore.present
        ? preferredStore.value
        : this.preferredStore,
    cheapestKnownStore: cheapestKnownStore.present
        ? cheapestKnownStore.value
        : this.cheapestKnownStore,
    cheapestKnownPrice: cheapestKnownPrice.present
        ? cheapestKnownPrice.value
        : this.cheapestKnownPrice,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    pendingSync: pendingSync ?? this.pendingSync,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalShoppingItem copyWithCompanion(LocalShoppingItemsCompanion data) {
    return LocalShoppingItem(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      store: data.store.present ? data.store.value : this.store,
      price: data.price.present ? data.price.value : this.price,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      checked: data.checked.present ? data.checked.value : this.checked,
      sourceMealLabels: data.sourceMealLabels.present
          ? data.sourceMealLabels.value
          : this.sourceMealLabels,
      preferredStore: data.preferredStore.present
          ? data.preferredStore.value
          : this.preferredStore,
      cheapestKnownStore: data.cheapestKnownStore.present
          ? data.cheapestKnownStore.value
          : this.cheapestKnownStore,
      cheapestKnownPrice: data.cheapestKnownPrice.present
          ? data.cheapestKnownPrice.value
          : this.cheapestKnownPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingItem(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('productName: $productName, ')
          ..write('store: $store, ')
          ..write('price: $price, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('checked: $checked, ')
          ..write('sourceMealLabels: $sourceMealLabels, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('cheapestKnownStore: $cheapestKnownStore, ')
          ..write('cheapestKnownPrice: $cheapestKnownPrice, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    productName,
    store,
    price,
    unitPrice,
    checked,
    sourceMealLabels,
    preferredStore,
    cheapestKnownStore,
    cheapestKnownPrice,
    quantity,
    unit,
    pendingSync,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingItem &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.productName == this.productName &&
          other.store == this.store &&
          other.price == this.price &&
          other.unitPrice == this.unitPrice &&
          other.checked == this.checked &&
          other.sourceMealLabels == this.sourceMealLabels &&
          other.preferredStore == this.preferredStore &&
          other.cheapestKnownStore == this.cheapestKnownStore &&
          other.cheapestKnownPrice == this.cheapestKnownPrice &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.pendingSync == this.pendingSync &&
          other.updatedAt == this.updatedAt);
}

class LocalShoppingItemsCompanion extends UpdateCompanion<LocalShoppingItem> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> productName;
  final Value<String> store;
  final Value<double> price;
  final Value<String?> unitPrice;
  final Value<bool> checked;
  final Value<List<String>> sourceMealLabels;
  final Value<String?> preferredStore;
  final Value<String?> cheapestKnownStore;
  final Value<double?> cheapestKnownPrice;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<bool> pendingSync;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.productName = const Value.absent(),
    this.store = const Value.absent(),
    this.price = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.checked = const Value.absent(),
    this.sourceMealLabels = const Value.absent(),
    this.preferredStore = const Value.absent(),
    this.cheapestKnownStore = const Value.absent(),
    this.cheapestKnownPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingItemsCompanion.insert({
    required String id,
    required String householdId,
    required String productName,
    this.store = const Value.absent(),
    this.price = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.checked = const Value.absent(),
    this.sourceMealLabels = const Value.absent(),
    this.preferredStore = const Value.absent(),
    this.cheapestKnownStore = const Value.absent(),
    this.cheapestKnownPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       productName = Value(productName);
  static Insertable<LocalShoppingItem> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? productName,
    Expression<String>? store,
    Expression<double>? price,
    Expression<String>? unitPrice,
    Expression<bool>? checked,
    Expression<String>? sourceMealLabels,
    Expression<String>? preferredStore,
    Expression<String>? cheapestKnownStore,
    Expression<double>? cheapestKnownPrice,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<bool>? pendingSync,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (productName != null) 'product_name': productName,
      if (store != null) 'store': store,
      if (price != null) 'price': price,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (checked != null) 'checked': checked,
      if (sourceMealLabels != null) 'source_meal_labels': sourceMealLabels,
      if (preferredStore != null) 'preferred_store': preferredStore,
      if (cheapestKnownStore != null)
        'cheapest_known_store': cheapestKnownStore,
      if (cheapestKnownPrice != null)
        'cheapest_known_price': cheapestKnownPrice,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? productName,
    Value<String>? store,
    Value<double>? price,
    Value<String?>? unitPrice,
    Value<bool>? checked,
    Value<List<String>>? sourceMealLabels,
    Value<String?>? preferredStore,
    Value<String?>? cheapestKnownStore,
    Value<double?>? cheapestKnownPrice,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<bool>? pendingSync,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalShoppingItemsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      productName: productName ?? this.productName,
      store: store ?? this.store,
      price: price ?? this.price,
      unitPrice: unitPrice ?? this.unitPrice,
      checked: checked ?? this.checked,
      sourceMealLabels: sourceMealLabels ?? this.sourceMealLabels,
      preferredStore: preferredStore ?? this.preferredStore,
      cheapestKnownStore: cheapestKnownStore ?? this.cheapestKnownStore,
      cheapestKnownPrice: cheapestKnownPrice ?? this.cheapestKnownPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pendingSync: pendingSync ?? this.pendingSync,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (store.present) {
      map['store'] = Variable<String>(store.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<String>(unitPrice.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (sourceMealLabels.present) {
      map['source_meal_labels'] = Variable<String>(
        $LocalShoppingItemsTable.$convertersourceMealLabels.toSql(
          sourceMealLabels.value,
        ),
      );
    }
    if (preferredStore.present) {
      map['preferred_store'] = Variable<String>(preferredStore.value);
    }
    if (cheapestKnownStore.present) {
      map['cheapest_known_store'] = Variable<String>(cheapestKnownStore.value);
    }
    if (cheapestKnownPrice.present) {
      map['cheapest_known_price'] = Variable<double>(cheapestKnownPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('productName: $productName, ')
          ..write('store: $store, ')
          ..write('price: $price, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('checked: $checked, ')
          ..write('sourceMealLabels: $sourceMealLabels, ')
          ..write('preferredStore: $preferredStore, ')
          ..write('cheapestKnownStore: $cheapestKnownStore, ')
          ..write('cheapestKnownPrice: $cheapestKnownPrice, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  attachmentUrls = GeneratedColumn<String>(
    'attachment_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($LocalExpensesTable.$converterattachmentUrls);
  static const VerificationMeta _locationLatMeta = const VerificationMeta(
    'locationLat',
  );
  @override
  late final GeneratedColumn<double> locationLat = GeneratedColumn<double>(
    'location_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationLngMeta = const VerificationMeta(
    'locationLng',
  );
  @override
  late final GeneratedColumn<double> locationLng = GeneratedColumn<double>(
    'location_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAddressMeta = const VerificationMeta(
    'locationAddress',
  );
  @override
  late final GeneratedColumn<String> locationAddress = GeneratedColumn<String>(
    'location_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    category,
    amount,
    date,
    description,
    monthKey,
    attachmentUrls,
    locationLat,
    locationLng,
    locationAddress,
    pendingSync,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('location_lat')) {
      context.handle(
        _locationLatMeta,
        locationLat.isAcceptableOrUnknown(
          data['location_lat']!,
          _locationLatMeta,
        ),
      );
    }
    if (data.containsKey('location_lng')) {
      context.handle(
        _locationLngMeta,
        locationLng.isAcceptableOrUnknown(
          data['location_lng']!,
          _locationLngMeta,
        ),
      );
    }
    if (data.containsKey('location_address')) {
      context.handle(
        _locationAddressMeta,
        locationAddress.isAcceptableOrUnknown(
          data['location_address']!,
          _locationAddressMeta,
        ),
      );
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      attachmentUrls: $LocalExpensesTable.$converterattachmentUrls.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachment_urls'],
        )!,
      ),
      locationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_lat'],
      ),
      locationLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_lng'],
      ),
      locationAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_address'],
      ),
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterattachmentUrls =
      const StringListConverter();
}

class LocalExpense extends DataClass implements Insertable<LocalExpense> {
  final String id;
  final String householdId;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String monthKey;
  final List<String> attachmentUrls;
  final double? locationLat;
  final double? locationLng;
  final String? locationAddress;
  final bool pendingSync;
  final DateTime updatedAt;
  const LocalExpense({
    required this.id,
    required this.householdId,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.monthKey,
    required this.attachmentUrls,
    this.locationLat,
    this.locationLng,
    this.locationAddress,
    required this.pendingSync,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['month_key'] = Variable<String>(monthKey);
    {
      map['attachment_urls'] = Variable<String>(
        $LocalExpensesTable.$converterattachmentUrls.toSql(attachmentUrls),
      );
    }
    if (!nullToAbsent || locationLat != null) {
      map['location_lat'] = Variable<double>(locationLat);
    }
    if (!nullToAbsent || locationLng != null) {
      map['location_lng'] = Variable<double>(locationLng);
    }
    if (!nullToAbsent || locationAddress != null) {
      map['location_address'] = Variable<String>(locationAddress);
    }
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      monthKey: Value(monthKey),
      attachmentUrls: Value(attachmentUrls),
      locationLat: locationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLat),
      locationLng: locationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(locationLng),
      locationAddress: locationAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAddress),
      pendingSync: Value(pendingSync),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpense(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      attachmentUrls: serializer.fromJson<List<String>>(json['attachmentUrls']),
      locationLat: serializer.fromJson<double?>(json['locationLat']),
      locationLng: serializer.fromJson<double?>(json['locationLng']),
      locationAddress: serializer.fromJson<String?>(json['locationAddress']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'monthKey': serializer.toJson<String>(monthKey),
      'attachmentUrls': serializer.toJson<List<String>>(attachmentUrls),
      'locationLat': serializer.toJson<double?>(locationLat),
      'locationLng': serializer.toJson<double?>(locationLng),
      'locationAddress': serializer.toJson<String?>(locationAddress),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalExpense copyWith({
    String? id,
    String? householdId,
    String? category,
    double? amount,
    DateTime? date,
    Value<String?> description = const Value.absent(),
    String? monthKey,
    List<String>? attachmentUrls,
    Value<double?> locationLat = const Value.absent(),
    Value<double?> locationLng = const Value.absent(),
    Value<String?> locationAddress = const Value.absent(),
    bool? pendingSync,
    DateTime? updatedAt,
  }) => LocalExpense(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
    monthKey: monthKey ?? this.monthKey,
    attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    locationLat: locationLat.present ? locationLat.value : this.locationLat,
    locationLng: locationLng.present ? locationLng.value : this.locationLng,
    locationAddress: locationAddress.present
        ? locationAddress.value
        : this.locationAddress,
    pendingSync: pendingSync ?? this.pendingSync,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalExpense copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpense(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      attachmentUrls: data.attachmentUrls.present
          ? data.attachmentUrls.value
          : this.attachmentUrls,
      locationLat: data.locationLat.present
          ? data.locationLat.value
          : this.locationLat,
      locationLng: data.locationLng.present
          ? data.locationLng.value
          : this.locationLng,
      locationAddress: data.locationAddress.present
          ? data.locationAddress.value
          : this.locationAddress,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpense(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('monthKey: $monthKey, ')
          ..write('attachmentUrls: $attachmentUrls, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    category,
    amount,
    date,
    description,
    monthKey,
    attachmentUrls,
    locationLat,
    locationLng,
    locationAddress,
    pendingSync,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpense &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.monthKey == this.monthKey &&
          other.attachmentUrls == this.attachmentUrls &&
          other.locationLat == this.locationLat &&
          other.locationLng == this.locationLng &&
          other.locationAddress == this.locationAddress &&
          other.pendingSync == this.pendingSync &&
          other.updatedAt == this.updatedAt);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpense> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String> monthKey;
  final Value<List<String>> attachmentUrls;
  final Value<double?> locationLat;
  final Value<double?> locationLng;
  final Value<String?> locationAddress;
  final Value<bool> pendingSync;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.attachmentUrls = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String id,
    required String householdId,
    required String category,
    required double amount,
    required DateTime date,
    this.description = const Value.absent(),
    required String monthKey,
    this.attachmentUrls = const Value.absent(),
    this.locationLat = const Value.absent(),
    this.locationLng = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       category = Value(category),
       amount = Value(amount),
       date = Value(date),
       monthKey = Value(monthKey);
  static Insertable<LocalExpense> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? monthKey,
    Expression<String>? attachmentUrls,
    Expression<double>? locationLat,
    Expression<double>? locationLng,
    Expression<String>? locationAddress,
    Expression<bool>? pendingSync,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (monthKey != null) 'month_key': monthKey,
      if (attachmentUrls != null) 'attachment_urls': attachmentUrls,
      if (locationLat != null) 'location_lat': locationLat,
      if (locationLng != null) 'location_lng': locationLng,
      if (locationAddress != null) 'location_address': locationAddress,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? category,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<String>? monthKey,
    Value<List<String>>? attachmentUrls,
    Value<double?>? locationLat,
    Value<double?>? locationLng,
    Value<String?>? locationAddress,
    Value<bool>? pendingSync,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      monthKey: monthKey ?? this.monthKey,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      locationAddress: locationAddress ?? this.locationAddress,
      pendingSync: pendingSync ?? this.pendingSync,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (attachmentUrls.present) {
      map['attachment_urls'] = Variable<String>(
        $LocalExpensesTable.$converterattachmentUrls.toSql(
          attachmentUrls.value,
        ),
      );
    }
    if (locationLat.present) {
      map['location_lat'] = Variable<double>(locationLat.value);
    }
    if (locationLng.present) {
      map['location_lng'] = Variable<double>(locationLng.value);
    }
    if (locationAddress.present) {
      map['location_address'] = Variable<String>(locationAddress.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('monthKey: $monthKey, ')
          ..write('attachmentUrls: $attachmentUrls, ')
          ..write('locationLat: $locationLat, ')
          ..write('locationLng: $locationLng, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMealPlansTable extends LocalMealPlans
    with TableInfo<$LocalMealPlansTable, LocalMealPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMealPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planJsonMeta = const VerificationMeta(
    'planJson',
  );
  @override
  late final GeneratedColumn<String> planJson = GeneratedColumn<String>(
    'plan_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, householdId, planJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_meal_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMealPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('plan_json')) {
      context.handle(
        _planJsonMeta,
        planJson.isAcceptableOrUnknown(data['plan_json']!, _planJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_planJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMealPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMealPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      planJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalMealPlansTable createAlias(String alias) {
    return $LocalMealPlansTable(attachedDatabase, alias);
  }
}

class LocalMealPlan extends DataClass implements Insertable<LocalMealPlan> {
  final String id;
  final String householdId;
  final String planJson;
  final DateTime updatedAt;
  const LocalMealPlan({
    required this.id,
    required this.householdId,
    required this.planJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['plan_json'] = Variable<String>(planJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMealPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalMealPlansCompanion(
      id: Value(id),
      householdId: Value(householdId),
      planJson: Value(planJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMealPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMealPlan(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      planJson: serializer.fromJson<String>(json['planJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'planJson': serializer.toJson<String>(planJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMealPlan copyWith({
    String? id,
    String? householdId,
    String? planJson,
    DateTime? updatedAt,
  }) => LocalMealPlan(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    planJson: planJson ?? this.planJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalMealPlan copyWithCompanion(LocalMealPlansCompanion data) {
    return LocalMealPlan(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      planJson: data.planJson.present ? data.planJson.value : this.planJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMealPlan(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('planJson: $planJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, householdId, planJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMealPlan &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.planJson == this.planJson &&
          other.updatedAt == this.updatedAt);
}

class LocalMealPlansCompanion extends UpdateCompanion<LocalMealPlan> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> planJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMealPlansCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.planJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMealPlansCompanion.insert({
    required String id,
    required String householdId,
    required String planJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       planJson = Value(planJson);
  static Insertable<LocalMealPlan> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? planJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (planJson != null) 'plan_json': planJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMealPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? planJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalMealPlansCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      planJson: planJson ?? this.planJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (planJson.present) {
      map['plan_json'] = Variable<String>(planJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMealPlansCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('planJson: $planJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    domain,
    action,
    payload,
    createdAt,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String id;
  final String householdId;
  final String domain;
  final String action;
  final String payload;
  final DateTime createdAt;
  final bool completed;
  const SyncQueueEntry({
    required this.id,
    required this.householdId,
    required this.domain,
    required this.action,
    required this.payload,
    required this.createdAt,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['domain'] = Variable<String>(domain);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      domain: Value(domain),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      completed: Value(completed),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      domain: serializer.fromJson<String>(json['domain']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'domain': serializer.toJson<String>(domain),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  SyncQueueEntry copyWith({
    String? id,
    String? householdId,
    String? domain,
    String? action,
    String? payload,
    DateTime? createdAt,
    bool? completed,
  }) => SyncQueueEntry(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    domain: domain ?? this.domain,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    completed: completed ?? this.completed,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      domain: data.domain.present ? data.domain.value : this.domain,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('domain: $domain, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    householdId,
    domain,
    action,
    payload,
    createdAt,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.domain == this.domain &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.completed == this.completed);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> domain;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<bool> completed;
  final Value<int> rowid;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.domain = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    required String id,
    required String householdId,
    required String domain,
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       domain = Value(domain),
       action = Value(action),
       payload = Value(payload);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? domain,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (domain != null) 'domain': domain,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? domain,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<bool>? completed,
    Value<int>? rowid,
  }) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      domain: domain ?? this.domain,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('domain: $domain, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoachMessagesTable extends CoachMessages
    with TableInfo<$CoachMessagesTable, CoachMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoachMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    householdId,
    role,
    content,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coach_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoachMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoachMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoachMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $CoachMessagesTable createAlias(String alias) {
    return $CoachMessagesTable(attachedDatabase, alias);
  }
}

class CoachMessage extends DataClass implements Insertable<CoachMessage> {
  final String id;
  final String householdId;
  final String role;
  final String content;
  final DateTime timestamp;
  const CoachMessage({
    required this.id,
    required this.householdId,
    required this.role,
    required this.content,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  CoachMessagesCompanion toCompanion(bool nullToAbsent) {
    return CoachMessagesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      role: Value(role),
      content: Value(content),
      timestamp: Value(timestamp),
    );
  }

  factory CoachMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoachMessage(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  CoachMessage copyWith({
    String? id,
    String? householdId,
    String? role,
    String? content,
    DateTime? timestamp,
  }) => CoachMessage(
    id: id ?? this.id,
    householdId: householdId ?? this.householdId,
    role: role ?? this.role,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp,
  );
  CoachMessage copyWithCompanion(CoachMessagesCompanion data) {
    return CoachMessage(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoachMessage(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, householdId, role, content, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoachMessage &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.role == this.role &&
          other.content == this.content &&
          other.timestamp == this.timestamp);
}

class CoachMessagesCompanion extends UpdateCompanion<CoachMessage> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const CoachMessagesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoachMessagesCompanion.insert({
    required String id,
    required String householdId,
    required String role,
    required String content,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       householdId = Value(householdId),
       role = Value(role),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<CoachMessage> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoachMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? householdId,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return CoachMessagesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoachMessagesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalShoppingItemsTable localShoppingItems =
      $LocalShoppingItemsTable(this);
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  late final $LocalMealPlansTable localMealPlans = $LocalMealPlansTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  late final $CoachMessagesTable coachMessages = $CoachMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localShoppingItems,
    localExpenses,
    localMealPlans,
    syncQueueEntries,
    coachMessages,
  ];
}

typedef $$LocalShoppingItemsTableCreateCompanionBuilder =
    LocalShoppingItemsCompanion Function({
      required String id,
      required String householdId,
      required String productName,
      Value<String> store,
      Value<double> price,
      Value<String?> unitPrice,
      Value<bool> checked,
      Value<List<String>> sourceMealLabels,
      Value<String?> preferredStore,
      Value<String?> cheapestKnownStore,
      Value<double?> cheapestKnownPrice,
      Value<double?> quantity,
      Value<String?> unit,
      Value<bool> pendingSync,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalShoppingItemsTableUpdateCompanionBuilder =
    LocalShoppingItemsCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> productName,
      Value<String> store,
      Value<double> price,
      Value<String?> unitPrice,
      Value<bool> checked,
      Value<List<String>> sourceMealLabels,
      Value<String?> preferredStore,
      Value<String?> cheapestKnownStore,
      Value<double?> cheapestKnownPrice,
      Value<double?> quantity,
      Value<String?> unit,
      Value<bool> pendingSync,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get sourceMealLabels => $composableBuilder(
    column: $table.sourceMealLabels,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cheapestKnownStore => $composableBuilder(
    column: $table.cheapestKnownStore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cheapestKnownPrice => $composableBuilder(
    column: $table.cheapestKnownPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get store => $composableBuilder(
    column: $table.store,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMealLabels => $composableBuilder(
    column: $table.sourceMealLabels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cheapestKnownStore => $composableBuilder(
    column: $table.cheapestKnownStore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cheapestKnownPrice => $composableBuilder(
    column: $table.cheapestKnownPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get store =>
      $composableBuilder(column: $table.store, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get sourceMealLabels =>
      $composableBuilder(
        column: $table.sourceMealLabels,
        builder: (column) => column,
      );

  GeneratedColumn<String> get preferredStore => $composableBuilder(
    column: $table.preferredStore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cheapestKnownStore => $composableBuilder(
    column: $table.cheapestKnownStore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cheapestKnownPrice => $composableBuilder(
    column: $table.cheapestKnownPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalShoppingItemsTable,
          LocalShoppingItem,
          $$LocalShoppingItemsTableFilterComposer,
          $$LocalShoppingItemsTableOrderingComposer,
          $$LocalShoppingItemsTableAnnotationComposer,
          $$LocalShoppingItemsTableCreateCompanionBuilder,
          $$LocalShoppingItemsTableUpdateCompanionBuilder,
          (
            LocalShoppingItem,
            BaseReferences<
              _$AppDatabase,
              $LocalShoppingItemsTable,
              LocalShoppingItem
            >,
          ),
          LocalShoppingItem,
          PrefetchHooks Function()
        > {
  $$LocalShoppingItemsTableTableManager(
    _$AppDatabase db,
    $LocalShoppingItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> store = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String?> unitPrice = const Value.absent(),
                Value<bool> checked = const Value.absent(),
                Value<List<String>> sourceMealLabels = const Value.absent(),
                Value<String?> preferredStore = const Value.absent(),
                Value<String?> cheapestKnownStore = const Value.absent(),
                Value<double?> cheapestKnownPrice = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingItemsCompanion(
                id: id,
                householdId: householdId,
                productName: productName,
                store: store,
                price: price,
                unitPrice: unitPrice,
                checked: checked,
                sourceMealLabels: sourceMealLabels,
                preferredStore: preferredStore,
                cheapestKnownStore: cheapestKnownStore,
                cheapestKnownPrice: cheapestKnownPrice,
                quantity: quantity,
                unit: unit,
                pendingSync: pendingSync,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String productName,
                Value<String> store = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String?> unitPrice = const Value.absent(),
                Value<bool> checked = const Value.absent(),
                Value<List<String>> sourceMealLabels = const Value.absent(),
                Value<String?> preferredStore = const Value.absent(),
                Value<String?> cheapestKnownStore = const Value.absent(),
                Value<double?> cheapestKnownPrice = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingItemsCompanion.insert(
                id: id,
                householdId: householdId,
                productName: productName,
                store: store,
                price: price,
                unitPrice: unitPrice,
                checked: checked,
                sourceMealLabels: sourceMealLabels,
                preferredStore: preferredStore,
                cheapestKnownStore: cheapestKnownStore,
                cheapestKnownPrice: cheapestKnownPrice,
                quantity: quantity,
                unit: unit,
                pendingSync: pendingSync,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalShoppingItemsTable,
      LocalShoppingItem,
      $$LocalShoppingItemsTableFilterComposer,
      $$LocalShoppingItemsTableOrderingComposer,
      $$LocalShoppingItemsTableAnnotationComposer,
      $$LocalShoppingItemsTableCreateCompanionBuilder,
      $$LocalShoppingItemsTableUpdateCompanionBuilder,
      (
        LocalShoppingItem,
        BaseReferences<
          _$AppDatabase,
          $LocalShoppingItemsTable,
          LocalShoppingItem
        >,
      ),
      LocalShoppingItem,
      PrefetchHooks Function()
    >;
typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String id,
      required String householdId,
      required String category,
      required double amount,
      required DateTime date,
      Value<String?> description,
      required String monthKey,
      Value<List<String>> attachmentUrls,
      Value<double?> locationLat,
      Value<double?> locationLng,
      Value<String?> locationAddress,
      Value<bool> pendingSync,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> category,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> description,
      Value<String> monthKey,
      Value<List<String>> attachmentUrls,
      Value<double?> locationLat,
      Value<double?> locationLng,
      Value<String?> locationAddress,
      Value<bool> pendingSync,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get attachmentUrls => $composableBuilder(
    column: $table.attachmentUrls,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentUrls => $composableBuilder(
    column: $table.attachmentUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get attachmentUrls =>
      $composableBuilder(
        column: $table.attachmentUrls,
        builder: (column) => column,
      );

  GeneratedColumn<double> get locationLat => $composableBuilder(
    column: $table.locationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get locationLng => $composableBuilder(
    column: $table.locationLng,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExpensesTable,
          LocalExpense,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpense,
            BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
          ),
          LocalExpense,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(_$AppDatabase db, $LocalExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<List<String>> attachmentUrls = const Value.absent(),
                Value<double?> locationLat = const Value.absent(),
                Value<double?> locationLng = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                id: id,
                householdId: householdId,
                category: category,
                amount: amount,
                date: date,
                description: description,
                monthKey: monthKey,
                attachmentUrls: attachmentUrls,
                locationLat: locationLat,
                locationLng: locationLng,
                locationAddress: locationAddress,
                pendingSync: pendingSync,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String category,
                required double amount,
                required DateTime date,
                Value<String?> description = const Value.absent(),
                required String monthKey,
                Value<List<String>> attachmentUrls = const Value.absent(),
                Value<double?> locationLat = const Value.absent(),
                Value<double?> locationLng = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                id: id,
                householdId: householdId,
                category: category,
                amount: amount,
                date: date,
                description: description,
                monthKey: monthKey,
                attachmentUrls: attachmentUrls,
                locationLat: locationLat,
                locationLng: locationLng,
                locationAddress: locationAddress,
                pendingSync: pendingSync,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExpensesTable,
      LocalExpense,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpense,
        BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
      ),
      LocalExpense,
      PrefetchHooks Function()
    >;
typedef $$LocalMealPlansTableCreateCompanionBuilder =
    LocalMealPlansCompanion Function({
      required String id,
      required String householdId,
      required String planJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$LocalMealPlansTableUpdateCompanionBuilder =
    LocalMealPlansCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> planJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalMealPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMealPlansTable> {
  $$LocalMealPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planJson => $composableBuilder(
    column: $table.planJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMealPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMealPlansTable> {
  $$LocalMealPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planJson => $composableBuilder(
    column: $table.planJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMealPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMealPlansTable> {
  $$LocalMealPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planJson =>
      $composableBuilder(column: $table.planJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMealPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMealPlansTable,
          LocalMealPlan,
          $$LocalMealPlansTableFilterComposer,
          $$LocalMealPlansTableOrderingComposer,
          $$LocalMealPlansTableAnnotationComposer,
          $$LocalMealPlansTableCreateCompanionBuilder,
          $$LocalMealPlansTableUpdateCompanionBuilder,
          (
            LocalMealPlan,
            BaseReferences<_$AppDatabase, $LocalMealPlansTable, LocalMealPlan>,
          ),
          LocalMealPlan,
          PrefetchHooks Function()
        > {
  $$LocalMealPlansTableTableManager(
    _$AppDatabase db,
    $LocalMealPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMealPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMealPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMealPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> planJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMealPlansCompanion(
                id: id,
                householdId: householdId,
                planJson: planJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String planJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMealPlansCompanion.insert(
                id: id,
                householdId: householdId,
                planJson: planJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMealPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMealPlansTable,
      LocalMealPlan,
      $$LocalMealPlansTableFilterComposer,
      $$LocalMealPlansTableOrderingComposer,
      $$LocalMealPlansTableAnnotationComposer,
      $$LocalMealPlansTableCreateCompanionBuilder,
      $$LocalMealPlansTableUpdateCompanionBuilder,
      (
        LocalMealPlan,
        BaseReferences<_$AppDatabase, $LocalMealPlansTable, LocalMealPlan>,
      ),
      LocalMealPlan,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      required String id,
      required String householdId,
      required String domain,
      required String action,
      required String payload,
      Value<DateTime> createdAt,
      Value<bool> completed,
      Value<int> rowid,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> domain,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<bool> completed,
      Value<int> rowid,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueEntry,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueEntriesTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                id: id,
                householdId: householdId,
                domain: domain,
                action: action,
                payload: payload,
                createdAt: createdAt,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String domain,
                required String action,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueEntriesCompanion.insert(
                id: id,
                householdId: householdId,
                domain: domain,
                action: action,
                payload: payload,
                createdAt: createdAt,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueEntry,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$CoachMessagesTableCreateCompanionBuilder =
    CoachMessagesCompanion Function({
      required String id,
      required String householdId,
      required String role,
      required String content,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$CoachMessagesTableUpdateCompanionBuilder =
    CoachMessagesCompanion Function({
      Value<String> id,
      Value<String> householdId,
      Value<String> role,
      Value<String> content,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$CoachMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CoachMessagesTable> {
  $$CoachMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoachMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoachMessagesTable> {
  $$CoachMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoachMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoachMessagesTable> {
  $$CoachMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$CoachMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoachMessagesTable,
          CoachMessage,
          $$CoachMessagesTableFilterComposer,
          $$CoachMessagesTableOrderingComposer,
          $$CoachMessagesTableAnnotationComposer,
          $$CoachMessagesTableCreateCompanionBuilder,
          $$CoachMessagesTableUpdateCompanionBuilder,
          (
            CoachMessage,
            BaseReferences<_$AppDatabase, $CoachMessagesTable, CoachMessage>,
          ),
          CoachMessage,
          PrefetchHooks Function()
        > {
  $$CoachMessagesTableTableManager(_$AppDatabase db, $CoachMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoachMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoachMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoachMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> householdId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoachMessagesCompanion(
                id: id,
                householdId: householdId,
                role: role,
                content: content,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String householdId,
                required String role,
                required String content,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => CoachMessagesCompanion.insert(
                id: id,
                householdId: householdId,
                role: role,
                content: content,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoachMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoachMessagesTable,
      CoachMessage,
      $$CoachMessagesTableFilterComposer,
      $$CoachMessagesTableOrderingComposer,
      $$CoachMessagesTableAnnotationComposer,
      $$CoachMessagesTableCreateCompanionBuilder,
      $$CoachMessagesTableUpdateCompanionBuilder,
      (
        CoachMessage,
        BaseReferences<_$AppDatabase, $CoachMessagesTable, CoachMessage>,
      ),
      CoachMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(_db, _db.localShoppingItems);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
  $$LocalMealPlansTableTableManager get localMealPlans =>
      $$LocalMealPlansTableTableManager(_db, _db.localMealPlans);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$CoachMessagesTableTableManager get coachMessages =>
      $$CoachMessagesTableTableManager(_db, _db.coachMessages);
}
