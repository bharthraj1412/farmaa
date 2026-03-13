import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/crop_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Add or edit a grain listing. Price is always freely editable.
class AddEditCropScreen extends ConsumerStatefulWidget {
  final String? cropId; // null for new crop
  const AddEditCropScreen({super.key, this.cropId});

  @override
  ConsumerState<AddEditCropScreen> createState() => _AddEditCropScreenState();
}

class _AddEditCropScreenState extends ConsumerState<AddEditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = false;

  final _nameCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();

  String _category = 'Rice';

  bool get _isEditing => widget.cropId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isFetching = true);
    try {
      final crop = await CropService.instance.getCropById(widget.cropId!);
      _nameCtrl.text = crop.name;
      _varietyCtrl.text = crop.variety ?? '';
      _descCtrl.text = crop.description ?? '';
      _priceCtrl.text = crop.pricePerKg.toStringAsFixed(2);
      _stockCtrl.text = crop.stockKg.toStringAsFixed(0);
      _minOrderCtrl.text = crop.minOrderKg?.toStringAsFixed(0) ?? '';
      _category = crop.category;
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await CropService.instance.updateCrop(
          cropId: widget.cropId!,
          pricePerKg: double.tryParse(_priceCtrl.text),
          stockKg: double.tryParse(_stockCtrl.text),
          description: _descCtrl.text.isNotEmpty ? _descCtrl.text : null,
          minOrderKg: _minOrderCtrl.text.isNotEmpty
              ? double.tryParse(_minOrderCtrl.text)
              : null,
        );
      } else {
        await CropService.instance.createCrop(
          name: _nameCtrl.text.trim(),
          category: _category,
          variety:
              _varietyCtrl.text.isNotEmpty ? _varietyCtrl.text.trim() : null,
          description: _descCtrl.text.isNotEmpty ? _descCtrl.text.trim() : null,
          pricePerKg: double.parse(_priceCtrl.text),
          stockKg: double.parse(_stockCtrl.text),
          minOrderKg: _minOrderCtrl.text.isNotEmpty
              ? double.tryParse(_minOrderCtrl.text)
              : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? AppLocalizations.of(context).cropUpdated
                : AppLocalizations.of(context).cropSubmitted),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (e is DioException) {
        ApiClient().resetCircuitBreaker();
        _showError(e.message ?? 'Network error. Please check your connection.');
      } else {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception: ', '')),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _varietyCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _minOrderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editListing : l.listNewGrain),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QA notice
                    _buildInfoBanner(
                      icon: Icons.verified_outlined,
                      text: l.qaNotice,
                      color: AppTheme.infoBlue,
                    ),
                    const SizedBox(height: 20),

                    // Category selector — all 8 grains
                    if (!_isEditing) ...[
                      _label(l.grainCategory),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.cropCategories.map((cat) {
                          final isSelected = _category == cat;
                          final emoji = AppConstants.cropEmojis[cat] ?? '🌾';
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : Colors.white,
                                borderRadius: AppTheme.radiusMedium,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.borderLight,
                                ),
                                boxShadow:
                                    isSelected ? AppTheme.cardShadow : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Name
                    if (!_isEditing) ...[
                      _label(l.grainName),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(hintText: l.grainNameHint),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Variety
                    _label(l.variety),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _varietyCtrl,
                      decoration: InputDecoration(hintText: l.varietyHint),
                    ),
                    const SizedBox(height: 16),

                    // Price per kg — always editable
                    _label(l.priceKgLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        hintText: '0.00',
                        suffixText: '/kg',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Price is required';
                        }
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Enter a valid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    _label(l.stockKgLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: 'kg',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Stock is required';
                        }
                        if ((int.tryParse(v) ?? 0) <= 0) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Min order
                    _label(l.minOrderLabel),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _minOrderCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'e.g., 50',
                        suffixText: 'kg',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _label(l.description),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: l.descriptionHint,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? l.saveChanges : l.submitForReview),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w600, color: AppTheme.textDark));

  Widget _buildInfoBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
