import 'package:moor/moor.dart';

import 'related_entities.dart';
import 'test_entities.dart';

part 'database.moor.dart';

@UseMoor(tables: [
  TestMoorEntities,
  FirstRelatedEntities,
  SecondRelatedEntities,
])
class TestDatabase extends _$TestDatabase {
  TestDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<TestMoorEntity>> getTestMoorEntities() async {
    return select(testMoorEntities).get();
  }
}
