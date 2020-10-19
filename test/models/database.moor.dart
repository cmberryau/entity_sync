// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class TestMoorEntity extends DataClass implements Insertable<TestMoorEntity> {
  final bool shouldSync;
  final String remote_uuid;
  final int id;
  final String name;
  final DateTime created;
  TestMoorEntity(
      {@required this.shouldSync,
      this.remote_uuid,
      @required this.id,
      @required this.name,
      @required this.created});
  factory TestMoorEntity.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final boolType = db.typeSystem.forDartType<bool>();
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return TestMoorEntity(
      shouldSync: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}should_sync']),
      remote_uuid: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}remote_uuid']),
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      created: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || shouldSync != null) {
      map['should_sync'] = Variable<bool>(shouldSync);
    }
    if (!nullToAbsent || remote_uuid != null) {
      map['remote_uuid'] = Variable<String>(remote_uuid);
    }
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    return map;
  }

  TestMoorEntitiesCompanion toCompanion(bool nullToAbsent) {
    return TestMoorEntitiesCompanion(
      shouldSync: shouldSync == null && nullToAbsent
          ? const Value.absent()
          : Value(shouldSync),
      remote_uuid: remote_uuid == null && nullToAbsent
          ? const Value.absent()
          : Value(remote_uuid),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
    );
  }

  factory TestMoorEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return TestMoorEntity(
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
      remote_uuid: serializer.fromJson<String>(json['remote_uuid']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shouldSync': serializer.toJson<bool>(shouldSync),
      'remote_uuid': serializer.toJson<String>(remote_uuid),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  TestMoorEntity copyWith(
          {bool shouldSync,
          String remote_uuid,
          int id,
          String name,
          DateTime created}) =>
      TestMoorEntity(
        shouldSync: shouldSync ?? this.shouldSync,
        remote_uuid: remote_uuid ?? this.remote_uuid,
        id: id ?? this.id,
        name: name ?? this.name,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('TestMoorEntity(')
          ..write('shouldSync: $shouldSync, ')
          ..write('remote_uuid: $remote_uuid, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      shouldSync.hashCode,
      $mrjc(remote_uuid.hashCode,
          $mrjc(id.hashCode, $mrjc(name.hashCode, created.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is TestMoorEntity &&
          other.shouldSync == this.shouldSync &&
          other.remote_uuid == this.remote_uuid &&
          other.id == this.id &&
          other.name == this.name &&
          other.created == this.created);
}

class TestMoorEntitiesCompanion extends UpdateCompanion<TestMoorEntity> {
  final Value<bool> shouldSync;
  final Value<String> remote_uuid;
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> created;
  const TestMoorEntitiesCompanion({
    this.shouldSync = const Value.absent(),
    this.remote_uuid = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.created = const Value.absent(),
  });
  TestMoorEntitiesCompanion.insert({
    this.shouldSync = const Value.absent(),
    this.remote_uuid = const Value.absent(),
    this.id = const Value.absent(),
    @required String name,
    @required DateTime created,
  })  : name = Value(name),
        created = Value(created);
  static Insertable<TestMoorEntity> custom({
    Expression<bool> shouldSync,
    Expression<String> remote_uuid,
    Expression<int> id,
    Expression<String> name,
    Expression<DateTime> created,
  }) {
    return RawValuesInsertable({
      if (shouldSync != null) 'should_sync': shouldSync,
      if (remote_uuid != null) 'remote_uuid': remote_uuid,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (created != null) 'created': created,
    });
  }

  TestMoorEntitiesCompanion copyWith(
      {Value<bool> shouldSync,
      Value<String> remote_uuid,
      Value<int> id,
      Value<String> name,
      Value<DateTime> created}) {
    return TestMoorEntitiesCompanion(
      shouldSync: shouldSync ?? this.shouldSync,
      remote_uuid: remote_uuid ?? this.remote_uuid,
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
    if (remote_uuid.present) {
      map['remote_uuid'] = Variable<String>(remote_uuid.value);
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
          ..write('remote_uuid: $remote_uuid, ')
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
  final String _alias;
  $TestMoorEntitiesTable(this._db, [this._alias]);
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

  final VerificationMeta _remote_uuidMeta =
      const VerificationMeta('remote_uuid');
  GeneratedTextColumn _remote_uuid;
  @override
  GeneratedTextColumn get remote_uuid =>
      _remote_uuid ??= _constructRemoteUuid();
  GeneratedTextColumn _constructRemoteUuid() {
    return GeneratedTextColumn('remote_uuid', $tableName, true,
        minTextLength: 36, maxTextLength: 36);
  }

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

  @override
  List<GeneratedColumn> get $columns =>
      [shouldSync, remote_uuid, id, name, created];
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
              data['should_sync'], _shouldSyncMeta));
    }
    if (data.containsKey('remote_uuid')) {
      context.handle(
          _remote_uuidMeta,
          remote_uuid.isAcceptableOrUnknown(
              data['remote_uuid'], _remote_uuidMeta));
    }
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
