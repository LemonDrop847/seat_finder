import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class Seat {
  final int seatNo;
  final String type;
  final String status;

  Seat({required this.seatNo, required this.type, required this.status});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatNo: json['seat_no'],
      type: (json['type'] == "Lower Berth")
          ? "LOWER"
          : (json['type'] == "Upper Berth")
              ? 'UPPER'
              : (json['type'] == 'Middle Berth')
                  ? 'MIDDLE'
                  : (json['type'] == 'Side Lower Berth')
                      ? 'SIDE LOWER'
                      : 'SIDE UPPER',
      status: json['status'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Seat> seats = [];
  List<Seat> searchSeats = [];
  TextEditingController searchController = TextEditingController();

  Future<String> loadSeatsFromAsset() async {
    return await rootBundle.loadString('assets/seats.json');
  }

  Future loadSeats() async {
    String jsonString = await loadSeatsFromAsset();
    final jsonResponse = json.decode(jsonString);
    setState(() {
      seats = List<Seat>.from(jsonResponse.map((data) => Seat.fromJson(data)));
    });
  }

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Widget _buildSeat(int seatNo) {
    Color color = seats[seatNo - 1].status == 'booked'
        ? Colors.blueGrey
        : Colors.lightBlue;
    return InkWell(
      onTap: () {
        searchController.text = seatNo.toString();
        _showSeatDetails(seatNo);
      },
      child: Ink(
        width: 80.0,
        height: 60.0,
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$seatNo',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              seats[seatNo - 1].type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.9,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int startSeatNo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSeat(startSeatNo),
            _buildSeat(startSeatNo + 1),
            _buildSeat(startSeatNo + 2),
            const SizedBox(
              width: 10.0,
              child: Divider(),
            ),
            _buildSeat(startSeatNo + 6),
          ],
        ),
        const SizedBox(
          height: 20,
          child: Divider(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSeat(startSeatNo + 3),
            _buildSeat(startSeatNo + 4),
            _buildSeat(startSeatNo + 5),
            const SizedBox(
              width: 10.0,
              child: Divider(),
            ),
            _buildSeat(startSeatNo + 7),
          ],
        ),
        const Divider(
          color: Colors.black,
          height: 20,
        ),
      ],
    );
  }

  Widget _buildSearchResult() {
    if (searchSeats.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: searchSeats.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).pop();
                _showSeatDetails(searchSeats[index].seatNo);
              },
              title: Text(
                'Seat No: ${searchSeats[index].seatNo}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Type: ${searchSeats[index].type} | Status: ${searchSeats[index].status}',
              ),
            );
          },
        ),
      );
    }
  }

  void _searchSeats(String query) {
    if (query.isNotEmpty) {
      setState(() {
        searchSeats = seats
            .where((seat) =>
                seat.seatNo.toString().contains(query) ||
                seat.type.toLowerCase().contains(query.toLowerCase()) ||
                seat.status.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        searchSeats.clear();
      });
    }
  }

  void _showSeatDetails(int seatNo) {
    final seat = seats[seatNo - 1];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seat Details - ${seat.seatNo}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${seat.type}'),
                Text('Status: ${seat.status}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat Booking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Seat Booking'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _searchSeats(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by seat no, type or status',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            searchSeats.isEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildRow(1),
                            _buildRow(9),
                            _buildRow(17),
                            _buildRow(25),
                            _buildRow(33),
                            _buildRow(41),
                            _buildRow(49),
                            _buildRow(57),
                          ],
                        ),
                      ),
                    ),
                  )
                : _buildSearchResult(),
          ],
        ),
      ),
    );
  }
}
