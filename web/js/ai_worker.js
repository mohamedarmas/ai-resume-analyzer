self.onmessage = function onmessage(event) {
  self.postMessage({
    type: 'not_ready',
    input: event.data,
    message:
      'AI worker scaffold exists, but a local model runtime has not been attached yet.',
  });
};
