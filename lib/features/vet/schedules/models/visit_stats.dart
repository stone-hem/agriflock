class VisitStats {
  final int pending;
  final int inProgress;
  final int completed;
  final int accepted;
  final int declined;
  final int cancelled;
  final int total;

  VisitStats({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.accepted,
    required this.declined,
    required this.cancelled,
    required this.total,
  });

  factory VisitStats.fromJson(Map<String, dynamic> json) {
    return VisitStats(
      pending: json['pending'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      accepted: json['accepted'] as int? ?? 0,
      declined: json['declined'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'in_progress': inProgress,
      'completed': completed,
      'accepted': accepted,
      'declined': declined,
      'cancelled': cancelled,
      'total': total,
    };
  }

  // Helper method to get count for a specific status
  int getCountForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pending;
      case 'in_progress':
      case 'in progress':
        return inProgress;
      case 'completed':
        return completed;
      case 'accepted':
        return accepted;
      case 'declined':
        return declined;
      case 'cancelled':
        return cancelled;
      default:
        return 0;
    }
  }

  // Check if there are any visits for a specific status
  bool hasStatus(String status) {
    return getCountForStatus(status) > 0;
  }

  // Get percentage for a specific status
  double getPercentageForStatus(String status) {
    if (total == 0) return 0.0;
    return (getCountForStatus(status) / total) * 100;
  }

  // Get all statuses with their counts
  Map<String, int> getAllStatusCounts() {
    return {
      'pending': pending,
      'in_progress': inProgress,
      'completed': completed,
      'accepted': accepted,
      'declined': declined,
      'cancelled': cancelled,
    };
  }
}