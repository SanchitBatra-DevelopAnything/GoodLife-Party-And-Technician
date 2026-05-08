import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove),
          ),

          Text(
            quantity.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}