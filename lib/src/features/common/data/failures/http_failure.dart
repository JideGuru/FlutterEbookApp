enum HttpFailure {
  notFound('404 not found'),
  unknown('Unknown error');

  final String description;
  const HttpFailure(this.description);
}
