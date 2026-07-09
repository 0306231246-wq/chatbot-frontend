import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/pc_build.dart';
import '../../services/api_service.dart';
import 'chat_header.dart';
import 'chat_message_list.dart';

class ChatBotWidget extends StatefulWidget {
  final Function(PcBuild)? onApplyBuild;
  const ChatBotWidget({super.key, this.onApplyBuild});

  @override
  State<ChatBotWidget> createState() => ChatBotWidgetState();
}

class ChatBotWidgetState extends State<ChatBotWidget> {
  bool _isOpen = false;
  bool _isLoading = false;
  StateSetter? _modalSetState;

  void _updateState(VoidCallback fn) {
    setState(fn);
    _modalSetState?.call(() {});
  }

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_getHistoryKey());
    if (historyString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyString);
        final List<Map<String, dynamic>> loadedMessages = decoded.map((msg) {
           return {
             'text': msg['text'],
             'isUser': msg['isUser'],
             'hasCard': msg['hasCard'],
             'buildData': msg['buildData'] != null ? PcBuild.fromJson(msg['buildData']) : null,
           };
        }).toList();
        
        if (loadedMessages.isNotEmpty) {
           _updateState(() {
             _messages.addAll(loadedMessages);
           });
           _scrollToBottom();
           return;
        }
      } catch (e) {
        print("Lỗi load lịch sử: $e");
      }
    }
    
    // Nếu không có lịch sử thì thêm câu chào
    _updateState(() {
      _messages.add({
        'text':
            'Xin chào! Tôi có thể giúp gì cho bạn trong việc chọn cấu hình PC hôm nay?',
        'isUser': false
      });
    });
  }

  String _getHistoryKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return 'chat_history_${user.uid}';
    }
    return 'chat_history_guest';
  }

  void _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> toSave = _messages.map((msg) {
      return {
        'text': msg['text'],
        'isUser': msg['isUser'],
        'hasCard': msg['hasCard'],
        'buildData': (msg['buildData'] as PcBuild?)?.toJson(),
      };
    }).toList();
    await prefs.setString(_getHistoryKey(), jsonEncode(toSave));
  }

  void _sendMessage() async {
    if (_isLoading)
      return; // Chặn tuyệt đối không cho gửi yêu cầu mới khi hệ thống đang xử lý
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _updateState(() {
      _messages.add({'text': text, 'isUser': true});
      _isLoading = true;
    });
    _saveChatHistory();
    _scrollToBottom();
    final response = await ApiService.sendMessageToChatbot(text);

    String responseText = response['text'] ??
        response['response'] ??
        response['message'] ??
        'Hệ thống trả về dữ liệu không xác định. Vui lòng thử lại.';
    final RegExp replyRegex =
        RegExp(r'^\{chatbot_reply:\s*(.*)\}$', dotAll: true);
    final match = replyRegex.firstMatch(responseText);
    if (match != null) {
      responseText = match.group(1) ?? responseText;
    }

    _updateState(() {
      _isLoading = false;
      _messages.add({
        'text': responseText,
        'isUser': false,
        'hasCard': response['has_card'] ?? false,
        'buildData': response['build_data'] != null
            ? PcBuild.fromJson(response['build_data'])
            : null,
      });
    });
    _saveChatHistory();
    _scrollToBottom();
  }

  void openAndSendMessage(String msg) {
    if (!_isOpen) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isDesktop = screenWidth > 600 && MediaQuery.of(context).size.height > 600;
      if (isDesktop) {
        setState(() => _isOpen = true);
      } else {
        _showMobileChatBottomSheet(Theme.of(context).colorScheme.primary);
      }
    }
    _controller.text = msg;
    _sendMessage();
  }

  void _handleRetry(int index) {
    if (_isLoading) return;
    
    if (index > 0 && index < _messages.length) {
      final userMsgIndex = index - 1;
      final userMsg = _messages[userMsgIndex];
      
      if (userMsg['isUser'] == true) {
        final text = userMsg['text'];
        
        _updateState(() {
          _messages.removeAt(index); // Xóa tin nhắn lỗi của bot
          _messages.removeAt(userMsgIndex); // Xóa câu hỏi cũ của user
        });
        _saveChatHistory();
        
        _controller.text = text; // Điền lại text
        _sendMessage(); // Tự động gửi lại
      }
    }
  }

  void _resetChat() async {
    _updateState(() {
      _isLoading = true;
    });
    await ApiService.deleteSession();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getHistoryKey());

    _updateState(() {
      _isLoading = false;
      _messages.clear();
      _messages.add({
        'text':
            'Đã làm mới phiên tư vấn! Xin chào, tôi có thể giúp gì cho bạn hôm nay?',
        'isUser': false
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _showMobileChatBottomSheet(Color primary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Material(
                  color: Colors.white,
                  child: StatefulBuilder(
                    builder: (ctx, setModalState) {
                      _modalSetState = setModalState;
                      return Column(
                        children: [
                          ChatHeader(
                            primary: primary,
                            isDesktop: false,
                            isModal: true,
                            onClose: () => Navigator.pop(context),
                            onReset: _resetChat,
                          ),
                          Expanded(
                            child: ChatMessageList(
                              messages: _messages,
                              isLoading: _isLoading,
                              primary: primary,
                              scrollController: _scrollController,
                              onApplyBuild: widget.onApplyBuild,
                              onRetry: _handleRetry,
                            ),
                          ),
                          _buildInputArea(primary),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      _modalSetState = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop =
        screenWidth > 600 && MediaQuery.of(context).size.height > 600;
    final windowWidth = isDesktop ? 360.0 : screenWidth - 32;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen && isDesktop)
          Positioned(
            bottom: 88,
            right: 16,
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withOpacity(0.3),
              child: Container(
                width: windowWidth,
                height: 480,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    ChatHeader(
                      primary: primary,
                      isDesktop: true,
                      onReset: _resetChat,
                    ),
                    Expanded(
                      child: ChatMessageList(
                        messages: _messages,
                        isLoading: _isLoading,
                        primary: primary,
                        scrollController: _scrollController,
                        onApplyBuild: widget.onApplyBuild,
                        onRetry: _handleRetry,
                      ),
                    ),
                    _buildInputArea(primary),
                  ],
                ),
              ),
            ),
          ),
        if (isDesktop || !_isOpen)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(
                      color: primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    if (isDesktop) {
                      setState(() => _isOpen = !_isOpen);
                    } else {
                      _showMobileChatBottomSheet(primary);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
                      child: Icon(
                          _isOpen && isDesktop
                              ? Icons.close
                              : Icons.support_agent_rounded,
                          key: ValueKey(_isOpen),
                          color: Colors.white,
                          size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea(Color primary) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Nhập yêu cầu tư vấn PC...',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
              ),
              onSubmitted: _isLoading ? null : (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: Icon(Icons.send_rounded,
                color: _isLoading ? Colors.grey.shade400 : primary),
          ),
        ],
      ),
    );
  }
}
