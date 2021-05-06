// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class TestMoorEntity extends DataClass implements Insertable<TestMoorEntity> {
  /// Indicates if the entity should be synced
  final bool shouldSync;
  final String? uuid;
  final int id;
  final String name;
  final DateTime created;
  TestMoorEntity(
      {required this.shouldSync,
      this.uuid,
      required this.id,
      required this.name,
      required this.created});
  factory TestMoorEntity.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final boolType = db.typeSystem.forDartType<bool>();
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return TestMoorEntity(
      shouldSync: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}should_sync'])!,
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid']),
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      created: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['should_sync'] = Variable<bool>(shouldSync);
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String?>(uuid);
    }
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  TestMoorEntitiesCompanion toCompanion(bool nullToAbsent) {
    return TestMoorEntitiesCompanion(
      shouldSync: Value(shouldSync),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      id: Value(id),
      name: Value(name),
      created: Value(created),
    );
  }

  factory TestMoorEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TestMoorEntity(
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
      uuid: serializer.fromJson<String?>(json['uuid']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shouldSync': serializer.toJson<bool>(shouldSync),
      'uuid': serializer.toJson<String?>(uuid),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  TestMoorEntity copyWith(
          {bool? shouldSync,
          String? uuid,
          int? id,
          String? name,
          DateTime? created}) =>
      TestMoorEntity(
        shouldSync: shouldSync ?? this.shouldSync,
        uuid: uuid ?? this.uuid,
        id: id ?? this.id,
        name: name ?? this.name,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('TestMoorEntity(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      shouldSync.hashCode,
      $mrjc(uuid.hashCode,
          $mrjc(id.hashCode, $mrjc(name.hashCode, created.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is TestMoorEntity &&
          other.shouldSync == this.shouldSync &&
          other.uuid == this.uuid &&
          other.id == this.id &&
          other.name == this.name &&
          other.created == this.created);
}

class TestMoorEntitiesCompanion extends UpdateCompanion<TestMoorEntity> {
  final Value<bool> shouldSync;
  final Value<String?> uuid;
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> created;
  const TestMoorEntitiesCompanion({
    this.shouldSync = const Value.absent(),
    this.uuid = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.created = const Value.absent(),
  });
  TestMoorEntitiesCompanion.insert({
    this.shouldSync = const Value.absent(),
    this.uuid = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    required DateTime created,
  })   : name = Value(name),
        created = Value(created);
  static Insertable<TestMoorEntity> custom({
    Expression<bool>? shouldSync,
    Expression<String?>? uuid,
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (shouldSync != null) 'should_sync': shouldSync,
      if (uuid != null) 'uuid': uuid,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (created != null) 'created': created,
    });
  }

  TestMoorEntitiesCompanion copyWith(
      {Value<bool>? shouldSync,
      Value<String?>? uuid,
      Value<int>? id,
      Value<String>? name,
      Value<DateTime>? created}) {
    return TestMoorEntitiesCompanion(
      shouldSync: shouldSync ?? this.shouldSync,
      uuid: uuid ?? this.uuid,
      id: id ?? this.id,
      name: name ?? this.name,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shouldSync.present) {
      map['should_sync'] = Variable<bool>(shouldSync.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String?>(uuid.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestMoorEntitiesCompanion(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }
}

class $TestMoorEntitiesTable extends TestMoorEntities
    with TableInfo<$TestMoorEntitiesTable, TestMoorEntity> {
  final GeneratedDatabase _db;
  final String? _alias;
  $TestMoorEntitiesTable(this._db, [this._alias]);
  final VerificationMeta _shouldSyncMeta = const VerificationMeta('shouldSync');
  @override
  late final GeneratedBoolColumn shouldSync = _constructShouldSync();
  GeneratedBoolColumn _constructShouldSync() {
    return GeneratedBoolColumn(
      'should_sync',
      $tableName,
      false,
    )..clientDefault = () => true;
  }

  final VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedTextColumn uuid = _constructUuid();
  GeneratedTextColumn _constructUuid() {
    return GeneratedTextColumn('uuid', $tableName, true,
        minTextLength: 36, maxTextLength: 36);
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedIntColumn id = _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false,
        minTextLength: 3, maxTextLength: 100);
  }

  final VerificationMeta _createdMeta = const VerificationMeta('created');
  @override
  late final GeneratedDateTimeColumn created = _constructCreated();
  GeneratedDateTimeColumn _constructCreated() {
    return GeneratedDateTimeColumn(
      'created',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [shouldSync, uuid, id, name, created];
  @override
  $TestMoorEntitiesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'test_moor_entities';
  @override
  final String actualTableName = 'test_moor_entities';
  @override
  VerificationContext validateIntegrity(Insertable<TestMoorEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('should_sync')) {
      context.handle(
          _shouldSyncMeta,
          shouldSync.isAcceptableOrUnknown(
              data['should_sync']!, _shouldSyncMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestMoorEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return TestMoorEntity.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $TestMoorEntitiesTable createAlias(String alias) {
    return $TestMoorEntitiesTable(_db, alias);
  }
}

class FirstRelatedEntity extends DataClass
    implements Insertable<FirstRelatedEntity> {
  /// Indicates if the entity should be synced
  final bool shouldSync;
  final String uuid;
  final int id;
  final String relatedEntity;
  FirstRelatedEntity(
      {required this.shouldSync,
      required this.uuid,
      required this.id,
      required this.relatedEntity});
  factory FirstRelatedEntity.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final boolType = db.typeSystem.forDartType<bool>();
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return FirstRelatedEntity(
      shouldSync: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}should_sync'])!,
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid'])!,
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      relatedEntity: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}related_entity'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['should_sync'] = Variable<bool>(shouldSync);
    map['uuid'] = Variable<String>(uuid);
    map['id'] = Variable<int>(id);
    map['related_entity'] = Variable<String>(relatedEntity);
    return map;
  }

  FirstRelatedEntitiesCompanion toCompanion(bool nullToAbsent) {
    return FirstRelatedEntitiesCompanion(
      shouldSync: Value(shouldSync),
      uuid: Value(uuid),
      id: Value(id),
      relatedEntity: Value(relatedEntity),
    );
  }

  factory FirstRelatedEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return FirstRelatedEntity(
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
      uuid: serializer.fromJson<String>(json['uuid']),
      id: serializer.fromJson<int>(json['id']),
      relatedEntity: serializer.fromJson<String>(json['relatedEntity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shouldSync': serializer.toJson<bool>(shouldSync),
      'uuid': serializer.toJson<String>(uuid),
      'id': serializer.toJson<int>(id),
      'relatedEntity': serializer.toJson<String>(relatedEntity),
    };
  }

  FirstRelatedEntity copyWith(
          {bool? shouldSync, String? uuid, int? id, String? relatedEntity}) =>
      FirstRelatedEntity(
        shouldSync: shouldSync ?? this.shouldSync,
        uuid: uuid ?? this.uuid,
        id: id ?? this.id,
        relatedEntity: relatedEntity ?? this.relatedEntity,
      );
  @override
  String toString() {
    return (StringBuffer('FirstRelatedEntity(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id, ')
          ..write('relatedEntity: $relatedEntity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(shouldSync.hashCode,
      $mrjc(uuid.hashCode, $mrjc(id.hashCode, relatedEntity.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is FirstRelatedEntity &&
          other.shouldSync == this.shouldSync &&
          other.uuid == this.uuid &&
          other.id == this.id &&
          other.relatedEntity == this.relatedEntity);
}

class FirstRelatedEntitiesCompanion
    extends UpdateCompanion<FirstRelatedEntity> {
  final Value<bool> shouldSync;
  final Value<String> uuid;
  final Value<int> id;
  final Value<String> relatedEntity;
  const FirstRelatedEntitiesCompanion({
    this.shouldSync = const Value.absent(),
    this.uuid = const Value.absent(),
    this.id = const Value.absent(),
    this.relatedEntity = const Value.absent(),
  });
  FirstRelatedEntitiesCompanion.insert({
    this.shouldSync = const Value.absent(),
    required String uuid,
    this.id = const Value.absent(),
    required String relatedEntity,
  })   : uuid = Value(uuid),
        relatedEntity = Value(relatedEntity);
  static Insertable<FirstRelatedEntity> custom({
    Expression<bool>? shouldSync,
    Expression<String>? uuid,
    Expression<int>? id,
    Expression<String>? relatedEntity,
  }) {
    return RawValuesInsertable({
      if (shouldSync != null) 'should_sync': shouldSync,
      if (uuid != null) 'uuid': uuid,
      if (id != null) 'id': id,
      if (relatedEntity != null) 'related_entity': relatedEntity,
    });
  }

  FirstRelatedEntitiesCompanion copyWith(
      {Value<bool>? shouldSync,
      Value<String>? uuid,
      Value<int>? id,
      Value<String>? relatedEntity}) {
    return FirstRelatedEntitiesCompanion(
      shouldSync: shouldSync ?? this.shouldSync,
      uuid: uuid ?? this.uuid,
      id: id ?? this.id,
      relatedEntity: relatedEntity ?? this.relatedEntity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shouldSync.present) {
      map['should_sync'] = Variable<bool>(shouldSync.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (relatedEntity.present) {
      map['related_entity'] = Variable<String>(relatedEntity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FirstRelatedEntitiesCompanion(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id, ')
          ..write('relatedEntity: $relatedEntity')
          ..write(')'))
        .toString();
  }
}

class $FirstRelatedEntitiesTable extends FirstRelatedEntities
    with TableInfo<$FirstRelatedEntitiesTable, FirstRelatedEntity> {
  final GeneratedDatabase _db;
  final String? _alias;
  $FirstRelatedEntitiesTable(this._db, [this._alias]);
  final VerificationMeta _shouldSyncMeta = const VerificationMeta('shouldSync');
  @override
  late final GeneratedBoolColumn shouldSync = _constructShouldSync();
  GeneratedBoolColumn _constructShouldSync() {
    return GeneratedBoolColumn(
      'should_sync',
      $tableName,
      false,
    )..clientDefault = () => true;
  }

  final VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedTextColumn uuid = _constructUuid();
  GeneratedTextColumn _constructUuid() {
    return GeneratedTextColumn(
      'uuid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedIntColumn id = _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _relatedEntityMeta =
      const VerificationMeta('relatedEntity');
  @override
  late final GeneratedTextColumn relatedEntity = _constructRelatedEntity();
  GeneratedTextColumn _constructRelatedEntity() {
    return GeneratedTextColumn(
      'related_entity',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [shouldSync, uuid, id, relatedEntity];
  @override
  $FirstRelatedEntitiesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'first_related_entities';
  @override
  final String actualTableName = 'first_related_entities';
  @override
  VerificationContext validateIntegrity(Insertable<FirstRelatedEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('should_sync')) {
      context.handle(
          _shouldSyncMeta,
          shouldSync.isAcceptableOrUnknown(
              data['should_sync']!, _shouldSyncMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('related_entity')) {
      context.handle(
          _relatedEntityMeta,
          relatedEntity.isAcceptableOrUnknown(
              data['related_entity']!, _relatedEntityMeta));
    } else if (isInserting) {
      context.missing(_relatedEntityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FirstRelatedEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return FirstRelatedEntity.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $FirstRelatedEntitiesTable createAlias(String alias) {
    return $FirstRelatedEntitiesTable(_db, alias);
  }
}

class SecondRelatedEntity extends DataClass
    implements Insertable<SecondRelatedEntity> {
  /// Indicates if the entity should be synced
  final bool shouldSync;
  final String uuid;
  final int id;
  SecondRelatedEntity(
      {required this.shouldSync, required this.uuid, required this.id});
  factory SecondRelatedEntity.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final boolType = db.typeSystem.forDartType<bool>();
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return SecondRelatedEntity(
      shouldSync: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}should_sync'])!,
      uuid: stringType.mapFromDatabaseResponse(data['${effectivePrefix}uuid'])!,
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['should_sync'] = Variable<bool>(shouldSync);
    map['uuid'] = Variable<String>(uuid);
    map['id'] = Variable<int>(id);
    return map;
  }

  SecondRelatedEntitiesCompanion toCompanion(bool nullToAbsent) {
    return SecondRelatedEntitiesCompanion(
      shouldSync: Value(shouldSync),
      uuid: Value(uuid),
      id: Value(id),
    );
  }

  factory SecondRelatedEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return SecondRelatedEntity(
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
      uuid: serializer.fromJson<String>(json['uuid']),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shouldSync': serializer.toJson<bool>(shouldSync),
      'uuid': serializer.toJson<String>(uuid),
      'id': serializer.toJson<int>(id),
    };
  }

  SecondRelatedEntity copyWith({bool? shouldSync, String? uuid, int? id}) =>
      SecondRelatedEntity(
        shouldSync: shouldSync ?? this.shouldSync,
        uuid: uuid ?? this.uuid,
        id: id ?? this.id,
      );
  @override
  String toString() {
    return (StringBuffer('SecondRelatedEntity(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(shouldSync.hashCode, $mrjc(uuid.hashCode, id.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is SecondRelatedEntity &&
          other.shouldSync == this.shouldSync &&
          other.uuid == this.uuid &&
          other.id == this.id);
}

class SecondRelatedEntitiesCompanion
    extends UpdateCompanion<SecondRelatedEntity> {
  final Value<bool> shouldSync;
  final Value<String> uuid;
  final Value<int> id;
  const SecondRelatedEntitiesCompanion({
    this.shouldSync = const Value.absent(),
    this.uuid = const Value.absent(),
    this.id = const Value.absent(),
  });
  SecondRelatedEntitiesCompanion.insert({
    this.shouldSync = const Value.absent(),
    required String uuid,
    this.id = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<SecondRelatedEntity> custom({
    Expression<bool>? shouldSync,
    Expression<String>? uuid,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (shouldSync != null) 'should_sync': shouldSync,
      if (uuid != null) 'uuid': uuid,
      if (id != null) 'id': id,
    });
  }

  SecondRelatedEntitiesCompanion copyWith(
      {Value<bool>? shouldSync, Value<String>? uuid, Value<int>? id}) {
    return SecondRelatedEntitiesCompanion(
      shouldSync: shouldSync ?? this.shouldSync,
      uuid: uuid ?? this.uuid,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shouldSync.present) {
      map['should_sync'] = Variable<bool>(shouldSync.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SecondRelatedEntitiesCompanion(')
          ..write('shouldSync: $shouldSync, ')
          ..write('uuid: $uuid, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $SecondRelatedEntitiesTable extends SecondRelatedEntities
    with TableInfo<$SecondRelatedEntitiesTable, SecondRelatedEntity> {
  final GeneratedDatabase _db;
  final String? _alias;
  $SecondRelatedEntitiesTable(this._db, [this._alias]);
  final VerificationMeta _shouldSyncMeta = const VerificationMeta('shouldSync');
  @override
  late final GeneratedBoolColumn shouldSync = _constructShouldSync();
  GeneratedBoolColumn _constructShouldSync() {
    return GeneratedBoolColumn(
      'should_sync',
      $tableName,
      false,
    )..clientDefault = () => true;
  }

  final VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedTextColumn uuid = _constructUuid();
  GeneratedTextColumn _constructUuid() {
    return GeneratedTextColumn(
      'uuid',
      $tableName,
      false,
    );
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedIntColumn id = _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  @override
  List<GeneratedColumn> get $columns => [shouldSync, uuid, id];
  @override
  $SecondRelatedEntitiesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'second_related_entities';
  @override
  final String actualTableName = 'second_related_entities';
  @override
  VerificationContext validateIntegrity(
      Insertable<SecondRelatedEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('should_sync')) {
      context.handle(
          _shouldSyncMeta,
          shouldSync.isAcceptableOrUnknown(
              data['should_sync']!, _shouldSyncMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SecondRelatedEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return SecondRelatedEntity.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $SecondRelatedEntitiesTable createAlias(String alias) {
    return $SecondRelatedEntitiesTable(_db, alias);
  }
}

abstract class _$TestDatabase extends GeneratedDatabase {
  _$TestDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $TestMoorEntitiesTable testMoorEntities =
      $TestMoorEntitiesTable(this);
  late final $FirstRelatedEntitiesTable firstRelatedEntities =
      $FirstRelatedEntitiesTable(this);
  late final $SecondRelatedEntitiesTable secondRelatedEntities =
      $SecondRelatedEntitiesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [testMoorEntities, firstRelatedEntities, secondRelatedEntities];
}
