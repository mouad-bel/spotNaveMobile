import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/app_colors.dart';
import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/common/widgets/custom_icon_button.dart';
import 'package:spotnav/presentation/nearby_map/cubits/nearby_radius/nearby_radius_cubit.dart';
import 'package:spotnav/presentation/nearby_map/views/destination_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return TextField(
      controller: _radiusController,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        hintText: 'Radius',
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black45,
        ),
        contentPadding: const EdgeInsets.all(0),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderRadius: NearbyRadiusInput._borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: NearbyRadiusInput._borderRadius,
          borderSide: BorderSide.none,
        ),
        prefixIcon: UnconstrainedBox(
          child: ImageIcon(AssetImage(AppAssets.icons.radar), size: 20),
        ),
        suffixIconConstraints: const BoxConstraints(maxWidth: 30 + 46),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'km',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            CustomIconButton(
              icon: AppAssets.icons.checked,
              onTap: () => _updateRadius(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }
}
