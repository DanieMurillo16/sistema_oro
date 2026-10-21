import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sistema_oro/core/config/app_config.dart';
import 'package:sistema_oro/core/errors/app_exception.dart';
import 'package:sistema_oro/core/services/app_toast.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/auth/providers/login_provider.dart';
import 'package:sistema_oro/features/auth/widgets/login_form.dart';
import 'package:sistema_oro/shared/widgets/app_appear.dart';
import 'package:sistema_oro/shared/widgets/brand_mark.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasError) {
        AppToast.error(userErrorMessage(next.error));
      }
    });
    final isLoading = ref.watch(loginProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: DesignTokens.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: DesignTokens.loginMaxWidth,
              ),
              child: AppAppear(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: DesignTokens.logoSize),
                    const SizedBox(height: DesignTokens.spaceMd),
                    Text(AppConfig.appName, style: textTheme.headlineSmall),
                    const SizedBox(height: DesignTokens.spaceXs),
                    Text(
                      'Ingresa a la administración',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: DesignTokens.spaceXl),
                    LoginForm(
                      isLoading: isLoading,
                      onSubmit: (username, password) => ref
                          .read(loginProvider.notifier)
                          .submit(username, password),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
