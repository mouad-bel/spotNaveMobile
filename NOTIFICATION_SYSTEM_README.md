# Notification Panel System

## Overview

This document describes the implementation of the Notification Panel feature for the SpotNav Flutter app. The system provides a full-screen notification panel accessible via a bell icon in the top-right corner of the Home screen.

## Features

### 🌍 New Spot Suggestions
- Discover new destinations and hidden gems
- Real-time updates about new spots in user's area

### 🌀 Virtual/AR Tours
- Notifications about new virtual tours available
- AR experiences for historical sites and landmarks

### 💡 Personalized Tips
- Custom recommendations based on user preferences
- Local insights and travel tips

### 📅 Event Alerts
- Local festivals and cultural events
- Time-sensitive notifications for upcoming events

### ⚙ System Updates
- App updates and new features
- Onboarding reminders and tips

## Technical Architecture

### Data Structure

The notification system uses a static JSON file (`assets/data/notifications.json`) with the following structure:

```json
[
  {
    "id": "notif001",
    "title": "New Spot in Marrakech!",
    "body": "Discover 'Le Jardin Secret' in the Hidden Corners section.",
    "type": "newSpot",
    "timestamp": "2025-01-27T14:00:00Z",
    "isRead": false,
    "deepLink": "/spotDetail?id=SPOT001"
  }
]
```

### Components

#### 1. NotificationModel (`lib/data/models/notification_model.dart`)
- Defines the notification data structure
- Includes type-specific icons and labels
- Handles JSON serialization/deserialization

#### 2. NotificationLocalDataSource (`lib/data/data_sources/local/notification_local_data_source.dart`)
- Reads notifications from static JSON file
- Manages read/unread state
- Provides unread count functionality

#### 3. NotificationRepository (`lib/data/repositories/notification_repository.dart`)
- Business logic layer for notifications
- Sorts notifications by timestamp (newest first)
- Error handling and fallbacks

#### 4. NotificationBloc (`lib/presentation/notifications/bloc/notification_bloc.dart`)
- State management using BLoC pattern
- Handles loading, marking as read, and refreshing
- Manages notification state across the app

#### 5. NotificationPanel (`lib/presentation/notifications/views/notification_panel.dart`)
- Full-screen notification interface
- Displays notifications with type-specific styling
- Supports pull-to-refresh and mark-all-as-read

#### 6. NotificationBadge (`lib/common/widgets/notification_badge.dart`)
- Badge widget showing unread count
- Displays on bell icon in home header
- Handles overflow (99+ for large numbers)

## User Interface

### Home Screen Integration
- Bell icon in top-right corner of home header
- Badge showing unread notification count
- Tap to open full-screen notification panel

### Notification Panel Features
- **Header**: Title with "Mark all read" button (when unread notifications exist)
- **Empty State**: Friendly message when no notifications
- **Notification Items**: 
  - Type-specific icons and colors
  - Read/unread visual indicators
  - Timestamp formatting
  - Tap to mark as read and navigate

### Visual Design
- **Unread Notifications**: Highlighted with primary color background
- **Read Notifications**: Standard white background
- **Type Icons**: Emoji-based icons for each notification type
- **Color Coding**: Different colors for different notification types

## Usage

### For Users
1. **Access Notifications**: Tap the bell icon in the top-right corner of the Home screen
2. **View Notifications**: Scroll through the list of notifications
3. **Mark as Read**: Tap any notification to mark it as read
4. **Mark All as Read**: Use the "Mark all read" button in the header
5. **Refresh**: Pull down to refresh the notification list

### For Developers

#### Adding New Notifications
1. Edit `assets/data/notifications.json`
2. Add new notification objects with required fields
3. Use appropriate `type` values: `newSpot`, `virtualTour`, `personalizedTip`, `eventAlert`, `systemUpdate`

#### Customizing Notification Types
1. Update `NotificationModel.typeIcon` and `NotificationModel.typeLabel` getters
2. Add new type colors in `NotificationItem._getTypeColor()`

#### Deep Link Navigation
1. Implement navigation logic in `NotificationPanel._handleDeepLink()`
2. Parse the `deepLink` field and navigate accordingly

## Dependencies

The notification system uses the following Flutter packages:
- `flutter_bloc`: State management
- `gap`: Layout spacing
- `intl`: Date formatting (for future enhancements)

## Testing

A test file (`lib/test_notification.dart`) is provided to verify the notification system functionality:

```bash
flutter run -t lib/test_notification.dart
```

## Future Enhancements

1. **Real-time Updates**: Integrate with Firebase Cloud Messaging for push notifications
2. **Push Notifications**: Send notifications when app is in background
3. **Notification Preferences**: Allow users to customize notification types
4. **Rich Notifications**: Support for images and action buttons
5. **Analytics**: Track notification engagement and user behavior
6. **Offline Support**: Cache notifications for offline viewing

## File Structure

```
lib/
├── data/
│   ├── models/
│   │   └── notification_model.dart
│   ├── data_sources/
│   │   └── local/
│   │       └── notification_local_data_source.dart
│   └── repositories/
│       └── notification_repository.dart
├── presentation/
│   └── notifications/
│       ├── bloc/
│       │   └── notification_bloc.dart
│       └── views/
│           └── notification_panel.dart
└── common/
    └── widgets/
        └── notification_badge.dart

assets/
└── data/
    └── notifications.json
```

## Integration Points

- **Home Header**: Bell icon with badge
- **Dependency Injection**: Registered in `lib/core/di.dart`
- **Main App**: NotificationBloc provided in `lib/main.dart`
- **Home Fragment**: Loads notifications on page load

## Performance Considerations

- Notifications are loaded once and cached in memory
- JSON parsing is done asynchronously
- Badge updates are reactive to state changes
- Pull-to-refresh provides manual refresh capability

## Error Handling

- Graceful fallback to empty list if JSON loading fails
- Silent error handling for read/unread operations
- User-friendly error messages in UI
- Retry functionality for failed operations 