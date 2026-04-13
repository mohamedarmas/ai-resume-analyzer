window.resumeAnalyzer = window.resumeAnalyzer || {};

const MAMMOTH_URL =
  'https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.8.0/mammoth.browser.min.js';

let mammothLoadPromise;

function loadExternalScript(url) {
  return new Promise((resolve, reject) => {
    const existingScript = document.querySelector(`script[data-src="${url}"]`);
    if (existingScript) {
      if (existingScript.dataset.loaded === 'true') {
        resolve();
        return;
      }

      existingScript.addEventListener('load', () => resolve(), { once: true });
      existingScript.addEventListener(
        'error',
        () => reject(new Error(`Failed to load script: ${url}`)),
        { once: true },
      );
      return;
    }

    const script = document.createElement('script');
    script.src = url;
    script.async = true;
    script.dataset.src = url;
    script.addEventListener(
      'load',
      () => {
        script.dataset.loaded = 'true';
        resolve();
      },
      { once: true },
    );
    script.addEventListener(
      'error',
      () => reject(new Error(`Failed to load script: ${url}`)),
      { once: true },
    );
    document.head.appendChild(script);
  });
}

async function ensureMammoth() {
  if (window.mammoth) {
    return window.mammoth;
  }

  if (!mammothLoadPromise) {
    mammothLoadPromise = loadExternalScript(MAMMOTH_URL).then(() => {
      if (!window.mammoth) {
        throw new Error('Mammoth did not register on window.');
      }

      return window.mammoth;
    });
  }

  return mammothLoadPromise;
}

function normalizeBytes(input) {
  if (input instanceof Uint8Array) {
    return input;
  }

  if (input instanceof ArrayBuffer) {
    return new Uint8Array(input);
  }

  if (ArrayBuffer.isView(input)) {
    return new Uint8Array(input.buffer, input.byteOffset, input.byteLength);
  }

  throw new Error('Unsupported binary payload passed to DOCX parser.');
}

function toExactArrayBuffer(input) {
  const view = normalizeBytes(input);
  return view.buffer.slice(view.byteOffset, view.byteOffset + view.byteLength);
}

function sanitizeText(value) {
  return value
    .replace(/\u0000/g, '')
    .replace(/[ \t]+\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

window.resumeAnalyzer.parseDocx = async function parseDocx(input) {
  const mammoth = await ensureMammoth();
  const result = await mammoth.extractRawText({
    arrayBuffer: toExactArrayBuffer(input),
  });
  const rawText = sanitizeText(result.value || '');
  const messages = Array.isArray(result.messages)
    ? result.messages.map((message) => message.message || String(message))
    : [];

  return {
    rawText,
    parser: 'mammoth',
    pageCount: 1,
    charCount: rawText.length,
    messages,
  };
};
