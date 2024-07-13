class Result<T> {
  final T? value;
  final String? error;

  Result({this.value, this.error});

  bool get hasError => error != null;
}

