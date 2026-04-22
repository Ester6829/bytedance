import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bytedance/bytedance.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _id = 'Unknown';
  String _log = '';
  final _bytedancePlugin = Bytedance();

  @override
  void initState() {
    super.initState();
  }

  void _appendLog(String message) {
    setState(() {
      _log = '$_log\n[${DateTime.now().toString().substring(11, 19)}] $message';
    });
    print(message);
  }

  Future<void> _initBytedanceSdk() async {
    try {
      _bytedancePlugin.initSdk();
      _appendLog('SDK 初始化成功');
    } catch (e) {
      _appendLog('SDK 初始化失败: $e');
    }
  }

  Future<void> _getId() async {
    try {
      final id = await _bytedancePlugin.getId();
      setState(() {
        _id = id ?? 'Failed to get ID';
      });
      _appendLog('ID: $_id');
    } catch (e) {
      _appendLog('获取 ID 失败: $e');
    }
  }

  void _clearLog() {
    setState(() {
      _log = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Bytedance 示例'), elevation: 2),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '设备信息',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('ID: $_id'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '操作',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _initBytedanceSdk,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('初始化 SDK'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _getId,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('获取 ID'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.terminal,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '操作日志',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _clearLog,
                          icon: const Icon(Icons.clear),
                          label: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _log.isEmpty ? '暂无日志...' : _log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _log.isEmpty
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
