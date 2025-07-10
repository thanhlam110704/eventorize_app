import 'package:flutter/foundation.dart';
import 'package:eventorize_app/core/utils/exceptions.dart';
import 'package:eventorize_app/data/models/event.dart';
import 'package:eventorize_app/data/models/ticket.dart';
import 'package:eventorize_app/data/models/order.dart';
import 'package:eventorize_app/data/models/organizer.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/ticket_repository.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final TicketRepository _ticketRepository;
  final OrganizerRepository _organizerRepository;
  final ErrorState _errorState = ErrorState();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingRelated = false;
  bool get isLoadingRelated => _isLoadingRelated;

  bool _isLoadingTickets = false;
  bool get isLoadingTickets => _isLoadingTickets;

  String? get errorMessage => _errorState.errorMessage;
  String? get errorTitle => _errorState.errorTitle;

  Event? _event;
  Event? get event => _event;

  Organizer? _organizer;
  Organizer? get organizer => _organizer;

  List<Event> _relatedEvents = [];
  List<Event> get relatedEvents => _relatedEvents;

  List<Ticket> _tickets = [];
  List<Ticket> get tickets => _tickets;

  EventDetailViewModel({
    required EventRepository eventRepository,
    required TicketRepository ticketRepository,
    required OrganizerRepository organizerRepository,
  })  : _eventRepository = eventRepository,
        _ticketRepository = ticketRepository,
        _organizerRepository = organizerRepository;

  Future<void> fetchEventDetail(String id) async {
    _isLoading = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      _event = await _eventRepository.getEventDetail(id);
      if (_event != null) {
        _organizer = await _organizerRepository.getDetailPublic(_event!.organizerId);
      }
      await fetchRelatedEvents(id);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy chi tiết sự kiện', _errorState);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRelatedEvents(String eventId) async {
    if (_event == null) return;

    _isLoadingRelated = true;
    notifyListeners();

    try {
      final result = await _eventRepository.getAll();
      _relatedEvents = result['data'] as List<Event>;
      _relatedEvents = _relatedEvents.where((e) => e.id != eventId).toList();
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy sự kiện liên quan', _errorState);
    } finally {
      _isLoadingRelated = false;
      notifyListeners();
    }
  }

  Future<void> fetchEventTickets(String eventId) async {
    _isLoadingTickets = true;
    ErrorHandler.clearError(_errorState);
    notifyListeners();

    try {
      final result = await _ticketRepository.getEventTickets(eventId: eventId);
      _tickets = result['data'] as List<Ticket>;
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi lấy danh sách vé', _errorState);
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  Future<Order> buyTicket({
    required String eventId,
    required List<Map<String, dynamic>> orderItems,
    String? promotionCode,
    double? overrideAmount,
  }) async {
    try {
      final result = await _ticketRepository.buyTicket(
        eventId: eventId,
        orderItems: orderItems,
        promotionCode: promotionCode,
        overrideAmount: overrideAmount,
      );
      return Order.fromJson(result);
    } catch (e) {
      ErrorHandler.handleError(e, 'Lỗi khi mua vé', _errorState);
      rethrow;
    }
  }

  void clearError() {
    ErrorHandler.clearError(_errorState);
    notifyListeners();
  }
}