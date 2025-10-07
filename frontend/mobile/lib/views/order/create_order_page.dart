import 'package:flutter/material.dart';

class CreateOrderPage extends StatefulWidget {
  final int? resellerId;

  const CreateOrderPage({Key? key, this.resellerId}) : super(key: key);

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_productController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Placeholder: simulate network call
    await Future.delayed(Duration(seconds: 1));

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order dibuat (placeholder)')),
    );

    Navigator.pop(context, true); // return true to indicate created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Order Baru'),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _productController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text('Buat Order'),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Reseller ID: ${widget.resellerId ?? '-'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
