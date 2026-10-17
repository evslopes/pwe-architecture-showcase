import 'package:pwe/core/utils/swallowed_error_logger.dart';

import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import 'package:pwe/core/network/cancellation_token.dart';
import 'package:pwe/core/error/exceptions.dart';
import 'package:pwe/core/services/llm_performance_tracker.dart';
import 'package:pwe/core/services/model_download_service.dart';

import '../../domain/enums/lectio_stage.dart';

import 'package:pwe/features/profile/domain/entities/lectio_maturity_level.dart';

import '../../domain/entities/retrieved_context.dart';
import '../utils/edge_prompt_window.dart';
import '../utils/prompt_template_factory.dart';

abstract class ILlmLocalDataSource {
  Future<String> generateMeditationPoints(
    String passage, {
    LectioStage stage = LectioStage.meditatio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  });

  Future<String> generatePrayerPrompts(
    String text, {
    LectioStage stage = LectioStage.oratio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  });

  Future<String> generateContemplatioGuidance(
    String userPrayerNotes, {
    LectioStage stage = LectioStage.contemplatio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  });

  Future<String> generateSocraticReview(String userReflection, String passage);

  /// Emite a revisão socrática em streaming com suporte a cancelamento.
  Stream<String> streamSocraticReview(
    String userReflection,
    String passage, {
    CancellationToken? token,
  });

  Future<String> generateExegeseCentral(
    String passage, {
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
    String language = 'pt',
  });

  Future<String> generateSummary(String text);

  /// Gera um fluxo contínuo de tokens/chunks de resposta via streaming no dispositivo local.
  Stream<String> generateStream(String prompt);

  /// Cancela ou interrompe a inferência ativa no motor on-device.
  void abort();

  bool get isModelLoaded;

  Future<void> initialize();

  void dispose();

  /// Nome do modelo local (ex: Gemma-4-E2B-it (LiteRT LM)).
  String get modelName => 'Gemma-4-E2B-it (LiteRT LM)';

  /// Backend ativo de aceleração de hardware (ex: GPU, CPU, Metal).
  String get activeBackend;
}

class GemmaLocalDataSourceImpl implements ILlmLocalDataSource {
  static const _channel = MethodChannel('pwe/gemma_local');
  final IModelDownloadService _downloadService;
  final PromptTemplateFactory _promptFactory;
  bool _modelLoaded = false;
  String _activeBackend = 'CPU';

  /// Timeout seguro para inferência on-device (evita travar a jornada do usuário).
  static const Duration _inferenceTimeout = Duration(seconds: 20);

  GemmaLocalDataSourceImpl(
    this._downloadService, [
    PromptTemplateFactory? promptFactory,
  ]) : _promptFactory = promptFactory ?? PromptTemplateFactory();

  @override
  String get modelName => 'Gemma-4-E2B-it (LiteRT LM)';

  @override
  String get activeBackend => _activeBackend;

  @override
  bool get isModelLoaded => _modelLoaded;

  @override
  Future<void> initialize() async {
    if (_modelLoaded) return;

    final sw = Stopwatch()..start();
    try {
      final path = await _downloadService.getModelPath();
      if (path == null) {
        throw const LocalInferenceException(
          'Modelo não encontrado localmente.',
        );
      }

      final success = await _channel.invokeMethod<bool>('loadModel', {
        'path': path,
      });
      _modelLoaded = success ?? false;

      if (_modelLoaded) {
        try {
          final backend = await _channel.invokeMethod<String>(
            'getActiveBackend',
          );
          if (backend != null && backend.isNotEmpty) {
            _activeBackend = backend;
          }
          // Dispara warmup assíncrono para pré-compilar shaders sem travar a UI
          unawaited(_channel.invokeMethod<bool>('warmup'));
        } catch (error, stackTrace) {
          logSwallowedError(error, stackTrace);
        }
      }

      sw.stop();
      log(
        '[GemmaLocal] Modelo local carregado com sucesso via $_activeBackend: $_modelLoaded (${sw.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      sw.stop();
      log(
        '[GemmaLocal] Erro ao carregar modelo local após ${sw.elapsedMilliseconds}ms: $e',
      );
      _modelLoaded = false;
      throw LocalInferenceException('Erro ao carregar modelo: $e');
    }
  }

  /// Recarrega preventivamente o modelo na CPU caso a GPU falhe ou trave.
  Future<void> _reloadOnCpu() async {
    try {
      final path = await _downloadService.getModelPath();
      if (path != null) {
        final success = await _channel.invokeMethod<bool>('loadModel', {
          'path': path,
          'backend': 'CPU',
        });
        if (success == true) {
          _activeBackend = 'CPU';
          log('[GemmaLocal] ℹ️ Modelo reconfigurado com sucesso para CPU.');
        }
      }
    } catch (e) {
      log('[GemmaLocal] ⚠️ Erro ao recarregar modelo na CPU: $e');
    }
  }

  /// Executa a inferência com medição de métricas de telemetria e timeout de proteção.
  Future<String> _executeInference({
    required String prompt,
    required String stageName,
  }) async {
    await _ensureInitialized();
    final sw = Stopwatch()..start();

    try {
      final resultRaw = await _channel
          .invokeMethod<dynamic>('generate', {'prompt': prompt})
          .timeout(
            _inferenceTimeout,
            onTimeout: () => throw TimeoutException(
              'Timeout de ${_inferenceTimeout.inSeconds}s excedido na inferência local.',
            ),
          );

      sw.stop();

      String output = '';
      int? ttftMs;
      int durationMs = sw.elapsedMilliseconds;

      if (resultRaw is Map) {
        output = (resultRaw['text'] as String?) ?? '';
        ttftMs = (resultRaw['ttftMs'] as num?)?.toInt();
        durationMs =
            (resultRaw['durationMs'] as num?)?.toInt() ??
            sw.elapsedMilliseconds;
        _activeBackend = (resultRaw['backend'] as String?) ?? 'CPU';
      } else if (resultRaw is String) {
        output = resultRaw;
      }

      final metrics = LlmExecutionMetrics(
        modelName: modelName,
        stage: stageName,
        durationMs: durationMs,
        ttftMs: ttftMs,
        inputChars: prompt.length,
        outputChars: output.length,
        backend: _activeBackend,
        isSuccess: true,
      );
      metrics.logMetrics();

      return output;
    } on TimeoutException catch (e) {
      sw.stop();
      if (_activeBackend == 'GPU') {
        log(
          '[GemmaLocal] ⚠️ Timeout na GPU. Disparando recarregamento em CPU para próximas requisições...',
        );
        unawaited(_reloadOnCpu());
      }
      final metrics = LlmExecutionMetrics(
        modelName: modelName,
        stage: stageName,
        durationMs: sw.elapsedMilliseconds,
        inputChars: prompt.length,
        outputChars: 0,
        backend: _activeBackend,
        isSuccess: false,
        error: e.message,
      );
      metrics.logMetrics();
      throw LocalInferenceException(e.message ?? 'Timeout na inferência local');
    } on PlatformException catch (e) {
      sw.stop();
      final isHardwareGpuError =
          _activeBackend == 'GPU' &&
          (e.code == 'TIMEOUT' ||
              (e.message?.contains('CL_') == true ||
                  e.message?.contains('OpenCL') == true ||
                  e.message?.contains('Vulkan') == true ||
                  e.message?.toLowerCase().contains('out of memory') == true));

      if (isHardwareGpuError) {
        log(
          '[GemmaLocal] ⚠️ Falha crítica de GPU detectada (${e.code}: ${e.message}). Disparando recarregamento em CPU para próximas requisições...',
        );
        unawaited(_reloadOnCpu());
      }
      final metrics = LlmExecutionMetrics(
        modelName: modelName,
        stage: stageName,
        durationMs: sw.elapsedMilliseconds,
        inputChars: prompt.length,
        outputChars: 0,
        backend: _activeBackend,
        isSuccess: false,
        error: e.message,
      );
      metrics.logMetrics();
      throw LocalInferenceException('Erro na inferência local: ${e.message}');
    } catch (e) {
      sw.stop();
      final metrics = LlmExecutionMetrics(
        modelName: modelName,
        stage: stageName,
        durationMs: sw.elapsedMilliseconds,
        inputChars: prompt.length,
        outputChars: 0,
        backend: _activeBackend,
        isSuccess: false,
        error: e.toString(),
      );
      metrics.logMetrics();
      throw LocalInferenceException('Erro inesperado na inferência local: $e');
    }
  }

  /// Formata contexto RAG conciso para modelos Edge utilizando janela deslizante estruturada.
  /// Isso reduz drasticamente o prefill e faz o TTFT cair para ~2 a 4 segundos na CPU.
  String? _formatEdgeContext(List<RetrievedContext>? historicalContext) {
    if (historicalContext == null || historicalContext.isEmpty) return null;
    final summaries = historicalContext.map((c) {
      return (c.compressedSummary != null && c.compressedSummary!.isNotEmpty)
          ? c.compressedSummary!
          : c.relevantText;
    }).toList();

    return EdgePromptWindow.formatPrompt(
      systemInstruction: '',
      biblicalPassage: '',
      userInput: '',
      recentHistory: summaries,
      maxChars: 400,
    ).trim();
  }

  @override
  Stream<String> streamSocraticReview(
    String userReflection,
    String passage, {
    CancellationToken? token,
  }) async* {
    if (token?.isCancelled == true) {
      throw const OperationCancelledException();
    }

    final prompt = _promptFactory.buildEdgeSocraticPrompt(
      userReflection: userReflection,
      passage: passage,
    );

    token?.register(() {
      log('[GemmaLocal] Cancelamento acionado via CancellationToken.');
      abort();
    });

    try {
      final result = await _executeInference(
        prompt: prompt,
        stageName: 'SocraticReview',
      );
      if (token?.isCancelled == true) {
        throw const OperationCancelledException();
      }
      yield result;
    } on LocalInferenceException {
      rethrow;
    } catch (e) {
      if (token?.isCancelled == true) {
        throw const OperationCancelledException();
      }
      throw LocalInferenceException('Erro na inferência local: $e');
    }
  }

  @override
  Future<String> generateMeditationPoints(
    String passage, {
    LectioStage stage = LectioStage.meditatio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  }) async {
    final contextStr = _formatEdgeContext(historicalContext);
    final prompt = _promptFactory.buildEdgePrompt(
      stage: stage,
      userInput: passage,
      historicalContext: contextStr,
      maturityLevel: maturityLevel,
    );

    return _executeInference(prompt: prompt, stageName: 'Meditatio');
  }

  @override
  Future<String> generatePrayerPrompts(
    String text, {
    LectioStage stage = LectioStage.oratio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  }) async {
    final contextStr = _formatEdgeContext(historicalContext);
    final prompt = _promptFactory.buildEdgePrompt(
      stage: stage,
      userInput: text,
      historicalContext: contextStr,
      maturityLevel: maturityLevel,
    );

    return _executeInference(prompt: prompt, stageName: 'Oratio');
  }

  @override
  Future<String> generateContemplatioGuidance(
    String userPrayerNotes, {
    LectioStage stage = LectioStage.contemplatio,
    List<RetrievedContext>? historicalContext,
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
  }) async {
    final contextStr = _formatEdgeContext(historicalContext);
    final prompt = _promptFactory.buildEdgePrompt(
      stage: stage,
      userInput: userPrayerNotes,
      historicalContext: contextStr,
      maturityLevel: maturityLevel,
    );

    return _executeInference(prompt: prompt, stageName: 'Contemplatio');
  }

  @override
  Future<String> generateSocraticReview(
    String userReflection,
    String passage,
  ) async {
    final prompt = _promptFactory.buildEdgeSocraticPrompt(
      userReflection: userReflection,
      passage: passage,
    );

    return _executeInference(prompt: prompt, stageName: 'SocraticReview');
  }

  @override
  Future<String> generateExegeseCentral(
    String passage, {
    LectioMaturityLevel maturityLevel = LectioMaturityLevel.beginner,
    String language = 'pt',
  }) async {
    final prompt = _promptFactory.buildEdgePrompt(
      stage: LectioStage.meditatioExegese,
      userInput: passage,
      maturityLevel: maturityLevel,
      language: language,
    );

    return _executeInference(prompt: prompt, stageName: 'ExegeseCentral');
  }

  @override
  Future<String> generateSummary(String text) async {
    final prompt = _promptFactory.buildEdgePrompt(
      stage: LectioStage.summary,
      userInput: text,
    );

    return _executeInference(prompt: prompt, stageName: 'Summary');
  }

  bool _isAborted = false;

  @override
  Stream<String> generateStream(String prompt) async* {
    _isAborted = false;
    await _ensureInitialized();

    final result = await _executeInference(
      prompt: prompt,
      stageName: 'StreamInference',
    );

    if (_isAborted) return;

    final words = result.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (_isAborted) break;
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
  }

  @override
  void abort() {
    _isAborted = true;
    try {
      _channel.invokeMethod('abort');
      log('[GemmaLocal] 🛑 Inferência local abortada.');
    } catch (e) {
      log('[GemmaLocal] Erro ao abortar inferência local: $e');
    }
  }

  @override
  void dispose() {
    abort();
    _channel.invokeMethod('dispose');
    _modelLoaded = false;
    _activeBackend = 'CPU';
  }

  Future<void> _ensureInitialized() async {
    if (!_modelLoaded) {
      await initialize();
    }
  }
}
