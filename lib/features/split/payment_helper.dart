import 'package:intl/intl.dart';

class PaymentHelper {
  static String settlementMessage({
    required String fromName,
    required String toName,
    required double amount,
    String? note,
  }) {
    final String formatted = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(amount);
    final String extra = (note == null || note.isEmpty) ? '' : ' - $note';
    return 'Pembayaran Split Bill: $fromName ➜ $toName sebesar $formatted$extra';
  }

  // Stub deep-link to an e-wallet app (examples: ovo://, dana://, linkaja://)
  // In real integration, construct URIs per provider docs.
  static Uri buildStubEwalletUri({
    required String provider, // 'ovo' | 'dana' | 'linkaja'
    required String toName,
    required double amount,
    String? note,
  }) {
    final String amt = amount.toStringAsFixed(2);
    final String n = note == null ? '' : Uri.encodeComponent(note);
    final String name = Uri.encodeComponent(toName);
    return Uri.parse('$provider://pay?name=$name&amount=$amt&note=$n');
  }
}


