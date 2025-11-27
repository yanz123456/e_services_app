enum RequestStatus {
  all('All', '/api/requests'),
  pending('Pending', '/api/requests/pending'),
  accepted('Accepted', '/api/requests/accepted'),
  declined('Declined', '/api/requests/declined'),
  paid('Paid', '/api/requests/paid'),
  processed('Processing', '/api/requests/processed'),
  completed('Completed', '/api/requests/completed');

  final String label;
  final String path;
  const RequestStatus(this.label, this.path);

  static RequestStatus fromLabel(String label) {
    return RequestStatus.values.firstWhere(
      (status) => status.label.toLowerCase() == label.toLowerCase(),
      orElse: () => RequestStatus.all,
    );
  }
}
