part of 'moor.dart';

class MoorLimitOffsetPaginator extends Paginator {
  /// The limit per each pagination
  final int limit;

  /// The moor table that we are paginating with
  final SyncableTable table;

  /// The moor database that we are syncing with
  final GeneratedDatabase database;

  MoorLimitOffsetPaginator(
      {@required this.limit, @required this.table, @required this.database})
      : assert(limit != null),
        assert(table != null),
        assert(database != null);

  @override
  Future<String> params() async {
    final offset = await getOffset();

    return 'offset=$offset&limit=$limit';
  }

  Future<int> getOffset() async {
    return (await (database.select(table.actualTable())).get()).length;
  }
}
