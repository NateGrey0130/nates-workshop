// The Button. One press: the words slam onto the screen and voice.wav plays
// pitched down, through a reverb and a feedback echo built with Web Audio.
// voice.wav is a plain Windows "David" recording; every effect is applied
// here at playback, so changing the sound never means re-recording it.
(function () {
  const TEXT = 'Face is a dumb bitch';
  const PITCH = 0.72;        // playbackRate: below 1 is deeper (and slower)
  const ECHO_DELAY = 0.38;   // seconds between repeats
  const ECHO_FEEDBACK = 0.5; // how much of each repeat feeds the next

  const button = document.getElementById('big-red');
  const message = document.getElementById('message');

  let ctx = null;
  let bufferPromise = null;
  let input = null;          // where each press's source connects
  let current = null;        // the source playing now, stopped on a re-press

  // Built on the first press, because browsers only allow audio after a gesture.
  function setup() {
    ctx = new (window.AudioContext || window.webkitAudioContext)();

    bufferPromise = fetch('voice.wav')
      .then(r => r.arrayBuffer())
      .then(data => new Promise((resolve, reject) => ctx.decodeAudioData(data, resolve, reject)));

    input = ctx.createGain();

    const dry = ctx.createGain();
    dry.gain.value = 0.9;
    input.connect(dry).connect(ctx.destination);

    // Reverb: a synthetic impulse of decaying noise, a big stone room.
    const reverb = ctx.createConvolver();
    reverb.buffer = impulse(3.5, 2.5);
    const wet = ctx.createGain();
    wet.gain.value = 0.7;
    input.connect(reverb).connect(wet).connect(ctx.destination);

    // Echo: a delay that feeds back into itself through a low-pass, so each
    // repeat comes back quieter and darker.
    const delay = ctx.createDelay(2);
    delay.delayTime.value = ECHO_DELAY;
    const feedback = ctx.createGain();
    feedback.gain.value = ECHO_FEEDBACK;
    const tone = ctx.createBiquadFilter();
    tone.type = 'lowpass';
    tone.frequency.value = 1800;
    const echoOut = ctx.createGain();
    echoOut.gain.value = 0.55;
    input.connect(delay);
    delay.connect(tone).connect(feedback).connect(delay);
    tone.connect(echoOut).connect(reverb);
    echoOut.connect(ctx.destination);
  }

  function impulse(seconds, decay) {
    const rate = ctx.sampleRate;
    const length = Math.floor(rate * seconds);
    const buf = ctx.createBuffer(2, length, rate);
    for (let ch = 0; ch < 2; ch++) {
      const d = buf.getChannelData(ch);
      for (let i = 0; i < length; i++) {
        d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, decay);
      }
    }
    return buf;
  }

  function play() {
    if (!ctx) setup();
    if (ctx.state === 'suspended') ctx.resume();
    bufferPromise.then(buffer => {
      if (current) { try { current.stop(); } catch (e) { /* already ended */ } }
      const src = ctx.createBufferSource();
      src.buffer = buffer;
      src.playbackRate.value = PITCH;
      src.connect(input);
      src.start();
      current = src;
    }).catch(err => console.error('The Button: voice failed to load', err));
  }

  function show() {
    message.textContent = TEXT;
    message.classList.remove('show');
    void message.offsetWidth; // restart the animation on every press
    message.classList.add('show');
  }

  button.addEventListener('click', () => {
    show();
    play();
    button.classList.add('pressed');
    setTimeout(() => button.classList.remove('pressed'), 120);
  });
})();
