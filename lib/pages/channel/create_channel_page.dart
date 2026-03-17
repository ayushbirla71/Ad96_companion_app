import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/channel_provider.dart';

class CreateChannelPage extends StatefulWidget {
  const CreateChannelPage({super.key});

  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage> {
  final TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  Future<void> createChannel() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    loading = true;
  });

  try {
    await context
        .read<ChannelProvider>()
        .createChannel(nameController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Channel created successfully")),
    );

    Navigator.pop(context);

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ),
    );
  }

  if (mounted) {
    setState(() {
      loading = false;
    });
  }
}
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Channel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// CHANNEL NAME FIELD
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Channel Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Channel name is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// CREATE BUTTON
              SizedBox(
                width: double.infinity,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: createChannel,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Create Channel"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}