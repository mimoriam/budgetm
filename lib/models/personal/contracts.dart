mixin DueDateContract {
  DateTime get date;    // mandatory
  DateTime get dueDate; // mandatory

  void validateDates() {
    if (date.isAtSameMomentAs(dueDate)) {
      throw ArgumentError('date and dueDate cannot be the same moment');
    }
    if (dueDate.isBefore(date)) {
      throw ArgumentError('dueDate must be after date');
    }
  }
}