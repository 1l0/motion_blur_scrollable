import 'package:flutter/material.dart';

import 'package:motion_blur_scrollable/motion_blur_scrollable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Content(),
      ),
    );
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: MotionBlurScrollable(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              if (index % 5 == 0) {
                return const Title('Photos');
              }
              return RandomOsloPhoto(
                key: ValueKey(index),
                index: index,
              );
            },
            itemCount: 100,
          ),
        ),
      ),
    );
  }
}

class RandomOsloPhoto extends StatefulWidget {
  const RandomOsloPhoto({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<RandomOsloPhoto> createState() => _RandomPhotoState();
}

class _RandomPhotoState extends State<RandomOsloPhoto>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Image.network(
        'https://picsum.photos/seed/${widget.index}/800/600',
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Title extends StatelessWidget {
  const Title(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Text(
        title,
        style: style,
      ),
    );
  }
}
