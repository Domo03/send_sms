import 'package:flutter_test/flutter_test.dart';
import 'package:sms_sender/sms_sender.dart';
import 'package:sms_sender/sms_sender_platform_interface.dart';
import 'package:sms_sender/sms_sender_method_channel.dart';

void main() {
  final SmsSenderPlatform initialPlatform = SmsSenderPlatform.instance;

  test('$MethodChannelSmsSender is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmsSender>());
  });

  test('sendSms', () async {
    expect(await SmsSender.sendSms("09999999999", "Test"), true);
  });
}
