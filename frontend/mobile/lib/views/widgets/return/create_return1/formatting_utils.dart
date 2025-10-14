class FormattingUtils {
  static String formatTransactionId(int id) {
    return '#$id';
  }

  static String formatStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
