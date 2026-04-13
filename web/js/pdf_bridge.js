window.resumeAnalyzer = window.resumeAnalyzer || {};

const PDF_JS_URL =
  'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js';
const PDF_WORKER_URL =
  'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';

let pdfJsLoadPromise;

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

async function ensurePdfJs() {
  if (window.pdfjsLib) {
    window.pdfjsLib.GlobalWorkerOptions.workerSrc = PDF_WORKER_URL;
    return window.pdfjsLib;
  }

  if (!pdfJsLoadPromise) {
    pdfJsLoadPromise = loadExternalScript(PDF_JS_URL).then(() => {
      if (!window.pdfjsLib) {
        throw new Error('PDF.js did not register on window.');
      }

      window.pdfjsLib.GlobalWorkerOptions.workerSrc = PDF_WORKER_URL;
      return window.pdfjsLib;
    });
  }

  return pdfJsLoadPromise;
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

  throw new Error('Unsupported binary payload passed to PDF parser.');
}

function sanitizeText(value) {
  return value
    .replace(/\u0000/g, '')
    .replace(/[ \t]+\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

window.resumeAnalyzer.parsePdf = async function parsePdf(input) {
  const pdfjsLib = await ensurePdfJs();
  const bytes = normalizeBytes(input);
  const loadingTask = pdfjsLib.getDocument({ data: bytes });
  const pdf = await loadingTask.promise;
  const pages = [];
  const pageCount = pdf.numPages || 0;

  try {
    for (let pageNumber = 1; pageNumber <= pageCount; pageNumber += 1) {
      const page = await pdf.getPage(pageNumber);
      const textContent = await page.getTextContent();
      const pageText = textContent.items
        .map((item) => item.str || '')
        .join(' ')
        .replace(/\s+/g, ' ')
        .trim();

      if (pageText) {
        pages.push(pageText);
      }
    }
  } finally {
    if (typeof pdf.cleanup === 'function') {
      pdf.cleanup();
    }

    if (typeof loadingTask.destroy === 'function') {
      loadingTask.destroy();
    }
  }

  const rawText = sanitizeText(pages.join('\n\n'));

  return {
    rawText,
    parser: 'pdfjs',
    pageCount,
    charCount: rawText.length,
    messages: [],
  };
};
