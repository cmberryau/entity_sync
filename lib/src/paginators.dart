import 'package:meta/meta.dart';

abstract class Paginator {
  String _params();
}

class LimitOffsetPagination extends Paginator {
  final int limit;

  LimitOffsetPagination({@required this.limit}) : assert(limit != null);

  @override
  String _params() {
    final offset = getOffset();

    return 'limit=$limit&offset=$offset';
  }

  int getOffset() {
    throw UnimplementedError();
  }

  int setOffset() {
    throw UnimplementedError();
  }
}
