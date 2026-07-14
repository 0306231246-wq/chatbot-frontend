part of 'chat_message_list.dart';

String _formatPrice(num value) {
  return value
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
