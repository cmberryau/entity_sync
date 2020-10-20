abstract class Paginator {
  // The page size of the paginator
  int get pageSize;

  // Returns the URL parameters
  String params();
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
  int _pageSize;
  int page = 0;

  @override
  int get pageSize {
    return _pageSize;
  }

  RestfulApiEndpointPaginator(this._pageSize);

  @override
  String params() {
    return 'offset=${page * pageSize}&limit=$pageSize';
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
