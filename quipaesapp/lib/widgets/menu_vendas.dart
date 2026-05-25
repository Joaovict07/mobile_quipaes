import 'package:flutter/material.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;

enum TransactionType {
  expense('Despesa', Colors.red, Icons.remove_circle_outline),
  income('Receita', Colors.green, Icons.add_circle_outline),
  transfer('Transferência', Colors.blue, Icons.swap_horiz_rounded);

  final String label;
  final Color color;
  final IconData icon;
  const TransactionType(this.label, this.color, this.icon);
}

enum TransactionCategory {
  food(
    'Loja',
    Colors.black,
    Icons.store_mall_directory,
    TransactionType.expense,
  ),
  salary(
    'Delivery',
    Colors.black,
    Icons.delivery_dining,
    TransactionType.income,
  );

  final String label;
  final Color color;
  final IconData icon;
  final TransactionType defaultType;
  const TransactionCategory(
    this.label,
    this.color,
    this.icon,
    this.defaultType,
  );
}

enum FormaDePagamento {
  pix('Pix', Colors.black, Icons.pix, TransactionType.expense),
  dinheiro('Dinheiro', Colors.black, Icons.payments, TransactionType.income),
  credito('Crédito', Colors.black, Icons.credit_card, TransactionType.income),
  debito('Débito', Colors.black, Icons.credit_score, TransactionType.income);

  final String label;
  final Color color;
  final IconData icon;
  final TransactionType defaultType;
  const FormaDePagamento(this.label, this.color, this.icon, this.defaultType);
}

class Transaction {
  final double amount;
  final TransactionCategory category;
  final DateTime date;

  Transaction({
    required this.amount,
    required this.category,
    required this.date,
  });

  static Transaction create({
    required double amount,
    required TransactionCategory category,
    required String description,
    required DateTime date,
    String? note,
  }) => Transaction(
    amount: amount,
    category: category,
    date: date,
  );
}

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionCategory _category = TransactionCategory.food;
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    FormaDePagamento _formaPagamento = FormaDePagamento.pix;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
  
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nova Transação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _FormaDePagamentoDropdown(
                selected: _formaPagamento,
                onChanged: (novaForma) {
                  setState(() {
                    _formaPagamento =
                        novaForma; 
                  });
                },
              ),
              const SizedBox(height: 12),

              _CategoryDropdown(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),

              _DatePicker(
                date: _date,
                onChanged: (d) => setState(() => _date = d),
              ),

              Padding(
                padding: EdgeInsetsGeometry.only(top: 12),
                child: const SizedBox(height: 24),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorsTheme.AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Salvar venda',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
    final tx = Transaction.create(
      amount: amount,
      category: _category,
      description: _descCtrl.text.trim(),
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _loading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venda criada!'),
          backgroundColor: colorsTheme.AppColors.primary,
        ),
      );
    }
  }
}


class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;
  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TransactionType.values.map((type) {
        final isSelected = type == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? type.color : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.black45,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final TransactionCategory selected;
  final ValueChanged<TransactionCategory> onChanged;

  const _CategoryDropdown({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TransactionCategory>(
      value: selected, 
      decoration: const InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: TransactionCategory.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Row(
            children: [
              Icon(cat.icon, size: 18, color: cat.color),
              const SizedBox(width: 8),
              Text(cat.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePicker({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(formatted, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class AddTransactionFab extends StatelessWidget {
  const AddTransactionFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddTransactionSheet(),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Nova Transação'),
    );
  }
}

class _FormaDePagamentoDropdown extends StatelessWidget {
  final FormaDePagamento selected;
  final ValueChanged<FormaDePagamento> onChanged;

  const _FormaDePagamentoDropdown({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FormaDePagamento>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Forma de Pagamento',
        prefixIcon: Icon(
          Icons.account_balance_wallet_outlined,
        ), // Ícone mais sugestivo
      ),
      items: FormaDePagamento.values.map((forma) {
        return DropdownMenuItem(
          value: forma,
          child: Row(
            children: [
              Icon(forma.icon, size: 18, color: forma.color),
              const SizedBox(width: 8),
              Text(forma.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}
