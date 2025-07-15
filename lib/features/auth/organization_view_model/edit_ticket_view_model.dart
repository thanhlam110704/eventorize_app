import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/ticket.dart';
import 'package:eventorize_app/data/repositories/ticket_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditTicketViewModel extends ChangeNotifier {
  final TicketRepository _ticketRepository;
  final SessionManager _sessionManager;

  Ticket? _ticket;
  String? _saleDateRange; // Changed to String
  bool _isLoading = false;
  bool _isUpdateSuccessful = false;
  final ErrorState errorState = ErrorState();

  Ticket? get ticket => _ticket;
  String? get saleDateRange => _saleDateRange; // Updated getter
  bool get isLoading => _isLoading;
  bool get isUpdateSuccessful => _isUpdateSuccessful;
  String? get errorMessage => errorState.errorMessage;
  String? get errorTitle => errorState.errorTitle;

  EditTicketViewModel({
    required TicketRepository ticketRepository,
    required SessionManager sessionManager,
  })  : _ticketRepository = ticketRepository,
        _sessionManager = sessionManager;

  void setDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      _saleDateRange = '${dateFormat.format(start)} to ${dateFormat.format(end)}';
    } else {
      _saleDateRange = null;
    }
    notifyListeners();
  }

  Future<void> fetchTicket(String eventId, String ticketId) async {
    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return;
    }

    _isLoading = true;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    await executeApiCall(
      apiCall: () => _ticketRepository.getTicketDetail(eventId: eventId, ticketId: ticketId),
      onSuccess: (ticket) {
        _ticket = ticket as Ticket;
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        _saleDateRange = '${dateFormat.format(ticket.startSaleDate)} to ${dateFormat.format(ticket.endSaleDate)}';
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTicket(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    required String eventId,
    required String ticketId,
    String? title,
    String? description,
    int? quantity,
    int? price,
    int? minPerUser,
    int? maxPerUser,
    String? status,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return;
    }

    if (_saleDateRange == null) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Vui lòng chọn thời gian bán vé';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isUpdateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    try {
      final dates = _saleDateRange!.split(' to ');
      if (dates.length != 2) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Thời gian bán vé không hợp lệ';
        _isUpdateSuccessful = false;
        notifyListeners();
        return;
      }

      final startSaleDate = dates[0];
      final endSaleDate = dates[1];
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      try {
        dateFormat.parseStrict(startSaleDate);
        dateFormat.parseStrict(endSaleDate);
      } catch (e) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Định dạng thời gian không hợp lệ';
        _isUpdateSuccessful = false;
        notifyListeners();
        return;
      }

      // Validate status
      if (status != null) {
        const validStatuses = ['active', 'sold out', 'paused', 'hidden'];
        if (!validStatuses.contains(status)) {
          errorState.errorTitle = 'Lỗi';
          errorState.errorMessage = 'Trạng thái không hợp lệ';
          _isUpdateSuccessful = false;
          notifyListeners();
          return;
        }
      }

      await executeApiCall(
        apiCall: () => _ticketRepository.editTicket(
          eventId: eventId,
          ticketId: ticketId,
          title: title,
          description: description,
          quantity: quantity,
          startSaleDate: startSaleDate, // Pass as String
          endSaleDate: endSaleDate, // Pass as String
          price: price,
          minPerUser: minPerUser,
          maxPerUser: maxPerUser,
          status: status,
        ),
        onSuccess: (updatedTicket) {
          _ticket = updatedTicket as Ticket;
          _isUpdateSuccessful = true;
          ErrorHandler.clearError(errorState);
          if (context.mounted) {
            context.go('/ticket-list/$eventId');
          }
        },
      );
    } catch (e) {
      ErrorHandler.handleError(e, '', errorState);
      _isUpdateSuccessful = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> executeApiCall({
    required Future<dynamic> Function() apiCall,
    required void Function(dynamic data) onSuccess,
  }) async {
    try {
      final result = await apiCall();
      onSuccess(result);
    } catch (e) {
      ErrorHandler.handleError(e, '', errorState);
      _isUpdateSuccessful = false;
      notifyListeners();
      rethrow;
    }
  }

  void setError(String title, String message) {
    errorState.errorTitle = title.isEmpty ? null : title;
    errorState.errorMessage = message;
    _isUpdateSuccessful = false;
    notifyListeners();
  }

  void clearError() {
    ErrorHandler.clearError(errorState);
    notifyListeners();
  }

  void clearUpdateStatus() {
    _isUpdateSuccessful = false;
    notifyListeners();
  }
}