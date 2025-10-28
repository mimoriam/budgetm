import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isExportSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          _buildCustomAppBar(context),
          _buildToggleChips(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: _isExportSelected ? _buildExportTab() : _buildImportTab(),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.yourData,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildChip(
              AppLocalizations.of(context)!.exportTabExport,
              _isExportSelected,
              () {
                setState(() => _isExportSelected = true);
              },
            ),
          ),
          Expanded(
            child: _buildChip(
              AppLocalizations.of(context)!.exportTabImport,
              !_isExportSelected,
              () {
                setState(() => _isExportSelected = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Colors.black54,
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildExportTab() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormBuilderRadioGroup<String>(
            name: 'period',
            initialValue: 'Last 365 Days',
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            options:
                [
                      AppLocalizations.of(context)!.exportCurrentMonth,
                      AppLocalizations.of(context)!.exportLast30Days,
                      AppLocalizations.of(context)!.exportLast90Days,
                      AppLocalizations.of(context)!.exportLast365Days,
                    ]
                    .map(
                      (period) => FormBuilderFieldOption(
                        value: period,
                        child: Text(period),
                      ),
                    )
                    .toList(growable: false),
            orientation: OptionsOrientation.vertical,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.exportFormat,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          FormBuilderDropdown<String>(
            name: 'format',
            initialValue: 'CSV',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            decoration: _inputDecoration(),
            items: [AppLocalizations.of(context)!.exportCsv, AppLocalizations.of(context)!.exportJson]
                .map(
                  (format) =>
                      DropdownMenuItem(value: format, child: Text(format)),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.exportOptions,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          FormBuilderCheckbox(
            name: 'export_account_data',
            title: Text(AppLocalizations.of(context)!.exportAccountData),
            initialValue: false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          FormBuilderCheckbox(
            name: 'export_goals_data',
            title: Text(AppLocalizations.of(context)!.exportGoalsData),
            initialValue: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    const textStyle = TextStyle(fontSize: 13);
    return Column(
      children: [
        Image.asset('images/icons/import_data.png', height: 220),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.exportImportInstructions,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Text('•', style: textStyle),
          title: Text(
            AppLocalizations.of(context)!.exportInstructions1,
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        ListTile(
          leading: const Text('•', style: textStyle),
          title: Text(
            AppLocalizations.of(context)!.exportInstructions2,
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        ListTile(
          leading: const Text('•', style: textStyle),
          title: Text(AppLocalizations.of(context)!.exportInstructions3, style: textStyle),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        ListTile(
          leading: const Text('•', style: textStyle),
          title: Text(
            AppLocalizations.of(context)!.exportInstructions4,
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      color: AppColors.scaffoldBackground,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_isExportSelected) {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                debugPrint(_formKey.currentState?.value.toString());
                Navigator.of(context).pop();
              }
            } else {
              // Handle import logic
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gradientEnd,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Text(
            _isExportSelected ? AppLocalizations.of(context)!.exportButtonExport : AppLocalizations.of(context)!.exportButtonImport,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
