import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotnav/data/models/notification_model.dart';
import 'package:spotnav/data/repositories/firebase_notification_repository.dart';

// Events
abstract class NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {}

class StartListeningToNotificationsEvent extends NotificationEvent {}

class StopListeningToNotificationsEvent extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final String notificationId;
  MarkAsReadEvent(this.notificationId);
}

class MarkAllAsReadEvent extends NotificationEvent {}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;
  DeleteNotificationEvent(this.notificationId);
}

class DeleteAllNotificationsEvent extends NotificationEvent {}

class RefreshNotificationsEvent extends NotificationEvent {}

// States
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseNotificationRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _notificationSubscription;

  NotificationBloc({
    required FirebaseNotificationRepository repository,
    required FirebaseAuth firebaseAuth,
  })  : _repository = repository,
        _firebaseAuth = firebaseAuth,
        super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<StartListeningToNotificationsEvent>(_onStartListening);
    on<StopListeningToNotificationsEvent>(_onStopListening);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllNotificationsEvent>(_onDeleteAllNotifications);
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
  }

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('🔔 NotificationBloc: User not authenticated');
      emit(NotificationError('User not authenticated'));
      return;
    }

    print('🔔 NotificationBloc: Loading notifications for user: $userId');
    emit(NotificationLoading());
    
    final notificationsResult = await _repository.fetchNotifications(userId);
    final unreadCountResult = await _repository.getUnreadCount(userId);

    notificationsResult.fold(
      (failure) {
        print('🔔 NotificationBloc: Failed to load notifications: ${failure.message}');
        emit(NotificationError(failure.message));
      },
      (notifications) {
        print('🔔 NotificationBloc: Loaded ${notifications.length} notifications');
        unreadCountResult.fold(
          (failure) {
            print('🔔 NotificationBloc: Failed to get unread count: ${failure.message}');
            emit(NotificationLoaded(
              notifications: notifications,
              unreadCount: 0,
            ));
          },
          (unreadCount) {
            print('🔔 NotificationBloc: Unread count: $unreadCount');
            emit(NotificationLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ));
          },
        );
      },
    );
  }

  Future<void> _onStartListening(
    StartListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      print('🔔 NotificationBloc: User not authenticated for streaming');
      emit(NotificationError('User not authenticated'));
      return;
    }

    print('🔔 NotificationBloc: Starting to listen for user: $userId');
    // Cancel existing subscription
    await _notificationSubscription?.cancel();

    // Only emit loading if we don't already have data
    if (state is! NotificationLoaded) {
      print('🔔 NotificationBloc: Emitting loading state');
      emit(NotificationLoading());
    }

    try {
      print('🔔 NotificationBloc: Setting up stream subscription');
      _notificationSubscription = _repository.streamNotifications(userId).listen(
        (result) {
          print('🔔 NotificationBloc: Received stream result');
          result.fold(
            (failure) {
              print('🔔 NotificationBloc: Stream failure: ${failure.message}');
              if (!emit.isDone) {
                emit(NotificationError(failure.message));
              }
            },
            (notifications) async {
              print('🔔 NotificationBloc: Stream loaded ${notifications.length} notifications');
              if (!emit.isDone) {
                // Get unread count
                final unreadCountResult = await _repository.getUnreadCount(userId);
                final unreadCount = unreadCountResult.fold(
                  (failure) => 0,
                  (count) => count,
                );

                print('🔔 NotificationBloc: Emitting loaded state with ${notifications.length} notifications');
                emit(NotificationLoaded(
                  notifications: notifications,
                  unreadCount: unreadCount,
                ));
              }
            },
          );
        },
        onError: (error) {
          print('🔔 NotificationBloc: Stream error: $error');
          if (!emit.isDone) {
            emit(NotificationError('Error streaming notifications: $error'));
          }
        },
      );
      print('🔔 NotificationBloc: Stream subscription set up successfully');
    } catch (e) {
      print('🔔 NotificationBloc: Failed to start listening: $e');
      if (!emit.isDone) {
        emit(NotificationError('Failed to start listening: $e'));
      }
    }
  }

  Future<void> _onStopListening(
    StopListeningToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    final result = await _repository.markAsRead(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError('Failed to mark notification as read')),
      (_) async {
        // Refresh notifications
        add(LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    final result = await _repository.markAllAsRead(userId);
    result.fold(
      (failure) => emit(NotificationError('Failed to mark all notifications as read')),
      (_) async {
        // Refresh notifications
        add(LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.deleteNotification(event.notificationId);
    result.fold(
      (failure) => emit(NotificationError('Failed to delete notification')),
      (_) async {
        // Update state directly without reloading
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = currentState.notifications
              .where((notification) => notification.id != event.notificationId)
              .toList();
          
          // Recalculate unread count
          final unreadCount = updatedNotifications
              .where((notification) => !notification.isRead)
              .length;
          
          emit(NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: unreadCount,
          ));
        }
      },
    );
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    final result = await _repository.deleteAllNotifications(userId);
    result.fold(
      (failure) => emit(NotificationError('Failed to delete all notifications')),
      (_) async {
        // Refresh notifications
        add(LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(NotificationError('User not authenticated'));
      return;
    }

    final notificationsResult = await _repository.fetchNotifications(userId);
    final unreadCountResult = await _repository.getUnreadCount(userId);

    notificationsResult.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        unreadCountResult.fold(
          (failure) => emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: 0,
          )),
          (unreadCount) => emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          )),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}