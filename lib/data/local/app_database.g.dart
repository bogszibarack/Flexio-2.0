// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedFoodsTable extends CachedFoods
    with TableInfo<$CachedFoodsTable, CachedFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("off"));
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedNameMeta =
      const VerificationMeta('normalizedName');
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
      'normalized_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
      'kcal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
      'sugar', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _saturatedFatMeta =
      const VerificationMeta('saturatedFat');
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
      'saturated_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
      'salt', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _servingsJsonMeta =
      const VerificationMeta('servingsJson');
  @override
  late final GeneratedColumn<String> servingsJson = GeneratedColumn<String>(
      'servings_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("[]"));
  static const VerificationMeta _popularityMeta =
      const VerificationMeta('popularity');
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
      'popularity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _qualityScoreMeta =
      const VerificationMeta('qualityScore');
  @override
  late final GeneratedColumn<double> qualityScore = GeneratedColumn<double>(
      'quality_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
      'last_used_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        remoteId,
        source,
        barcode,
        name,
        normalizedName,
        brand,
        category,
        imageUrl,
        kcal,
        protein,
        fat,
        carbs,
        sugar,
        saturatedFat,
        salt,
        fiber,
        servingsJson,
        popularity,
        qualityScore,
        isFavorite,
        lastUsedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_foods';
  @override
  VerificationContext validateIntegrity(Insertable<CachedFoodRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
          _normalizedNameMeta,
          normalizedName.isAcceptableOrUnknown(
              data['normalized_name']!, _normalizedNameMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    }
    if (data.containsKey('sugar')) {
      context.handle(
          _sugarMeta, sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta));
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
          _saturatedFatMeta,
          saturatedFat.isAcceptableOrUnknown(
              data['saturated_fat']!, _saturatedFatMeta));
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    }
    if (data.containsKey('servings_json')) {
      context.handle(
          _servingsJsonMeta,
          servingsJson.isAcceptableOrUnknown(
              data['servings_json']!, _servingsJsonMeta));
    }
    if (data.containsKey('popularity')) {
      context.handle(
          _popularityMeta,
          popularity.isAcceptableOrUnknown(
              data['popularity']!, _popularityMeta));
    }
    if (data.containsKey('quality_score')) {
      context.handle(
          _qualityScoreMeta,
          qualityScore.isAcceptableOrUnknown(
              data['quality_score']!, _qualityScoreMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFoodRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      normalizedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_name'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kcal'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      sugar: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sugar']),
      saturatedFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}saturated_fat']),
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salt']),
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber']),
      servingsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}servings_json'])!,
      popularity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}popularity'])!,
      qualityScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quality_score'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $CachedFoodsTable createAlias(String alias) {
    return $CachedFoodsTable(attachedDatabase, alias);
  }
}

class CachedFoodRow extends DataClass implements Insertable<CachedFoodRow> {
  final String id;
  final String? remoteId;
  final String source;
  final String? barcode;
  final String name;
  final String normalizedName;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final double? sugar;
  final double? saturatedFat;
  final double? salt;
  final double? fiber;
  final String servingsJson;
  final int popularity;
  final double qualityScore;
  final bool isFavorite;
  final DateTime? lastUsedAt;

  /// Saját étel, ami még nincs felküldve a szerverre.
  final bool isDirty;
  const CachedFoodRow(
      {required this.id,
      this.remoteId,
      required this.source,
      this.barcode,
      required this.name,
      required this.normalizedName,
      this.brand,
      this.category,
      this.imageUrl,
      required this.kcal,
      required this.protein,
      required this.fat,
      required this.carbs,
      this.sugar,
      this.saturatedFat,
      this.salt,
      this.fiber,
      required this.servingsJson,
      required this.popularity,
      required this.qualityScore,
      required this.isFavorite,
      this.lastUsedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    map['servings_json'] = Variable<String>(servingsJson);
    map['popularity'] = Variable<int>(popularity);
    map['quality_score'] = Variable<double>(qualityScore);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  CachedFoodsCompanion toCompanion(bool nullToAbsent) {
    return CachedFoodsCompanion(
      id: Value(id),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      source: Value(source),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      normalizedName: Value(normalizedName),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      kcal: Value(kcal),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
      sugar:
          sugar == null && nullToAbsent ? const Value.absent() : Value(sugar),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      fiber:
          fiber == null && nullToAbsent ? const Value.absent() : Value(fiber),
      servingsJson: Value(servingsJson),
      popularity: Value(popularity),
      qualityScore: Value(qualityScore),
      isFavorite: Value(isFavorite),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      isDirty: Value(isDirty),
    );
  }

  factory CachedFoodRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFoodRow(
      id: serializer.fromJson<String>(json['id']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      source: serializer.fromJson<String>(json['source']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      salt: serializer.fromJson<double?>(json['salt']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      servingsJson: serializer.fromJson<String>(json['servingsJson']),
      popularity: serializer.fromJson<int>(json['popularity']),
      qualityScore: serializer.fromJson<double>(json['qualityScore']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteId': serializer.toJson<String?>(remoteId),
      'source': serializer.toJson<String>(source),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
      'sugar': serializer.toJson<double?>(sugar),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'salt': serializer.toJson<double?>(salt),
      'fiber': serializer.toJson<double?>(fiber),
      'servingsJson': serializer.toJson<String>(servingsJson),
      'popularity': serializer.toJson<int>(popularity),
      'qualityScore': serializer.toJson<double>(qualityScore),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  CachedFoodRow copyWith(
          {String? id,
          Value<String?> remoteId = const Value.absent(),
          String? source,
          Value<String?> barcode = const Value.absent(),
          String? name,
          String? normalizedName,
          Value<String?> brand = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          double? kcal,
          double? protein,
          double? fat,
          double? carbs,
          Value<double?> sugar = const Value.absent(),
          Value<double?> saturatedFat = const Value.absent(),
          Value<double?> salt = const Value.absent(),
          Value<double?> fiber = const Value.absent(),
          String? servingsJson,
          int? popularity,
          double? qualityScore,
          bool? isFavorite,
          Value<DateTime?> lastUsedAt = const Value.absent(),
          bool? isDirty}) =>
      CachedFoodRow(
        id: id ?? this.id,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        source: source ?? this.source,
        barcode: barcode.present ? barcode.value : this.barcode,
        name: name ?? this.name,
        normalizedName: normalizedName ?? this.normalizedName,
        brand: brand.present ? brand.value : this.brand,
        category: category.present ? category.value : this.category,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        kcal: kcal ?? this.kcal,
        protein: protein ?? this.protein,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
        sugar: sugar.present ? sugar.value : this.sugar,
        saturatedFat:
            saturatedFat.present ? saturatedFat.value : this.saturatedFat,
        salt: salt.present ? salt.value : this.salt,
        fiber: fiber.present ? fiber.value : this.fiber,
        servingsJson: servingsJson ?? this.servingsJson,
        popularity: popularity ?? this.popularity,
        qualityScore: qualityScore ?? this.qualityScore,
        isFavorite: isFavorite ?? this.isFavorite,
        lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  CachedFoodRow copyWithCompanion(CachedFoodsCompanion data) {
    return CachedFoodRow(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      source: data.source.present ? data.source.value : this.source,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      salt: data.salt.present ? data.salt.value : this.salt,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      servingsJson: data.servingsJson.present
          ? data.servingsJson.value
          : this.servingsJson,
      popularity:
          data.popularity.present ? data.popularity.value : this.popularity,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFoodRow(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('salt: $salt, ')
          ..write('fiber: $fiber, ')
          ..write('servingsJson: $servingsJson, ')
          ..write('popularity: $popularity, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        remoteId,
        source,
        barcode,
        name,
        normalizedName,
        brand,
        category,
        imageUrl,
        kcal,
        protein,
        fat,
        carbs,
        sugar,
        saturatedFat,
        salt,
        fiber,
        servingsJson,
        popularity,
        qualityScore,
        isFavorite,
        lastUsedAt,
        isDirty
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFoodRow &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.source == this.source &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.imageUrl == this.imageUrl &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs &&
          other.sugar == this.sugar &&
          other.saturatedFat == this.saturatedFat &&
          other.salt == this.salt &&
          other.fiber == this.fiber &&
          other.servingsJson == this.servingsJson &&
          other.popularity == this.popularity &&
          other.qualityScore == this.qualityScore &&
          other.isFavorite == this.isFavorite &&
          other.lastUsedAt == this.lastUsedAt &&
          other.isDirty == this.isDirty);
}

class CachedFoodsCompanion extends UpdateCompanion<CachedFoodRow> {
  final Value<String> id;
  final Value<String?> remoteId;
  final Value<String> source;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<String?> imageUrl;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<double?> sugar;
  final Value<double?> saturatedFat;
  final Value<double?> salt;
  final Value<double?> fiber;
  final Value<String> servingsJson;
  final Value<int> popularity;
  final Value<double> qualityScore;
  final Value<bool> isFavorite;
  final Value<DateTime?> lastUsedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const CachedFoodsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.source = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.fiber = const Value.absent(),
    this.servingsJson = const Value.absent(),
    this.popularity = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFoodsCompanion.insert({
    required String id,
    this.remoteId = const Value.absent(),
    this.source = const Value.absent(),
    this.barcode = const Value.absent(),
    required String name,
    this.normalizedName = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.fiber = const Value.absent(),
    this.servingsJson = const Value.absent(),
    this.popularity = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CachedFoodRow> custom({
    Expression<String>? id,
    Expression<String>? remoteId,
    Expression<String>? source,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? imageUrl,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<double>? sugar,
    Expression<double>? saturatedFat,
    Expression<double>? salt,
    Expression<double>? fiber,
    Expression<String>? servingsJson,
    Expression<int>? popularity,
    Expression<double>? qualityScore,
    Expression<bool>? isFavorite,
    Expression<DateTime>? lastUsedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (source != null) 'source': source,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (sugar != null) 'sugar': sugar,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (salt != null) 'salt': salt,
      if (fiber != null) 'fiber': fiber,
      if (servingsJson != null) 'servings_json': servingsJson,
      if (popularity != null) 'popularity': popularity,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFoodsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? remoteId,
      Value<String>? source,
      Value<String?>? barcode,
      Value<String>? name,
      Value<String>? normalizedName,
      Value<String?>? brand,
      Value<String?>? category,
      Value<String?>? imageUrl,
      Value<double>? kcal,
      Value<double>? protein,
      Value<double>? fat,
      Value<double>? carbs,
      Value<double?>? sugar,
      Value<double?>? saturatedFat,
      Value<double?>? salt,
      Value<double?>? fiber,
      Value<String>? servingsJson,
      Value<int>? popularity,
      Value<double>? qualityScore,
      Value<bool>? isFavorite,
      Value<DateTime?>? lastUsedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return CachedFoodsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      source: source ?? this.source,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      salt: salt ?? this.salt,
      fiber: fiber ?? this.fiber,
      servingsJson: servingsJson ?? this.servingsJson,
      popularity: popularity ?? this.popularity,
      qualityScore: qualityScore ?? this.qualityScore,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (servingsJson.present) {
      map['servings_json'] = Variable<String>(servingsJson.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<double>(qualityScore.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFoodsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('source: $source, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('salt: $salt, ')
          ..write('fiber: $fiber, ')
          ..write('servingsJson: $servingsJson, ')
          ..write('popularity: $popularity, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryRowsTable extends DiaryRows
    with TableInfo<$DiaryRowsTable, DiaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _loggedAtMeta =
      const VerificationMeta('loggedAt');
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
      'logged_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _localDateMeta =
      const VerificationMeta('localDate');
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
      'local_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
      'food_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _foodLocalIdMeta =
      const VerificationMeta('foodLocalId');
  @override
  late final GeneratedColumn<String> foodLocalId = GeneratedColumn<String>(
      'food_local_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _foodNameMeta =
      const VerificationMeta('foodName');
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
      'food_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _foodImageMeta =
      const VerificationMeta('foodImage');
  @override
  late final GeneratedColumn<String> foodImage = GeneratedColumn<String>(
      'food_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountGMeta =
      const VerificationMeta('amountG');
  @override
  late final GeneratedColumn<double> amountG = GeneratedColumn<double>(
      'amount_g', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _servingLabelMeta =
      const VerificationMeta('servingLabel');
  @override
  late final GeneratedColumn<String> servingLabel = GeneratedColumn<String>(
      'serving_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
      'kcal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
      'sugar', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _saturatedFatMeta =
      const VerificationMeta('saturatedFat');
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
      'saturated_fat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
      'salt', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
      'fiber', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        loggedAt,
        localDate,
        mealType,
        foodId,
        foodLocalId,
        foodName,
        foodImage,
        amountG,
        servingLabel,
        kcal,
        protein,
        fat,
        carbs,
        sugar,
        saturatedFat,
        salt,
        fiber,
        updatedAt,
        deletedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_rows';
  @override
  VerificationContext validateIntegrity(Insertable<DiaryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(_loggedAtMeta,
          loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta));
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(_localDateMeta,
          localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta));
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    }
    if (data.containsKey('food_local_id')) {
      context.handle(
          _foodLocalIdMeta,
          foodLocalId.isAcceptableOrUnknown(
              data['food_local_id']!, _foodLocalIdMeta));
    }
    if (data.containsKey('food_name')) {
      context.handle(_foodNameMeta,
          foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta));
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('food_image')) {
      context.handle(_foodImageMeta,
          foodImage.isAcceptableOrUnknown(data['food_image']!, _foodImageMeta));
    }
    if (data.containsKey('amount_g')) {
      context.handle(_amountGMeta,
          amountG.isAcceptableOrUnknown(data['amount_g']!, _amountGMeta));
    }
    if (data.containsKey('serving_label')) {
      context.handle(
          _servingLabelMeta,
          servingLabel.isAcceptableOrUnknown(
              data['serving_label']!, _servingLabelMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(
          _kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    }
    if (data.containsKey('sugar')) {
      context.handle(
          _sugarMeta, sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta));
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
          _saturatedFatMeta,
          saturatedFat.isAcceptableOrUnknown(
              data['saturated_fat']!, _saturatedFatMeta));
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    }
    if (data.containsKey('fiber')) {
      context.handle(
          _fiberMeta, fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      loggedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}logged_at'])!,
      localDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_date'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_id']),
      foodLocalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_local_id']),
      foodName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_name'])!,
      foodImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_image']),
      amountG: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_g'])!,
      servingLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}serving_label']),
      kcal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kcal'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      sugar: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sugar']),
      saturatedFat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}saturated_fat']),
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salt']),
      fiber: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fiber']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $DiaryRowsTable createAlias(String alias) {
    return $DiaryRowsTable(attachedDatabase, alias);
  }
}

class DiaryRow extends DataClass implements Insertable<DiaryRow> {
  final String id;
  final String userId;
  final DateTime loggedAt;
  final String localDate;
  final String mealType;
  final String? foodId;
  final String? foodLocalId;
  final String foodName;
  final String? foodImage;
  final double amountG;
  final String? servingLabel;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final double? sugar;
  final double? saturatedFat;
  final double? salt;
  final double? fiber;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDirty;
  const DiaryRow(
      {required this.id,
      required this.userId,
      required this.loggedAt,
      required this.localDate,
      required this.mealType,
      this.foodId,
      this.foodLocalId,
      required this.foodName,
      this.foodImage,
      required this.amountG,
      this.servingLabel,
      required this.kcal,
      required this.protein,
      required this.fat,
      required this.carbs,
      this.sugar,
      this.saturatedFat,
      this.salt,
      this.fiber,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['local_date'] = Variable<String>(localDate);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    if (!nullToAbsent || foodLocalId != null) {
      map['food_local_id'] = Variable<String>(foodLocalId);
    }
    map['food_name'] = Variable<String>(foodName);
    if (!nullToAbsent || foodImage != null) {
      map['food_image'] = Variable<String>(foodImage);
    }
    map['amount_g'] = Variable<double>(amountG);
    if (!nullToAbsent || servingLabel != null) {
      map['serving_label'] = Variable<String>(servingLabel);
    }
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  DiaryRowsCompanion toCompanion(bool nullToAbsent) {
    return DiaryRowsCompanion(
      id: Value(id),
      userId: Value(userId),
      loggedAt: Value(loggedAt),
      localDate: Value(localDate),
      mealType: Value(mealType),
      foodId:
          foodId == null && nullToAbsent ? const Value.absent() : Value(foodId),
      foodLocalId: foodLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodLocalId),
      foodName: Value(foodName),
      foodImage: foodImage == null && nullToAbsent
          ? const Value.absent()
          : Value(foodImage),
      amountG: Value(amountG),
      servingLabel: servingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(servingLabel),
      kcal: Value(kcal),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
      sugar:
          sugar == null && nullToAbsent ? const Value.absent() : Value(sugar),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      fiber:
          fiber == null && nullToAbsent ? const Value.absent() : Value(fiber),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory DiaryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      mealType: serializer.fromJson<String>(json['mealType']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      foodLocalId: serializer.fromJson<String?>(json['foodLocalId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      foodImage: serializer.fromJson<String?>(json['foodImage']),
      amountG: serializer.fromJson<double>(json['amountG']),
      servingLabel: serializer.fromJson<String?>(json['servingLabel']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      salt: serializer.fromJson<double?>(json['salt']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'localDate': serializer.toJson<String>(localDate),
      'mealType': serializer.toJson<String>(mealType),
      'foodId': serializer.toJson<String?>(foodId),
      'foodLocalId': serializer.toJson<String?>(foodLocalId),
      'foodName': serializer.toJson<String>(foodName),
      'foodImage': serializer.toJson<String?>(foodImage),
      'amountG': serializer.toJson<double>(amountG),
      'servingLabel': serializer.toJson<String?>(servingLabel),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
      'sugar': serializer.toJson<double?>(sugar),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'salt': serializer.toJson<double?>(salt),
      'fiber': serializer.toJson<double?>(fiber),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  DiaryRow copyWith(
          {String? id,
          String? userId,
          DateTime? loggedAt,
          String? localDate,
          String? mealType,
          Value<String?> foodId = const Value.absent(),
          Value<String?> foodLocalId = const Value.absent(),
          String? foodName,
          Value<String?> foodImage = const Value.absent(),
          double? amountG,
          Value<String?> servingLabel = const Value.absent(),
          double? kcal,
          double? protein,
          double? fat,
          double? carbs,
          Value<double?> sugar = const Value.absent(),
          Value<double?> saturatedFat = const Value.absent(),
          Value<double?> salt = const Value.absent(),
          Value<double?> fiber = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isDirty}) =>
      DiaryRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        loggedAt: loggedAt ?? this.loggedAt,
        localDate: localDate ?? this.localDate,
        mealType: mealType ?? this.mealType,
        foodId: foodId.present ? foodId.value : this.foodId,
        foodLocalId: foodLocalId.present ? foodLocalId.value : this.foodLocalId,
        foodName: foodName ?? this.foodName,
        foodImage: foodImage.present ? foodImage.value : this.foodImage,
        amountG: amountG ?? this.amountG,
        servingLabel:
            servingLabel.present ? servingLabel.value : this.servingLabel,
        kcal: kcal ?? this.kcal,
        protein: protein ?? this.protein,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
        sugar: sugar.present ? sugar.value : this.sugar,
        saturatedFat:
            saturatedFat.present ? saturatedFat.value : this.saturatedFat,
        salt: salt.present ? salt.value : this.salt,
        fiber: fiber.present ? fiber.value : this.fiber,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  DiaryRow copyWithCompanion(DiaryRowsCompanion data) {
    return DiaryRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      foodLocalId:
          data.foodLocalId.present ? data.foodLocalId.value : this.foodLocalId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      foodImage: data.foodImage.present ? data.foodImage.value : this.foodImage,
      amountG: data.amountG.present ? data.amountG.value : this.amountG,
      servingLabel: data.servingLabel.present
          ? data.servingLabel.value
          : this.servingLabel,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      salt: data.salt.present ? data.salt.value : this.salt,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('localDate: $localDate, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('foodLocalId: $foodLocalId, ')
          ..write('foodName: $foodName, ')
          ..write('foodImage: $foodImage, ')
          ..write('amountG: $amountG, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('salt: $salt, ')
          ..write('fiber: $fiber, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        loggedAt,
        localDate,
        mealType,
        foodId,
        foodLocalId,
        foodName,
        foodImage,
        amountG,
        servingLabel,
        kcal,
        protein,
        fat,
        carbs,
        sugar,
        saturatedFat,
        salt,
        fiber,
        updatedAt,
        deletedAt,
        isDirty
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.loggedAt == this.loggedAt &&
          other.localDate == this.localDate &&
          other.mealType == this.mealType &&
          other.foodId == this.foodId &&
          other.foodLocalId == this.foodLocalId &&
          other.foodName == this.foodName &&
          other.foodImage == this.foodImage &&
          other.amountG == this.amountG &&
          other.servingLabel == this.servingLabel &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs &&
          other.sugar == this.sugar &&
          other.saturatedFat == this.saturatedFat &&
          other.salt == this.salt &&
          other.fiber == this.fiber &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class DiaryRowsCompanion extends UpdateCompanion<DiaryRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> loggedAt;
  final Value<String> localDate;
  final Value<String> mealType;
  final Value<String?> foodId;
  final Value<String?> foodLocalId;
  final Value<String> foodName;
  final Value<String?> foodImage;
  final Value<double> amountG;
  final Value<String?> servingLabel;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<double?> sugar;
  final Value<double?> saturatedFat;
  final Value<double?> salt;
  final Value<double?> fiber;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const DiaryRowsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.mealType = const Value.absent(),
    this.foodId = const Value.absent(),
    this.foodLocalId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.foodImage = const Value.absent(),
    this.amountG = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.fiber = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryRowsCompanion.insert({
    required String id,
    required String userId,
    required DateTime loggedAt,
    required String localDate,
    required String mealType,
    this.foodId = const Value.absent(),
    this.foodLocalId = const Value.absent(),
    required String foodName,
    this.foodImage = const Value.absent(),
    this.amountG = const Value.absent(),
    this.servingLabel = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.fiber = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        loggedAt = Value(loggedAt),
        localDate = Value(localDate),
        mealType = Value(mealType),
        foodName = Value(foodName),
        updatedAt = Value(updatedAt);
  static Insertable<DiaryRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? loggedAt,
    Expression<String>? localDate,
    Expression<String>? mealType,
    Expression<String>? foodId,
    Expression<String>? foodLocalId,
    Expression<String>? foodName,
    Expression<String>? foodImage,
    Expression<double>? amountG,
    Expression<String>? servingLabel,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<double>? sugar,
    Expression<double>? saturatedFat,
    Expression<double>? salt,
    Expression<double>? fiber,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (localDate != null) 'local_date': localDate,
      if (mealType != null) 'meal_type': mealType,
      if (foodId != null) 'food_id': foodId,
      if (foodLocalId != null) 'food_local_id': foodLocalId,
      if (foodName != null) 'food_name': foodName,
      if (foodImage != null) 'food_image': foodImage,
      if (amountG != null) 'amount_g': amountG,
      if (servingLabel != null) 'serving_label': servingLabel,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (sugar != null) 'sugar': sugar,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (salt != null) 'salt': salt,
      if (fiber != null) 'fiber': fiber,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<DateTime>? loggedAt,
      Value<String>? localDate,
      Value<String>? mealType,
      Value<String?>? foodId,
      Value<String?>? foodLocalId,
      Value<String>? foodName,
      Value<String?>? foodImage,
      Value<double>? amountG,
      Value<String?>? servingLabel,
      Value<double>? kcal,
      Value<double>? protein,
      Value<double>? fat,
      Value<double>? carbs,
      Value<double?>? sugar,
      Value<double?>? saturatedFat,
      Value<double?>? salt,
      Value<double?>? fiber,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return DiaryRowsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      loggedAt: loggedAt ?? this.loggedAt,
      localDate: localDate ?? this.localDate,
      mealType: mealType ?? this.mealType,
      foodId: foodId ?? this.foodId,
      foodLocalId: foodLocalId ?? this.foodLocalId,
      foodName: foodName ?? this.foodName,
      foodImage: foodImage ?? this.foodImage,
      amountG: amountG ?? this.amountG,
      servingLabel: servingLabel ?? this.servingLabel,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      salt: salt ?? this.salt,
      fiber: fiber ?? this.fiber,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (foodLocalId.present) {
      map['food_local_id'] = Variable<String>(foodLocalId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (foodImage.present) {
      map['food_image'] = Variable<String>(foodImage.value);
    }
    if (amountG.present) {
      map['amount_g'] = Variable<double>(amountG.value);
    }
    if (servingLabel.present) {
      map['serving_label'] = Variable<String>(servingLabel.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryRowsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('localDate: $localDate, ')
          ..write('mealType: $mealType, ')
          ..write('foodId: $foodId, ')
          ..write('foodLocalId: $foodLocalId, ')
          ..write('foodName: $foodName, ')
          ..write('foodImage: $foodImage, ')
          ..write('amountG: $amountG, ')
          ..write('servingLabel: $servingLabel, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('salt: $salt, ')
          ..write('fiber: $fiber, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutRowsTable extends WorkoutRows
    with TableInfo<$WorkoutRowsTable, WorkoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("{}"));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        kind,
        title,
        scheduledAt,
        completedAt,
        durationMinutes,
        calories,
        difficulty,
        payloadJson,
        updatedAt,
        deletedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_rows';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $WorkoutRowsTable createAlias(String alias) {
    return $WorkoutRowsTable(attachedDatabase, alias);
  }
}

class WorkoutRow extends DataClass implements Insertable<WorkoutRow> {
  final String id;
  final String userId;
  final String kind;
  final String title;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final int? durationMinutes;
  final double? calories;
  final String? difficulty;
  final String payloadJson;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDirty;
  const WorkoutRow(
      {required this.id,
      required this.userId,
      required this.kind,
      required this.title,
      this.scheduledAt,
      this.completedAt,
      this.durationMinutes,
      this.calories,
      this.difficulty,
      required this.payloadJson,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<double>(calories);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  WorkoutRowsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutRowsCompanion(
      id: Value(id),
      userId: Value(userId),
      kind: Value(kind),
      title: Value(title),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory WorkoutRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      calories: serializer.fromJson<double?>(json['calories']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'calories': serializer.toJson<double?>(calories),
      'difficulty': serializer.toJson<String?>(difficulty),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  WorkoutRow copyWith(
          {String? id,
          String? userId,
          String? kind,
          String? title,
          Value<DateTime?> scheduledAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> durationMinutes = const Value.absent(),
          Value<double?> calories = const Value.absent(),
          Value<String?> difficulty = const Value.absent(),
          String? payloadJson,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isDirty}) =>
      WorkoutRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        calories: calories.present ? calories.value : this.calories,
        difficulty: difficulty.present ? difficulty.value : this.difficulty,
        payloadJson: payloadJson ?? this.payloadJson,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  WorkoutRow copyWithCompanion(WorkoutRowsCompanion data) {
    return WorkoutRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      calories: data.calories.present ? data.calories.value : this.calories,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('calories: $calories, ')
          ..write('difficulty: $difficulty, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      kind,
      title,
      scheduledAt,
      completedAt,
      durationMinutes,
      calories,
      difficulty,
      payloadJson,
      updatedAt,
      deletedAt,
      isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.durationMinutes == this.durationMinutes &&
          other.calories == this.calories &&
          other.difficulty == this.difficulty &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class WorkoutRowsCompanion extends UpdateCompanion<WorkoutRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> kind;
  final Value<String> title;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> completedAt;
  final Value<int?> durationMinutes;
  final Value<double?> calories;
  final Value<String?> difficulty;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const WorkoutRowsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.calories = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutRowsCompanion.insert({
    required String id,
    required String userId,
    required String kind,
    this.title = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.calories = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.payloadJson = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        kind = Value(kind),
        updatedAt = Value(updatedAt);
  static Insertable<WorkoutRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? completedAt,
    Expression<int>? durationMinutes,
    Expression<double>? calories,
    Expression<String>? difficulty,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (calories != null) 'calories': calories,
      if (difficulty != null) 'difficulty': difficulty,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? kind,
      Value<String>? title,
      Value<DateTime?>? scheduledAt,
      Value<DateTime?>? completedAt,
      Value<int?>? durationMinutes,
      Value<double?>? calories,
      Value<String?>? difficulty,
      Value<String>? payloadJson,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return WorkoutRowsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRowsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('calories: $calories, ')
          ..write('difficulty: $difficulty, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepRowsTable extends SleepRows
    with TableInfo<$SleepRowsTable, SleepRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bedtimeMeta =
      const VerificationMeta('bedtime');
  @override
  late final GeneratedColumn<DateTime> bedtime = GeneratedColumn<DateTime>(
      'bedtime', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _wakeTimeMeta =
      const VerificationMeta('wakeTime');
  @override
  late final GeneratedColumn<DateTime> wakeTime = GeneratedColumn<DateTime>(
      'wake_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        bedtime,
        wakeTime,
        quality,
        note,
        updatedAt,
        deletedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_rows';
  @override
  VerificationContext validateIntegrity(Insertable<SleepRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bedtime')) {
      context.handle(_bedtimeMeta,
          bedtime.isAcceptableOrUnknown(data['bedtime']!, _bedtimeMeta));
    } else if (isInserting) {
      context.missing(_bedtimeMeta);
    }
    if (data.containsKey('wake_time')) {
      context.handle(_wakeTimeMeta,
          wakeTime.isAcceptableOrUnknown(data['wake_time']!, _wakeTimeMeta));
    } else if (isInserting) {
      context.missing(_wakeTimeMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      bedtime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}bedtime'])!,
      wakeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}wake_time'])!,
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $SleepRowsTable createAlias(String alias) {
    return $SleepRowsTable(attachedDatabase, alias);
  }
}

class SleepRow extends DataClass implements Insertable<SleepRow> {
  final String id;
  final String userId;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int? quality;
  final String? note;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDirty;
  const SleepRow(
      {required this.id,
      required this.userId,
      required this.bedtime,
      required this.wakeTime,
      this.quality,
      this.note,
      required this.updatedAt,
      this.deletedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['bedtime'] = Variable<DateTime>(bedtime);
    map['wake_time'] = Variable<DateTime>(wakeTime);
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  SleepRowsCompanion toCompanion(bool nullToAbsent) {
    return SleepRowsCompanion(
      id: Value(id),
      userId: Value(userId),
      bedtime: Value(bedtime),
      wakeTime: Value(wakeTime),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
    );
  }

  factory SleepRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      bedtime: serializer.fromJson<DateTime>(json['bedtime']),
      wakeTime: serializer.fromJson<DateTime>(json['wakeTime']),
      quality: serializer.fromJson<int?>(json['quality']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'bedtime': serializer.toJson<DateTime>(bedtime),
      'wakeTime': serializer.toJson<DateTime>(wakeTime),
      'quality': serializer.toJson<int?>(quality),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  SleepRow copyWith(
          {String? id,
          String? userId,
          DateTime? bedtime,
          DateTime? wakeTime,
          Value<int?> quality = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? isDirty}) =>
      SleepRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        bedtime: bedtime ?? this.bedtime,
        wakeTime: wakeTime ?? this.wakeTime,
        quality: quality.present ? quality.value : this.quality,
        note: note.present ? note.value : this.note,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  SleepRow copyWithCompanion(SleepRowsCompanion data) {
    return SleepRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      bedtime: data.bedtime.present ? data.bedtime.value : this.bedtime,
      wakeTime: data.wakeTime.present ? data.wakeTime.value : this.wakeTime,
      quality: data.quality.present ? data.quality.value : this.quality,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bedtime: $bedtime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, bedtime, wakeTime, quality, note,
      updatedAt, deletedAt, isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.bedtime == this.bedtime &&
          other.wakeTime == this.wakeTime &&
          other.quality == this.quality &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty);
}

class SleepRowsCompanion extends UpdateCompanion<SleepRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> bedtime;
  final Value<DateTime> wakeTime;
  final Value<int?> quality;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const SleepRowsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.bedtime = const Value.absent(),
    this.wakeTime = const Value.absent(),
    this.quality = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepRowsCompanion.insert({
    required String id,
    required String userId,
    required DateTime bedtime,
    required DateTime wakeTime,
    this.quality = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        bedtime = Value(bedtime),
        wakeTime = Value(wakeTime),
        updatedAt = Value(updatedAt);
  static Insertable<SleepRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? bedtime,
    Expression<DateTime>? wakeTime,
    Expression<int>? quality,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (bedtime != null) 'bedtime': bedtime,
      if (wakeTime != null) 'wake_time': wakeTime,
      if (quality != null) 'quality': quality,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<DateTime>? bedtime,
      Value<DateTime>? wakeTime,
      Value<int?>? quality,
      Value<String?>? note,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return SleepRowsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bedtime.present) {
      map['bedtime'] = Variable<DateTime>(bedtime.value);
    }
    if (wakeTime.present) {
      map['wake_time'] = Variable<DateTime>(wakeTime.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepRowsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('bedtime: $bedtime, ')
          ..write('wakeTime: $wakeTime, ')
          ..write('quality: $quality, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileRowsTable extends ProfileRows
    with TableInfo<$ProfileRowsTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _activityLevelMeta =
      const VerificationMeta('activityLevel');
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
      'activity_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant("moderate"));
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
      'goal', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _calorieGoalMeta =
      const VerificationMeta('calorieGoal');
  @override
  late final GeneratedColumn<double> calorieGoal = GeneratedColumn<double>(
      'calorie_goal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _proteinGoalMeta =
      const VerificationMeta('proteinGoal');
  @override
  late final GeneratedColumn<double> proteinGoal = GeneratedColumn<double>(
      'protein_goal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _fatGoalMeta =
      const VerificationMeta('fatGoal');
  @override
  late final GeneratedColumn<double> fatGoal = GeneratedColumn<double>(
      'fat_goal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _carbsGoalMeta =
      const VerificationMeta('carbsGoal');
  @override
  late final GeneratedColumn<double> carbsGoal = GeneratedColumn<double>(
      'carbs_goal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _waterGoalMlMeta =
      const VerificationMeta('waterGoalMl');
  @override
  late final GeneratedColumn<int> waterGoalMl = GeneratedColumn<int>(
      'water_goal_ml', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _manualGoalsMeta =
      const VerificationMeta('manualGoals');
  @override
  late final GeneratedColumn<bool> manualGoals = GeneratedColumn<bool>(
      'manual_goals', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("manual_goals" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        firstName,
        gender,
        birthDate,
        heightCm,
        weightKg,
        activityLevel,
        goal,
        calorieGoal,
        proteinGoal,
        fatGoal,
        carbsGoal,
        waterGoalMl,
        manualGoals,
        updatedAt,
        isDirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('activity_level')) {
      context.handle(
          _activityLevelMeta,
          activityLevel.isAcceptableOrUnknown(
              data['activity_level']!, _activityLevelMeta));
    }
    if (data.containsKey('goal')) {
      context.handle(
          _goalMeta, goal.isAcceptableOrUnknown(data['goal']!, _goalMeta));
    }
    if (data.containsKey('calorie_goal')) {
      context.handle(
          _calorieGoalMeta,
          calorieGoal.isAcceptableOrUnknown(
              data['calorie_goal']!, _calorieGoalMeta));
    }
    if (data.containsKey('protein_goal')) {
      context.handle(
          _proteinGoalMeta,
          proteinGoal.isAcceptableOrUnknown(
              data['protein_goal']!, _proteinGoalMeta));
    }
    if (data.containsKey('fat_goal')) {
      context.handle(_fatGoalMeta,
          fatGoal.isAcceptableOrUnknown(data['fat_goal']!, _fatGoalMeta));
    }
    if (data.containsKey('carbs_goal')) {
      context.handle(_carbsGoalMeta,
          carbsGoal.isAcceptableOrUnknown(data['carbs_goal']!, _carbsGoalMeta));
    }
    if (data.containsKey('water_goal_ml')) {
      context.handle(
          _waterGoalMlMeta,
          waterGoalMl.isAcceptableOrUnknown(
              data['water_goal_ml']!, _waterGoalMlMeta));
    }
    if (data.containsKey('manual_goals')) {
      context.handle(
          _manualGoalsMeta,
          manualGoals.isAcceptableOrUnknown(
              data['manual_goals']!, _manualGoalsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      activityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_level'])!,
      goal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal']),
      calorieGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calorie_goal']),
      proteinGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein_goal']),
      fatGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_goal']),
      carbsGoal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs_goal']),
      waterGoalMl: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}water_goal_ml']),
      manualGoals: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual_goals'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
    );
  }

  @override
  $ProfileRowsTable createAlias(String alias) {
    return $ProfileRowsTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String userId;
  final String? firstName;
  final String? gender;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final String activityLevel;
  final String? goal;
  final double? calorieGoal;
  final double? proteinGoal;
  final double? fatGoal;
  final double? carbsGoal;
  final int? waterGoalMl;
  final bool manualGoals;
  final DateTime updatedAt;
  final bool isDirty;
  const ProfileRow(
      {required this.userId,
      this.firstName,
      this.gender,
      this.birthDate,
      this.heightCm,
      this.weightKg,
      required this.activityLevel,
      this.goal,
      this.calorieGoal,
      this.proteinGoal,
      this.fatGoal,
      this.carbsGoal,
      this.waterGoalMl,
      required this.manualGoals,
      required this.updatedAt,
      required this.isDirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['activity_level'] = Variable<String>(activityLevel);
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    if (!nullToAbsent || calorieGoal != null) {
      map['calorie_goal'] = Variable<double>(calorieGoal);
    }
    if (!nullToAbsent || proteinGoal != null) {
      map['protein_goal'] = Variable<double>(proteinGoal);
    }
    if (!nullToAbsent || fatGoal != null) {
      map['fat_goal'] = Variable<double>(fatGoal);
    }
    if (!nullToAbsent || carbsGoal != null) {
      map['carbs_goal'] = Variable<double>(carbsGoal);
    }
    if (!nullToAbsent || waterGoalMl != null) {
      map['water_goal_ml'] = Variable<int>(waterGoalMl);
    }
    map['manual_goals'] = Variable<bool>(manualGoals);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  ProfileRowsCompanion toCompanion(bool nullToAbsent) {
    return ProfileRowsCompanion(
      userId: Value(userId),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      activityLevel: Value(activityLevel),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      calorieGoal: calorieGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(calorieGoal),
      proteinGoal: proteinGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinGoal),
      fatGoal: fatGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(fatGoal),
      carbsGoal: carbsGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsGoal),
      waterGoalMl: waterGoalMl == null && nullToAbsent
          ? const Value.absent()
          : Value(waterGoalMl),
      manualGoals: Value(manualGoals),
      updatedAt: Value(updatedAt),
      isDirty: Value(isDirty),
    );
  }

  factory ProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      userId: serializer.fromJson<String>(json['userId']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      gender: serializer.fromJson<String?>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      activityLevel: serializer.fromJson<String>(json['activityLevel']),
      goal: serializer.fromJson<String?>(json['goal']),
      calorieGoal: serializer.fromJson<double?>(json['calorieGoal']),
      proteinGoal: serializer.fromJson<double?>(json['proteinGoal']),
      fatGoal: serializer.fromJson<double?>(json['fatGoal']),
      carbsGoal: serializer.fromJson<double?>(json['carbsGoal']),
      waterGoalMl: serializer.fromJson<int?>(json['waterGoalMl']),
      manualGoals: serializer.fromJson<bool>(json['manualGoals']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'firstName': serializer.toJson<String?>(firstName),
      'gender': serializer.toJson<String?>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'activityLevel': serializer.toJson<String>(activityLevel),
      'goal': serializer.toJson<String?>(goal),
      'calorieGoal': serializer.toJson<double?>(calorieGoal),
      'proteinGoal': serializer.toJson<double?>(proteinGoal),
      'fatGoal': serializer.toJson<double?>(fatGoal),
      'carbsGoal': serializer.toJson<double?>(carbsGoal),
      'waterGoalMl': serializer.toJson<int?>(waterGoalMl),
      'manualGoals': serializer.toJson<bool>(manualGoals),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  ProfileRow copyWith(
          {String? userId,
          Value<String?> firstName = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          String? activityLevel,
          Value<String?> goal = const Value.absent(),
          Value<double?> calorieGoal = const Value.absent(),
          Value<double?> proteinGoal = const Value.absent(),
          Value<double?> fatGoal = const Value.absent(),
          Value<double?> carbsGoal = const Value.absent(),
          Value<int?> waterGoalMl = const Value.absent(),
          bool? manualGoals,
          DateTime? updatedAt,
          bool? isDirty}) =>
      ProfileRow(
        userId: userId ?? this.userId,
        firstName: firstName.present ? firstName.value : this.firstName,
        gender: gender.present ? gender.value : this.gender,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        goal: goal.present ? goal.value : this.goal,
        calorieGoal: calorieGoal.present ? calorieGoal.value : this.calorieGoal,
        proteinGoal: proteinGoal.present ? proteinGoal.value : this.proteinGoal,
        fatGoal: fatGoal.present ? fatGoal.value : this.fatGoal,
        carbsGoal: carbsGoal.present ? carbsGoal.value : this.carbsGoal,
        waterGoalMl: waterGoalMl.present ? waterGoalMl.value : this.waterGoalMl,
        manualGoals: manualGoals ?? this.manualGoals,
        updatedAt: updatedAt ?? this.updatedAt,
        isDirty: isDirty ?? this.isDirty,
      );
  ProfileRow copyWithCompanion(ProfileRowsCompanion data) {
    return ProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      goal: data.goal.present ? data.goal.value : this.goal,
      calorieGoal:
          data.calorieGoal.present ? data.calorieGoal.value : this.calorieGoal,
      proteinGoal:
          data.proteinGoal.present ? data.proteinGoal.value : this.proteinGoal,
      fatGoal: data.fatGoal.present ? data.fatGoal.value : this.fatGoal,
      carbsGoal: data.carbsGoal.present ? data.carbsGoal.value : this.carbsGoal,
      waterGoalMl:
          data.waterGoalMl.present ? data.waterGoalMl.value : this.waterGoalMl,
      manualGoals:
          data.manualGoals.present ? data.manualGoals.value : this.manualGoals,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('carbsGoal: $carbsGoal, ')
          ..write('waterGoalMl: $waterGoalMl, ')
          ..write('manualGoals: $manualGoals, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      firstName,
      gender,
      birthDate,
      heightCm,
      weightKg,
      activityLevel,
      goal,
      calorieGoal,
      proteinGoal,
      fatGoal,
      carbsGoal,
      waterGoalMl,
      manualGoals,
      updatedAt,
      isDirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.userId == this.userId &&
          other.firstName == this.firstName &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.activityLevel == this.activityLevel &&
          other.goal == this.goal &&
          other.calorieGoal == this.calorieGoal &&
          other.proteinGoal == this.proteinGoal &&
          other.fatGoal == this.fatGoal &&
          other.carbsGoal == this.carbsGoal &&
          other.waterGoalMl == this.waterGoalMl &&
          other.manualGoals == this.manualGoals &&
          other.updatedAt == this.updatedAt &&
          other.isDirty == this.isDirty);
}

class ProfileRowsCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> userId;
  final Value<String?> firstName;
  final Value<String?> gender;
  final Value<DateTime?> birthDate;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String> activityLevel;
  final Value<String?> goal;
  final Value<double?> calorieGoal;
  final Value<double?> proteinGoal;
  final Value<double?> fatGoal;
  final Value<double?> carbsGoal;
  final Value<int?> waterGoalMl;
  final Value<bool> manualGoals;
  final Value<DateTime> updatedAt;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const ProfileRowsCompanion({
    this.userId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.carbsGoal = const Value.absent(),
    this.waterGoalMl = const Value.absent(),
    this.manualGoals = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileRowsCompanion.insert({
    required String userId,
    this.firstName = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieGoal = const Value.absent(),
    this.proteinGoal = const Value.absent(),
    this.fatGoal = const Value.absent(),
    this.carbsGoal = const Value.absent(),
    this.waterGoalMl = const Value.absent(),
    this.manualGoals = const Value.absent(),
    required DateTime updatedAt,
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? userId,
    Expression<String>? firstName,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? activityLevel,
    Expression<String>? goal,
    Expression<double>? calorieGoal,
    Expression<double>? proteinGoal,
    Expression<double>? fatGoal,
    Expression<double>? carbsGoal,
    Expression<int>? waterGoalMl,
    Expression<bool>? manualGoals,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (firstName != null) 'first_name': firstName,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (goal != null) 'goal': goal,
      if (calorieGoal != null) 'calorie_goal': calorieGoal,
      if (proteinGoal != null) 'protein_goal': proteinGoal,
      if (fatGoal != null) 'fat_goal': fatGoal,
      if (carbsGoal != null) 'carbs_goal': carbsGoal,
      if (waterGoalMl != null) 'water_goal_ml': waterGoalMl,
      if (manualGoals != null) 'manual_goals': manualGoals,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileRowsCompanion copyWith(
      {Value<String>? userId,
      Value<String?>? firstName,
      Value<String?>? gender,
      Value<DateTime?>? birthDate,
      Value<double?>? heightCm,
      Value<double?>? weightKg,
      Value<String>? activityLevel,
      Value<String?>? goal,
      Value<double?>? calorieGoal,
      Value<double?>? proteinGoal,
      Value<double?>? fatGoal,
      Value<double?>? carbsGoal,
      Value<int?>? waterGoalMl,
      Value<bool>? manualGoals,
      Value<DateTime>? updatedAt,
      Value<bool>? isDirty,
      Value<int>? rowid}) {
    return ProfileRowsCompanion(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      manualGoals: manualGoals ?? this.manualGoals,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (calorieGoal.present) {
      map['calorie_goal'] = Variable<double>(calorieGoal.value);
    }
    if (proteinGoal.present) {
      map['protein_goal'] = Variable<double>(proteinGoal.value);
    }
    if (fatGoal.present) {
      map['fat_goal'] = Variable<double>(fatGoal.value);
    }
    if (carbsGoal.present) {
      map['carbs_goal'] = Variable<double>(carbsGoal.value);
    }
    if (waterGoalMl.present) {
      map['water_goal_ml'] = Variable<int>(waterGoalMl.value);
    }
    if (manualGoals.present) {
      map['manual_goals'] = Variable<bool>(manualGoals.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRowsCompanion(')
          ..write('userId: $userId, ')
          ..write('firstName: $firstName, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('goal: $goal, ')
          ..write('calorieGoal: $calorieGoal, ')
          ..write('proteinGoal: $proteinGoal, ')
          ..write('fatGoal: $fatGoal, ')
          ..write('carbsGoal: $carbsGoal, ')
          ..write('waterGoalMl: $waterGoalMl, ')
          ..write('manualGoals: $manualGoals, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta with TableInfo<$SyncMetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory MetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) => MetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  MetaRow copyWithCompanion(SyncMetaCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedFoodsTable cachedFoods = $CachedFoodsTable(this);
  late final $DiaryRowsTable diaryRows = $DiaryRowsTable(this);
  late final $WorkoutRowsTable workoutRows = $WorkoutRowsTable(this);
  late final $SleepRowsTable sleepRows = $SleepRowsTable(this);
  late final $ProfileRowsTable profileRows = $ProfileRowsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedFoods, diaryRows, workoutRows, sleepRows, profileRows, syncMeta];
}

typedef $$CachedFoodsTableCreateCompanionBuilder = CachedFoodsCompanion
    Function({
  required String id,
  Value<String?> remoteId,
  Value<String> source,
  Value<String?> barcode,
  required String name,
  Value<String> normalizedName,
  Value<String?> brand,
  Value<String?> category,
  Value<String?> imageUrl,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<double?> sugar,
  Value<double?> saturatedFat,
  Value<double?> salt,
  Value<double?> fiber,
  Value<String> servingsJson,
  Value<int> popularity,
  Value<double> qualityScore,
  Value<bool> isFavorite,
  Value<DateTime?> lastUsedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$CachedFoodsTableUpdateCompanionBuilder = CachedFoodsCompanion
    Function({
  Value<String> id,
  Value<String?> remoteId,
  Value<String> source,
  Value<String?> barcode,
  Value<String> name,
  Value<String> normalizedName,
  Value<String?> brand,
  Value<String?> category,
  Value<String?> imageUrl,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<double?> sugar,
  Value<double?> saturatedFat,
  Value<double?> salt,
  Value<double?> fiber,
  Value<String> servingsJson,
  Value<int> popularity,
  Value<double> qualityScore,
  Value<bool> isFavorite,
  Value<DateTime?> lastUsedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$CachedFoodsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servingsJson => $composableBuilder(
      column: $table.servingsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$CachedFoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servingsJson => $composableBuilder(
      column: $table.servingsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$CachedFoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFoodsTable> {
  $$CachedFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => column);

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<String> get servingsJson => $composableBuilder(
      column: $table.servingsJson, builder: (column) => column);

  GeneratedColumn<int> get popularity => $composableBuilder(
      column: $table.popularity, builder: (column) => column);

  GeneratedColumn<double> get qualityScore => $composableBuilder(
      column: $table.qualityScore, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$CachedFoodsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedFoodsTable,
    CachedFoodRow,
    $$CachedFoodsTableFilterComposer,
    $$CachedFoodsTableOrderingComposer,
    $$CachedFoodsTableAnnotationComposer,
    $$CachedFoodsTableCreateCompanionBuilder,
    $$CachedFoodsTableUpdateCompanionBuilder,
    (
      CachedFoodRow,
      BaseReferences<_$AppDatabase, $CachedFoodsTable, CachedFoodRow>
    ),
    CachedFoodRow,
    PrefetchHooks Function()> {
  $$CachedFoodsTableTableManager(_$AppDatabase db, $CachedFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> normalizedName = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<double> kcal = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> salt = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            Value<String> servingsJson = const Value.absent(),
            Value<int> popularity = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastUsedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedFoodsCompanion(
            id: id,
            remoteId: remoteId,
            source: source,
            barcode: barcode,
            name: name,
            normalizedName: normalizedName,
            brand: brand,
            category: category,
            imageUrl: imageUrl,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbs: carbs,
            sugar: sugar,
            saturatedFat: saturatedFat,
            salt: salt,
            fiber: fiber,
            servingsJson: servingsJson,
            popularity: popularity,
            qualityScore: qualityScore,
            isFavorite: isFavorite,
            lastUsedAt: lastUsedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> remoteId = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> barcode = const Value.absent(),
            required String name,
            Value<String> normalizedName = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<double> kcal = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> salt = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            Value<String> servingsJson = const Value.absent(),
            Value<int> popularity = const Value.absent(),
            Value<double> qualityScore = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastUsedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedFoodsCompanion.insert(
            id: id,
            remoteId: remoteId,
            source: source,
            barcode: barcode,
            name: name,
            normalizedName: normalizedName,
            brand: brand,
            category: category,
            imageUrl: imageUrl,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbs: carbs,
            sugar: sugar,
            saturatedFat: saturatedFat,
            salt: salt,
            fiber: fiber,
            servingsJson: servingsJson,
            popularity: popularity,
            qualityScore: qualityScore,
            isFavorite: isFavorite,
            lastUsedAt: lastUsedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedFoodsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedFoodsTable,
    CachedFoodRow,
    $$CachedFoodsTableFilterComposer,
    $$CachedFoodsTableOrderingComposer,
    $$CachedFoodsTableAnnotationComposer,
    $$CachedFoodsTableCreateCompanionBuilder,
    $$CachedFoodsTableUpdateCompanionBuilder,
    (
      CachedFoodRow,
      BaseReferences<_$AppDatabase, $CachedFoodsTable, CachedFoodRow>
    ),
    CachedFoodRow,
    PrefetchHooks Function()>;
typedef $$DiaryRowsTableCreateCompanionBuilder = DiaryRowsCompanion Function({
  required String id,
  required String userId,
  required DateTime loggedAt,
  required String localDate,
  required String mealType,
  Value<String?> foodId,
  Value<String?> foodLocalId,
  required String foodName,
  Value<String?> foodImage,
  Value<double> amountG,
  Value<String?> servingLabel,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<double?> sugar,
  Value<double?> saturatedFat,
  Value<double?> salt,
  Value<double?> fiber,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$DiaryRowsTableUpdateCompanionBuilder = DiaryRowsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<DateTime> loggedAt,
  Value<String> localDate,
  Value<String> mealType,
  Value<String?> foodId,
  Value<String?> foodLocalId,
  Value<String> foodName,
  Value<String?> foodImage,
  Value<double> amountG,
  Value<String?> servingLabel,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<double?> sugar,
  Value<double?> saturatedFat,
  Value<double?> salt,
  Value<double?> fiber,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$DiaryRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryRowsTable> {
  $$DiaryRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localDate => $composableBuilder(
      column: $table.localDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodLocalId => $composableBuilder(
      column: $table.foodLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get foodImage => $composableBuilder(
      column: $table.foodImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountG => $composableBuilder(
      column: $table.amountG, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servingLabel => $composableBuilder(
      column: $table.servingLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$DiaryRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryRowsTable> {
  $$DiaryRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
      column: $table.loggedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localDate => $composableBuilder(
      column: $table.localDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodId => $composableBuilder(
      column: $table.foodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodLocalId => $composableBuilder(
      column: $table.foodLocalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodName => $composableBuilder(
      column: $table.foodName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get foodImage => $composableBuilder(
      column: $table.foodImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountG => $composableBuilder(
      column: $table.amountG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servingLabel => $composableBuilder(
      column: $table.servingLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kcal => $composableBuilder(
      column: $table.kcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get protein => $composableBuilder(
      column: $table.protein, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbs => $composableBuilder(
      column: $table.carbs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sugar => $composableBuilder(
      column: $table.sugar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fiber => $composableBuilder(
      column: $table.fiber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$DiaryRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryRowsTable> {
  $$DiaryRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get foodLocalId => $composableBuilder(
      column: $table.foodLocalId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get foodImage =>
      $composableBuilder(column: $table.foodImage, builder: (column) => column);

  GeneratedColumn<double> get amountG =>
      $composableBuilder(column: $table.amountG, builder: (column) => column);

  GeneratedColumn<String> get servingLabel => $composableBuilder(
      column: $table.servingLabel, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
      column: $table.saturatedFat, builder: (column) => column);

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$DiaryRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiaryRowsTable,
    DiaryRow,
    $$DiaryRowsTableFilterComposer,
    $$DiaryRowsTableOrderingComposer,
    $$DiaryRowsTableAnnotationComposer,
    $$DiaryRowsTableCreateCompanionBuilder,
    $$DiaryRowsTableUpdateCompanionBuilder,
    (DiaryRow, BaseReferences<_$AppDatabase, $DiaryRowsTable, DiaryRow>),
    DiaryRow,
    PrefetchHooks Function()> {
  $$DiaryRowsTableTableManager(_$AppDatabase db, $DiaryRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> loggedAt = const Value.absent(),
            Value<String> localDate = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String?> foodId = const Value.absent(),
            Value<String?> foodLocalId = const Value.absent(),
            Value<String> foodName = const Value.absent(),
            Value<String?> foodImage = const Value.absent(),
            Value<double> amountG = const Value.absent(),
            Value<String?> servingLabel = const Value.absent(),
            Value<double> kcal = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> salt = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryRowsCompanion(
            id: id,
            userId: userId,
            loggedAt: loggedAt,
            localDate: localDate,
            mealType: mealType,
            foodId: foodId,
            foodLocalId: foodLocalId,
            foodName: foodName,
            foodImage: foodImage,
            amountG: amountG,
            servingLabel: servingLabel,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbs: carbs,
            sugar: sugar,
            saturatedFat: saturatedFat,
            salt: salt,
            fiber: fiber,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required DateTime loggedAt,
            required String localDate,
            required String mealType,
            Value<String?> foodId = const Value.absent(),
            Value<String?> foodLocalId = const Value.absent(),
            required String foodName,
            Value<String?> foodImage = const Value.absent(),
            Value<double> amountG = const Value.absent(),
            Value<String?> servingLabel = const Value.absent(),
            Value<double> kcal = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double?> sugar = const Value.absent(),
            Value<double?> saturatedFat = const Value.absent(),
            Value<double?> salt = const Value.absent(),
            Value<double?> fiber = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiaryRowsCompanion.insert(
            id: id,
            userId: userId,
            loggedAt: loggedAt,
            localDate: localDate,
            mealType: mealType,
            foodId: foodId,
            foodLocalId: foodLocalId,
            foodName: foodName,
            foodImage: foodImage,
            amountG: amountG,
            servingLabel: servingLabel,
            kcal: kcal,
            protein: protein,
            fat: fat,
            carbs: carbs,
            sugar: sugar,
            saturatedFat: saturatedFat,
            salt: salt,
            fiber: fiber,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiaryRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiaryRowsTable,
    DiaryRow,
    $$DiaryRowsTableFilterComposer,
    $$DiaryRowsTableOrderingComposer,
    $$DiaryRowsTableAnnotationComposer,
    $$DiaryRowsTableCreateCompanionBuilder,
    $$DiaryRowsTableUpdateCompanionBuilder,
    (DiaryRow, BaseReferences<_$AppDatabase, $DiaryRowsTable, DiaryRow>),
    DiaryRow,
    PrefetchHooks Function()>;
typedef $$WorkoutRowsTableCreateCompanionBuilder = WorkoutRowsCompanion
    Function({
  required String id,
  required String userId,
  required String kind,
  Value<String> title,
  Value<DateTime?> scheduledAt,
  Value<DateTime?> completedAt,
  Value<int?> durationMinutes,
  Value<double?> calories,
  Value<String?> difficulty,
  Value<String> payloadJson,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$WorkoutRowsTableUpdateCompanionBuilder = WorkoutRowsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> kind,
  Value<String> title,
  Value<DateTime?> scheduledAt,
  Value<DateTime?> completedAt,
  Value<int?> durationMinutes,
  Value<double?> calories,
  Value<String?> difficulty,
  Value<String> payloadJson,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$WorkoutRowsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutRowsTable> {
  $$WorkoutRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$WorkoutRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutRowsTable> {
  $$WorkoutRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutRowsTable> {
  $$WorkoutRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$WorkoutRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutRowsTable,
    WorkoutRow,
    $$WorkoutRowsTableFilterComposer,
    $$WorkoutRowsTableOrderingComposer,
    $$WorkoutRowsTableAnnotationComposer,
    $$WorkoutRowsTableCreateCompanionBuilder,
    $$WorkoutRowsTableUpdateCompanionBuilder,
    (WorkoutRow, BaseReferences<_$AppDatabase, $WorkoutRowsTable, WorkoutRow>),
    WorkoutRow,
    PrefetchHooks Function()> {
  $$WorkoutRowsTableTableManager(_$AppDatabase db, $WorkoutRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<double?> calories = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutRowsCompanion(
            id: id,
            userId: userId,
            kind: kind,
            title: title,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            durationMinutes: durationMinutes,
            calories: calories,
            difficulty: difficulty,
            payloadJson: payloadJson,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String kind,
            Value<String> title = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<double?> calories = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorkoutRowsCompanion.insert(
            id: id,
            userId: userId,
            kind: kind,
            title: title,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            durationMinutes: durationMinutes,
            calories: calories,
            difficulty: difficulty,
            payloadJson: payloadJson,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorkoutRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutRowsTable,
    WorkoutRow,
    $$WorkoutRowsTableFilterComposer,
    $$WorkoutRowsTableOrderingComposer,
    $$WorkoutRowsTableAnnotationComposer,
    $$WorkoutRowsTableCreateCompanionBuilder,
    $$WorkoutRowsTableUpdateCompanionBuilder,
    (WorkoutRow, BaseReferences<_$AppDatabase, $WorkoutRowsTable, WorkoutRow>),
    WorkoutRow,
    PrefetchHooks Function()>;
typedef $$SleepRowsTableCreateCompanionBuilder = SleepRowsCompanion Function({
  required String id,
  required String userId,
  required DateTime bedtime,
  required DateTime wakeTime,
  Value<int?> quality,
  Value<String?> note,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$SleepRowsTableUpdateCompanionBuilder = SleepRowsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<DateTime> bedtime,
  Value<DateTime> wakeTime,
  Value<int?> quality,
  Value<String?> note,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$SleepRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepRowsTable> {
  $$SleepRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get bedtime => $composableBuilder(
      column: $table.bedtime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get wakeTime => $composableBuilder(
      column: $table.wakeTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$SleepRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepRowsTable> {
  $$SleepRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get bedtime => $composableBuilder(
      column: $table.bedtime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get wakeTime => $composableBuilder(
      column: $table.wakeTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$SleepRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepRowsTable> {
  $$SleepRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get bedtime =>
      $composableBuilder(column: $table.bedtime, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeTime =>
      $composableBuilder(column: $table.wakeTime, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$SleepRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepRowsTable,
    SleepRow,
    $$SleepRowsTableFilterComposer,
    $$SleepRowsTableOrderingComposer,
    $$SleepRowsTableAnnotationComposer,
    $$SleepRowsTableCreateCompanionBuilder,
    $$SleepRowsTableUpdateCompanionBuilder,
    (SleepRow, BaseReferences<_$AppDatabase, $SleepRowsTable, SleepRow>),
    SleepRow,
    PrefetchHooks Function()> {
  $$SleepRowsTableTableManager(_$AppDatabase db, $SleepRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> bedtime = const Value.absent(),
            Value<DateTime> wakeTime = const Value.absent(),
            Value<int?> quality = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepRowsCompanion(
            id: id,
            userId: userId,
            bedtime: bedtime,
            wakeTime: wakeTime,
            quality: quality,
            note: note,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required DateTime bedtime,
            required DateTime wakeTime,
            Value<int?> quality = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepRowsCompanion.insert(
            id: id,
            userId: userId,
            bedtime: bedtime,
            wakeTime: wakeTime,
            quality: quality,
            note: note,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SleepRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SleepRowsTable,
    SleepRow,
    $$SleepRowsTableFilterComposer,
    $$SleepRowsTableOrderingComposer,
    $$SleepRowsTableAnnotationComposer,
    $$SleepRowsTableCreateCompanionBuilder,
    $$SleepRowsTableUpdateCompanionBuilder,
    (SleepRow, BaseReferences<_$AppDatabase, $SleepRowsTable, SleepRow>),
    SleepRow,
    PrefetchHooks Function()>;
typedef $$ProfileRowsTableCreateCompanionBuilder = ProfileRowsCompanion
    Function({
  required String userId,
  Value<String?> firstName,
  Value<String?> gender,
  Value<DateTime?> birthDate,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String> activityLevel,
  Value<String?> goal,
  Value<double?> calorieGoal,
  Value<double?> proteinGoal,
  Value<double?> fatGoal,
  Value<double?> carbsGoal,
  Value<int?> waterGoalMl,
  Value<bool> manualGoals,
  required DateTime updatedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});
typedef $$ProfileRowsTableUpdateCompanionBuilder = ProfileRowsCompanion
    Function({
  Value<String> userId,
  Value<String?> firstName,
  Value<String?> gender,
  Value<DateTime?> birthDate,
  Value<double?> heightCm,
  Value<double?> weightKg,
  Value<String> activityLevel,
  Value<String?> goal,
  Value<double?> calorieGoal,
  Value<double?> proteinGoal,
  Value<double?> fatGoal,
  Value<double?> carbsGoal,
  Value<int?> waterGoalMl,
  Value<bool> manualGoals,
  Value<DateTime> updatedAt,
  Value<bool> isDirty,
  Value<int> rowid,
});

class $$ProfileRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsGoal => $composableBuilder(
      column: $table.carbsGoal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get waterGoalMl => $composableBuilder(
      column: $table.waterGoalMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get manualGoals => $composableBuilder(
      column: $table.manualGoals, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));
}

class $$ProfileRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goal => $composableBuilder(
      column: $table.goal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatGoal => $composableBuilder(
      column: $table.fatGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsGoal => $composableBuilder(
      column: $table.carbsGoal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get waterGoalMl => $composableBuilder(
      column: $table.waterGoalMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get manualGoals => $composableBuilder(
      column: $table.manualGoals, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));
}

class $$ProfileRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileRowsTable> {
  $$ProfileRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
      column: $table.activityLevel, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<double> get calorieGoal => $composableBuilder(
      column: $table.calorieGoal, builder: (column) => column);

  GeneratedColumn<double> get proteinGoal => $composableBuilder(
      column: $table.proteinGoal, builder: (column) => column);

  GeneratedColumn<double> get fatGoal =>
      $composableBuilder(column: $table.fatGoal, builder: (column) => column);

  GeneratedColumn<double> get carbsGoal =>
      $composableBuilder(column: $table.carbsGoal, builder: (column) => column);

  GeneratedColumn<int> get waterGoalMl => $composableBuilder(
      column: $table.waterGoalMl, builder: (column) => column);

  GeneratedColumn<bool> get manualGoals => $composableBuilder(
      column: $table.manualGoals, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$ProfileRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfileRowsTable,
    ProfileRow,
    $$ProfileRowsTableFilterComposer,
    $$ProfileRowsTableOrderingComposer,
    $$ProfileRowsTableAnnotationComposer,
    $$ProfileRowsTableCreateCompanionBuilder,
    $$ProfileRowsTableUpdateCompanionBuilder,
    (ProfileRow, BaseReferences<_$AppDatabase, $ProfileRowsTable, ProfileRow>),
    ProfileRow,
    PrefetchHooks Function()> {
  $$ProfileRowsTableTableManager(_$AppDatabase db, $ProfileRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String?> firstName = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String> activityLevel = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<double?> calorieGoal = const Value.absent(),
            Value<double?> proteinGoal = const Value.absent(),
            Value<double?> fatGoal = const Value.absent(),
            Value<double?> carbsGoal = const Value.absent(),
            Value<int?> waterGoalMl = const Value.absent(),
            Value<bool> manualGoals = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfileRowsCompanion(
            userId: userId,
            firstName: firstName,
            gender: gender,
            birthDate: birthDate,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            fatGoal: fatGoal,
            carbsGoal: carbsGoal,
            waterGoalMl: waterGoalMl,
            manualGoals: manualGoals,
            updatedAt: updatedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<String?> firstName = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<String> activityLevel = const Value.absent(),
            Value<String?> goal = const Value.absent(),
            Value<double?> calorieGoal = const Value.absent(),
            Value<double?> proteinGoal = const Value.absent(),
            Value<double?> fatGoal = const Value.absent(),
            Value<double?> carbsGoal = const Value.absent(),
            Value<int?> waterGoalMl = const Value.absent(),
            Value<bool> manualGoals = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> isDirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfileRowsCompanion.insert(
            userId: userId,
            firstName: firstName,
            gender: gender,
            birthDate: birthDate,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal,
            calorieGoal: calorieGoal,
            proteinGoal: proteinGoal,
            fatGoal: fatGoal,
            carbsGoal: carbsGoal,
            waterGoalMl: waterGoalMl,
            manualGoals: manualGoals,
            updatedAt: updatedAt,
            isDirty: isDirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProfileRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfileRowsTable,
    ProfileRow,
    $$ProfileRowsTableFilterComposer,
    $$ProfileRowsTableOrderingComposer,
    $$ProfileRowsTableAnnotationComposer,
    $$ProfileRowsTableCreateCompanionBuilder,
    $$ProfileRowsTableUpdateCompanionBuilder,
    (ProfileRow, BaseReferences<_$AppDatabase, $ProfileRowsTable, ProfileRow>),
    ProfileRow,
    PrefetchHooks Function()>;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    MetaRow,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()> {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    MetaRow,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (MetaRow, BaseReferences<_$AppDatabase, $SyncMetaTable, MetaRow>),
    MetaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedFoodsTableTableManager get cachedFoods =>
      $$CachedFoodsTableTableManager(_db, _db.cachedFoods);
  $$DiaryRowsTableTableManager get diaryRows =>
      $$DiaryRowsTableTableManager(_db, _db.diaryRows);
  $$WorkoutRowsTableTableManager get workoutRows =>
      $$WorkoutRowsTableTableManager(_db, _db.workoutRows);
  $$SleepRowsTableTableManager get sleepRows =>
      $$SleepRowsTableTableManager(_db, _db.sleepRows);
  $$ProfileRowsTableTableManager get profileRows =>
      $$ProfileRowsTableTableManager(_db, _db.profileRows);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
