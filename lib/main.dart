import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/transaction_list.dart';
import 'widgets/transaction_detail.dart';
import 'widgets/certificate_qr_dialog.dart';
import 'models/http_transaction.dart';
import 'services/proxy_service.dart';
import 'dart:io';

void main() {
  // Suppress macOS input method warnings
  if (Platform.isMacOS) {
    // Set environment variables to suppress input method warnings
    Map<String, String> env = Map.from(Platform.environment);
    env['NSSupportsAutomaticTextReplacement'] = 'false';
    env['NSSupportsAutomaticSpellingCorrection'] = 'false';
    env['NSSupportsAutomaticQuoteSubstitution'] = 'false';
    env['NSSupportsAutomaticDashSubstitution'] = 'false';
    env['NSSupportsAutomaticPeriodSubstitution'] = 'false';
    env['NSSupportsAutomaticCapitalization'] = 'false';
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxyman Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<HttpTransaction> transactions = [];
  List<HttpTransaction> filteredTransactions = [];
  HttpTransaction? selectedTransaction;
  String? proxyIp;
  bool isProxyRunning = false;
  final int proxyPort = 8080;
  final NetworkInfo _networkInfo = NetworkInfo();
  late ProxyService _proxyService;
  final TextEditingController _filterController = TextEditingController();
  String? selectedMethodFilter;

  final List<String> methodFilters = [
    'All',
    'GET',
    'POST',
    'PUT',
    'DELETE',
    'PATCH',
    'CONNECT'
  ];

  @override
  void initState() {
    super.initState();
    _proxyService = ProxyService(port: proxyPort);
    _getLocalIpAddress();
    _listenToTransactions();
    _filterController.addListener(_filterTransactions);
  }

  void _listenToTransactions() {
    _proxyService.transactionStream.listen((transaction) {
      setState(() {
        transactions.insert(0, transaction); // Add new transactions at the top
        _filterTransactions(); // Apply current filter
      });
    });
  }

  void _filterTransactions() {
    final filter = _filterController.text.toLowerCase();
    var filtered = transactions;

    // Apply method filter
    if (selectedMethodFilter != null && selectedMethodFilter != 'All') {
      filtered = filtered
          .where((transaction) =>
              transaction.request.method == selectedMethodFilter)
          .toList();
    }

    // Apply text filter
    if (filter.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final request = transaction.request;
        return request.method.toLowerCase().contains(filter) ||
            request.url.toLowerCase().contains(filter) ||
            (transaction.response?.statusCode.toString().contains(filter) ??
                false) ||
            request.headers.values
                .any((value) => value.toLowerCase().contains(filter));
      }).toList();
    }

    setState(() {
      filteredTransactions = filtered;
    });
  }

  void _clearLogs() {
    setState(() {
      transactions.clear();
      filteredTransactions.clear();
      selectedTransaction = null;
    });
  }

  Future<void> _getLocalIpAddress() async {
    try {
      final wifiIP = await _networkInfo.getWifiIP();
      setState(() {
        proxyIp = wifiIP;
      });
    } catch (e) {
      setState(() {
        proxyIp = '127.0.0.1';
      });
    }
  }

  Future<void> _toggleProxy() async {
    if (isProxyRunning) {
      await _proxyService.stop();
      setState(() {
        isProxyRunning = false;
      });
    } else {
      final success = await _proxyService.start();
      setState(() {
        isProxyRunning = success;
      });
    }
  }

  void _openCertificateDownload() async {
    final certificateUrl =
        'http://${proxyIp ?? '127.0.0.1'}:${_proxyService.certificatePort}';
    print('Opening certificate download page: $certificateUrl');

    try {
      final uri = Uri.parse(certificateUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $certificateUrl';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open certificate page: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => CertificateQRDialog(
        proxyIP: proxyIp ?? '127.0.0.1',
        certificatePort: _proxyService.certificatePort,
      ),
    );
  }

  @override
  void dispose() {
    _proxyService.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxyman Flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Proxy Status and IP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isProxyRunning
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isProxyRunning ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProxyRunning ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: isProxyRunning ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Proxy IP',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${proxyIp ?? 'Loading...'}:$proxyPort',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isProxyRunning
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Certificate Download Button
          if (isProxyRunning)
            ElevatedButton.icon(
              onPressed: () => _openCertificateDownload(),
              icon: const Icon(Icons.security),
              label: const Text('Download Cert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          if (isProxyRunning) const SizedBox(width: 8),
          // QR Code Button
          if (isProxyRunning)
            ElevatedButton.icon(
              onPressed: () => _showQRCode(),
              icon: const Icon(Icons.qr_code),
              label: const Text('QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          if (isProxyRunning) const SizedBox(width: 8),
          // Proxy Toggle Button
          ElevatedButton.icon(
            onPressed: _toggleProxy,
            icon: Icon(isProxyRunning ? Icons.stop : Icons.play_arrow),
            label: Text(isProxyRunning ? 'Stop Proxy' : 'Start Proxy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isProxyRunning ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Filter and Clear Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Method Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedMethodFilter,
                    hint: const Text('Method'),
                    underline: const SizedBox(),
                    items: methodFilters.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMethodFilter = newValue;
                        _filterTransactions();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Search/Filter Field
                Expanded(
                  child: TextField(
                    controller: _filterController,
                    decoration: InputDecoration(
                      hintText:
                          'Filter requests (URL, method, status, headers...)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Clear Logs Button
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                // Transaction Count
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${filteredTransactions.length} requests',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Transaction List (left side)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TransactionList(
                    transactions: filteredTransactions,
                    selectedTransaction: selectedTransaction,
                    onTransactionSelected: (transaction) {
                      setState(() {
                        selectedTransaction = transaction;
                      });
                    },
                  ),
                ),
                // Transaction Detail (right side)
                Expanded(
                  child: TransactionDetail(
                    transaction: selectedTransaction,
                    onTransactionUpdated: (updatedTransaction) {
                      setState(() {
                        // Update the transaction in the list
                        final index = transactions.indexWhere(
                          (t) => t.id == updatedTransaction.id,
                        );
                        if (index != -1) {
                          transactions[index] = updatedTransaction;
                          // Update selected transaction if it's the same one
                          if (selectedTransaction?.id ==
                              updatedTransaction.id) {
                            selectedTransaction = updatedTransaction;
                          }
                          // Re-apply filters
                          _filterTransactions();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
