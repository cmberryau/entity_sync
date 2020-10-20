abstract class Paginator {
  // Returns the URL parameters
  Future<String> params();

  // Moves the paginator to the next page
  void next();
  // Moves the paginator to the previous page
  void prev();
  // Resets the paginator
  void reset();
  // Clones the paginator
  Paginator clone();
}

class RestfulApiEndpointPaginator extends Paginator{
  int pageSize;
  int page = 0;

  RestfulApiEndpointPaginator(this.pageSize);

  Future<String> params() async {
    return 'offset=$page&limit=$pageSize';
  }

  void next() {
    page++;
  }

  void prev() {
    page--;
  }

  void reset() {
    page = 0;
  }

  RestfulApiEndpointPaginator clone() {
    return RestfulApiEndpointPaginator(pageSize);
  }
}
