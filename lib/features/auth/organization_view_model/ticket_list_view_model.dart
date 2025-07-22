import 'package:flutter/foundation.dart';
import 'package:eventorize_app/data/models/ticket.dart';
import 'package:eventorize_app/data/repositories/ticket_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';

class TicketListViewModel extends ChangeNotifier {
  final TicketRepository _ticketRepository;
  final SessionManager _sessionManager;
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  int _currentPage = 1;
  int _currentLimit = 20;
  String _currentSearch = "";

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get errorTitle => _errorTitle;

  TicketListViewModel({
    required TicketRepository ticketRepository,
    required SessionManager sessionManager,
  }) : _ticketRepository = ticketRepository, _sessionManager = sessionManager;

  Future<void> fetchTickets({
    required String eventId,
    int page = 1,
    int limit = 20,
    String search = "",
  }) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _ticketRepository.getEventTickets(
        eventId: eventId,
        page: page,
        limit: limit,
        search: search,
      );

      final ticketList = response['data'] as List<Ticket>;
      _tickets = ticketList;
      _currentPage = page;
      _currentLimit = limit;
      _currentSearch = search;
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách vé: $e';
      _errorTitle = 'Lỗi';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    if (_sessionManager.user == null) {
      _errorMessage = 'Vui lòng đăng nhập trước';
      _errorTitle = 'Lỗi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final originalTickets = List<Ticket>.from(_tickets);
    _tickets = _tickets.where((ticket) => ticket.id != ticketId).toList();
    notifyListeners();

    try {
      await _ticketRepository.deleteTicket(ticketId);
      _errorMessage = null;
      _errorTitle = null;
    } catch (e) {
      _tickets = originalTickets;
      _errorMessage = 'Xóa vé thất bại: $e';
      _errorTitle = 'Lỗi';
      await fetchTickets(
        eventId: _tickets.isNotEmpty ? _tickets.first.eventId : '',
        page: _currentPage,
        limit: _currentLimit,
        search: _currentSearch,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _errorTitle = null;
    notifyListeners();
  }
}