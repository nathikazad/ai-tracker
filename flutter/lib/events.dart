import 'package:Logger/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For converting the fetched data and handling JSON.
import 'package:intl/intl.dart';

class Event {
  final String id, eventType, startTime, endTime, metadata, status;

  Event(this.id, this.eventType, this.startTime, this.endTime, this.metadata,
      this.status);

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      json['id'].toString(),
      json['event_type_object']['parent_tree'],
      json['start_time'],
      json['end_time'],
      jsonEncode(json['metadata']),
      json['status'],
    );
  }
}

class Interaction {
  final int id;
  final String content, time;

  Interaction(this.id, this.content, this.time);

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      json['id'],
      json['content'],
      DateFormat('hh:mm a').format(DateTime.parse(json['timestamp']).toLocal()),
    );
  }
}

class EventPage extends StatefulWidget {
  final ValueNotifier<bool> fetchEventsNotifier;

  EventPage(this.fetchEventsNotifier);
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Interaction> _events = [];
  ScrollController _scrollController = ScrollController();

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // _scrollController.addListener(_scrollListener);
    _fetchEvents();
    widget.fetchEventsNotifier.addListener(() {
      if (widget.fetchEventsNotifier.value) {
        _fetchEvents();
        widget.fetchEventsNotifier.value = false;
      }
    });
  }

  Future<void> _fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://$serverUrl/getinteractions'));
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        _events =
            jsonResponse.map((data) => Interaction.fromJson(data)).toList();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> _deleteEvent(int id) async {
    final response =
        await http.delete(Uri.parse('http://$serverUrl/interaction/$id'));
    if (response.statusCode == 200) {
      _fetchEvents(); // Refresh the events list
    } else {
      throw Exception('Failed to delete event');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event.time),
            subtitle: Text(event.content),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteEvent(event.id),
            ),
          );
        },
      ),
    );
  }
}
