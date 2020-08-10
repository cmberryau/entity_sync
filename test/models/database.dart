import 'package:moor/moor.dart';
import 'test_entities.dart';

part 'database.g.dart';

@UseMoor(tables: [TestMoorEntities])
class TestDatabase {

}