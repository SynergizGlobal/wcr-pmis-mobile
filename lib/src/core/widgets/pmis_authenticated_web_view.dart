import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:wcr_pmis_mobile/src/core/constants/api_constants.dart';
import 'package:wcr_pmis_mobile/src/core/network/dio_client.dart';
import 'package:wcr_pmis_mobile/src/core/webview/pmis_web_session_bridge.dart';
import 'package:wcr_pmis_mobile/src/core/webview/webview_platform_initializer.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/providers/auth_token_provider.dart';

class PmisAuthenticatedWebView extends ConsumerStatefulWidget {
  const PmisAuthenticatedWebView({
    super.key,
    required this.url,
    this.projectId,
    this.projectName,
    this.reloadToken = 0,
  });

  final String url;
  final String? projectId;
  final String? projectName;
  final int reloadToken;

  @override
  ConsumerState<PmisAuthenticatedWebView> createState() =>
      _PmisAuthenticatedWebViewState();
}

class _PmisAuthenticatedWebViewState extends ConsumerState<PmisAuthenticatedWebView> {
  WebViewController? _controller;
  bool _initializing = false;
  bool _hasError = false;
  String? _errorMessage;
  int _progress = 0;
  bool _readyToMount = false;
  bool _storageBootstrapped = false;
  bool _loadingTargetPage = false;

  static final Uri _bootstrapUri = Uri.parse(ApiConstants.wcrBaseUrl);

  @override
  void initState() {
    super.initState();
    ensureWebViewPlatformInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleInitialize());
  }

  @override
  void didUpdateWidget(PmisAuthenticatedWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadToken != widget.reloadToken ||
        oldWidget.url != widget.url ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.projectName != widget.projectName) {
      _reloadPage();
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  void _scheduleInitialize() {
    if (!mounted || _initializing || _controller != null) {
      return;
    }
    _initializeController();
  }

  AuthSession? _activeSession() {
    return ref.read(authControllerProvider).valueOrNull;
  }

  Future<void> _initializeController() async {
    if (!mounted || _initializing) {
      return;
    }

    final AuthSession? session = _activeSession();
    if (session == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'You are not signed in. Please log in and try again.';
      });
      return;
    }

    setState(() {
      _initializing = true;
      _hasError = false;
      _errorMessage = null;
      _readyToMount = false;
      _storageBootstrapped = false;
      _loadingTargetPage = false;
    });

    try {
      await Future<void>.delayed(Duration.zero);
      if (!mounted) {
        return;
      }

      final WebViewController controller = await _createController(session);
      if (!mounted) {
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _readyToMount = true;
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initializing = false;
        _hasError = true;
        _errorMessage = error.message ?? error.toString();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initializing = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _reloadPage() async {
    final WebViewController? controller = _controller;
    if (controller == null) {
      _scheduleInitialize();
      return;
    }
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _progress = 0;
      _storageBootstrapped = false;
      _loadingTargetPage = false;
    });
    try {
      await _beginAuthenticatedLoad(controller);
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
        _errorMessage = error.message ?? error.toString();
      });
    }
  }

  Future<WebViewController> _createController(AuthSession session) async {
    final WebViewController controller = WebViewController.fromPlatformCreationParams(
      _platformCreationParams(),
    );

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (!mounted) {
              return;
            }
            setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _hasError = false;
              _errorMessage = null;
              _progress = 0;
            });
          },
          onPageFinished: (String url) => _handlePageFinished(controller, url),
          onWebResourceError: (WebResourceError error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
            });
          },
        ),
      );

    await _configurePlatformController(controller);
    await _beginAuthenticatedLoad(controller);
    return controller;
  }

  Future<void> _beginAuthenticatedLoad(WebViewController controller) async {
    await _syncSessionCookies();
    _storageBootstrapped = false;
    _loadingTargetPage = false;
    await controller.loadRequest(_bootstrapUri);
  }

  Future<void> _handlePageFinished(
    WebViewController controller,
    String url,
  ) async {
    final AuthSession? session = _activeSession();
    if (session == null) {
      return;
    }

    if (!_storageBootstrapped && _isBootstrapUrl(url)) {
      await _injectWebSession(controller, session);
      _storageBootstrapped = true;
      _loadingTargetPage = true;
      await controller.loadRequest(
        Uri.parse(widget.url),
        headers: await _authHeaders(),
      );
      return;
    }

    if (_loadingTargetPage) {
      _loadingTargetPage = false;
    }
    await _injectMobileViewport(controller);
  }

  bool _isBootstrapUrl(String url) {
    final Uri? parsed = Uri.tryParse(url);
    if (parsed == null) {
      return false;
    }
    return parsed.host == _bootstrapUri.host && parsed.path.startsWith('/wcrpmis');
  }

  Future<void> _injectWebSession(
    WebViewController controller,
    AuthSession session,
  ) async {
    final String script = PmisWebSessionBridge.buildStorageBootstrapScript(
      session: session,
      projectId: widget.projectId,
      projectName: widget.projectName,
    );
    try {
      await controller.runJavaScript(script);
    } catch (_) {
      // Continue; navigation may still succeed if cookies are valid.
    }
  }

  PlatformWebViewControllerCreationParams _platformCreationParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    }
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      return AndroidWebViewControllerCreationParams();
    }
    return const PlatformWebViewControllerCreationParams();
  }

  Future<void> _configurePlatformController(WebViewController controller) async {
    try {
      if (controller.platform is AndroidWebViewController) {
        final AndroidWebViewController android =
            controller.platform as AndroidWebViewController;
        if (kDebugMode) {
          await AndroidWebViewController.enableDebugging(true);
        }
        await android.setMediaPlaybackRequiresUserGesture(false);
        await android.setUseWideViewPort(true);
        await android.enableZoom(true);
      } else if (controller.platform is WebKitWebViewController) {
        final WebKitWebViewController ios =
            controller.platform as WebKitWebViewController;
        await ios.setAllowsBackForwardNavigationGestures(true);
      }
    } on PlatformException {
      // Ignore optional platform tuning when the channel is unavailable.
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final String? token = ref.read(authTokenProvider)?.trim();
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Future<void> _syncSessionCookies() async {
    final sessionCookieManager =
        ref.read(sessionCookieManagerProvider).valueOrNull;
    if (sessionCookieManager == null) {
      return;
    }

    final List<Cookie> cookies =
        await sessionCookieManager.currentCookiesForWebView();
    if (cookies.isEmpty) {
      return;
    }

    final WebViewCookieManager cookieManager = WebViewCookieManager();
    final Uri origin = ApiConstants.wcrOriginUri;
    const String webPath = '/wcrpmis/';

    for (final Cookie cookie in cookies) {
      final String domain = _normalizeCookieDomain(cookie.domain) ?? origin.host;
      final String path = cookie.path?.trim().isNotEmpty == true
          ? cookie.path!.trim()
          : webPath;
      try {
        await cookieManager.setCookie(
          WebViewCookie(
            name: cookie.name,
            value: cookie.value,
            domain: domain,
            path: path,
          ),
        );
      } on PlatformException {
        // Continue loading even if a cookie could not be set.
      }
    }
  }

  String? _normalizeCookieDomain(String? domain) {
    final String trimmed = domain?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.startsWith('.') ? trimmed.substring(1) : trimmed;
  }

  Future<void> _injectMobileViewport(WebViewController controller) async {
    const String script = '''
(function() {
  var meta = document.querySelector('meta[name="viewport"]');
  if (!meta) {
    meta = document.createElement('meta');
    meta.name = 'viewport';
    document.head.appendChild(meta);
  }
  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
})();
''';
    try {
      await controller.runJavaScript(script);
    } catch (_) {
      // Non-fatal if the page blocks script injection.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight < 1 || constraints.maxWidth < 1) {
          return const SizedBox.shrink();
        }

        if (_initializing || (!_readyToMount && _controller == null && !_hasError)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_hasError) {
          return _ErrorView(
            colorScheme: cs,
            message: _errorMessage,
            onRetry: () {
              setState(() {
                _controller = null;
                _readyToMount = false;
              });
              _scheduleInitialize();
            },
          );
        }

        final WebViewController? controller = _controller;
        if (controller == null || !_readyToMount) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WebViewWidget(controller: controller),
              ),
            ),
            if (_progress > 0 && _progress < 100)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 2,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.colorScheme,
    required this.message,
    required this.onRetry,
  });

  final ColorScheme colorScheme;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.wifi_off_rounded, size: 40, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Unable to load page',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
