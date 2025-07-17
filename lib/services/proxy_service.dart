import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/http_transaction.dart';
import 'certificate_service.dart';

class ProxyService extends ChangeNotifier {
  HttpServer? _server;
  final int port;
  final StreamController<HttpTransaction> _transactionController =
      StreamController<HttpTransaction>.broadcast();
  final List<HttpTransaction> _transactions = [];
  bool _isRunning = false;
  String _proxyIP = '0.0.0.0';
  int _proxyPort = 8080;

  // Certificate service for HTTPS interception
  late CertificateService _certificateService;

  // HTTP server for certificate download
  HttpServer? _certificateServer;

  Stream<HttpTransaction> get transactionStream =>
      _transactionController.stream;

  ProxyService({this.port = 8080}) {
    _certificateService = CertificateService();
  }

  Future<bool> start() async {
    try {
      // Start certificate download server
      await _startCertificateServer();

      // Start main proxy server
      _server = await HttpServer.bind(_proxyIP, _proxyPort);
      _isRunning = true;
      print('Proxy server started on $_proxyIP:$_proxyPort');

      _server!.listen(_handleRequest);
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to start proxy server: $e');
      return false;
    }
  }

  Future<void> _startCertificateServer() async {
    try {
      // Start certificate server on a different port
      _certificateServer = await HttpServer.bind(_proxyIP, _proxyPort + 1);
      print('Certificate server started on $_proxyIP:${_proxyPort + 1}');

      _certificateServer!.listen(_handleCertificateRequest);
    } catch (e) {
      print('Failed to start certificate server: $e');
    }
  }

  void _handleCertificateRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' && request.uri.path == '/download_cert') {
        // Serve the root certificate
        final certificatePEM = _certificateService.exportRootCertificatePEM();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('application', 'x-x509-ca-cert')
          ..headers.add('Content-Disposition',
              'attachment; filename="proxyman_root_ca.crt"')
          ..write(certificatePEM);

        request.response.close();
        print(
            'Certificate downloaded from ${request.connectionInfo?.remoteAddress}:${request.connectionInfo?.remotePort}');
      } else if (request.method == 'GET' &&
          request.uri.path == '/download_cert_pem') {
        // Serve the root certificate as PEM
        final certificatePEM = _certificateService.exportRootCertificatePEM();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('application', 'x-pem-file')
          ..headers.add('Content-Disposition',
              'attachment; filename="proxyman_root_ca.pem"')
          ..write(certificatePEM);

        request.response.close();
        print('PEM certificate downloaded');
      } else if (request.method == 'GET' &&
          request.uri.path == '/download_cert_cer') {
        // Serve the root certificate as CER
        final certificatePEM = _certificateService.exportRootCertificatePEM();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('application', 'x-x509-ca-cert')
          ..headers.add('Content-Disposition',
              'attachment; filename="proxyman_root_ca.cer"')
          ..write(certificatePEM);

        request.response.close();
        print('CER certificate downloaded');
      } else if (request.method == 'GET' &&
          request.uri.path == '/download_cert_mobile') {
        // Serve certificate optimized for mobile devices (especially iOS)
        final certificatePEM = _certificateService.exportRootCertificatePEM();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('application', 'x-x509-ca-cert')
          ..headers.add('Content-Disposition',
              'attachment; filename="proxyman_root_ca.crt"')
          ..write(certificatePEM);

        request.response.close();
        print('Mobile certificate downloaded');
      } else if (request.method == 'GET' &&
          request.uri.path == '/download_cert_ios') {
        // Serve certificate specifically for iOS - direct certificate file
        final certificatePEM = _certificateService.exportRootCertificatePEM();

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('application', 'x-x509-ca-cert')
          ..headers.add('Content-Disposition',
              'attachment; filename="proxyman_root_ca.crt"')
          ..write(certificatePEM);

        request.response.close();
        print('iOS certificate downloaded');
      } else if (request.method == 'GET' && request.uri.path == '/mobile') {
        // Serve mobile-optimized page for iOS devices
        final mobileHtml = '''
<!DOCTYPE html>
<html>
<head>
    <title>Proxyman Flutter - iOS Certificate</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: #f2f2f7; 
            line-height: 1.6;
        }
        .container { 
            max-width: 500px; 
            margin: 0 auto; 
            background: white; 
            padding: 30px; 
            border-radius: 20px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1); 
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #1d1d1f;
            margin-bottom: 10px;
        }
        .header p {
            color: #86868b;
            margin: 0;
        }
        .download-btn { 
            display: block; 
            width: 100%;
            background: #007aff; 
            color: white; 
            padding: 18px 25px; 
            text-decoration: none; 
            border-radius: 12px; 
            margin: 15px 0;
            text-align: center;
            font-weight: 600;
            font-size: 18px;
            transition: all 0.3s;
            box-sizing: border-box;
        }
        .download-btn:hover { 
            background: #0056b3; 
            transform: translateY(-2px);
        }
        .download-btn.secondary { 
            background: #f2f2f7; 
            color: #007aff;
            border: 2px solid #007aff;
        }
        .download-btn.secondary:hover { 
            background: #e5e5ea; 
        }
        .info { 
            background: #f0f8ff; 
            padding: 20px; 
            border-radius: 12px; 
            margin: 25px 0; 
            border-left: 4px solid #007aff; 
        }
        .warning { 
            background: #fff3cd; 
            padding: 20px; 
            border-radius: 12px; 
            margin: 25px 0; 
            border-left: 4px solid #ffc107; 
        }
        .steps {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            margin: 25px 0;
        }
        .steps ol {
            margin: 0;
            padding-left: 20px;
        }
        .steps li {
            margin: 12px 0;
            color: #1d1d1f;
        }
        .proxy-info {
            background: #e9ecef; 
            padding: 20px; 
            border-radius: 12px; 
            font-family: 'SF Mono', Monaco, monospace; 
            font-size: 16px;
            text-align: center;
            font-weight: bold;
            color: #1d1d1f;
            margin: 20px 0;
        }
        .desktop-link {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e5e5ea;
        }
        .desktop-link a {
            color: #007aff;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Proxyman Flutter</h1>
            <p>Install certificate for HTTPS interception</p>
        </div>

        <div class="info">
            <h3>📱 iOS Certificate Installation</h3>
            <p>This certificate allows the proxy to decrypt HTTPS traffic for debugging purposes.</p>
        </div>

        <a href="/download_cert_ios" class="download-btn">
            🍎 Install Certificate
        </a>
        
        <a href="/download_cert_mobile" class="download-btn secondary">
            📄 Alternative Format
        </a>

        <div class="steps">
            <h3>📋 Installation Steps</h3>
            <ol>
                <li>Tap "Install Certificate" above</li>
                <li>iOS will prompt to install the certificate</li>
                <li>Tap "Install" and enter your passcode</li>
                <li>Go to <strong>Settings → General → About → Certificate Trust Settings</strong></li>
                <li>Find "Proxyman Flutter Root CA" and enable trust</li>
                <li>Configure your device to use proxy: <strong>${_proxyIP}:${_proxyPort}</strong></li>
            </ol>
        </div>

        <div class="warning">
            <h3>⚠️ Security Notice</h3>
            <p>This certificate allows decryption of HTTPS traffic. Only install if you trust this proxy server.</p>
        </div>

        <div class="proxy-info">
            Proxy: ${_proxyIP}:${_proxyPort}
        </div>

        <div class="desktop-link">
            <a href="/?format=desktop">View Desktop Version</a>
        </div>
    </div>
</body>
</html>
        ''';

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('text', 'html', charset: 'utf-8')
          ..write(mobileHtml);

        request.response.close();
        print('Mobile page served');
      } else if (request.method == 'GET' && request.uri.path == '/cert_info') {
        // Serve certificate info as JSON
        final certInfo = _certificateService.getCertificateInfo('Root CA');

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(certInfo));

        request.response.close();
      } else if (request.method == 'GET' && request.uri.path == '/') {
        // Detect mobile devices and serve appropriate content
        final userAgent =
            request.headers.value('user-agent')?.toLowerCase() ?? '';
        final isIOS = userAgent.contains('iphone') ||
            userAgent.contains('ipad') ||
            userAgent.contains('ipod');
        final isMobile = userAgent.contains('mobile') ||
            isIOS ||
            userAgent.contains('android');

        if (isIOS && request.uri.queryParameters['format'] != 'desktop') {
          // Redirect iOS users to mobile-optimized page
          request.response
            ..statusCode = 302
            ..headers.add('Location', '/mobile')
            ..close();
          return;
        }

        // Serve a simple HTML page with download links
        final html = '''
<!DOCTYPE html>
<html>
<head>
    <title>Proxyman Flutter Certificate Download</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: #f5f5f5; 
            line-height: 1.6;
        }
        .container { 
            max-width: 700px; 
            margin: 0 auto; 
            background: white; 
            padding: 30px; 
            border-radius: 15px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1); 
        }
        .download-section { 
            margin: 25px 0; 
            padding: 25px; 
            background: #f8f9fa; 
            border-radius: 12px; 
            border-left: 4px solid #007bff; 
        }
        .download-btn { 
            display: inline-block; 
            background: #007bff; 
            color: white; 
            padding: 15px 25px; 
            text-decoration: none; 
            border-radius: 8px; 
            margin: 10px 5px;
            transition: all 0.3s;
            font-weight: 500;
            text-align: center;
            min-width: 200px;
        }
        .download-btn:hover { 
            background: #0056b3; 
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,123,255,0.3);
        }
        .download-btn.secondary { background: #6c757d; }
        .download-btn.secondary:hover { background: #545b62; }
        .download-btn.success { background: #28a745; }
        .download-btn.success:hover { background: #1e7e34; }
        .download-btn.ios { background: #000; }
        .download-btn.ios:hover { background: #333; }
        .info { 
            background: #e7f3ff; 
            padding: 20px; 
            border-radius: 10px; 
            margin: 25px 0; 
            border-left: 4px solid #007bff; 
        }
        .warning { 
            background: #fff3cd; 
            padding: 20px; 
            border-radius: 10px; 
            margin: 25px 0; 
            border-left: 4px solid #ffc107; 
        }
        .mobile-section {
            background: #f0f8ff;
            padding: 20px;
            border-radius: 10px;
            margin: 25px 0;
            border-left: 4px solid #007bff;
        }
        .platform-info { 
            display: flex; 
            gap: 20px; 
            margin: 25px 0; 
            flex-wrap: wrap;
        }
        .platform { 
            flex: 1; 
            min-width: 250px;
            padding: 20px; 
            background: #f8f9fa; 
            border-radius: 10px; 
            border: 1px solid #e9ecef;
        }
        .platform h4 { 
            margin-top: 0; 
            color: #495057; 
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .platform ul { 
            margin: 0; 
            padding-left: 20px; 
        }
        .platform li { 
            margin: 8px 0; 
        }
        .proxy-config {
            background: #e9ecef; 
            padding: 20px; 
            border-radius: 10px; 
            font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace; 
            font-size: 16px;
            text-align: center;
            font-weight: bold;
            color: #495057;
            border: 2px solid #dee2e6;
        }
        @media (max-width: 768px) {
            body { padding: 10px; }
            .container { padding: 20px; }
            .download-btn { 
                display: block; 
                margin: 10px 0; 
                min-width: auto;
            }
            .platform-info { flex-direction: column; }
            .platform { min-width: auto; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Proxyman Flutter Certificate</h1>
        
        <div class="info">
            <h3>Root CA Certificate</h3>
            <p>Download and install this certificate to enable HTTPS interception and view encrypted traffic on your device.</p>
        </div>

        <div class="mobile-section">
            <h3>📱 Mobile Devices (iPhone/iPad)</h3>
            <p>For iOS devices, download the certificate directly:</p>
            
            <a href="/download_cert_ios" class="download-btn ios">
                🍎 Download for iOS (.crt)
            </a>
            <a href="/download_cert_mobile" class="download-btn success">
                📱 Mobile Certificate (.crt)
            </a>
        </div>

        <div class="download-section">
            <h3>💻 Desktop & Other Devices</h3>
            <p>Choose the format that works best for your system:</p>
            
            <a href="/download_cert" class="download-btn success">
                📄 Download .CRT (Recommended)
            </a>
            <a href="/download_cert_cer" class="download-btn">
                📄 Download .CER
            </a>
            <a href="/download_cert_pem" class="download-btn secondary">
                📄 Download .PEM
            </a>
        </div>

        <div class="warning">
            <h3>⚠️ Important Security Notice</h3>
            <p>This certificate allows the proxy to decrypt HTTPS traffic. Only install it if you trust this proxy server and understand the security implications.</p>
        </div>

        <div class="platform-info">
            <div class="platform">
                <h4>🍎 iOS (iPhone/iPad)</h4>
                <ul>
                    <li>Download .CRT file</li>
                    <li>Tap to open the file</li>
                    <li>Tap "Install" when prompted</li>
                    <li>Go to Settings → General → About → Certificate Trust Settings</li>
                    <li>Enable trust for "Proxyman Flutter Root CA"</li>
                    <li>Configure proxy settings in Wi-Fi settings</li>
                </ul>
            </div>
            <div class="platform">
                <h4>🪟 Windows</h4>
                <ul>
                    <li>Download .CRT file</li>
                    <li>Double-click to open</li>
                    <li>Click "Install Certificate"</li>
                    <li>Choose "Local Machine"</li>
                    <li>Select "Trusted Root Certification Authorities"</li>
                </ul>
            </div>
            <div class="platform">
                <h4>🍎 macOS</h4>
                <ul>
                    <li>Download .CRT file</li>
                    <li>Double-click to open</li>
                    <li>Add to "System" keychain</li>
                    <li>Set trust to "Always Trust"</li>
                </ul>
            </div>
            <div class="platform">
                <h4>🐧 Linux</h4>
                <ul>
                    <li>Download .PEM file</li>
                    <li>Copy to /usr/local/share/ca-certificates/</li>
                    <li>Run: sudo update-ca-certificates</li>
                </ul>
            </div>
        </div>

        <div class="download-section">
            <h3>🔧 Proxy Configuration</h3>
            <p>Configure your proxy settings to use:</p>
            <div class="proxy-config">
                ${_proxyIP}:${_proxyPort}
            </div>
        </div>

        <div style="text-align: center; margin-top: 30px; color: #6c757d;">
            <p>Certificate server running on port ${_proxyPort + 1}</p>
            <a href="/cert_info" style="color: #007bff;">View Certificate Details</a>
        </div>
    </div>
</body>
</html>
        ''';

        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.html
          ..write(html);

        request.response.close();
      }
    } catch (e) {
      print('Error handling certificate request: $e');
      request.response
        ..statusCode = 500
        ..write('Internal Server Error')
        ..close();
    }
  }

  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
    }
    if (_certificateServer != null) {
      await _certificateServer!.close();
      _certificateServer = null;
    }
    _isRunning = false;
    print('Proxy server stopped');
    notifyListeners();
  }

  bool get isRunning => _isRunning;
  String get proxyIP => _proxyIP;
  int get proxyPort => _proxyPort;
  int get certificatePort => _proxyPort + 1;
  List<HttpTransaction> get transactions => List.unmodifiable(_transactions);

  void _handleRequest(HttpRequest clientRequest) async {
    try {
      // Convert headers to Map<String, String>
      Map<String, String> headers = {};
      clientRequest.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });

      if (clientRequest.method == 'CONNECT') {
        await _handleConnectRequest(clientRequest);
      } else {
        await _handleHttpRequest(clientRequest, headers);
      }
    } catch (e) {
      print('Request handling error: $e');
      try {
        clientRequest.response.statusCode = 500;
        await clientRequest.response.close();
      } catch (e) {
        // Already closed
      }
    }
  }

  Future<void> _handleConnectRequest(HttpRequest clientRequest) async {
    try {
      // Parse the CONNECT target from the URI
      String target = clientRequest.uri.toString();
      if (target.startsWith('http://') || target.startsWith('https://')) {
        target = clientRequest.uri.authority;
      }

      if (target.isEmpty) {
        print('CONNECT failed: Empty target');
        clientRequest.response.statusCode = 400;
        await clientRequest.response.close();
        return;
      }

      var parts = target.split(':');
      var host = parts[0];
      var port = parts.length > 1 ? int.parse(parts[1]) : 443;

      print('CONNECT to $host:$port');

      // Create CONNECT transaction
      Map<String, String> headers = {};
      clientRequest.headers.forEach((name, values) {
        headers[name] = values.join(', ');
      });

      final connectTransaction = HttpTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        request: HttpRequestData(
          method: 'CONNECT',
          url: '$host:$port',
          headers: headers,
          body: '', // CONNECT requests don't have a body
        ),
      );
      _transactionController.add(connectTransaction);

      var remote = await Socket.connect(host, port);

      // Send 200 OK to client
      clientRequest.response
        ..statusCode = 200
        ..reasonPhrase = 'Connection established';
      await clientRequest.response.flush();

      // Get the client socket
      final clientSocket = await clientRequest.response.detachSocket();

      // Set up bidirectional data flow
      bool clientClosed = false;
      bool remoteClosed = false;

      // Buffer for parsing HTTP requests
      List<int> clientBuffer = [];

      remote.listen(
        (data) {
          if (!clientClosed) {
            try {
              clientSocket.add(data);
            } catch (e) {
              clientClosed = true;
              if (!remoteClosed) {
                remote.close();
              }
            }
          }
        },
        onError: (e) {
          print('Remote socket error: $e');
          clientClosed = true;
          if (!remoteClosed) {
            remote.close();
          }
        },
        onDone: () {
          clientClosed = true;
          if (!remoteClosed) {
            remote.close();
          }
        },
      );

      clientSocket.listen(
        (data) {
          if (!remoteClosed) {
            try {
              // Add data to buffer for parsing
              clientBuffer.addAll(data);

              print(
                  'Received ${data.length} bytes from client, buffer size: ${clientBuffer.length}');

              // Try to parse complete HTTP request from buffer
              final parsed =
                  _parseHttpRequestFromBuffer(clientBuffer, host, port);
              if (parsed) {
                // Clear buffer after successful parsing
                clientBuffer.clear();
                print('Successfully parsed HTTP request, cleared buffer');
              }

              remote.add(data);
            } catch (e) {
              print('Error in client socket listener: $e');
              remoteClosed = true;
              if (!clientClosed) {
                clientSocket.close();
              }
            }
          }
        },
        onError: (e) {
          print('Client socket error: $e');
          remoteClosed = true;
          if (!clientClosed) {
            clientSocket.close();
          }
        },
        onDone: () {
          remoteClosed = true;
          if (!clientClosed) {
            clientSocket.close();
          }
        },
      );
    } catch (e) {
      print('CONNECT failed: $e');
      try {
        clientRequest.response.statusCode = 502;
        await clientRequest.response.close();
      } catch (e) {
        // Already closed
      }
    }
  }

  Future<void> _handleHttpRequest(
      HttpRequest clientRequest, Map<String, String> headers) async {
    try {
      final uri = clientRequest.uri;
      final targetUri = uri.isAbsolute
          ? uri
          : Uri.parse(
              'http://${clientRequest.headers.host}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}');

      final httpClient = HttpClient();
      final proxyRequest =
          await httpClient.openUrl(clientRequest.method, targetUri);

      // Copy headers
      clientRequest.headers.forEach((name, values) {
        for (var value in values) {
          proxyRequest.headers.add(name, value);
        }
      });

      // Debug: Print all headers
      print('Request headers:');
      clientRequest.headers.forEach((name, values) {
        print('  $name: ${values.join(', ')}');
      });

      // Forward request body and capture it
      String requestBody = '';
      if (clientRequest.method != 'GET' && clientRequest.method != 'HEAD') {
        print(
            'Reading request body for ${clientRequest.method} request to ${clientRequest.uri}');

        // Check content length
        final contentLength = clientRequest.headers.contentLength;
        print('Content-Length: $contentLength');

        // Check if there's a body to read
        if (contentLength != null && contentLength > 0) {
          print('Expected body size: $contentLength bytes');

          try {
            await for (List<int> chunk in clientRequest) {
              proxyRequest.add(chunk);
              requestBody += String.fromCharCodes(chunk);
              print(
                  'Read chunk: ${chunk.length} bytes, total: ${requestBody.length} characters');
            }
          } catch (e) {
            print('Error reading request body: $e');
          }
        } else {
          // Try to read anyway in case content-length is not set
          print('No content-length, attempting to read body anyway');
          try {
            await for (List<int> chunk in clientRequest) {
              proxyRequest.add(chunk);
              requestBody += String.fromCharCodes(chunk);
              print(
                  'Read chunk: ${chunk.length} bytes, total: ${requestBody.length} characters');
            }
          } catch (e) {
            print('Error reading request body: $e');
          }
        }

        print('Final request body length: ${requestBody.length} characters');
        if (requestBody.isNotEmpty) {
          print(
              'Request body preview: ${requestBody.substring(0, requestBody.length > 100 ? 100 : requestBody.length)}...');
        } else {
          print('No request body found');
        }
      } else {
        print('Skipping body read for ${clientRequest.method} request');
      }

      // Create transaction after reading body
      final transaction = HttpTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        request: HttpRequestData(
          method: clientRequest.method,
          url: clientRequest.uri.toString(),
          headers: headers,
          body: requestBody,
        ),
      );
      _transactionController.add(transaction);

      // Handle response
      final proxyResponse = await proxyRequest.close();
      clientRequest.response.statusCode = proxyResponse.statusCode;

      // Capture response headers
      Map<String, String> responseHeaders = {};
      proxyResponse.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
        for (var value in values) {
          clientRequest.response.headers.add(name, value);
        }
      });

      // Capture response body
      String responseBody = '';
      await for (List<int> chunk in proxyResponse) {
        clientRequest.response.add(chunk);
        responseBody += String.fromCharCodes(chunk);
      }

      // Update transaction with response info
      final updatedTransaction = HttpTransaction(
        id: transaction.id,
        startTime: transaction.startTime,
        duration: DateTime.now().difference(transaction.startTime),
        request: transaction.request,
        response: HttpResponseData(
          statusCode: proxyResponse.statusCode,
          headers: responseHeaders,
          body: responseBody,
          timestamp: DateTime.now(),
        ),
      );

      // Add updated transaction to stream
      _transactionController.add(updatedTransaction);

      await clientRequest.response.close();
    } catch (e) {
      print('HTTP proxy failed: $e');
      try {
        clientRequest.response.statusCode = 502;
        await clientRequest.response.close();
      } catch (e) {
        // Already closed
      }
    }
  }

  @override
  void dispose() {
    stop();
    _transactionController.close();
    super.dispose();
  }

  void _addTransaction(HttpTransaction transaction) {
    _transactionController.add(transaction);
  }

  void _parseHttpRequestFromData(List<int> data, String host, int port) {
    // This method is now replaced by _parseHttpRequestFromBuffer
  }

  bool _parseHttpRequestFromBuffer(List<int> buffer, String host, int port) {
    try {
      // Convert buffer to string for parsing
      final bufferString = String.fromCharCodes(buffer);

      print(
          'Parsing buffer (${buffer.length} bytes): ${bufferString.substring(0, bufferString.length > 200 ? 200 : bufferString.length)}...');

      // Check if this looks like an HTTP request
      if (bufferString.startsWith('GET ') ||
          bufferString.startsWith('POST ') ||
          bufferString.startsWith('PUT ') ||
          bufferString.startsWith('DELETE ') ||
          bufferString.startsWith('PATCH ') ||
          bufferString.startsWith('HEAD ') ||
          bufferString.startsWith('OPTIONS ')) {
        print('Detected HTTP request method');

        // Look for the end of headers (double CRLF)
        final headerEndIndex = bufferString.indexOf('\r\n\r\n');
        if (headerEndIndex == -1) {
          // Headers not complete yet, keep buffering
          print('Headers not complete yet, waiting for \\r\\n\\r\\n');
          return false;
        }

        print(
            'Found complete HTTP request in CONNECT tunnel: ${bufferString.split('\n')[0]}');

        // Parse the request line
        final lines = bufferString.split('\r\n');
        if (lines.isNotEmpty) {
          final requestLine = lines[0];
          final parts = requestLine.split(' ');

          if (parts.length >= 3) {
            final method = parts[0];
            final path = parts[1];
            final url = 'https://$host$path';

            // Parse headers
            Map<String, String> headers = {};
            int bodyStartIndex = -1;

            for (int i = 1; i < lines.length; i++) {
              final line = lines[i];
              if (line.isEmpty) {
                bodyStartIndex = i + 1;
                break;
              }

              final colonIndex = line.indexOf(':');
              if (colonIndex > 0) {
                final key = line.substring(0, colonIndex).trim();
                final value = line.substring(colonIndex + 1).trim();
                headers[key] = value;
              }
            }

            // Extract body using raw buffer data
            String body = '';
            final contentLength = headers['content-length'];

            if (contentLength != null) {
              final expectedBodyLength = int.tryParse(contentLength) ?? 0;
              if (expectedBodyLength > 0) {
                // Check if we have enough data for the complete body
                final bodyStart = headerEndIndex + 4; // Skip \r\n\r\n
                if (buffer.length >= bodyStart + expectedBodyLength) {
                  // Extract body from raw buffer
                  final bodyBytes =
                      buffer.sublist(bodyStart, bodyStart + expectedBodyLength);
                  body = String.fromCharCodes(bodyBytes);
                  print(
                      'Extracted body with Content-Length: ${body.length} bytes');
                } else {
                  // Body not complete yet, keep buffering
                  print(
                      'Waiting for complete body: have ${buffer.length - bodyStart}, need $expectedBodyLength');
                  return false;
                }
              }
            } else {
              // No Content-Length, try to extract what we have
              final bodyStart = headerEndIndex + 4;
              if (bodyStart < buffer.length) {
                final bodyBytes = buffer.sublist(bodyStart);
                body = String.fromCharCodes(bodyBytes);
                print(
                    'Extracted body without Content-Length: ${body.length} bytes');
              }
            }

            // Create transaction for the actual HTTP request
            final transaction = HttpTransaction(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              startTime: DateTime.now(),
              request: HttpRequestData(
                method: method,
                url: url,
                headers: headers,
                body: body,
              ),
            );

            print(
                'Parsed HTTPS request: $method $url with body length: ${body.length}');
            if (body.isNotEmpty) {
              print(
                  'Body preview: ${body.substring(0, body.length > 100 ? 100 : body.length)}...');
            }
            _transactionController.add(transaction);
            return true;
          }
        }
      } else {
        // No HTTP request detected
        if (buffer.length > 50) {
          print(
              'No HTTP request detected in buffer. First 50 chars: ${bufferString.substring(0, 50)}');
        }
      }
    } catch (e) {
      // Ignore parsing errors, just continue
      print('Error parsing HTTP request from buffer: $e');
    }
    return false;
  }

  String _generateMobileConfig(String certificatePEM) {
    // Generate a mobile configuration profile for iOS
    final now = DateTime.now();
    final uuid = '${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';

    final mobileConfig = {
      'PayloadContent': [
        {
          'PayloadType': 'com.apple.root',
          'PayloadVersion': 1,
          'PayloadIdentifier': 'com.proxyman.flutter.rootca.$uuid',
          'PayloadUUID': uuid,
          'PayloadDisplayName': 'Proxyman Flutter Root CA',
          'PayloadDescription':
              'Root CA certificate for Proxyman Flutter proxy',
          'PayloadOrganization': 'Proxyman Flutter',
          'PayloadRemovalDisallowed': false,
          'PayloadCertificateFileName': 'proxyman_root_ca.crt',
          'PayloadContent': certificatePEM,
        }
      ],
      'PayloadType': 'Configuration',
      'PayloadVersion': 1,
      'PayloadIdentifier': 'com.proxyman.flutter.config.$uuid',
      'PayloadUUID': uuid,
      'PayloadDisplayName': 'Proxyman Flutter Certificate',
      'PayloadDescription':
          'Install the root CA certificate for HTTPS interception',
      'PayloadOrganization': 'Proxyman Flutter',
      'PayloadRemovalDisallowed': false,
    };

    return jsonEncode(mobileConfig);
  }

  String _generateIOSConfig(String certificatePEM) {
    // Generate iOS-specific configuration profile with proper format
    final now = DateTime.now();
    final uuid = '${now.millisecondsSinceEpoch}-${now.microsecondsSinceEpoch}';

    final iosConfig = {
      'PayloadContent': [
        {
          'PayloadType': 'com.apple.root',
          'PayloadVersion': 1,
          'PayloadIdentifier': 'com.proxyman.flutter.rootca.ios.$uuid',
          'PayloadUUID': uuid,
          'PayloadDisplayName': 'Proxyman Flutter Root CA',
          'PayloadDescription':
              'Root CA certificate for Proxyman Flutter proxy - iOS',
          'PayloadOrganization': 'Proxyman Flutter',
          'PayloadRemovalDisallowed': false,
          'PayloadCertificateFileName': 'proxyman_root_ca.crt',
          'PayloadContent': certificatePEM,
        }
      ],
      'PayloadType': 'Configuration',
      'PayloadVersion': 1,
      'PayloadIdentifier': 'com.proxyman.flutter.config.ios.$uuid',
      'PayloadUUID': uuid,
      'PayloadDisplayName': 'Proxyman Flutter Certificate',
      'PayloadDescription':
          'Install the root CA certificate for HTTPS interception on iOS',
      'PayloadOrganization': 'Proxyman Flutter',
      'PayloadRemovalDisallowed': false,
      'PayloadExpirationDate': now.add(Duration(days: 365)).toIso8601String(),
    };

    return jsonEncode(iosConfig);
  }
}
