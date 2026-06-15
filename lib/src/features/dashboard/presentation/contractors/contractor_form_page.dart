import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/core/utils/india_input_validators.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_dialog.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_select_sheet_field.dart';
import 'package:wcr_pmis_mobile/src/core/widgets/app_text_form_field.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';

class ContractorFormPage extends StatefulWidget {
  const ContractorFormPage({
    super.key,
    required this.dataSource,
    this.contractorId,
  });

  static const String routeName = 'contractor-form';
  static const String routePath = '/contractors/form';

  final DashboardRemoteDataSource dataSource;
  final String? contractorId;

  @override
  State<ContractorFormPage> createState() => _ContractorFormPageState();
}

class _ContractorFormPageState extends State<ContractorFormPage> {
  static const List<String> _specializations = <String>[
    'Construction',
    'Consultancy',
    'Design Consultancy',
    'OEM',
    'Project Management Consultancy',
  ];
  static const int _shortCodeMaxLength = 5;
  static final RegExp _alphanumericPattern = RegExp(r'[A-Z0-9]');

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _shortCodeCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _primaryContactCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _gstCtrl = TextEditingController();
  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _accountNoCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _bankAddressCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();

  String? _specialization;
  bool _loading = false;
  bool _submitting = false;
  String? _loadError;

  bool get _isEdit =>
      widget.contractorId != null && widget.contractorId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadContractor());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortCodeCtrl.dispose();
    _panCtrl.dispose();
    _addressCtrl.dispose();
    _primaryContactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNoCtrl.dispose();
    _ifscCtrl.dispose();
    _bankAddressCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Update Contractor' : 'Add Contractor'),
      ),
      body: Stack(
        children: <Widget>[
          if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_loadError!, textAlign: TextAlign.center),
              ),
            )
          else
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: <Widget>[
                _sectionCard(
                  title: 'Basic Information',
                  children: <Widget>[
                    AppTextFormField(
                      label: 'Contractor Name *',
                      controller: _nameCtrl,
                      hintText: 'Enter contractor name',
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Contractor Short Code',
                      controller: _shortCodeCtrl,
                      hintText: 'Max $_shortCodeMaxLength characters',
                      maxLength: _shortCodeMaxLength,
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'PAN Number *',
                      controller: _panCtrl,
                      hintText: 'e.g. ABCDE1234F',
                      maxLength: 10,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: <TextInputFormatter>[
                        _UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(_alphanumericPattern),
                      ],
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppSelectSheetField<String>(
                      label: 'Specialization *',
                      title: 'Select Specialization',
                      items: _specializations,
                      itemLabelBuilder: (String value) => value,
                      value: _specialization,
                      enabled: !_loading && !_submitting,
                      placeholderText: 'Select specialization',
                      onChanged: (String value) =>
                          setState(() => _specialization = value),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _sectionCard(
                  title: 'Contact Details',
                  children: <Widget>[
                    AppTextFormField(
                      label: 'Address',
                      controller: _addressCtrl,
                      hintText: 'Enter address',
                      minLines: 2,
                      maxLines: 4,
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Primary Contact',
                      controller: _primaryContactCtrl,
                      hintText: '10 digit number',
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      hintText: '10 digit number',
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Email',
                      controller: _emailCtrl,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: _loading || _submitting,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _sectionCard(
                  title: 'Bank & Tax Details',
                  children: <Widget>[
                    AppTextFormField(
                      label: 'GST Number',
                      controller: _gstCtrl,
                      hintText: '15 character GSTIN',
                      maxLength: 15,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: <TextInputFormatter>[
                        _UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(_alphanumericPattern),
                      ],
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Bank Name',
                      controller: _bankNameCtrl,
                      hintText: 'Enter bank name',
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Account Number',
                      controller: _accountNoCtrl,
                      hintText: 'Enter account number',
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'IFSC Code',
                      controller: _ifscCtrl,
                      hintText: 'Enter IFSC code',
                      readOnly: _loading || _submitting,
                    ),
                    const SizedBox(height: 10),
                    AppTextFormField(
                      label: 'Bank Address',
                      controller: _bankAddressCtrl,
                      hintText: 'Enter bank address',
                      minLines: 2,
                      maxLines: 3,
                      readOnly: _loading || _submitting,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _sectionCard(
                  title: 'Remarks',
                  children: <Widget>[
                    AppTextFormField(
                      label: 'Remarks',
                      controller: _remarksCtrl,
                      hintText: 'Enter remarks',
                      minLines: 2,
                      maxLines: 4,
                      readOnly: _loading || _submitting,
                    ),
                  ],
                ),
              ],
            ),
          if (_loading || _submitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _loadError == null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _loading || _submitting ? null : _submit,
                        child: Text(_isEdit ? 'Update' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _loadContractor() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final List<Map<String, dynamic>> rows =
          await widget.dataSource.fetchContractorsList();
      final String id = widget.contractorId!.trim();
      Map<String, dynamic>? match;
      for (final Map<String, dynamic> row in rows) {
        if (_string(row['contractorId']) == id) {
          match = row;
          break;
        }
      }
      if (match == null) {
        setState(() => _loadError = 'Contractor not found.');
        return;
      }
      _applyRow(match);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadError = 'Unable to load contractor details.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyRow(Map<String, dynamic> row) {
    _nameCtrl.text = _string(row['contractorName']);
    _shortCodeCtrl.text = _string(row['contractorShortCode']);
    _panCtrl.text = _string(row['panNumber']);
    _addressCtrl.text = _string(row['address']);
    _primaryContactCtrl.text = _string(row['primaryContact']);
    _phoneCtrl.text = _string(row['phoneNumber']);
    _emailCtrl.text = _string(row['email']);
    _gstCtrl.text = _string(row['gstNumber']);
    _bankNameCtrl.text = _string(row['bankName']);
    _accountNoCtrl.text = _string(row['accountNo']);
    _ifscCtrl.text = _string(row['ifscCode']);
    _bankAddressCtrl.text = _string(row['bankAddress']);
    _remarksCtrl.text = _string(row['remarks']);
    final String spec = _string(
      row['specilaization'] ?? row['specialization'],
    );
    _specialization = _specializations.contains(spec) ? spec : null;
  }

  Map<String, dynamic> _buildPayload() {
    return <String, dynamic>{
      'contractorName': _nameCtrl.text.trim(),
      'contractorShortCode': _shortCodeCtrl.text.trim(),
      'panNumber': _panCtrl.text.trim().toUpperCase(),
      'specilaization': _specialization ?? '',
      'address': _addressCtrl.text.trim(),
      'primaryContact': _primaryContactCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'gstNumber': _gstCtrl.text.trim().toUpperCase(),
      'bankName': _bankNameCtrl.text.trim(),
      'accountNo': _accountNoCtrl.text.trim(),
      'ifscCode': _ifscCtrl.text.trim(),
      'bankAddress': _bankAddressCtrl.text.trim(),
      'remarks': _remarksCtrl.text.trim(),
      if (_isEdit) 'searchStr': null,
    };
  }

  Future<void> _submit() async {
    final String? validationError = _validationError();
    if (validationError != null) {
      await AppDialog.show(
        context: context,
        title: 'Invalid Details',
        message: validationError,
        type: AppDialogType.info,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> payload = _buildPayload();
      if (_isEdit) {
        await widget.dataSource.updateContractor(
          contractorId: widget.contractorId!.trim(),
          payload: payload,
        );
      } else {
        await widget.dataSource.addContractor(payload);
      }
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: _isEdit ? 'Updated' : 'Saved',
        message: _isEdit
            ? 'Contractor updated successfully.'
            : 'Contractor added successfully.',
        type: AppDialogType.success,
      );
      if (!mounted) {
        return;
      }
      context.pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppDialog.show(
        context: context,
        title: _isEdit ? 'Update Failed' : 'Save Failed',
        message: 'Unable to save contractor. Please verify the data and retry.',
        type: AppDialogType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _validationError() {
    if (_nameCtrl.text.trim().isEmpty) {
      return 'Contractor name is required.';
    }
    if (_specialization == null || _specialization!.isEmpty) {
      return 'Specialization is required.';
    }

    final List<String? Function()> checks = <String? Function()>[
      () => IndiaInputValidators.validateShortCode(
        _shortCodeCtrl.text,
        maxLength: _shortCodeMaxLength,
      ),
      () => IndiaInputValidators.validatePan(_panCtrl.text, required: true),
      () => IndiaInputValidators.validateTenDigitPhone(
        _primaryContactCtrl.text,
        label: 'Primary contact',
      ),
      () => IndiaInputValidators.validateTenDigitPhone(
        _phoneCtrl.text,
        label: 'Phone number',
      ),
      () => IndiaInputValidators.validateEmail(_emailCtrl.text),
      () => IndiaInputValidators.validateGst(_gstCtrl.text),
    ];
    for (final String? Function() check in checks) {
      final String? error = check();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  String _string(dynamic raw) {
    if (raw == null) {
      return '';
    }
    final String value = raw.toString().trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return '';
    }
    return value;
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
