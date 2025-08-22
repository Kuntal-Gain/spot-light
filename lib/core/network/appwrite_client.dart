import 'package:appwrite/appwrite.dart';

class AppwriteClient {
  late final Client client;
  late final Account account;
  late final Databases database;
  late final Realtime realtime;

  AppwriteClient() {
    client = Client()
      ..setEndpoint(
          'https://nyc.cloud.appwrite.io/v1') // your Appwrite endpoint
      ..setProject('spot-time') // your actual project ID
      ..setSelfSigned(status: true); // only if local dev OR self-signed certs

    account = Account(client);
    database = Databases(client);
    realtime = Realtime(client);
  }
}
