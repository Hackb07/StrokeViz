import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keystroke_listener.dart';
import 'models/theme_config.dart';
import 'widgets/keycap_widget.dart';
import 'dart:async';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true, // Only run primarily via sys tray icon and frameless window
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const StrokeVizApp());
}

class StrokeVizApp extends StatefulWidget {
  const StrokeVizApp({super.key});

  @override
  State<StrokeVizApp> createState() => _StrokeVizAppState();
}

class _StrokeVizAppState extends State<StrokeVizApp> with TrayListener {
  bool _isOverlayActive = false;
  ThemeConfig _currentTheme = ThemeConfig.appleMagic();
  String _positionStr = 'bottomCenter';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    trayManager.addListener(this);
    _initTray();
  }

  Future<void> _initTray() async {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png',
    );
    _buildTrayMenu();
  }

  void _buildTrayMenu() {
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'toggle_overlay',
          label: _isOverlayActive ? '■ Stop Overlay' : '▶ Start Overlay',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'theme_apple',
          label: 'Theme: Apple Magic',
        ),
        MenuItem(
          key: 'theme_low_profile',
          label: 'Theme: Low Profile',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit StrokeViz',
        ),
      ],
    );
    trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'toggle_overlay':
        _toggleOverlay();
        break;
      case 'theme_apple':
        _saveTheme('appleMagic');
        break;
      case 'theme_low_profile':
        _saveTheme('lowProfile');
        break;
      case 'exit_app':
        windowManager.close();
        break;
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme') ?? 'appleMagic';
    final posStr = prefs.getString('position') ?? 'bottomCenter';
    setState(() {
      if (themeStr == 'lowProfile') {
        _currentTheme = ThemeConfig.lowProfile();
      } else {
        _currentTheme = ThemeConfig.appleMagic();
      }
      _positionStr = posStr;
    });
  }

  Future<void> _saveTheme(String themeStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeStr);
    setState(() {
      if (themeStr == 'lowProfile') {
        _currentTheme = ThemeConfig.lowProfile();
      } else {
        _currentTheme = ThemeConfig.appleMagic();
      }
    });
  }

  Future<void> _savePosition(String posStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('position', posStr);
    setState(() {
      _positionStr = posStr;
    });
  }

  Alignment getAlignment() {
    switch (_positionStr) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return Alignment.bottomCenter;
    }
  }

  void _toggleOverlay() async {
    setState(() {
      _isOverlayActive = !_isOverlayActive;
    });
    _buildTrayMenu(); // Update the tray menu labels
    if (_isOverlayActive) {
      await windowManager.setSize(const Size(800, 200));
      await windowManager.setAlignment(getAlignment());
    } else {
      await windowManager.setSize(const Size(800, 600));
      await windowManager.setAlignment(Alignment.center);
    }
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrokeViz',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(primary: Colors.blueAccent),
      ),
      debugShowCheckedModeBanner: false,
      home: _isOverlayActive 
        ? VisualizationScreen(
            theme: _currentTheme, 
            position: _positionStr,
          )
        : SetupScreen(
            theme: _currentTheme, 
            position: _positionStr,
            onThemeChange: _saveTheme, 
            onPositionChange: _savePosition,
            onStart: _toggleOverlay
          ),
    );
  }
}

class SetupScreen extends StatelessWidget {
  final ThemeConfig theme;
  final String position;
  final Function(String) onThemeChange;
  final Function(String) onPositionChange;
  final VoidCallback onStart;

  const SetupScreen({
    super.key, 
    required this.theme, 
    required this.position,
    required this.onThemeChange, 
    required this.onPositionChange,
    required this.onStart
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Column(
        children: [
          DragToMoveArea(
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        Image.asset('assets/app_icon.png', width: 20, height: 20, filterQuality: FilterQuality.high),
                        const SizedBox(width: 8),
                        const Text('StrokeViz Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => windowManager.close(),
                    hoverColor: Colors.red,
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: [
                        Row(
                           children: [
                             ClipRRect(
                               borderRadius: BorderRadius.circular(12),
                               child: Image.asset('assets/app_icon.png', width: 48, height: 48, fit: BoxFit.cover, filterQuality: FilterQuality.high),
                             ),
                             const SizedBox(width: 16),
                             const Text(
                               'StrokeViz Settings',
                               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                             ),
                           ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Note: Use the System Tray icon to easily start/stop the overlay and change themes without reopening this setup.', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 24),
                        Card(
                          color: const Color(0xFF2D2D30),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              RadioListTile<KeycapTheme>(
                                title: const Text('Apple Magic Theme'),
                                value: KeycapTheme.appleMagic,
                                groupValue: theme.theme,
                                onChanged: (val) => onThemeChange('appleMagic'),
                              ),
                              RadioListTile<KeycapTheme>(
                                title: const Text('Low Profile Theme'),
                                value: KeycapTheme.lowProfile,
                                groupValue: theme.theme,
                                onChanged: (val) => onThemeChange('lowProfile'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: const Color(0xFF2D2D30),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Screen Layout Position', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: position,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'topLeft', child: Text('Top Left')),
                                    DropdownMenuItem(value: 'topCenter', child: Text('Top Center')),
                                    DropdownMenuItem(value: 'topRight', child: Text('Top Right')),
                                    DropdownMenuItem(value: 'bottomLeft', child: Text('Bottom Left')),
                                    DropdownMenuItem(value: 'bottomCenter', child: Text('Bottom Center')),
                                    DropdownMenuItem(value: 'bottomRight', child: Text('Bottom Right')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) onPositionChange(val);
                                  }
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: onStart,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Overlay', style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: Center(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                KeycapWidget(keyName: 'W', config: theme),
                                KeycapWidget(keyName: 'A', config: theme),
                                KeycapWidget(keyName: 'S', config: theme),
                                KeycapWidget(keyName: 'D', config: theme),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VisualizationScreen extends StatefulWidget {
  final ThemeConfig theme;
  final String position;

  const VisualizationScreen({super.key, required this.theme, required this.position});

  @override
  State<VisualizationScreen> createState() => _VisualizationScreenState();
}

class _VisualizationScreenState extends State<VisualizationScreen> {
  final KeystrokeListener _listener = KeystrokeListener();
  StreamSubscription<KeystrokeEvent>? _subscription;

  final List<String> _activeKeys = [];
  final Map<int, String> _vkCodeToKey = {
    65: 'A', 66: 'B', 67: 'C', 68: 'D', 69: 'E', 70: 'F', 71: 'G', 72: 'H',
    73: 'I', 74: 'J', 75: 'K', 76: 'L', 77: 'M', 78: 'N', 79: 'O', 80: 'P',
    81: 'Q', 82: 'R', 83: 'S', 84: 'T', 85: 'U', 86: 'V', 87: 'W', 88: 'X',
    89: 'Y', 90: 'Z',
    160: 'LShift', 161: 'RShift', 162: 'LCtrl', 163: 'RCtrl', 164: 'LAlt', 165: 'RAlt',
    32: 'Space', 13: 'Enter', 8: 'Backspace',
    188: ',', 190: '.', 191: '/', 186: ';', 222: '\'', 219: '[', 221: ']', 220: '\\',
    189: '-', 187: '=', 192: '`',
    27: 'Esc',
  };

  @override
  void initState() {
    super.initState();
    _subscription = _listener.onKeystroke.listen((event) {
      if (event.type == 'keydown') {
        final keyName = _vkCodeToKey[event.vkCode] ?? 'Key(${event.vkCode})';
        if (!_activeKeys.contains(keyName)) {
          setState(() {
            _activeKeys.add(keyName);
            if (_activeKeys.length > 8) _activeKeys.removeAt(0);
          });
          
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _activeKeys.remove(keyName);
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  WrapAlignment _getWrapAlignment() {
    if (widget.position.toLowerCase().contains('left')) return WrapAlignment.start;
    if (widget.position.toLowerCase().contains('right')) return WrapAlignment.end;
    return WrapAlignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          DragToMoveArea(
            child: Container(
              color: Colors.black.withOpacity(0.01), 
              child: Column(
                mainAxisAlignment: widget.position.startsWith('top') ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: _getWrapAlignment(),
                      children: _activeKeys.map((key) => 
                        KeycapWidget(keyName: key, config: widget.theme)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
