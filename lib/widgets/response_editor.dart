import 'package:flutter/material.dart';
import '../models/http_transaction.dart';

class ResponseEditor extends StatefulWidget {
  final HttpResponseData response;
  final Function(HttpResponseData) onSave;
  final VoidCallback onCancel;

  const ResponseEditor({
    super.key,
    required this.response,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ResponseEditor> createState() => _ResponseEditorState();
}

class _ResponseEditorState extends State<ResponseEditor> {
  late TextEditingController _statusCodeController;
  late TextEditingController _bodyController;
  late Map<String, String> _headers;
  late List<MapEntry<String, String>> _headerEntries;

  @override
  void initState() {
    super.initState();
    _statusCodeController =
        TextEditingController(text: widget.response.statusCode.toString());
    _bodyController = TextEditingController(text: widget.response.body ?? '');
    _headers = Map.from(widget.response.headers);
    _headerEntries = _headers.entries.toList();
  }

  @override
  void dispose() {
    _statusCodeController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Response'),
        actions: [
          TextButton(
            onPressed: _saveResponse,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCodeField(),
            const SizedBox(height: 16),
            _buildHeadersSection(),
            const SizedBox(height: 16),
            _buildBodySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _statusCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '200',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_getStatusCode()).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getStatusColor(_getStatusCode())),
              ),
              child: Text(
                _getStatusText(_getStatusCode()),
                style: TextStyle(
                  color: _getStatusColor(_getStatusCode()),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeadersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Response Headers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addHeader,
              icon: const Icon(Icons.add),
              label: const Text('Add Header'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: _headerEntries.map((entry) {
              return _buildHeaderRow(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(String key, String value) {
    final keyController = TextEditingController(text: key);
    final valueController = TextEditingController(text: value);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: keyController,
              decoration: const InputDecoration(
                hintText: 'Header name',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (newKey) {
                _updateHeader(key, newKey, value);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: valueController,
              decoration: const InputDecoration(
                hintText: 'Header value',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (newValue) {
                _updateHeader(key, key, newValue);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            onPressed: () => _removeHeader(key),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Response Body',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bodyController,
          maxLines: 15,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter response body...',
            contentPadding: EdgeInsets.all(12),
          ),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _addHeader() {
    setState(() {
      _headers['New-Header'] = 'value';
      _headerEntries = _headers.entries.toList();
    });
  }

  void _removeHeader(String key) {
    setState(() {
      _headers.remove(key);
      _headerEntries = _headers.entries.toList();
    });
  }

  void _updateHeader(String oldKey, String newKey, String newValue) {
    setState(() {
      if (oldKey != newKey) {
        _headers.remove(oldKey);
      }
      _headers[newKey] = newValue;
      _headerEntries = _headers.entries.toList();
    });
  }

  int _getStatusCode() {
    try {
      return int.parse(_statusCodeController.text);
    } catch (e) {
      return 200;
    }
  }

  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else if (statusCode >= 500) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  void _saveResponse() {
    final updatedResponse = HttpResponseData(
      statusCode: _getStatusCode(),
      body: _bodyController.text.isEmpty ? null : _bodyController.text,
      headers: _headers,
      timestamp: widget.response.timestamp,
    );

    widget.onSave(updatedResponse);
    Navigator.of(context).pop();
  }
}
