import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';

part 'moor_storage.dart';

/// Responsible for creating proxies
abstract class ProxyFactory<TProxy extends ProxyMixin<TEntity>,
    TEntity extends DataClass> {
  /// Creates a proxy from a moor instance
  TProxy fromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin<TEntity extends DataClass>
    implements
        DataClass,
        Insertable<TEntity>,
        SyncableMixin,
        SerializableMixin {
  @override
  final flagField = BoolField('shouldSync');
}

abstract class SyncableTable extends Table {
  /// Indicates if the entity should be synced
  BoolColumn get shouldSync => boolean().clientDefault(() => true)();

  Column localKeyColumn();
  Column remoteKeyColumn();

  /// The actual table
  Table actualTable();
}
