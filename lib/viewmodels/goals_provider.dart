import 'package:flutter/foundation.dart';
import 'package:budgetm/models/goal.dart';
import 'package:budgetm/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsProvider extends ChangeNotifier {
  GoalsProvider();

  Future<void> addGoal(FirestoreGoal goal) async {
    await FirestoreService.instance.createGoal(goal);
    // Notify listeners in case UI needs to react to added goal (e.g., list refresh)
    notifyListeners();
  }

  // Expose Firestore goals stream to the UI
  Stream<List<FirestoreGoal>> getGoals() {
    return FirestoreService.instance.getGoals();
  }

  // Update a goal's progress by adding an amount to currentAmount and mark completed if target reached
  Future<void> updateGoalProgress(String goalId, double amount) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId);

    await firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Goal not found');
      }
      final data = snap.data() as Map<String, dynamic>;
      final double currentAmount = (data['currentAmount'] as num?)?.toDouble() ?? 0.0;
      final double targetAmount = (data['targetAmount'] as num?)?.toDouble() ?? 0.0;

      final double newCurrentAmount = currentAmount + amount;
      final bool isCompleted = newCurrentAmount >= targetAmount;

      tx.update(docRef, {
        'currentAmount': newCurrentAmount,
        'isCompleted': isCompleted,
      });
    });

    // Notify listeners so any UI dependent on goals can refresh
    notifyListeners();
  }
  
  Future<void> deleteGoal(String goalId, {bool cascadeDelete = false}) async {
    await FirestoreService.instance.deleteGoal(goalId, cascadeDelete: cascadeDelete);
    // Notify listeners so lists refresh after deletion
    notifyListeners();
  }

  Future<bool> doesGoalExist(String name) async {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      // Cannot check without authentication; treat as non-existing
      return false;
    }

    final lowerName = name.trim().toLowerCase();
    final querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final existingName = (data['name'] as String? ?? '').trim().toLowerCase();
      if (existingName == lowerName) {
        return true;
      }
    }
    return false;
  }
}