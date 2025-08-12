import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/app_constants.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:spotnav/common/widgets/notification_badge.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:spotnav/presentation/notifications/bloc/notification_bloc.dart';
import 'package:spotnav/presentation/notifications/views/notification_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHeader extends StatelessWidget {
  final bool isDarkMode;
  
  const HomeHeader({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is Authenticated) {
          user = state.user;
        }
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              AppAssets.images.logo,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            AppConstants.appName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.getTextPrimaryColor(isDarkMode),
            ),
          ),
          subtitle: Text(
            'Discover amazing destinations',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(isDarkMode),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          trailing: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notificationState) {
              int unreadCount = 0;
              if (notificationState is NotificationLoaded) {
                unreadCount = notificationState.unreadCount;
              }
              
              return NotificationBadge(
                count: unreadCount,
                child: CustomIconButton(
                  icon: AppAssets.icons.notification,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<NotificationBloc>(),
                          child: const NotificationPanel(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
