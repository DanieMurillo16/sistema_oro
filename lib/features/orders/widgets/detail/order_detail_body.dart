import 'package:flutter/material.dart';
import 'package:sistema_oro/core/theme/design_tokens.dart';
import 'package:sistema_oro/features/orders/models/order_detail.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_delivery_card.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_outcome_card.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_payments_card.dart';
import 'package:sistema_oro/features/orders/widgets/detail/order_summary_card.dart';

/// El contenido del detalle: una columna de tarjetas con scroll.
class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({super.key, required this.detail});

  final OrderDetail detail;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      OrderSummaryCard(order: detail.order),
      if (OrderOutcomeCard.applies(detail)) OrderOutcomeCard(detail: detail),
      OrderDeliveryCard(order: detail.order),
      OrderPaymentsCard(detail: detail),
    ];
    return ListView.separated(
      padding: DesignTokens.pagePaddingFor(MediaQuery.sizeOf(context).width)
          .copyWith(bottom: DesignTokens.listBottomSpace),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: DesignTokens.spaceMd),
      itemBuilder: (_, index) => cards[index],
    );
  }
}
