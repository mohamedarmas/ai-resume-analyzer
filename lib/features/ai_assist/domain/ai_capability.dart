class AiCapability {
  const AiCapability({
    required this.supported,
    required this.webGpuAvailable,
    required this.workerReady,
    required this.provider,
  });

  final bool supported;
  final bool webGpuAvailable;
  final bool workerReady;
  final String provider;

  bool get canAttemptLocalAi => supported && workerReady;

  String get statusLabel {
    if (!supported) {
      return 'Browser AI unsupported';
    }
    if (!workerReady) {
      return 'Worker scaffold available, model runtime not ready';
    }
    if (!webGpuAvailable) {
      return 'Worker ready, but WebGPU is not available';
    }
    return 'Local AI runtime available';
  }
}
