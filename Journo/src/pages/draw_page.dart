import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final List<_Stroke> _strokes = <_Stroke>[];
  Color _color = Colors.black;
  double _width = 3.0;

  void _onPanStart(DragStartDetails d) {
    setState(() => _strokes.add(_Stroke(color: _color, width: _width, points: <Offset>[d.localPosition])));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _strokes.last.points.add(d.localPosition));
  }

  Future<Uint8List> _exportPng(Size size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);

    for (final _Stroke s in _strokes) {
      final Paint p = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < s.points.length - 1; i++) {
        canvas.drawLine(s.points[i], s.points[i + 1], p);
      }
    }

    final ui.Picture pic = recorder.endRecording();
    final ui.Image img = await pic.toImage(size.width.toInt(), size.height.toInt());
    final ByteData? bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Drawing'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _strokes.clear()),
          ),
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check),
            onPressed: () async {
              final RenderBox box = context.findRenderObject()! as RenderBox;
              final Size size = box.size;
              final Uint8List png = await _exportPng(size);
              if (!context.mounted) return;
              Navigator.of(context).pop<Uint8List>(png);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.color_lens_outlined),
                onPressed: () async {
                  final Color? c = await showDialog<Color>(
                    context: context,
                    builder: (BuildContext context) => _ColorPickerDialog(initial: _color),
                  );
                  if (c != null) setState(() => _color = c);
                },
              ),
              Expanded(
                child: Slider(
                  value: _width,
                  onChanged: (double v) => setState(() => _width = v),
                  min: 1,
                  max: 12,
                  label: '${_width.toStringAsFixed(0)}px',
                ),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints c) {
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  child: CustomPaint(
                    painter: _Painter(_strokes),
                    size: Size(c.maxWidth, c.maxHeight),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  _Stroke({required this.color, required this.width, required this.points});
  final Color color;
  final double width;
  final List<Offset> points;
}

class _Painter extends CustomPainter {
  _Painter(this.strokes);
  final List<_Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);
    for (final _Stroke s in strokes) {
      final Paint p = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < s.points.length - 1; i++) {
        canvas.drawLine(s.points[i], s.points[i + 1], p);
      }
    }
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => oldDelegate.strokes != strokes;
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initial});
  final Color initial;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color = widget.initial;
  static final List<Color> _palette = <Color>[
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick color'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _palette
            .map((Color c) => GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(backgroundColor: c, radius: 16, child: _color == c ? const Icon(Icons.check, color: Colors.white) : null),
                ))
            .toList(),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, _color), child: const Text('Select')),
      ],
    );
  }
}