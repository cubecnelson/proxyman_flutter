import 'package:flutter/material.dart';
import '../models/http_transaction.dart';
import 'request_editor.dart';
import 'response_editor.dart';

class TransactionDetail extends StatelessWidget {
  final HttpTransaction? transaction;
  final Function(HttpTransaction)? onTransactionUpdated;

  const TransactionDetail({
    super.key,
    this.transaction,
    this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (transaction == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a transaction to view details',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildDetailContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final request = transaction!.request;
    final response = transaction!.response;

    Color statusColor = Colors.grey;
    if (response != null) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        statusColor = Colors.green;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        statusColor = Colors.orange;
      } else if (response.statusCode >= 500) {
        statusColor = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMethodColor(request.method),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.method,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.url,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onTransactionUpdated != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editRequest(context),
                  tooltip: 'Edit Request',
                ),
                if (response != null)
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 20),
                    onPressed: () => _editResponse(context),
                    tooltip: 'Edit Response',
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (response != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${response.statusCode}',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                'Time: ${_formatTime(transaction!.startTime)}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              if (transaction!.duration != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Duration: ${transaction!.duration!.inMilliseconds}ms',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.grey[50],
            child: const TabBar(
              tabs: [
                Tab(text: 'Request'),
                Tab(text: 'Response'),
                Tab(text: 'Headers'),
                Tab(text: 'Timing'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildRequestTab(),
                _buildResponseTab(),
                _buildHeadersTab(),
                _buildTimingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    final request = transaction!.request;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('URL'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              request.url,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (request.body != null && request.body!.isNotEmpty) ...[
            _buildSectionTitle('Body'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content type info
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Length: ${request.body!.length} characters',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Body content
                  Text(
                    request.body!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (request.method != 'GET' && request.method != 'HEAD') ...[
            _buildSectionTitle('Body'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                'No body content',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResponseTab() {
    final response = transaction!.response;

    if (response == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Waiting for response...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Status'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(response.statusCode).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${response.statusCode}',
              style: TextStyle(
                color: _getStatusColor(response.statusCode),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (response.body != null) ...[
            _buildSectionTitle('Body'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                response.body!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeadersTab() {
    final request = transaction!.request;
    final response = transaction!.response;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Request Headers'),
          _buildHeadersTable(request.headers),
          const SizedBox(height: 24),
          if (response != null) ...[
            _buildSectionTitle('Response Headers'),
            _buildHeadersTable(response.headers),
          ],
        ],
      ),
    );
  }

  Widget _buildHeadersTable(Map<String, String> headers) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: headers.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimingRow('Start Time', transaction!.startTime),
          if (transaction!.duration != null) ...[
            _buildTimingRow('Duration', null, duration: transaction!.duration),
          ],
          if (transaction!.response != null) ...[
            _buildTimingRow(
                'Response Time',
                transaction!.startTime
                    .add(transaction!.duration ?? Duration.zero)),
          ],
        ],
      ),
    );
  }

  Widget _buildTimingRow(String label, DateTime? time, {Duration? duration}) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              time != null
                  ? _formatTimeWithMillis(time)
                  : duration != null
                      ? '${duration.inMilliseconds}ms'
                      : 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatTimeWithMillis(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}.${time.millisecond.toString().padLeft(3, '0')}';
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _editRequest(BuildContext context) {
    if (transaction == null || onTransactionUpdated == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestEditor(
          request: transaction!.request,
          onSave: (updatedRequest) {
            final updatedTransaction = transaction!.copyWith(
              request: updatedRequest,
            );
            onTransactionUpdated!(updatedTransaction);
          },
          onCancel: () {},
        ),
      ),
    );
  }

  void _editResponse(BuildContext context) {
    if (transaction?.response == null || onTransactionUpdated == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResponseEditor(
          response: transaction!.response!,
          onSave: (updatedResponse) {
            final updatedTransaction = transaction!.copyWith(
              response: updatedResponse,
            );
            onTransactionUpdated!(updatedTransaction);
          },
          onCancel: () {},
        ),
      ),
    );
  }

  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else if (statusCode >= 500) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
