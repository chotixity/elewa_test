import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  //Mail details for use to send emails, env had a challenge with wasm so you can add yours to send email notifications
  final String username = '';
  final String password = '';

  //Sending emails
  Future<void> sendTaskNotification(
      String recipientEmail, String subject, String body) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your App Name')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
