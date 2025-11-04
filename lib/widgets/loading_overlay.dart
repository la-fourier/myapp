import 'package:flutter/material.dart';
import 'package:myapp/services/loading_service.dart';
import 'package:myapp/widgets/custom_loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LoadingService().isLoading,
      builder: (context, isLoading, _) {
        return Stack(
          children: [
            child,
            if (isLoading)
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
            if (isLoading) const Center(child: CustomLoadingIndicator()),
          ],
        );
      },
    );
  }
}
