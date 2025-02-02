import 'package:flutter/material.dart';
import 'package:sms_sender/sms_sender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Send SMS Plugin'),
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            controller: phoneNumberController,
            decoration: InputDecoration(label: Text("Phone Number")),
          ),
          TextFormField(
            controller: messageController,
            decoration: InputDecoration(label: Text("Message")),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await SmsSender.checkSms();

                final simCards = await SmsSender.getSimCards();
                print(simCards);
                if (context.mounted) {
                  final simSlot = await showDialog<int>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return SimCardDialog(
                          simCards: simCards,
                        );
                      });

                  print("Sim slot: $simSlot");
                  print("Phone Number: ${phoneNumberController.text}");
                  print("Message: ${messageController.text}");

                  await SmsSender.sendSms(
                    phoneNumberController.text,
                    messageController.text,
                    simSlot: simSlot,
                  );

                  final snackBar = SnackBar(
                    backgroundColor: Colors.green[400],
                    content: Text(
                      "SMS message sent.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
              } on Exception catch (e) {
                String errorMessage = e.toString();

                final snackBar = SnackBar(
                  backgroundColor: Colors.red[400],
                  content: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
            child: Text("Send SMS"),
          ),
        ],
      ),
    );
  }
}

class SimCardDialog extends StatefulWidget {
  const SimCardDialog({
    super.key,
    required this.simCards,
  });

  final List<Map<String, dynamic>> simCards;

  @override
  State<SimCardDialog> createState() => _SimCardDialogState();
}

class _SimCardDialogState extends State<SimCardDialog> {
  int? selectedSimCard;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select SIM"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var sim in widget.simCards) ...[
            RadioListTile<int>(
                title: Text(sim["displayName"]),
                value: sim["simSlotIndex"],
                groupValue: selectedSimCard,
                onChanged: (int? value) {
                  setState(() {
                    selectedSimCard = value ?? 0;
                  });
                }),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(selectedSimCard);
          },
          child: Text("Confirm"),
        ),
      ],
    );
  }
}
