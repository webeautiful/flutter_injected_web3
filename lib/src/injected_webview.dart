import 'dart:collection';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter_injected_web3/src/js_callback_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class InjectedWebview extends StatefulWidget {
  /// `gestureRecognizers` specifies which gestures should be consumed by the WebView.
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  /// When `gestureRecognizers` is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  ///The window id of a [CreateWindowAction.windowId].
  final int? windowId;
  final bool isDebug;
  int chainId;
  String rpc;
  bool initialized = false;
  String? currentURL;
  InjectedWebview({
    required this.chainId,
    required this.rpc,
    Key? key,
    this.windowId,
    this.initialUrlRequest,
    this.initialFile,
    this.initialData,
    this.initialSettings,
    this.initialUserScripts,
    this.pullToRefreshController,
    this.contextMenu,
    this.onWebViewCreated,
    this.onLoadStart,
    this.onLoadStop,
    this.onReceivedError,
    this.onReceivedHttpError,
    this.onConsoleMessage,
    this.onProgressChanged,
    this.shouldOverrideUrlLoading,
    this.onLoadResource,
    this.onScrollChanged,
    this.onDownloadStartRequest,
    this.onLoadResourceCustomScheme,
    this.onCreateWindow,
    this.onCloseWindow,
    this.onJsAlert,
    this.onJsConfirm,
    this.onJsPrompt,
    this.onReceivedHttpAuthRequest,
    this.onReceivedServerTrustAuthRequest,
    this.onReceivedClientCertRequest,
    this.shouldInterceptAjaxRequest,
    this.onAjaxReadyStateChange,
    this.onAjaxProgress,
    this.shouldInterceptFetchRequest,
    this.onUpdateVisitedHistory,
    this.onLongPressHitTestResult,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onPageCommitVisible,
    this.onTitleChanged,
    this.onWindowFocus,
    this.onWindowBlur,
    this.onOverScrolled,
    this.onZoomScaleChanged,
    this.onSafeBrowsingHit,
    this.androidOnPermissionRequest,
    this.onGeolocationPermissionsShowPrompt,
    this.onGeolocationPermissionsHidePrompt,
    this.shouldInterceptRequest,
    this.onRenderProcessGone,
    this.onRenderProcessResponsive,
    this.onRenderProcessUnresponsive,
    this.onFormResubmission,
    this.onReceivedIcon,
    this.onReceivedTouchIconUrl,
    this.onJsBeforeUnload,
    this.onReceivedLoginRequest,
    this.onWebContentProcessDidTerminate,
    this.onDidReceiveServerRedirectForProvisionalNavigation,
    this.onNavigationResponse,
    this.shouldAllowDeprecatedTLS,
    this.gestureRecognizers,
    this.signTransaction,
    this.signPersonalMessage,
    this.signMessage,
    this.signTypedMessage,
    this.ecRecover,
    this.requestAccounts,
    this.watchAsset,
    this.addEthereumChain,
    this.isDebug = false,
    this.findInteractionController,
  }) : super();

  @override
  // ignore: library_private_types_in_public_api
  _InjectedWebviewState createState() => _InjectedWebviewState();

  final void Function(InAppWebViewController controller)?
      onGeolocationPermissionsHidePrompt;

  final Future<GeolocationPermissionShowPromptResponse?> Function(
          InAppWebViewController controller, String origin)?
      onGeolocationPermissionsShowPrompt;

  final Future<PermissionResponse?> Function(
      InAppWebViewController, PermissionRequest)? androidOnPermissionRequest;

  final Future<SafeBrowsingResponse?> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat? threatType)? onSafeBrowsingHit;

  final InAppWebViewInitialData? initialData;

  final String? initialFile;

  final InAppWebViewSettings? initialSettings;

  final URLRequest? initialUrlRequest;

  final UnmodifiableListView<UserScript>? initialUserScripts;
  final PullToRefreshController? pullToRefreshController;

  final ContextMenu? contextMenu;

  final void Function(InAppWebViewController controller, Uri? url)?
      onPageCommitVisible;

  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  final void Function(InAppWebViewController controller)?
      onDidReceiveServerRedirectForProvisionalNavigation;

  final void Function(InAppWebViewController controller)?
      onWebContentProcessDidTerminate;

  final Future<NavigationResponseAction?> Function(
      InAppWebViewController controller,
      NavigationResponse navigationResponse)? onNavigationResponse;

  final Future<ShouldAllowDeprecatedTLSAction?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? shouldAllowDeprecatedTLS;

  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxProgress;

  final Future<AjaxRequestAction?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      onAjaxReadyStateChange;

  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)?
      onConsoleMessage;

  final Future<bool?> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction)? onCreateWindow;

  final void Function(InAppWebViewController controller)? onCloseWindow;

  final void Function(InAppWebViewController controller)? onWindowFocus;

  final void Function(InAppWebViewController controller)? onWindowBlur;

  final void Function(InAppWebViewController controller, Uint8List icon)?
      onReceivedIcon;

  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)?
      onReceivedTouchIconUrl;

  final void Function(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest)? onDownloadStartRequest;

  FindInteractionController? findInteractionController;

  final Future<JsAlertResponse?> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)?
      onJsAlert;

  final Future<JsConfirmResponse?> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)?
      onJsConfirm;

  final Future<JsPromptResponse?> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)?
      onJsPrompt;

  final void Function(InAppWebViewController controller,
      WebResourceRequest request, WebResourceError error)? onReceivedError;

  final void Function(
      InAppWebViewController controller,
      WebResourceRequest request,
      WebResourceResponse response)? onReceivedHttpError;

  final void Function(
          InAppWebViewController controller, LoadedResource resource)?
      onLoadResource;

  final Future<CustomSchemeResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      onLoadResourceCustomScheme;

  final void Function(InAppWebViewController controller, Uri? url)? onLoadStart;

  final void Function(InAppWebViewController controller, Uri? url)? onLoadStop;

  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult)? onLongPressHitTestResult;

  final void Function(InAppWebViewController controller, int progress)?
      onProgressChanged;

  final Future<ClientCertResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedClientCertRequest;

  final Future<HttpAuthResponse?> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedHttpAuthRequest;

  final Future<ServerTrustAuthResponse?> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge)? onReceivedServerTrustAuthRequest;

  final void Function(InAppWebViewController controller, int x, int y)?
      onScrollChanged;

  final void Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
      onUpdateVisitedHistory;

  final void Function(InAppWebViewController controller)? onWebViewCreated;

  final Future<AjaxRequest?> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)?
      shouldInterceptAjaxRequest;

  final Future<FetchRequest?> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)?
      shouldInterceptFetchRequest;

  final Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)?
      shouldOverrideUrlLoading;

  final void Function(InAppWebViewController controller)? onEnterFullscreen;

  final void Function(InAppWebViewController controller)? onExitFullscreen;

  final void Function(InAppWebViewController controller, int x, int y,
      bool clampedX, bool clampedY)? onOverScrolled;

  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)?
      onZoomScaleChanged;

  final Future<WebResourceResponse?> Function(
          InAppWebViewController controller, WebResourceRequest request)?
      shouldInterceptRequest;

  final Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessUnresponsive;

  final Future<WebViewRenderProcessAction?> Function(
      InAppWebViewController controller, Uri? url)? onRenderProcessResponsive;

  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)?
      onRenderProcessGone;

  final Future<FormResubmissionAction?> Function(
      InAppWebViewController controller, Uri? url)? onFormResubmission;

  final Future<JsBeforeUnloadResponse?> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest)? onJsBeforeUnload;

  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)?
      onReceivedLoginRequest;
  final Future<String> Function(InAppWebViewController controller,
      JsTransactionObject data, int chainId)? signTransaction;
  final Future<String> Function(InAppWebViewController controller, String data)?
      signPersonalMessage;
  final Future<String> Function(
      InAppWebViewController controller, String data, int chainId)? signMessage;
  final Future<String> Function(InAppWebViewController controller,
      JsEthSignTypedData data, int chainId)? signTypedMessage;
  final Future<String> Function(InAppWebViewController controller,
      JsEcRecoverObject data, int chainId)? ecRecover;
  final Future<IncomingAccountsModel> Function(
          InAppWebViewController controller, String data, int chainId)?
      requestAccounts;
  final Future<String> Function(
          InAppWebViewController controller, JsWatchAsset data, int chainId)?
      watchAsset;

  final Future<String> Function(InAppWebViewController controller,
      JsAddEthereumChain data, int chainId)? addEthereumChain;
}

class _InjectedWebviewState extends State<InjectedWebview> {
  String address = "";

  bool isLoadJs = false;
  String? jsProviderScript;
  String? currentURL;
  @override
  void initState() {
    super.initState();
    _loadWeb3();
  }

  ///Load provider initial web3 to inject web app
  Future<void> _loadWeb3() async {
    String? web3;
    String path = "packages/flutter_injected_web3/assets/provider.min.js";
    web3 = await DefaultAssetBundle.of(context).loadString(path);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentURL = widget.initialUrlRequest?.url.toString();
    String? savedAddress = prefs.getString('account_address_$currentURL');

    if (mounted) {
      setState(() {
        jsProviderScript = web3;
        isLoadJs = true;
        address = savedAddress ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoadJs == false
        ? Container()
        : InAppWebView(
            windowId: widget.windowId,
            initialUrlRequest: widget.initialUrlRequest,
            initialFile: widget.initialFile,
            initialData: widget.initialData,
            initialSettings: widget.initialSettings,
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: jsProviderScript ?? '',
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
              UserScript(
                source: address.isNotEmpty
                    ? _loadReInt(widget.chainId, widget.rpc, address)
                    : _loadInitJs(widget.chainId, widget.rpc),
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              ),
            ]),
            pullToRefreshController: widget.pullToRefreshController,
            contextMenu: widget.contextMenu,
            onWebViewCreated: widget.onWebViewCreated,
            onLoadStart: (controller, uri) async {
              widget.onLoadStart?.call(controller, uri);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              currentURL = widget.initialUrlRequest?.url.toString();
              String? savedAddress =
                  prefs.getString('account_address_$currentURL') ?? "";
              _initWeb3(controller, savedAddress.isNotEmpty);
              widget.initialized = true;
            },
            onLoadStop: (controller, uri) async {
              _initWeb3(controller, true);
              widget.onLoadStop?.call(controller, uri);
            },
            onReceivedError: widget.onReceivedError,
            onReceivedHttpError: widget.onReceivedHttpError,
            onConsoleMessage: (
              controller,
              consoleMessage,
            ) {
              if (widget.isDebug) {
                print("Console Message: ${consoleMessage.message}");
              }
              widget.onConsoleMessage?.call(
                controller,
                consoleMessage,
              );
            },
            onProgressChanged: (controller, progress) async {
              _initWeb3(controller, true);

              widget.onProgressChanged?.call(controller, progress);
            },
            shouldOverrideUrlLoading: widget.shouldOverrideUrlLoading,
            onLoadResource: widget.onLoadResource,
            onScrollChanged: widget.onScrollChanged,
            onDownloadStartRequest: widget.onDownloadStartRequest,
            onLoadResourceWithCustomScheme: widget.onLoadResourceCustomScheme,
            onCreateWindow: widget.onCreateWindow,
            onCloseWindow: widget.onCloseWindow,
            onJsAlert: widget.onJsAlert,
            onJsConfirm: widget.onJsConfirm,
            onJsPrompt: widget.onJsPrompt,
            onReceivedHttpAuthRequest: widget.onReceivedHttpAuthRequest,
            onReceivedServerTrustAuthRequest:
                widget.onReceivedServerTrustAuthRequest,
            onReceivedClientCertRequest: widget.onReceivedClientCertRequest,
            findInteractionController: widget.findInteractionController,
            shouldInterceptAjaxRequest: widget.shouldInterceptAjaxRequest,
            onAjaxReadyStateChange: widget.onAjaxReadyStateChange,
            onAjaxProgress: widget.onAjaxProgress,
            shouldInterceptFetchRequest: widget.shouldInterceptFetchRequest,
            onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
            onLongPressHitTestResult: widget.onLongPressHitTestResult,
            onEnterFullscreen: widget.onEnterFullscreen,
            onExitFullscreen: widget.onExitFullscreen,
            onPageCommitVisible: widget.onPageCommitVisible,
            onTitleChanged: widget.onTitleChanged,
            onWindowFocus: widget.onWindowFocus,
            onWindowBlur: widget.onWindowBlur,
            onOverScrolled: widget.onOverScrolled,
            onZoomScaleChanged: widget.onZoomScaleChanged,
            onSafeBrowsingHit: widget.onSafeBrowsingHit,
            onPermissionRequest: widget.androidOnPermissionRequest,
            onGeolocationPermissionsShowPrompt:
                widget.onGeolocationPermissionsShowPrompt,
            onGeolocationPermissionsHidePrompt:
                widget.onGeolocationPermissionsHidePrompt,
            shouldInterceptRequest: widget.shouldInterceptRequest,
            onRenderProcessGone: widget.onRenderProcessGone,
            onRenderProcessResponsive: widget.onRenderProcessResponsive,
            onRenderProcessUnresponsive: widget.onRenderProcessUnresponsive,
            onFormResubmission: widget.onFormResubmission,
            onReceivedIcon: widget.onReceivedIcon,
            onReceivedTouchIconUrl: widget.onReceivedTouchIconUrl,
            onJsBeforeUnload: widget.onJsBeforeUnload,
            onReceivedLoginRequest: widget.onReceivedLoginRequest,
            onWebContentProcessDidTerminate:
                widget.onWebContentProcessDidTerminate,
            onDidReceiveServerRedirectForProvisionalNavigation:
                widget.onDidReceiveServerRedirectForProvisionalNavigation,
            onNavigationResponse: widget.onNavigationResponse,
            shouldAllowDeprecatedTLS: widget.shouldAllowDeprecatedTLS,
            gestureRecognizers: widget.gestureRecognizers,
          );
  }

  _initWeb3(InAppWebViewController controller, bool reInit) async {
    if (Platform.isAndroid) {
      await controller.injectJavascriptFileFromAsset(
          assetFilePath:
              "packages/flutter_injected_web3/assets/provider.min.js");
      String initJs = reInit
          ? _loadReInt(widget.chainId, widget.rpc, address)
          : _loadInitJs(widget.chainId, widget.rpc);
      debugPrint("RPC: ${widget.rpc}");
      await controller.evaluateJavascript(source: initJs);
    }
    if (!controller.hasJavaScriptHandler(handlerName: "OrangeHandler")) {
      controller.addJavaScriptHandler(
          handlerName: "OrangeHandler",
          callback: (callback) async {
            final jsData = JsCallbackModel.fromJson(callback[0]);

            debugPrint("callBack: $callback");
            switch (jsData.name) {
              case "signTransaction":
                {
                  try {
                    final data =
                        JsTransactionObject.fromJson(jsData.object ?? {});

                    widget.signTransaction
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      if (signedData.isEmpty) return;
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "signPersonalMessage":
                {
                  try {
                    final data = JsDataModel.fromJson(jsData.object ?? {});

                    widget.signPersonalMessage
                        ?.call(controller, data.data ?? "")
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "signMessage":
                {
                  try {
                    final data = JsDataModel.fromJson(jsData.object ?? {});

                    widget.signMessage
                        ?.call(controller, data.data ?? "", widget.chainId)
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "signTypedMessage":
                {
                  final data = JsEthSignTypedData.fromJson(jsData.object ?? {});

                  try {
                    widget.signTypedMessage
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "ecRecover":
                {
                  final data = JsEcRecoverObject.fromJson(jsData.object ?? {});

                  try {
                    widget.ecRecover
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "requestAccounts":
              case 'eth_requestAccounts':
                {
                  try {
                    widget.requestAccounts
                        ?.call(controller, "", widget.chainId)
                        .then((signedData) async {
                      final setAddress =
                          "window.ethereum.setAddress(\"${signedData.address}\");";
                      address = signedData.address;
                      String callback =
                          "window.ethereum.sendResponse(${jsData.id}, [\"${signedData.address}\"])";
                      await _sendCustomResponse(controller, setAddress);
                      await _sendCustomResponse(controller, callback);
                      currentURL = (await controller.getUrl()).toString();
                      // Save address to SharedPreferences with the dApp URL
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          'account_address_$currentURL', signedData.address);

                      if (widget.chainId != signedData.chainId) {
                        final initString = _addChain(
                            signedData.chainId,
                            signedData.rpcUrl,
                            signedData.address,
                            widget.isDebug);
                        widget.chainId = signedData.chainId;
                        widget.rpc = signedData.rpcUrl;
                        await _sendCustomResponse(controller, initString);
                      }
                    }).onError((e, stackTrace) {
                      debugPrint(e.toString());
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    debugPrint(e.toString());

                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "watchAsset":
                {
                  try {
                    final data = JsWatchAsset.fromJson(jsData.object ?? {});

                    widget.watchAsset
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "addEthereumChain":
                {
                  try {
                    final data =
                        JsAddEthereumChain.fromJson(jsData.object ?? {});
                    widget.addEthereumChain
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      final initString = _addChain(int.parse(data.chainId!),
                          signedData, address, widget.isDebug);
                      widget.chainId = int.parse(data.chainId!);
                      widget.rpc = signedData;
                      _sendCustomResponse(controller, initString);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              case "switchEthereumChain":
              case "wallet_switchEthereumChain":
                {
                  try {
                    final data =
                        JsAddEthereumChain.fromJson(jsData.object ?? {});

                    widget.addEthereumChain
                        ?.call(controller, data, widget.chainId)
                        .then((signedData) {
                      _sendResult(
                          controller, "ethereum", signedData, jsData.id ?? 0);
                      widget.chainId = int.parse(data.chainId!);
                      widget.rpc = signedData;
                      final initString = _addChain(int.parse(data.chainId!),
                          signedData, address, widget.isDebug);
                      _sendCustomResponse(controller, initString);
                    }).onError((e, stackTrace) {
                      _sendError(
                          controller, "ethereum", e.toString(), jsData.id ?? 0);
                    });
                  } catch (e) {
                    _sendError(
                        controller, "ethereum", e.toString(), jsData.id ?? 0);
                  }
                  break;
                }
              default:
                {
                  _sendError(controller, jsData.network.toString(),
                      "Operation not supported", jsData.id ?? 0);
                  break;
                }
            }
          });
    }
    widget.initialized = true;
    return;
  }

  String _loadInitJs(int chainId, String rpcUrl) {
    String source = '''
        (function() {
            var config = {
                ethereum: {
                    chainId: $chainId,
                    rpcUrl: "$rpcUrl"
                },
                solana: {
                    cluster: "mainnet-beta",
                },
                isDebug: true
            };
            trustwallet.ethereum = new trustwallet.Provider(config);
            trustwallet.solana = new trustwallet.SolanaProvider(config);
            trustwallet.postMessage = (json) => {
                // window._tw_.postMessage(JSON.stringify(json));
                console.log('trustwallet.postMessage=>', json)
                if (window._tw_) {
                  window._tw_.postMessage(JSON.stringify(json));
                } else if(window.flutter_inappwebview.callHandler) {
                  // @params - eg. {id: 0, name: 'signMessage', object: { chainId: 56 }, network: 'BSC'}
                  window.flutter_inappwebview.callHandler('_tw_', json)
                }
            }
            window.ethereum = trustwallet.ethereum;
        })();
        ''';
    return source;
  }

  String _loadReInt(int chainId, String rpcUrl, String address) {
    String source = '''
        (function() {
          if(window.ethereum == null){
            var config = {
                ethereum: {
                    chainId: $chainId,
                    rpcUrl: "$rpcUrl",
                    address: "$address"
                },
                solana: {
                    cluster: "mainnet-beta",
                },
                isDebug: true
            };
            trustwallet.ethereum = new trustwallet.Provider(config);
            trustwallet.solana = new trustwallet.SolanaProvider(config);
            trustwallet.postMessage = (json) => {
                // window._tw_.postMessage(JSON.stringify(json));
                console.log('trustwallet.postMessage=>', json)
                if (window._tw_) {
                  window._tw_.postMessage(JSON.stringify(json));
                } else if(window.flutter_inappwebview.callHandler) {
                  // @params - eg. {id: 0, name: 'signMessage', object: { chainId: 56 }, network: 'BSC'}
                  window.flutter_inappwebview.callHandler('_tw_', json)
                }
            }
            window.ethereum = trustwallet.ethereum;
          }
        })();
        ''';
    return source;
  }

  String _addChain(int chainId, String rpcUrl, String address, bool isDebug) {
    String source = '''
        window.ethereum.setNetwork({
          ethereum:{
            chainId: $chainId,
            rpcUrl: "$rpcUrl",
            isDebug: $isDebug
            }
          }
        )
        ''';
    return source;
  }

  Future<void> _sendError(InAppWebViewController controller, String network,
      String message, int methodId) {
    String script = "window.$network.sendError($methodId, \"$message\")";
    return controller.evaluateJavascript(source: script);
  }

  Future<void> _sendResult(InAppWebViewController controller, String network,
      String message, int methodId) {
    String script = "window.$network.sendResponse($methodId, \"$message\")";
    debugPrint(script);
    return controller
        .evaluateJavascript(source: script)
        .then((value) => debugPrint(value))
        .onError((error, stackTrace) => debugPrint(error.toString()));
  }

  Future<void> _sendCustomResponse(
      InAppWebViewController controller, String response) {
    return controller
        .evaluateJavascript(source: response)
        .then((value) => debugPrint(value))
        .onError((error, stackTrace) => debugPrint(error.toString()));
  }

  Future<void> _sendResults(InAppWebViewController controller, String network,
      List<String> messages, int methodId) {
    String message = messages.join(",");
    String script = "window.$network.sendResponse($methodId, \"$message\")";
    return controller.evaluateJavascript(source: script);
  }
}
