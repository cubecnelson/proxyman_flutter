import 'package:flutter/material.dart';
import '../models/http_transaction.dart';

class RequestEditor extends StatefulWidget {
  final HttpRequestData request;
  final Function(HttpRequestData) onSave;
  final VoidCallback onCancel;

  const RequestEditor({
    super.key,
    required this.request,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<RequestEditor> createState() => _RequestEditorState();
}

class _RequestEditorState extends State<RequestEditor> {
  late TextEditingController _methodController;
  late TextEditingController _urlController;
  late TextEditingController _bodyController;
  late Map<String, String> _headers;
  late List<MapEntry<String, String>> _headerEntries;

  @override
  void initState() {
    super.initState();
    _methodController = TextEditingController(text: widget.request.method);
    _urlController = TextEditingController(text: widget.request.url);
    _bodyController = TextEditingController(text: widget.request.body ?? '');
    _headers = Map.from(widget.request.headers);
    _headerEntries = _headers.entries.toList();
  }

  @override
  void dispose() {
    _methodController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Request'),
        actions: [
          TextButton(
            onPressed: _saveRequest,
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
            _buildMethodField(),
            const SizedBox(height: 16),
            _buildUrlField(),
            const SizedBox(height: 16),
            _buildHeadersSection(),
            const SizedBox(height: 16),
            _buildBodySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _methodController.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS']
              .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _methodController.text = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'URL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'https://example.com/api/endpoint',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          style: const TextStyle(fontFamily: 'monospace'),
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
              'Headers',
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
          'Body',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bodyController,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter request body...',
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

  void _saveRequest() {
    final updatedRequest = HttpRequestData(
      method: _methodController.text,
      url: _urlController.text,
      body: _bodyController.text.isEmpty ? null : _bodyController.text,
      headers: _headers,
    );

    widget.onSave(updatedRequest);
    Navigator.of(context).pop();
  }
}
