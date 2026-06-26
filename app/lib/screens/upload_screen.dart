import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/catalog_controller.dart';
import '../data/contracts_controller.dart';
import '../data/contracts_repository.dart';
import '../data/extraction_result.dart';
import '../data/repository_provider.dart';
import '../l10n.dart';
import '../theme.dart';
import '../widgets/editorial.dart';
import 'add_contract_screen.dart';
import 'compare_screen.dart';
import 'review_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _picker = ImagePicker();
  final List<String> _pending = [];

  Future<void> _takePhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) _submit(photo.path, photo.name);
    } catch (_) {
      final photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) _submit(photo.path, photo.name);
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    for (final f in result?.files ?? const <PlatformFile>[]) {
      _submit(f.path, f.name);
    }
  }

  Future<void> _scanMultiple() async {
    final photos = await _picker.pickMultiImage();
    for (final p in photos) {
      _submit(p.path, p.name);
    }
  }

  Future<void> _addManual() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddContractScreen()),
    );
  }

  Future<void> _submit(String? path, String name) async {
    if (path == null) return;
    setState(() => _pending.add(name));
    try {
      await contractsRepository().submitDocument(path);
      await contractsController.refresh();
    } on ExtractionUnavailable catch (e) {
      if (mounted) _offerManual(e.message);
    } catch (e) {
      if (mounted) _offerManual('$e');
    } finally {
      if (mounted) setState(() => _pending.remove(name));
    }
  }

  void _offerManual(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Automatisches Auslesen nicht möglich',
            'Automatic reading unavailable')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('Später', 'Later')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addManual();
            },
            child: Text(t('Manuell eintragen', 'Enter manually')),
          ),
        ],
      ),
    );
  }

  Future<void> _openContract(ExtractionResult c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReviewScreen(result: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Kicker(t('Bestand', 'Portfolio')),
            const SizedBox(height: Sp.sm),
            Text(t('Deine Verträge', 'Your contracts'),
                style: serif(size: 30, color: context.inkColor)),
            const SizedBox(height: Sp.lg),
            Text(
              t('Foto, Scan, PDF – oder von Hand eintragen.',
                  'Photo, scan, PDF – or enter by hand.'),
              style: TextStyle(color: context.mutedColor, fontSize: 14),
            ),
            const SizedBox(height: Sp.lg),
            FilledButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: Text(t('Vertrag fotografieren', 'Photograph a contract')),
            ),
            const SizedBox(height: Sp.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickPdf,
                    child: Text(t('PDF wählen', 'Choose PDF')),
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addManual,
                    child: Text(t('Manuell eintragen', 'Enter manually')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.sm),
            TextButton.icon(
              onPressed: _scanMultiple,
              icon: const Icon(Icons.document_scanner_outlined, size: 18),
              label: Text(t('Mehrere Seiten scannen', 'Scan multiple pages')),
            ),
            const SizedBox(height: Sp.xl),
            ListenableBuilder(
              listenable:
                  Listenable.merge([contractsController, catalogController]),
              builder: (context, _) {
                final contracts = contractsController.contracts;
                final total = _pending.length + contracts.length;
                if (contractsController.loading && !contractsController.loaded) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // Types with 2+ contracts that also have criteria → compare chips.
                final byType = <String, List<ExtractionResult>>{};
                for (final c in contracts) {
                  if (c.contractType != null) {
                    byType.putIfAbsent(c.contractType!, () => []).add(c);
                  }
                }
                final comparableTypes = byType.entries
                    .where((e) =>
                        e.value.length > 1 &&
                        catalogController.criteriaFor(e.key).isNotEmpty)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (comparableTypes.isNotEmpty) ...[
                      Text(
                        t('Inhalt vergleichen', 'Compare content'),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: context.mutedColor),
                      ),
                      const SizedBox(height: Sp.sm),
                      Wrap(
                        spacing: Sp.sm,
                        runSpacing: Sp.sm,
                        children: [
                          for (final e in comparableTypes)
                            ActionChip(
                              label: Text(
                                catalogController.typeName(e.key),
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.terracotta,
                                    fontWeight: FontWeight.w600),
                              ),
                              avatar: Icon(Icons.compare_arrows,
                                  size: 16, color: context.terracotta),
                              backgroundColor: context.terracotta.withValues(alpha: 0.08),
                              side: BorderSide(
                                  color: context.terracotta.withValues(alpha: 0.3)),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        CompareScreen(contractType: e.key)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: Sp.lg),
                    ],
                    Text(t('Im Bestand · $total', 'On file · $total'),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: context.mutedColor)),
                    const SizedBox(height: Sp.sm),
                    const Hairline(),
                    if (total == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          t('Noch nichts erfasst — starte oben.',
                              'Nothing yet — start above.'),
                          style: TextStyle(
                              fontSize: 14, color: context.mutedColor),
                        ),
                      ),
                    for (final name in _pending) ...[
                      _PendingRow(name: name),
                      const Hairline(),
                    ],
                    for (final c in contracts) ...[
                      _ContractRow(
                          contract: c, onTap: () => _openContract(c)),
                      const Hairline(),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: context.accentColor),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: serif(size: 15, color: context.inkColor, spacing: 0)),
          ),
          Text(t('Wird gelesen…', 'Reading…'),
              style: TextStyle(fontSize: 12, color: context.mutedColor)),
        ],
      ),
    );
  }
}

class _ContractRow extends StatelessWidget {
  const _ContractRow({required this.contract, required this.onTap});
  final ExtractionResult contract;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final needsReview = contract.status == ExtractionStatus.needsReview;
    final premium = contract.monthlyPremiumEur;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(catalogController.typeIcon(contract.contractType),
                size: 20, color: context.accentColor),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contract.insurerName ?? '—',
                      style: serif(
                          size: 16, color: context.inkColor, spacing: 0)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          catalogController.typeName(contract.contractType),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: context.mutedColor),
                        ),
                      ),
                      if (needsReview) ...[
                        Text('  ·  ',
                            style: TextStyle(
                                fontSize: 12, color: context.mutedColor)),
                        Text(t('bitte prüfen', 'review'),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.terracotta)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Sp.md),
            Text(
              premium != null && premium > 0
                  ? '${premium.toStringAsFixed(2).replaceAll('.', ',')} €'
                  : '',
              style: serif(size: 15, color: context.inkColor, spacing: 0),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: context.mutedColor),
          ],
        ),
      ),
    );
  }
}
