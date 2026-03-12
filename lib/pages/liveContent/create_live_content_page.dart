import 'package:flutter/material.dart';
import '../../services/live_content_service.dart';

class CreateLiveContentPage extends StatefulWidget {
  const CreateLiveContentPage({super.key});

  @override
  State<CreateLiveContentPage> createState() => _CreateLiveContentPageState();
}

class _CreateLiveContentPageState extends State<CreateLiveContentPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  String type = "provider";
  String status = "active";

  bool loading = false;

  Future<void> createContent() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {

      await LiveContentService().createLiveContent(
        name: nameController.text,
        url: urlController.text,
        duration: int.parse(durationController.text),
        type: type,
        status: status,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Live content created")),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );

    } finally {

      setState(() {
        loading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Live Content"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// NAME
              TextFormField(

                controller: nameController,

                decoration: const InputDecoration(
                  labelText: "Content Name",
                  border: OutlineInputBorder(),
                ),

                validator: (v) =>
                    v == null || v.isEmpty ? "Enter content name" : null,
              ),

              const SizedBox(height: 16),

              /// URL
              TextFormField(

                controller: urlController,

                decoration: const InputDecoration(
                  labelText: "Stream URL",
                  border: OutlineInputBorder(),
                ),

                validator: (v) =>
                    v == null || v.isEmpty ? "Enter stream URL" : null,
              ),

              const SizedBox(height: 16),

              /// DURATION
              TextFormField(

                controller: durationController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Duration (seconds)",
                  border: OutlineInputBorder(),
                ),

                validator: (v) =>
                    v == null || v.isEmpty ? "Enter duration" : null,
              ),

              const SizedBox(height: 16),

              /// TYPE
              DropdownButtonFormField<String>(

                value: type,

                decoration: const InputDecoration(
                  labelText: "Content Type",
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: "provider",
                    child: Text("Provider"),
                  ),
                  DropdownMenuItem(
                    value: "streaming",
                    child: Text("Streaming"),
                  ),
                  DropdownMenuItem(
                    value: "website",
                    child: Text("Website"),
                  ),
                ],

                onChanged: (v) {
                  setState(() {
                    type = v!;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// STATUS
              DropdownButtonFormField<String>(

                value: status,

                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: "active",
                    child: Text("Active"),
                  ),
                  DropdownMenuItem(
                    value: "inactive",
                    child: Text("Inactive"),
                  ),
                ],

                onChanged: (v) {
                  setState(() {
                    status = v!;
                  });
                },
              ),

              const SizedBox(height: 30),

              /// BUTTON
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: loading ? null : createContent,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Live Content"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}