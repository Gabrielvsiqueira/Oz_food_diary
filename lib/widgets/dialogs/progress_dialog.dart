import 'dart:async';

import 'package:flutter/material.dart';

import '../../configs/constants/app_constants.dart';

/// Bloqueia a tela com um indicador de progresso até [task] terminar e
/// devolve o resultado.
Future<T> showProgressDialog<T>(
  BuildContext context, {
  required Future<T> task,
  required String message,
}) async {
  final navigator = Navigator.of(context);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    ),
  );
  try {
    return await task;
  } finally {
    navigator.pop();
  }
}
