import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/catalog.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/de_format.dart';
import '../data/repository_provider.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'category_info_screen.dart';

/// Schritt 1: Vertragsart wählen — gruppiert nach den drei Bedarfsstufen
/// (Bedarfspyramide). Schritt 2: generisches Formular (ContractFormScreen),
/// dessen Felder aus dem Katalog stammen.
class AddContractScreen extends StatelessWidget {
  const AddContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Vertrag hinzufügen', 'Add contract')),
      ),
      body: ListenableBuilder(
        listenable: catalogController,
        builder: (context, _) {
          if (!catalogController.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final byLevel = catalogController.categoriesByLevel;
          final levels = byLevel.keys.toList()..sort();
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(
                t('Welche Art von Vertrag möchtest du erfassen?',
                    'What kind of contract do you want to add?'),
                style: serif(size: 22, color: context.inkColor, height: 1.2),
              ),
              const SizedBox(height: Sp.sm),
              Text(
                t('Geordnet nach anerkannter Bedarfssystematik (Grundabsicherung zuerst).',
                    'Ordered by a recognised needs hierarchy (basic protection first).'),
                style: TextStyle(
                    color: context.mutedColor, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: Sp.xxl),
              for (final level in levels) ...[
                _LevelHeader(level: level),
                for (final cat in byLevel[level]!) _CategoryCard(category: cat),
                const SizedBox(height: Sp.xl),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$level',
                style: serif(size: 22, color: context.terracotta, spacing: 0)),
            const SizedBox(width: Sp.md),
            Text(definoLevelName(level),
                style: serif(size: 18, color: context.inkColor, spacing: 0)),
          ],
        ),
        const SizedBox(height: Sp.sm),
        const Hairline(),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final ContractCategory category;

  void _open(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => ContractFormScreen(contractType: category.key)),
    );
    if (added == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(category.iconData, color: context.accentColor, size: 22),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: serif(
                              size: 16, color: context.inkColor, spacing: 0)),
                      if (category.purpose != null) ...[
                        const SizedBox(height: 3),
                        Text(category.purpose!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: context.mutedColor)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: Sp.sm),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.info_outline,
                      size: 19, color: context.mutedColor),
                  tooltip: t('Was ist das?', 'What is this?'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            CategoryInfoScreen(categoryKey: category.key)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

const _intervals = [
  'monatlich',
  'vierteljaehrlich',
  'halbjaehrlich',
  'jaehrlich',
  'einmalig',
];

class ContractFormScreen extends StatefulWidget {
  const ContractFormScreen({super.key, required this.contractType});
  final String contractType;

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _controllers = <String, TextEditingController>{};
  final _dates = <String, String?>{};
  final _choices = <String, String?>{};
  final _bools = <String, bool>{};
  final _criteria = <String, bool>{};
  String? _premiumInterval = 'monatlich';
  bool _saving = false;

  List<ContractFieldSpec> get _fields =>
      catalogController.fieldsFor(widget.contractType);
  List<ContractCriterion> get _critSpecs =>
      catalogController.criteriaFor(widget.contractType);

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      if (f.kind == FieldKind.text ||
          f.kind == FieldKind.money ||
          f.kind == FieldKind.premium ||
          f.kind == FieldKind.intNum) {
        _controllers[f.fieldKey] = TextEditingController();
      }
      if (f.kind == FieldKind.boolean) _bools[f.fieldKey] = false;
    }
    for (final c in _critSpecs) {
      _criteria[c.key] = false;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(String key) {
    final raw =
        _controllers[key]?.text.trim().replaceAll('.', '').replaceAll(',', '.');
    if (raw == null || raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Map<String, dynamic> _assemble() {
    final data = <String, dynamic>{};
    for (final f in _fields) {
      switch (f.kind) {
        case FieldKind.text:
          final v = _controllers[f.fieldKey]!.text.trim();
          data[f.fieldKey] = v.isEmpty ? null : v;
        case FieldKind.date:
          data[f.fieldKey] = _dates[f.fieldKey];
        case FieldKind.money:
          final n = _num(f.fieldKey);
          data[f.fieldKey] = n == null ? null : {'amount': n, 'currency': 'EUR'};
        case FieldKind.premium:
          final n = _num(f.fieldKey);
          data[f.fieldKey] = (n == null || _premiumInterval == null)
              ? null
              : {
                  'amount': {'amount': n, 'currency': 'EUR'},
                  'interval': _premiumInterval,
                };
        case FieldKind.intNum:
          final raw = _controllers[f.fieldKey]!.text.trim();
          data[f.fieldKey] = raw.isEmpty ? null : int.tryParse(raw);
        case FieldKind.boolean:
          data[f.fieldKey] = _bools[f.fieldKey] ?? false;
        case FieldKind.choice:
          data[f.fieldKey] = _choices[f.fieldKey];
      }
    }
    if (_criteria.isNotEmpty) {
      data['criteria'] = Map<String, dynamic>.from(_criteria);
    }
    return data;
  }

  Future<void> _save() async {
    // Erstes Pflichtfeld (i.d.R. Anbieter) muss ausgefüllt sein.
    final requiredField = _fields.where((f) => f.required).firstOrNull;
    if (requiredField != null &&
        (_controllers[requiredField.fieldKey]?.text.trim().isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Bitte fülle „${requiredField.label}“ aus.',
              'Please fill in “${requiredField.label}”.')),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await contractsRepository()
          .addManualContract(widget.contractType, _assemble());
      await contractsController.refresh();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                t('Speichern fehlgeschlagen: $e', 'Could not save: $e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = catalogController.category(widget.contractType);
    return Scaffold(
      appBar: AppBar(
        title: Text(cat?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: t('Was ist das?', 'What is this?'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      CategoryInfoScreen(categoryKey: widget.contractType)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            t('Trage ein, was du weißt — Felder dürfen leer bleiben.',
                'Enter what you know — fields may stay empty.'),
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          for (final f in _fields) ...[
            _buildField(context, f),
            const SizedBox(height: 14),
          ],
          if (_critSpecs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(t('Leistungsmerkmale', 'Coverage features'),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4)),
            const SizedBox(height: 2),
            Text(
              t('Was ist im Vertrag enthalten? (für den inhaltlichen Vergleich)',
                  'What does the contract include? (for the content comparison)'),
              style: TextStyle(fontSize: 12, color: context.mutedColor),
            ),
            const SizedBox(height: 6),
            for (final c in _critSpecs)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _criteria[c.key] ?? false,
                onChanged: (v) => setState(() => _criteria[c.key] = v),
                title: Text(c.label, style: const TextStyle(fontSize: 13.5)),
              ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(t('Vertrag speichern', 'Save contract')),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _buildField(BuildContext context, ContractFieldSpec f) {
    switch (f.kind) {
      case FieldKind.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            TextField(controller: _controllers[f.fieldKey], decoration: _dec()),
          ],
        );
      case FieldKind.money:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            TextField(
              controller: _controllers[f.fieldKey],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _dec(suffix: '€'),
            ),
          ],
        );
      case FieldKind.intNum:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            TextField(
              controller: _controllers[f.fieldKey],
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _dec(),
            ),
          ],
        );
      case FieldKind.premium:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _controllers[f.fieldKey],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _dec(suffix: '€'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    initialValue: _premiumInterval,
                    decoration: _dec(),
                    items: [
                      for (final i in _intervals)
                        DropdownMenuItem(
                            value: i, child: Text('pro ${_intervalLabel(i)}')),
                    ],
                    onChanged: (v) => setState(() => _premiumInterval = v),
                  ),
                ),
              ],
            ),
          ],
        );
      case FieldKind.date:
        final iso = _dates[f.fieldKey];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            OutlinedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _dates[f.fieldKey] =
                      picked.toIso8601String().split('T').first);
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: context.borderColor),
              ),
              child: Text(
                iso == null
                    ? t('Datum wählen', 'Pick a date')
                    : formatFieldValue(iso),
                style: TextStyle(
                    color: iso == null ? context.mutedColor : context.inkColor),
              ),
            ),
          ],
        );
      case FieldKind.boolean:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _bools[f.fieldKey] ?? false,
          onChanged: (v) => setState(() => _bools[f.fieldKey] = v),
          title: Text(f.label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        );
      case FieldKind.choice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(f.label),
            DropdownButtonFormField<String>(
              initialValue: _choices[f.fieldKey],
              decoration: _dec(hint: t('Bitte wählen', 'Please choose')),
              items: [
                for (final c in f.choices)
                  DropdownMenuItem(value: c.value, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _choices[f.fieldKey] = v),
            ),
          ],
        );
    }
  }

  InputDecoration _dec({String? suffix, String? hint}) => InputDecoration(
        isDense: true,
        hintText: hint,
        suffixText: suffix,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
      );

  String _intervalLabel(String i) => switch (i) {
        'monatlich' => t('Monat', 'month'),
        'vierteljaehrlich' => t('Quartal', 'quarter'),
        'halbjaehrlich' => t('Halbjahr', 'half-year'),
        'jaehrlich' => t('Jahr', 'year'),
        _ => t('einmalig', 'one-time'),
      };
}
