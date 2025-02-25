import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  static const String _kFullAccessProductId = 'trip_expert_full_access';
  final ValueNotifier<bool> isFullAccess = ValueNotifier<bool>(false);
  VoidCallback? onFullAccessPurchased;
  VoidCallback? onRestoredFullAccess;
  VoidCallback? onFullAccessAlreadyActive;
  ValueChanged<String>? onError;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  late final Set<String> _productIds = <String>{_kFullAccessProductId};
  final Set<String> _consumedTransactionIds = {};
  bool _isAvailable = false;

  ProductDetails? _fullAccessProduct;

  Future<void> initialize() async {
    _isAvailable = await InAppPurchase.instance.isAvailable();
    if (!_isAvailable) {
      onError?.call('In-app purchases are not available.');
      return;
    }
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        onError?.call('Purchase stream error: $error');
      },
    );
    await _loadProductsFromStore();
  }

  Future<void> _loadProductsFromStore() async {
    final response = await InAppPurchase.instance.queryProductDetails(_productIds);
    if (response.error != null) {
      onError?.call('Product query error: ${response.error}');
      return;
    }
    if (response.notFoundIDs.isNotEmpty) {
      onError?.call('Could not find product IDs: ${response.notFoundIDs.join(', ')}');
      return;
    }
    if (response.productDetails.isNotEmpty) {
      _fullAccessProduct = response.productDetails.first;
    }
  }

  Future<void> initiatePurchase() async {
    if (!_isAvailable) {
      onError?.call('Store not available on this device.');
      return;
    }
    if (_fullAccessProduct == null) {
      await _loadProductsFromStore();
      if (_fullAccessProduct == null) {
        onError?.call('Full access product not found.');
        return;
      }
    }

    if (isFullAccess.value) {
      onFullAccessAlreadyActive?.call();
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: _fullAccessProduct!);
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      onError?.call('Store not available for restoring purchases.');
      return;
    }
    if (isFullAccess.value) {
      onFullAccessAlreadyActive?.call();
      return;
    }
    await InAppPurchase.instance.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.purchased:
          _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails, isRestore: true);
          break;
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          onError?.call(purchaseDetails.error?.message ?? 'Unknown error');
          break;
        case PurchaseStatus.canceled:
          break;
      }
    }
  }

  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails, {bool isRestore = false}) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }
    if (_consumedTransactionIds.contains(purchaseDetails.purchaseID)) {
      return;
    }
    _consumedTransactionIds.add(purchaseDetails.purchaseID!);

    if (!isFullAccess.value) {
      isFullAccess.value = true;
      if (isRestore) {
        onRestoredFullAccess?.call();
      } else {
        onFullAccessPurchased?.call();
      }
    }
  }

  void dispose() {
    _purchaseSubscription.cancel();
  }
}
