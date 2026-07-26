import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_import_service.dart';
import '../services/character_import_mapper.dart';
import '../services/saved_characters_service.dart';
import '../models/pdf_character_data.dart';
import '../widgets/mobile/mobile_scaffold.dart';
import '../core/app_theme.dart';

/// Screen for importing characters from WotC PDF character sheets
class PdfImportScreen extends StatefulWidget {
  const PdfImportScreen({super.key});

  @override
  State<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends State<PdfImportScreen> {
  File? _selectedPdf;
  PdfCharacterData? _parsedData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      setState(() {
        _selectedPdf = file;
        _parsedData = null;
        _errorMessage = null;
        _isLoading = true;
      });

      // Check if it's a WotC character sheet
      final isWotc = await PdfImportService.isWotcCharacterSheet(file);
      if (!isWotc) {
        setState(() {
          _errorMessage =
              'Il file selezionato non è una scheda personaggio WotC valida.';
          _isLoading = false;
        });
        return;
      }

      // Extract data
      final fields = await PdfImportService.extractAcroFormData(file);
      final data = PdfCharacterData.fromFieldMap(fields);

      setState(() {
        _parsedData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore durante la lettura del PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importCharacter() async {
    if (_parsedData == null) return;

    // Check if data is valid
    final isValid = CharacterImportMapper.isValidForImport(_parsedData!);
    if (!isValid) {
      final missing = CharacterImportMapper.getMissingFields(_parsedData!);
      setState(() {
        _errorMessage =
            'Dati incompleti. Campi mancanti: ${missing.join(", ")}';
      });
      return;
    }

    try {
      final pgBase = CharacterImportMapper.toPgBase(_parsedData!);

      await SavedCharactersService.save(pgBase);

      if (!mounted) return;
      Navigator.pop(context, pgBase);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personaggio importato con successo! ✅'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore durante l\'importazione: $e';
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Importa Personaggio da PDF',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Carica una scheda personaggio WotC in formato PDF per importare automaticamente i dati nel Master Aid.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_selectedPdf != null) ...[
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(
                _selectedPdf!.path.split(Platform.pathSeparator).last,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedPdf = null;
                    _parsedData = null;
                    _errorMessage = null;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              )
            else if (_parsedData != null) ...[
              _buildCharacterPreview(),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _importCharacter,
                icon: const Icon(Icons.save),
                label: const Text('Importa Personaggio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleziona PDF'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Seleziona un file PDF di una scheda personaggio WotC ufficiale',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacterPreview() {
    if (_parsedData == null) return const SizedBox.shrink();

    final data = _parsedData!;
    final isValid = CharacterImportMapper.isValidForImport(data);
    final missing = CharacterImportMapper.getMissingFields(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isValid ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid ? Colors.green.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.warning,
                color: isValid ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isValid
                      ? '✅ Tutti i dati necessari sono presenti!'
                      : '⚠️ Dati incompleti. Campi mancanti: ${missing.join(", ")}',
                  style: TextStyle(
                    color:
                        isValid
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Anteprima Personaggio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildInfoRow('Nome', data.name),
        _buildInfoRow('Classe', data.classLevel),
        _buildInfoRow('Razza', data.race),
        _buildInfoRow('Background', data.background),
        const Divider(),
        _buildInfoRow('PF Massimi', data.maxHitPoints.toString()),
        _buildInfoRow('CA', data.armorClass.toString()),
        _buildInfoRow('Velocità', '${data.speed} ft'),
        const Divider(),
        _buildInfoRow('Forza', data.strength.toString()),
        _buildInfoRow('Destrezza', data.dexterity.toString()),
        _buildInfoRow('Costituzione', data.constitution.toString()),
        _buildInfoRow('Intelligenza', data.intelligence.toString()),
        _buildInfoRow('Saggezza', data.wisdom.toString()),
        _buildInfoRow('Carisma', data.charisma.toString()),
        if (data.spellcastingClass != null) ...[
          const Divider(),
          _buildInfoRow('Classe Incantesimi', data.spellcastingClass!),
          if (data.spellSaveDC != null)
            _buildInfoRow(
              'Tiro Salvezza Incantesimi',
              data.spellSaveDC!.toString(),
            ),
          if (data.spellAttackBonus != null)
            _buildInfoRow(
              'Bonus Attacco Incantesimi',
              data.spellAttackBonus!.toString(),
            ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MobileScaffold(
      title: 'Importa PDF',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildFilePicker(),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'ℹ️ Formati supportati: schede personaggio WotC ufficiali (PDF)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
