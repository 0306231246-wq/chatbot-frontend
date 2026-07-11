part of 'chat_message_list.dart';

class _BuildCard extends StatelessWidget {
  final PcBuild pcBuild;
  final Function(PcBuild)? onApplyBuild;
  final Color primary;

  const _BuildCard({
    required this.pcBuild,
    this.onApplyBuild,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BuildCardHeader(pcBuild: pcBuild, primary: primary),
          Divider(color: Colors.grey.shade200, height: 12),
          _DetailRow(label: 'Vi xử lý', value: pcBuild.cpuModel),
          _DetailRow(label: 'Bo mạch chủ', value: pcBuild.motherboardModel),
          _DetailRow(label: 'Card đồ họa', value: pcBuild.gpuModel),
          _DetailRow(
            label: 'Lắp ráp & test',
            value: '${(pcBuild.assemblyFee / 1000).toStringAsFixed(0)}K đ',
          ),
          Divider(color: Colors.grey.shade200, height: 12),
          _BuildCardTotal(pcBuild: pcBuild),
          const SizedBox(height: 10),
          _ApplyBuildButton(pcBuild: pcBuild, onApplyBuild: onApplyBuild),
        ],
      ),
    );
  }
}

class _BuildCardHeader extends StatelessWidget {
  final PcBuild pcBuild;
  final Color primary;

  const _BuildCardHeader({
    required this.pcBuild,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          pcBuild.buildId,
          style: TextStyle(
            color: primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Sao chép cấu hình',
              child: InkWell(
                onTap: () => _copyBuild(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.copy_rounded, color: primary, size: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.computer, color: primary, size: 16),
          ],
        ),
      ],
    );
  }

  void _copyBuild(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _buildCopyText()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã sao chép cấu hình'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  String _buildCopyText() {
    final totalPriceStr = _formatPrice(pcBuild.totalPrice as double);
    final assemblyFee = (pcBuild.assemblyFee / 1000).toStringAsFixed(0);
    return '${pcBuild.buildId}\n'
        'Vi xử lý: ${pcBuild.cpuModel}\n'
        'Bo mạch chủ: ${pcBuild.motherboardModel}\n'
        'Card đồ họa: ${pcBuild.gpuModel}\n'
        'Lắp ráp & test: ${assemblyFee}K đ\n'
        'Tổng cộng: ${totalPriceStr}đ';
  }
}

class _BuildCardTotal extends StatelessWidget {
  final PcBuild pcBuild;

  const _BuildCardTotal({required this.pcBuild});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tổng cộng:',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          '${_formatPrice(pcBuild.totalPrice as double)}đ',
          style: const TextStyle(
            color: Color(0xFF1B9E5A),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _ApplyBuildButton extends StatelessWidget {
  final PcBuild pcBuild;
  final Function(PcBuild)? onApplyBuild;

  const _ApplyBuildButton({
    required this.pcBuild,
    this.onApplyBuild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 32,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B2B33),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          if (onApplyBuild != null) {
            onApplyBuild!(pcBuild);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm cấu hình ${pcBuild.buildId} vào giỏ hàng!'),
            ),
          );
        },
        child: const Text(
          'ÁP DỤNG CẤU HÌNH',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
