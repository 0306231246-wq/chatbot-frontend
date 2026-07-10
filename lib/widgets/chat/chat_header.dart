import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChatHeader extends StatefulWidget {
  final Color primary;
  final bool isDesktop;
  final bool isModal;
  final VoidCallback? onClose;
  final VoidCallback? onReset;

  const ChatHeader({
    super.key,
    required this.primary,
    required this.isDesktop,
    this.isModal = false,
    this.onClose,
    this.onReset,
  });

  @override
  State<ChatHeader> createState() => _ChatHeaderState();
}

class _ChatHeaderState extends State<ChatHeader> {
  String _healthStatus = 'checking';
  Timer? _healthTimer;

  @override
  void initState() {
    super.initState();
    _checkHealth();
    _healthTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    final status = await ApiService.getHealthStatus();
    if (mounted) {
      setState(() {
        _healthStatus = status;
      });
    }
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (_healthStatus) {
      case 'ok':
        statusColor = Colors.green;
        statusText = 'Trực tuyến';
        break;
      case 'degraded':
        statusColor = Colors.orange;
        statusText = 'Gián đoạn (LLM/DB)';
        break;
      case 'checking':
        statusColor = Colors.blue;
        statusText = 'Đang kiểm tra...';
        break;
      default:
        statusColor = Colors.red;
        statusText = 'Mất kết nối';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: widget.primary, shape: BoxShape.circle),
                child: const Icon(Icons.bolt, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('AI PC Assistant', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  Row(
                    children: [
                      Icon(Icons.circle, color: statusColor, size: 10),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onReset != null)
                IconButton(
                  icon: const Icon(Icons.cleaning_services_rounded, color: Colors.black54, size: 22),
                  onPressed: widget.onReset,
                  tooltip: 'Làm mới phiên chat',
                ),
              if (!widget.isDesktop && widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 26),
                  onPressed: widget.onClose,
                  tooltip: 'Đóng',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
