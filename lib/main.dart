import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Container(
        color: Colors.blue,
        child: const Column(
          children: [
            CounterWidget(),
            ClockWidget(),
            FutWidget(),
            StreWidget(),
            ItemWidget()
          ],
        ),
      ),
    );
  }
}

final helloWorldProvider = Provider<String>((ref) => "Hello world");

class HelloWorldWidget extends ConsumerWidget {
  const HelloWorldWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helloWorld = ref.watch(helloWorldProvider);
    return Text(helloWorld);
  }
}

final counterStateProvider = StateProvider((ref) => 0);

class CounterWidget extends ConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterStateProvider);
    return ElevatedButton(
      onPressed: () {
        ref.read(counterStateProvider.notifier).state++;
      },
      child: Text('Value: $counter'),
    );
  }
}

class Clock extends StateNotifier<DateTime> {
  Clock() : super(DateTime.now()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // 3. update the state with the current time
      state = DateTime.now();
    });
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

final clockProvider = StateNotifierProvider<Clock, DateTime>((ref) => Clock());

class ClockWidget extends ConsumerWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTime = ref.watch(clockProvider);
    final timeFormatted = DateFormat.Hms().format(currentTime);
    return Text(timeFormatted);
  }
}

final weatherFutureProvider = FutureProvider.autoDispose((ref) {
  final dio = Dio();
  return dio.get("https://mkt.aoxqwl.com/openenum/lstRegionAllByLevel",
      queryParameters: {"level": 1});
});

Future<List<String>> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  return ['abc'];
}

class FutWidget extends StatelessWidget {
  const FutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return const Text("ok");
      },
    );
  }
}

Stream<int> streamCounter() {
  return Stream.periodic(const Duration(seconds: 1), (i) {
    return i;
  });
}

class StreWidget extends StatelessWidget {
  const StreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamCounter(),
      builder: (context, snapshot) {
        return Text("close ${snapshot.data}");
      },
    );
  }
}

final itemStreamProvider = StreamProvider((ref) => streamCounter());

class ItemWidget extends ConsumerWidget {
  const ItemWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemValue = ref.watch(itemStreamProvider);
    return itemValue.when(
      data: (data) {
        return Text('$data');
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(error.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
