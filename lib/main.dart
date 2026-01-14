import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const EzanApp());
}

class EzanApp extends StatelessWidget {
  const EzanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE6E2AC),
      ),
      home: const DilSecimi(),
    );
  }
}

class DilSecimi extends StatelessWidget {
  const DilSecimi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dilButonu(context, "TÜRKÇE", "tr"),
            const SizedBox(height: 25),
            _dilButonu(context, "ENGLISH", "en"),
          ],
        ),
      ),
    );
  }

  Widget _dilButonu(BuildContext context, String metin, String kod) {
    return InkWell(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnaSayfa(dil: kod)),
      ),
      child: Text(
        metin,
        style: const TextStyle(fontSize: 16, letterSpacing: 2),
      ),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  final String dil;
  const AnaSayfa({super.key, required this.dil});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  PrayerTimes? vakitler;
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriAl();
  }

  Future<void> _verileriAl() async {
    try {
      LocationPermission p = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        vakitler = PrayerTimes.today(
          Coordinates(pos.latitude, pos.longitude),
          CalculationMethod.turkey.getParameters(),
        );
        yukleniyor = false;
      });
    } catch (e) {
      setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, String>> diller = {
      'tr': {
        'f': 'İmsak',
        's': 'Güneş',
        'd': 'Öğle',
        'a': 'İkindi',
        'm': 'Akşam',
        'i': 'Yatsı',
      },
      'en': {
        'f': 'Fajr',
        's': 'Sunrise',
        'd': 'Dhuhr',
        'a': 'Asr',
        'm': 'Maghrib',
        'i': 'Isha',
      },
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF008600),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DilSecimi()),
          ),
        ),
        title: Text(
          DateFormat("d MMMM", widget.dil).format(DateTime.now()).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ),
      body: yukleniyor
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : vakitler == null
          ? const Center(child: Text("Konum Alınamadı"))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _vakitSatiri(diller[widget.dil]!['f']!, vakitler!.fajr),
                  _vakitSatiri(diller[widget.dil]!['s']!, vakitler!.sunrise),
                  _vakitSatiri(diller[widget.dil]!['d']!, vakitler!.dhuhr),
                  _vakitSatiri(diller[widget.dil]!['a']!, vakitler!.asr),
                  _vakitSatiri(diller[widget.dil]!['m']!, vakitler!.maghrib),
                  _vakitSatiri(diller[widget.dil]!['i']!, vakitler!.isha),
                  const Spacer(),
                  const Text(
                    "MKB",
                    style: TextStyle(fontSize: 10, color: Colors.black26),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _vakitSatiri(String ad, DateTime vakit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ad, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(
            DateFormat('HH:mm').format(vakit),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
