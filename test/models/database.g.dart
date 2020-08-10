// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class TestMoorEntity extends DataClass implements Insertable<TestMoorEntity> {
  final int id;
  final String name;
  final DateTime created;
  final bool shouldSync;
  TestMoorEntity(
      {@required this.id,
      @required this.name,
      @required this.created,
      @required this.shouldSync});
  factory TestMoorEntity.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return TestMoorEntity(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      created: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created']),
      shouldSync: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}should_sync']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || shouldSync != null) {
      map['should_sync'] = Variable<bool>(shouldSync);
    }
    return map;
  }

  TestMoorEntitiesCompanion toCompanion(bool nullToAbsent) {
    return TestMoorEntitiesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
      shouldSync: shouldSync == null && nullToAbsent
          ? const Value.absent()
          : Value(shouldSync),
    );
  }

  factory TestMoorEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TestMoorEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      created: serializer.fromJson<DateTime>(json['created']),
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'created': serializer.toJson<DateTime>(created),
      'shouldSync': serializer.toJson<bool>(shouldSync),
    };
  }

  TestMoorEntity copyWith(
          {int id, String name, DateTime created, bool shouldSync}) =>
      TestMoorEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        created: created ?? this.created,
        shouldSync: shouldSync ?? this.shouldSync,
      );
  @override
  String toString() {
    return (StringBuffer('TestMoorEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created, ')
          ..write('shouldSync: $shouldSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(name.hashCode, $mrjc(created.hashCode, shouldSync.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is TestMoorEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.created == this.created &&
          other.shouldSync == this.shouldSync);
}

class TestMoorEntitiesCompanion extends UpdateCompanion<TestMoorEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> created;
  final Value<bool> shouldSync;
  const TestMoorEntitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.created = const Value.absent(),
    this.shouldSync = const Value.absent(),
  });
  TestMoorEntitiesCompanion.insert({
    this.id = const Value.absent(),
    @required String name,
    @required DateTime created,
    this.shouldSync = const Value.absent(),
  })  : name = Value(name),
        created = Value(created);
  static Insertable<TestMoorEntity> custom({
    Expression<int> id,
    Expression<String> name,
    Expression<DateTime> created,
    Expression<bool> shouldSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (created != null) 'created': created,
      if (shouldSync != null) 'should_sync': shouldSync,
    });
  }

  TestMoorEntitiesCompanion copyWith(
      {Value<int> id,
      Value<String> name,
      Value<DateTime> created,
      Value<bool> shouldSync}) {
    return TestMoorEntitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      created: created ?? this.created,
      shouldSync: shouldSync ?? this.shouldSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (shouldSync.present) {
      map['should_sync'] = Variable<bool>(shouldSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestMoorEntitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created, ')
          ..write('shouldSync: $shouldSync')
          ..write(')'))
        .toString();
  }
}

class $TestMoorEntitiesTable extends TestMoorEntities
    with TableInfo<$TestMoorEntitiesTable, TestMoorEntity> {
  final GeneratedDatabase _db;
  final String _alias;
  $TestMoorEntitiesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false,
        minTextLength: 3, maxTextLength: 100);
  }

  final VerificationMeta _createdMeta = const VerificationMeta('created');
  GeneratedDateTimeColumn _created;
  @override
  GeneratedDateTimeColumn get created => _created ??= _constructCreated();
  GeneratedDateTimeColumn _constructCreated() {
    return GeneratedDateTimeColumn(
      'created',
      $tableName,
      false,
    );
  }

  final VerificationMeta _shouldSyncMeta = const VerificationMeta('shouldSync');
  GeneratedBoolColumn _shouldSync;
  @override
  GeneratedBoolColumn get shouldSync => _shouldSync ??= _constructShouldSync();
  GeneratedBoolColumn _constructShouldSync() {
    return GeneratedBoolColumn(
      'should_sync',
      $tableName,
      false,
    )..clientDefault = () => true;
  }

  @override
  List<GeneratedColumn> get $columns => [id, name, created, shouldSync];
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created'], _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('should_sync')) {
      context.handle(
          _shouldSyncMeta,
          shouldSync.isAcceptableOrUnknown(
              data['should_sync'], _shouldSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestMoorEntity map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return TestMoorEntity.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $TestMoorEntitiesTable createAlias(String alias) {
    return $TestMoorEntitiesTable(_db, alias);
  }
}

abstract class _$TestDatabase extends GeneratedDatabase {
  _$TestDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $TestMoorEntitiesTable _testMoorEntities;
  $TestMoorEntitiesTable get testMoorEntities =>
      _testMoorEntities ??= $TestMoorEntitiesTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [testMoorEntities];
}
