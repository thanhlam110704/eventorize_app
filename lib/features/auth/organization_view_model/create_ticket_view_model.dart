import 'package:flutter/material.dart';
import 'package:eventorize_app/data/models/ticket.dart';
import 'package:eventorize_app/data/repositories/ticket_repository.dart';
import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/features/auth/organization_view_model/ticket_list_view_model.dart';
import 'package:intl/intl.dart';

class CreateTicketViewModel extends ChangeNotifier {
  final TicketRepository _ticketRepository;
  final SessionManager _sessionManager;

  String? _saleDateRange;
  bool _isLoading = false;
  bool _isCreateSuccessful = false;
  final ErrorState errorState = ErrorState();

  String? get saleDateRange => _saleDateRange;
  bool get isLoading => _isLoading;
  bool get isCreateSuccessful => _isCreateSuccessful;
  String? get errorMessage => errorState.errorMessage;
  String? get errorTitle => errorState.errorTitle;

  CreateTicketViewModel({
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

  Future<Ticket?> createTicket(
    BuildContext context,
    GlobalKey<FormState> formKey, {
    required String eventId,
    required String title,
    String? description,
    required int quantity,
    required int price,
    required int minPerUser,
    required int maxPerUser,
    required String status, // Expects backend values: ["active", "sold out", "paused", "hidden"]
  }) async {
    if (!formKey.currentState!.validate()) return null;

    if (_sessionManager.user == null) {
      errorState.errorTitle = null;
      errorState.errorMessage = 'Vui lòng đăng nhập trước';
      notifyListeners();
      return null;
    }

    if (_saleDateRange == null) {
      errorState.errorTitle = 'Lỗi';
      errorState.errorMessage = 'Vui lòng chọn thời gian bán vé';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _isCreateSuccessful = false;
    ErrorHandler.clearError(errorState);
    notifyListeners();

    try {
      final dates = _saleDateRange!.split(' to ');
      if (dates.length != 2) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Thời gian bán vé không hợp lệ';
        _isCreateSuccessful = false;
        notifyListeners();
        return null;
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
        _isCreateSuccessful = false;
        notifyListeners();
        return null;
      }

      // Validate status
      const validStatuses = ['active', 'sold out', 'paused', 'hidden'];
      if (!validStatuses.contains(status)) {
        errorState.errorTitle = 'Lỗi';
        errorState.errorMessage = 'Trạng thái không hợp lệ';
        _isCreateSuccessful = false;
        notifyListeners();
        return null;
      }

      final ticket = await _ticketRepository.createTicket(
        eventId: eventId,
        title: title,
        description: description,
        quantity: quantity,
        startSaleDate: startSaleDate,
        endSaleDate: endSaleDate,
        price: price,
        minPerUser: minPerUser,
        maxPerUser: maxPerUser,
        status: status,
      );

      final ticketListViewModel = GetIt.instance<TicketListViewModel>();
      await ticketListViewModel.fetchTickets(
        eventId: eventId,
        page: 1,
        limit: 20,
        search: "",
      );

      _isCreateSuccessful = true;
      ErrorHandler.clearError(errorState);
      notifyListeners();
      return ticket;
    } catch (e) {
      ErrorHandler.handleError(e, '', errorState);
      _isCreateSuccessful = false;
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setError(String title, String message) {
    errorState.errorTitle = title.isEmpty ? null : title;
    errorState.errorMessage = message;
    _isCreateSuccessful = false;
    notifyListeners();
  }

  void clearError() {
    ErrorHandler.clearError(errorState);
    notifyListeners();
  }

  void clearCreateStatus() {
    _isCreateSuccessful = false;
    notifyListeners();
  }
}