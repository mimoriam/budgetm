import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hugeicons/hugeicons.dart';

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
                'Your Data',
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
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Container(
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isExportSelected ? 0 : (width / 2) - 4,
                  right: _isExportSelected ? (width / 2) - 4 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gradientEnd,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 42,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildChip(
                        'Export',
                        _isExportSelected,
                        () => setState(() => _isExportSelected = true),
                      ),
                    ),
                    Expanded(
                      child: _buildChip(
                        'Import',
                        !_isExportSelected,
                        () => setState(() => _isExportSelected = false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
                      'Current Month',
                      'Last 30 Days',
                      'Last 90 Days',
                      'Last 365 Days',
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
          const Text(
            'Format',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            items: ['CSV', 'JSON']
                .map(
                  (format) =>
                      DropdownMenuItem(value: format, child: Text(format)),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Options',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          FormBuilderCheckbox(
            name: 'export_account_data',
            title: const Text('Export Account Data'),
            initialValue: false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          FormBuilderCheckbox(
            name: 'export_goals_data',
            title: const Text('Export Goals Data'),
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
        const Text(
          'You can import your data from a CSV file into the app.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Text('•', style: textStyle),
          title: Text(
            'Save the example file to see the required data format;',
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        const ListTile(
          leading: Text('•', style: textStyle),
          title: Text(
            'Format your data according to the template. Make sure that the columns, their order and names are exactly the same as in the template. The names of columns should be in English;',
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        const ListTile(
          leading: Text('•', style: textStyle),
          title: Text('Press Import and select your file;', style: textStyle),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        const ListTile(
          leading: Text('•', style: textStyle),
          title: Text(
            'Choose whether to override existing data or add imported data to the existing data. When choosing the override option, existing data will be permanently deleted;',
            style: textStyle,
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: 10,
        ),
        const ListTile(
          leading: Text('•', style: textStyle),
          title: Text(
            'If the imported transactions use currencies that are not in your list of currencies, you will be prompted to add them.',
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
            _isExportSelected ? 'Export' : 'Import',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
