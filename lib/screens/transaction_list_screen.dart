// lib/screens/transaction_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/my_transaction.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ - รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, prov, _) {
          final items = prov.transactions;
          if (items.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายการ'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tx = items[i];
              final color = tx.type == TransactionType.income
                  ? Colors.green
                  : Colors.red;

              return ListTile(
                onTap: () => _openEditSheet(context, tx), // ✅ แตะแถวเพื่อแก้ไข
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(
                    tx.type == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: color,
                  ),
                ),
                title: Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat.yMMMd().format(tx.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tx.amount.toStringAsFixed(2),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color.fromARGB(255, 137, 130, 130)),
                      tooltip: 'ลบรายการนี้',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('ยืนยันการลบ'),
                            content: Text('ต้องการลบรายการ "${tx.title}" ใช่ไหม?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('ยกเลิก'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('ลบ'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && tx.id != null) {
                          await context
                              .read<TransactionProvider>()
                              .deleteTransaction(tx.id!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ลบข้อมูลเรียบร้อย')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ✅ ฟอร์มเพิ่มข้อมูลใหม่
  void _openCreateSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(bottom: bottomInset + 12),
            child: Material(
              color: Theme.of(ctx).canvasColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: _TxForm(
                    titleCtrl: titleCtrl,
                    amountCtrl: amountCtrl,
                    noteCtrl: noteCtrl,
                    selectedDate: selectedDate,
                    selectedType: selectedType,
                    onPickDate: (d) => selectedDate = d,
                    onPickType: (t) => selectedType = t,
                    submitText: 'เพิ่ม',
                    onSubmit: () async {
                      final title = titleCtrl.text.trim();
                      final amt = double.tryParse(amountCtrl.text.trim());
                      if (title.isEmpty || amt == null) return;

                      final tx = MyTransaction(
                        title: title,
                        amount: amt,
                        date: selectedDate,
                        type: selectedType,
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      );
                      await context
                          .read<TransactionProvider>()
                          .addTransaction(tx);

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('เพิ่มรายการแล้ว')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ ฟอร์มแก้ไขข้อมูล
  void _openEditSheet(BuildContext context, MyTransaction tx) {
    final titleCtrl = TextEditingController(text: tx.title);
    final amountCtrl = TextEditingController(text: tx.amount.toString());
    final noteCtrl = TextEditingController(text: tx.note ?? '');
    TransactionType selectedType = tx.type;
    DateTime selectedDate = tx.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(bottom: bottomInset + 12),
            child: Material(
              color: Theme.of(ctx).canvasColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: _TxForm(
                    titleCtrl: titleCtrl,
                    amountCtrl: amountCtrl,
                    noteCtrl: noteCtrl,
                    selectedDate: selectedDate,
                    selectedType: selectedType,
                    onPickDate: (d) => selectedDate = d,
                    onPickType: (t) => selectedType = t,
                    submitText: 'ปรับปรุงข้อมูล', // ✅ ตามคำสั่งอาจารย์
                    onSubmit: () async {
                      final title = titleCtrl.text.trim();
                      final amt = double.tryParse(amountCtrl.text.trim());
                      if (title.isEmpty || amt == null) return;

                      final updated = tx.copyWith(
                        title: title,
                        amount: amt,
                        date: selectedDate,
                        type: selectedType,
                        note: noteCtrl.text.trim().isEmpty
                            ? null
                            : noteCtrl.text.trim(),
                      );

                      await context
                          .read<TransactionProvider>()
                          .updateTransaction(updated);

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('ปรับปรุงข้อมูลเรียบร้อยแล้ว')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------- ฟอร์มที่ใช้ทั้งเพิ่มและแก้ไข ----------------
class _TxForm extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController amountCtrl;
  final TextEditingController noteCtrl;
  final String submitText;
  final VoidCallback onSubmit;
  final DateTime selectedDate;
  final TransactionType selectedType;
  final void Function(DateTime) onPickDate;
  final void Function(TransactionType) onPickType;

  const _TxForm({
    super.key,
    required this.titleCtrl,
    required this.amountCtrl,
    required this.noteCtrl,
    required this.submitText,
    required this.onSubmit,
    required this.selectedDate,
    required this.selectedType,
    required this.onPickDate,
    required this.onPickType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountCtrl,
          decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TransactionType>(
          value: selectedType,
          items: const [
            DropdownMenuItem(value: TransactionType.income, child: Text('รายรับ')),
            DropdownMenuItem(value: TransactionType.expense, child: Text('รายจ่าย')),
          ],
          onChanged: (v) {
            if (v != null) onPickType(v);
          },
          decoration: const InputDecoration(labelText: 'ประเภท'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(labelText: 'โน้ต (ถ้ามี)'),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text('วันที่: ${DateFormat.yMMMd().format(selectedDate)}'),
            ),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) onPickDate(picked);
              },
              child: const Text('เปลี่ยนวันที่'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(submitText),
            ),
          ],
        ),
      ],
    );
  }
}
