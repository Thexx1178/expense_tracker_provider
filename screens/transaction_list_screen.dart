// สร้างไฟล์ lib/screens/transaction_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_provider/providers/transaction_provider.dart';
import 'package:expense_tracker_provider/models/my_transaction.dart';


class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) =>
            txProvider.transactions.isEmpty
                ? const Center(child: Text('ไม่มีรายการ'))
                : ListView.builder(
                    itemCount: txProvider.transactions.length,
                    itemBuilder: (ctx, i) {
                      final tx = txProvider.transactions[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(tx.type == TransactionType.income ? 'รับ' : 'จ่าย'),
                        ),
                        title: Text(tx.title),
                        subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                        trailing: Text(
                          '${tx.amount.toStringAsFixed(2)} บาท',
                          style: TextStyle(
                            color: tx.type == TransactionType.income ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}