import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/blocs/auth/auth_bloc.dart';
import 'package:spotnav/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DiscoverFragment extends StatelessWidget {
  const DiscoverFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AppBar(
            centerTitle: true,
            forceMaterialTransparency: true,
            backgroundColor: AppColors.background,
            title: const Text(
              'Discover Destination',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.white,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  UserModel? user;
                  if (state is Authenticated) {
                    user = state.user;
                  }
                  final address = user?.address ?? 'Garut, Indonesia';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ),
                        leading: ImageIcon(
                          AssetImage(AppAssets.icons.location),
                          color: AppColors.textPrimary,
                        ),
                        title: const Text(
                          'Your Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          address,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      ListTile(
                        leading: ImageIcon(
                          AssetImage(AppAssets.icons.map),
                          color: AppColors.textPrimary,
                        ),
                        title: const Text(
                          'Find on Map',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        onTap: () {
                          context.push('/nearby-map', extra: address);
                        },
                        trailing: Transform.translate(
                          offset: const Offset(8, 0),
                          child: ImageIcon(
                            AssetImage(AppAssets.icons.navigation.next),
                            color: AppColors.textPrimary,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                AppAssets.images.map.nearby,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
