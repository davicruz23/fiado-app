import 'package:fiado_app/database/dao/client_debt_dao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientHistoryPage extends StatefulWidget {
  final int clientId;
  final String clientName;

  const ClientHistoryPage({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ClientHistoryPage> createState() => _ClientHistoryPageState();
}

class _ClientHistoryPageState extends State<ClientHistoryPage> {
  final dao = ClientDebtDao();
  List<Map<String, dynamic>> history = [];
  DateTime? startDate;
  DateTime? endDate;

  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final allPaid = await dao.findPaymentsByClient(widget.clientId);

    List<Map<String, dynamic>> filtered = allPaid;

    if (startDate != null) {
      filtered = filtered.where((d) {
        final debtDate = DateTime.parse(d['created_at']);
        return debtDate.isAfter(startDate!.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((d) {
        final debtDate = DateTime.parse(d['created_at']);
        return debtDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    setState(() {
      history = filtered;
    });
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico - ${widget.clientName}'),
        actions: [
          IconButton(
            onPressed: pickDateRange,
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filtrar por datas',
          ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                'Nenhum histórico encontrado',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final d = history[index];
                final amount = (d['amount'] as num).toDouble();
                String formattedDate = '';
                try {
                  formattedDate =
                      DateFormat("dd/MM/yyyy · HH:mm").format(DateTime.parse(d['created_at']));
                } catch (_) {}

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(amount),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B6D11),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}