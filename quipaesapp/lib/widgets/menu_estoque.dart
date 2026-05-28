import 'package:flutter/material.dart';
import 'package:quipaesapp/databases/db.dart';
import 'package:quipaesapp/theme/colors.dart' as colorsTheme;

enum ProductCategory {
  food('Alimento', Colors.orange, Icons.fastfood),
  beverage('Bebida', Colors.blue, Icons.local_drink),
  cleaning('Limpeza', Colors.green, Icons.cleaning_services),
  other('Outro', Colors.grey, Icons.category);

  final String label;
  final Color color;
  final IconData icon;
  
  const ProductCategory(
    this.label,
    this.color,
    this.icon,
  );
}

class Product {
  final String name;
  final ProductCategory category;
  final int quantity;
  final DateTime expirationDate;

  Product({
    required this.name,
    required this.category,
    required this.quantity,
    required this.expirationDate,
  });
}

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  ProductCategory _category = ProductCategory.food;
  DateTime _expirationDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

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
                'Novo Produto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Nome do Produto
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome do produto';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Categoria
              _CategoryDropdown(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),


              TextFormField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em Estoque',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  final parsed = int.tryParse(v);
                  if (parsed == null || parsed < 0) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço de Venda (R\$)',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o preço';
                  final normalized = v.replaceAll(',', '.');
                  final parsed = double.tryParse(normalized);
                  if (parsed == null || parsed < 0) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _DatePicker(
                date: _expirationDate,
                onChanged: (d) => setState(() => _expirationDate = d),
              ),

              const SizedBox(height: 36),

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
                      : const Text(
                          'Salvar produto',
                          style: TextStyle(
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

    try {
      final dadosProduto = {
        'nome': _nameCtrl.text.trim(),
        'categoria': _category.label,
        'quantidade': int.parse(_quantityCtrl.text),
        'preco': double.parse(_priceCtrl.text.replaceAll(',', '.')),
        'validade':
            '${_expirationDate.day.toString().padLeft(2, '0')}/${_expirationDate.month.toString().padLeft(2, '0')}/${_expirationDate.year}',
      };

      await ProdutosRepository.inserir(dadosProduto);

      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CategoryDropdown extends StatelessWidget {
  final ProductCategory selected;
  final ValueChanged<ProductCategory> onChanged;

  const _CategoryDropdown({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ProductCategory>(
      value: selected,
      decoration: const InputDecoration(
        labelText: 'Categoria',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: ProductCategory.values.map((cat) {
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
          // Para vencimento, permitimos selecionar do dia atual até anos no futuro
          firstDate: DateTime.now(),
          lastDate: DateTime(2040),
          helpText: 'Selecione a data de vencimento',
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Vencimento',
          prefixIcon: Icon(Icons.event_busy_outlined),
        ),
        child: Text(formatted, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class AddProductFab extends StatelessWidget {
  const AddProductFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddProductSheet(),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Novo Produto'),
    );
  }
}