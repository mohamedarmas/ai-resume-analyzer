window.resumeAnalyzer = window.resumeAnalyzer || {};

let aiWorker;

function ensureAiWorker() {
  if (typeof Worker === 'undefined') {
    return null;
  }

  if (!aiWorker) {
    aiWorker = new Worker('js/ai_worker.js');
  }

  return aiWorker;
}

window.resumeAnalyzer.getAiCapability = async function getAiCapability() {
  const worker = ensureAiWorker();
  return {
    supported: typeof Worker !== 'undefined',
    webGpuAvailable: typeof navigator !== 'undefined' && 'gpu' in navigator,
    workerReady: worker !== null,
    provider: 'web-llm-placeholder',
  };
};
