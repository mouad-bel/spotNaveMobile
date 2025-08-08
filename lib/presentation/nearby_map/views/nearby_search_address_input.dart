import 'package:spotnav/common/utils/snackbar_util.dart';
import 'package:spotnav/presentation/nearby_map/cubits/center_coordinates/center_coordinates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:spotnav/common/app_assets.dart';
import 'package:spotnav/common/widgets/custom_back_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return TextField(
      controller: _addressController,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onSubmitted: (_) => _onSearch(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        hintText: 'Search location',
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black45,
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
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () => context.go('/home'),
            icon: ImageIcon(AssetImage(AppAssets.icons.arrow.left), size: 20),
          ),
        ),
        suffixIcon: IconButton(
          onPressed: _onSearch,
          icon: ImageIcon(AssetImage(AppAssets.icons.search), size: 20),
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
