import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/presentation/nearby_map/cubits/center_coordinates/center_coordinates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/presentation/settings/bloc/theme_bloc.dart';

class NearbySearchAddressInput extends StatefulWidget {
  final String initialAddress;

  const NearbySearchAddressInput({super.key, required this.initialAddress});

  @override
  State<NearbySearchAddressInput> createState() =>
      _NearbySearchAddressInputState();
}

class _NearbySearchAddressInputState extends State<NearbySearchAddressInput> {
  static const _borderRadius = BorderRadius.all(Radius.circular(16));

  final _addressController = TextEditingController();

  void _onSearch() {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      SnackbarUtil.showError(context, 'Location must be filled');
      return;
    }

    context.read<CenterCoordinatesCubit>().updateCoordinatesFromAddress(
      address,
    );
  }

  @override
  void initState() {
    _addressController.text = widget.initialAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.read<ThemeBloc>().state is ThemeLoaded 
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDarkMode 
        : false;
        
    return TextField(
      controller: _addressController,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onSubmitted: (_) => _onSearch(),
      style: TextStyle(
        color: AppColors.getTextPrimaryColor(isDarkMode),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.getInputBackgroundColor(isDarkMode),
        isDense: true,
        hintText: 'Search location',
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.getTextThinColor(isDarkMode),
        ),
        contentPadding: const EdgeInsets.all(0),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        prefixIcon: UnconstrainedBox(
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.getCardBackgroundColor(isDarkMode),
              foregroundColor: AppColors.getPrimaryColor(isDarkMode),
            ),
            onPressed: () => context.go('/home'),
            icon: ImageIcon(AssetImage(AppAssets.icons.arrow.left), size: 20),
          ),
        ),
        suffixIcon: IconButton(
          onPressed: _onSearch,
          icon: ImageIcon(
            AssetImage(AppAssets.icons.search), 
            size: 20,
            color: AppColors.getPrimaryColor(isDarkMode),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
