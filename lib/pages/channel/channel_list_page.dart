import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/channel_provider.dart';
import 'channel_details_page.dart';
import 'create_channel_page.dart';

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({super.key});

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ChannelProvider>().fetchChannels();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<ChannelProvider>();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Live Channels"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateChannelPage(),
                ),
              );
            },
          )
        ],
      ),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())

          : provider.error != null
              ? Center(child: Text(provider.error!))

              : ListView.builder(
                  itemCount: provider.channels.length,
                  itemBuilder: (context, index) {

                    final channel = provider.channels[index];

                    return Card(
                      margin: const EdgeInsets.all(12),

                      child: ListTile(

                        title: Text(channel.name),

                        subtitle: Text(channel.status),

                        trailing: const Icon(Icons.arrow_forward),

                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChannelDetailsPage(channel: channel),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}