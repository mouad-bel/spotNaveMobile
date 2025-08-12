import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:spotnav/presentation/nearby_map/cubits/nearby_radius/nearby_radius_cubit.dart';
import 'package:spotnav/presentation/nearby_map/views/destination_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

class NearbyRadiusInput extends StatefulWidget {
  const NearbyRadiusInput({super.key});

  static const _borderRadius = BorderRadius.all(Radius.circular(16));

  @override
  State<NearbyRadiusInput> createState() => _NearbyRadiusInputState();
}

class _NearbyRadiusInputState extends State<NearbyRadiusInput> {
  final TextEditingController _radiusController = TextEditingController();

  void _updateRadius(BuildContext context) {
    final radius = double.tryParse(_radiusController.text.trim());

    if (radius == null) {
      SnackbarUtil.showError(context, 'Radius is not valid');
      return;
    }
    if (radius < DestinationMap.minRadius) {
      SnackbarUtil.showError(
        context,
        'Minimum Radius: ${DestinationMap.minRadius}km',
      );
      return;
    }
    if (radius > DestinationMap.maxRadius) {
      SnackbarUtil.showError(
        context,
        'Maximum Radius: ${DestinationMap.maxRadius}km',
      );
      return;
    }

    context.read<NearbyRadiusCubit>().update(radius);
  }

  @override
  void initState() {
    const initialRadius = DestinationMap.initialRadius;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _radiusController.text = initialRadius.toString();
      context.read<NearbyRadiusCubit>().update(initialRadius);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getInputBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getDividerColor(isDarkMode),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _radiusController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _updateRadius(context),
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(isDarkMode),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                hintText: 'Radius (km)',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.getTextThinColor(isDarkMode),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.getDividerColor(isDarkMode),
          ),
          CustomIconButton(
            onTap: () => _updateRadius(context),
            icon: AppAssets.icons.refresh,
            backgroundColor: AppColors.getPrimaryColor(isDarkMode),
            foregroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
            borderRadius: BorderRadiusGeometry.circular(12),
            size: const Size(40, 40),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }
}
