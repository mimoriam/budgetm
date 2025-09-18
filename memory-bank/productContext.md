# Product Context

This file provides a high-level overview of the project and the expected product that will be created. Initially it is based upon projectBrief.md (if provided) and all other available project-related information in the working directory. This file is intended to be updated as the project evolves, and should be used to inform all other modes of the project's goals and context.
2025-09-17 07:16:45 - Log of updates made will be appended as footnotes to the end of this file.

*

## Project Goal

*   

## Key Features

*   

## Overall Architecture

*   
2025-09-17 07:28:0 - Initial project analysis completed. This is a Flutter-based personal finance management application with features for tracking income, expenses, budgets, goals, and personal finances (borrowed/lent money). The app includes onboarding, authentication, theme selection, and currency selection flows. It uses Provider for state management and SharedPreferences for local data storage.
[2025-09-18 1:18:00] - Fixed "table 'accounts' has more than one primary key" error by removing redundant PRIMARY KEY declaration in account_model.dart and updating app_database.dart schema version