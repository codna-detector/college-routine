import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';

const blue = Color(0xFF143C8C);
const green = Color(0xFF0E7A37);
const ink = Color(0xFF10213F);
const muted = Color(0xFF6B7690);
const border = Color(0xFFE2E7F0);
const fbUrl = 'https://www.facebook.com/share/19bfyPV4c5/?mibextid=wwXIfr';

const days = ['রবিবার', 'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার'];
const shortDays = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ'];
const groups = ['বিজ্ঞান', 'মানবিক', 'ব্যবসায় শিক্ষা'];
const times = [
  '৯:০০ - ৯:৪৫', '৯:৪৫ - ১০:৩০', '১০:৩০ - ১১:১৫',
  '১১:১৫ - ১২:০০', '১২:০০ - ১২:৪৫', '১২:৪৫ - ১:৩০',
  '২:০০ - ২:৪৫', '২:৪৫ - ৩:৩০', '৩:৩০ - ৪:১৫',
];
const starts = [540, 585, 630, 675, 720, 765, 840, 885, 930];

void main() => runApp(const CollegeRoutineApp());

class CollegeRoutineApp extends StatelessWidget {
  const CollegeRoutineApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'কলেজ রুটিন',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: blue),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List data = jsonDecode(routineJson) as List;
  late int day = () {
    final w = DateTime.now().weekday % 7; // রবি=০ ... শনি=৬
    return w <= 4 ? w : 0;
  }();
  int group = 0;

  int get today => DateTime.now().weekday % 7;
  int get nowMin => DateTime.now().hour * 60 + DateTime.now().minute;

  @override
  Widget build(BuildContext context) {
    final List items = data[day][group] as List;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(),
            const Divider(height: 1, color: border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _groupTabs(),
                  const SizedBox(height: 14),
                  _dayTabs(),
                  const SizedBox(height: 14),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: days[day],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ink)),
                    TextSpan(
                        text: '  ${groups[group]} · ৯টি ক্লাস',
                        style: const TextStyle(fontSize: 14, color: muted)),
                  ])),
                  const SizedBox(height: 12),
                  for (int i = 0; i < items.length; i++) ...[
                    if (i == 6) _breakRow(),
                    _classRow(i, items[i] as Map),
                  ],
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Image.asset('assets/college.png', width: 52, height: 52),
          const Expanded(
            child: Column(children: [
              Text('সরকারি সোহরাওয়ার্দী কলেজ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: blue)),
              SizedBox(height: 2),
              Text('পিরোজপুর · শিক্ষাবর্ষ ২০২৬-২০২৭',
                  style: TextStyle(fontSize: 13, color: muted)),
            ]),
          ),
          Image.asset('assets/gov.png', width: 52, height: 52),
        ]),
      );

  Widget _groupTabs() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color(0xFFE6EDFB),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (int i = 0; i < groups.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => group = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: i == group ? blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(groups[i],
                      style: TextStyle(
                          fontSize: 15,
                          color: i == group ? Colors.white : blue)),
                ),
              ),
            ),
        ]),
      );

  Widget _dayTabs() => Row(children: [
        for (int i = 0; i < shortDays.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 4 ? 0 : 6),
              child: GestureDetector(
                onTap: () => setState(() => day = i),
                child: Stack(children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: i == day ? green : Colors.white,
                        border: Border.all(color: i == day ? green : border),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(shortDays[i],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                i == day ? FontWeight.w600 : FontWeight.w400,
                            color: i == day ? Colors.white : ink)),
                  ),
                  if (i == today)
                    Positioned(
                      top: 5,
                      right: 6,
                      child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == day ? Colors.white : green)),
                    ),
                ]),
              ),
            ),
          ),
      ]);

  Widget _breakRow() => Container(
        margin: const EdgeInsets.only(bottom: 12, top: 2),
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.free_breakfast_outlined, size: 18, color: muted),
          SizedBox(width: 6),
          Text('বিরতি ১:৩০ - ২:০০',
              style: TextStyle(fontSize: 14, color: muted)),
        ]),
      );

  Widget _classRow(int i, Map c) {
    final parts = times[i].split(' - ');
    final isNow = day == today && nowMin >= starts[i] && nowMin < starts[i] + 45;
    final kind = c['k'] as String;
    final room = c['r'] as String;
    final teacher = c['t'] as String;

    Widget chip(String text, Color bg, Color fg) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
          child: Text(text, style: TextStyle(fontSize: 12.5, color: fg)),
        );

    Widget? trailing;
    if (kind == 'p') {
      trailing = chip('ব্যবহারিক', const Color(0xFFE3F4EA), green);
    } else if (kind == 't') {
      trailing = chip('তত্ত্বীয়', const Color(0xFFE6EDFB), blue);
    } else if (room.isNotEmpty) {
      trailing = chip('কক্ষ $room', const Color(0xFFF3F5F9), muted);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 56,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(parts[0],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: ink)),
              Text(parts[1], style: const TextStyle(fontSize: 13, color: muted)),
            ]),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
                color: isNow ? const Color(0xFFEAF6EF) : Colors.white,
                border: Border.all(color: isNow ? green : border),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['s'] as String,
                      style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: ink)),
                  if (kind == 'n' && teacher.isNotEmpty)
                    Text(teacher,
                        style: const TextStyle(fontSize: 14, color: muted)),
                  if (kind != 'n' && room.isNotEmpty)
                    Text('কক্ষ $room',
                        style: const TextStyle(fontSize: 14, color: muted)),
                  if (isNow)
                    const Text('এখন চলছে',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: green)),
                ]),
              ),
              if (trailing != null) trailing,
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _footer() => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: border))),
        child: Column(children: [
          Wrap(alignment: WrapAlignment.center, children: [
            const Text('Copyright: This website is made by ',
                style: TextStyle(fontSize: 13, color: muted)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(fbUrl),
                  mode: LaunchMode.externalApplication),
              child: const Text('Tamim Al Hadi',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: blue,
                      decoration: TextDecoration.underline)),
            ),
            const Text('.', style: TextStyle(fontSize: 13, color: muted)),
          ]),
          const SizedBox(height: 4),
          const Text('It is not an official website.',
              style: TextStyle(fontSize: 13, color: muted)),
        ]),
      );
}
