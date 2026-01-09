import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  final String networkName; // آسيا أو زين
  final Color networkColor;

  const TransferScreen({super.key, required this.networkName, required this.networkColor});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? _selectedMethod; // تحويل مباشر أو كود كرت
  final TextEditingController _amountController = TextEditingController();
  double _receivedAmount = 0.0; // القيمة التي ستصل للبطاقة

  // دالة الحساب الفوري (استقطاع 20%)
  void _calculateAmount(String value) {
    if (value.isEmpty) {
      setState(() => _receivedAmount = 0.0);
      return;
    }
    double amount = double.tryParse(value) ?? 0.0;
    setState(() {
      _receivedAmount = amount * 0.80;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('تحويل عبر ${widget.networkName}', style: const TextStyle(color: Colors.white)),
        backgroundColor: widget.networkColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع التحويل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // القائمة المنسدلة (Dropdown)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMethod,
                  hint: const Text('None'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'direct', child: Text('تحويل رصيد مباشر من SIMcard')),
                    DropdownMenuItem(value: 'code', child: Text('تحويل باستخدام الكود السري للبطاقة')),
                  ],
                  onChanged: (val) => setState(() => _selectedMethod = val),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // الحقول تظهر فقط بعد اختيار النوع
            if (_selectedMethod != null) ...[
              
              // حقل رقم الهاتف (يظهر فقط في المباشر ويكون غير قابل للتعديل)
              if (_selectedMethod == 'direct') ...[
                const Text('رقم هاتفك المسجل', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: '0770XXXXXXX', // رقم المستخدم المسجل
                  enabled: false,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // حقل الكود السري (يظهر فقط في كود الكرت)
              if (_selectedMethod == 'code') ...[
                const Text('الكود السري للبطاقة', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'ادخل الـ 16 رقم هنا',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // حقل رقم حساب البطاقة البنكية
              Row(
                children: [
                  const Text('رقم حساب البطاقة البنكية', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    onPressed: () {
                      // هنا تظهر الصورة التوضيحية للرقم القصير
                    },
                  ),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'ادخل الرقم القصير (مثلاً 10 ارقام)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),

              // حقل قيمة الرصيد مع الحاسبة
              const Text('قيمة الرصيد المراد تحويله', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                onChanged: _calculateAmount,
                decoration: InputDecoration(
                  hintText: 'مثال: 10000',
                  suffixText: 'د.ع',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),

              // الحاسبة الذكية
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF50C878).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سيصل لبطاقتك:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_receivedAmount.toStringAsFixed(0)} د.ع', 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // زر التحويل النهائي
              ElevatedButton(
                onPressed: () {
                  // منطق التحويل (اندرويد او ايفون)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C878),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('تأكيد وعمل التحويل', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
