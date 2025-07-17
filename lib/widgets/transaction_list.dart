import 'package:flutter/material.dart';
import '../models/http_transaction.dart';

class TransactionList extends StatelessWidget {
  final List<HttpTransaction> transactions;
  final HttpTransaction? selectedTransaction;
  final Function(HttpTransaction) onTransactionSelected;

  const TransactionList({
    super.key,
    required this.transactions,
    this.selectedTransaction,
    required this.onTransactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTransactionTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          const Icon(Icons.list, size: 20),
          const SizedBox(width: 8),
          Text(
            'HTTP Transactions (${transactions.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable() {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.network_check, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start the proxy to capture HTTP traffic',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isSelected = selectedTransaction?.id == transaction.id;

        return _buildTransactionRow(transaction, isSelected);
      },
    );
  }

  Widget _buildTransactionRow(HttpTransaction transaction, bool isSelected) {
    final request = transaction.request;
    final response = transaction.response;

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
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        selected: isSelected,
        onTap: () => onTransactionSelected(transaction),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (response != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${response.statusCode}',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatTime(transaction.startTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (transaction.duration != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${transaction.duration!.inMilliseconds}ms',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: response != null
            ? Icon(
                Icons.check_circle,
                color: statusColor,
                size: 20,
              )
            : const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
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
}
