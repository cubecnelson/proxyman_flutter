import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing proxy functionality...');

  // Test HTTP request through proxy
  try {
    final client = HttpClient();
    client.findProxy = (uri) {
      return 'PROXY 127.0.0.1:8080';
    };

    final request = await client.getUrl(Uri.parse('http://httpbin.org/get'));
    final response = await request.close();

    print('✅ HTTP request successful!');
    print('Status: ${response.statusCode}');

    final body = await response.transform(utf8.decoder).join();
    print('Response length: ${body.length} characters');
  } catch (e) {
    print('❌ HTTP request failed: $e');
  }

  // Test HTTPS request through proxy
  try {
    final client = HttpClient();
    client.findProxy = (uri) {
      return 'PROXY 127.0.0.1:8080';
    };

    final request = await client.getUrl(Uri.parse('https://httpbin.org/get'));
    final response = await request.close();

    print('✅ HTTPS request successful!');
    print('Status: ${response.statusCode}');

    final body = await response.transform(utf8.decoder).join();
    print('Response length: ${body.length} characters');
  } catch (e) {
    print('❌ HTTPS request failed: $e');
  }

  print('\nTest completed!');
  print(
      'Check your Flutter app to see if the requests appear in the transaction list.');
}
