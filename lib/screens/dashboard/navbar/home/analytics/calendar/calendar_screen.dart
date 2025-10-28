import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';
import 'package:budgetm/generated/i18n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final CleanCalendarController calendarController;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rangeStart = now;

    calendarController = CleanCalendarController(
      minDate: DateTime(now.year - 1),
      maxDate: now.add(const Duration(days: 365)),
      initialFocusDate: now,
      initialDateSelected: now,
      onRangeSelected: (firstDate, secondDate) {
        setState(() {
          _rangeStart = firstDate;
          _rangeEnd = secondDate;
        });
      },
      onDayTapped: (date) {
        setState(() {
          _rangeStart = date;
          _rangeEnd = null;
        });
      },
      weekdayStart: DateTime.sunday,
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    if (end != null) {
      if (DateUtils.isSameDay(start, end)) {
        return DateFormat('MMM d').format(start);
      }
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
    }
    return DateFormat('MMM d').format(start);
  }

  @override
  Widget build(BuildContext context) {
    String rangeText = AppLocalizations.of(context)!.calendarSelectDate;
    if (_rangeStart != null) {
      rangeText = _formatDateRange(_rangeStart!, _rangeEnd);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildCustomAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.calendarSelectDate,
                          style: const TextStyle(
                            color: AppColors.secondaryTextColorLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rangeText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              const Padding(padding: EdgeInsets.only(bottom: 6)),
              Expanded(
                child: ScrollableCleanCalendar(
                  calendarController: calendarController,
                  layout: Layout.BEAUTY,
                  monthTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  weekdayTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryTextColorLight,
                  ),
                  daySelectedBackgroundColor: AppColors.gradientEnd,
                  daySelectedBackgroundColorBetween: const Color(
                    0xFFFBFFB9,
                  ).withOpacity(0.7),
                  dayRadius: 100,
                  dayTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppLocalizations.of(context)!.buttonCancel,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.gradientEnd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.buttonOk,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.gradientEnd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 40),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
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
            padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
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
                  AppLocalizations.of(context)!.analyticsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
