import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {

  final TextEditingController nameController = TextEditingController();

  bool loading = false;

  Future createChannel() async {

    setState(() {
      loading = true;
    });

    final res = await http.post(
      Uri.parse("https://stg-cms.ad96.in/api/streaming/channel"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text
      }),
    );

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Channel"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Channel Name",
              ),
            ),

            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()

                : ElevatedButton(

                    onPressed: createChannel,

                    child: const Text("Create Channel"),
                  )
          ],
        ),
      ),
    );
  }
}