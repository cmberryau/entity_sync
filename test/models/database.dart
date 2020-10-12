import 'package:moor/moor.dart';
import 'test_entities.dart';

part 'database.g.dart';

@UseMoor(tables: [TestMoorEntities])
class TestDatabase extends _$TestDatabase {
  TestDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<TestMoorEntity>> getTestMoorEntities() async {
    return select(testMoorEntities).get();
  }
}
