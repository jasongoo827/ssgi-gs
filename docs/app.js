// Two jobs: build the object pickers, and only ever play the clip you are looking at.
// Phones cap how many <video> elements decode at once, and the page ships 18 clips.

const OBJECTS = [
  ['moonrock',  'Moon rock'],
  ['hotdog',    'Hotdog'],
  ['lego',      'Lego'],
  ['ficus',     'Ficus'],
  ['armadillo', 'Armadillo'],
  ['bust',      'Bust'],
];

// lego's rotation clip has 2 columns (5 skies | GT) where every other object has 3,
// so the caption under it would be wrong. Say so rather than silently showing it.
const CAPTIONS = {
  rotation: {
    default: 'Trained under 1 sky &nbsp;|&nbsp; trained under 5 skies &nbsp;|&nbsp; ground truth.',
    lego: 'Trained under 5 skies &nbsp;|&nbsp; ground truth. The 1-sky run was not rendered for this scene.',
  },
};

function currentObject(video) {
  const m = (video.getAttribute('src') || '').match(/\/([a-z]+)_[a-z]+\.mp4$/);
  return m ? m[1] : null;
}

function swap(video, obj, kind) {
  const wasPlaying = !video.paused;
  video.poster = `assets/poster/${obj}_${kind}.jpg`;
  video.src = `assets/video/${obj}_${kind}.mp4`;
  video.load();
  if (wasPlaying) video.play().catch(() => {});

  const caps = CAPTIONS[kind];
  if (caps) {
    const fig = video.closest('figure').querySelector('figcaption');
    if (fig) fig.innerHTML = caps[obj] || caps.default;
  }
}

for (const picker of document.querySelectorAll('.picker')) {
  const kind = picker.dataset.group;
  const video = document.querySelector(`video[data-slot="${kind}"]`);
  if (!video) continue;
  const active = currentObject(video);

  for (const [id, label] of OBJECTS) {
    const b = document.createElement('button');
    b.textContent = label;
    b.setAttribute('aria-pressed', String(id === active));
    b.addEventListener('click', () => {
      for (const sib of picker.children) sib.setAttribute('aria-pressed', 'false');
      b.setAttribute('aria-pressed', 'true');
      swap(video, id, kind);
    });
    picker.appendChild(b);
  }
}

// preload="none" keeps the clips off the wire until they scroll into view; the poster
// frame stands in until then. Honour reduced-motion by leaving everything paused.
const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (!reduced && 'IntersectionObserver' in window) {
  const io = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) e.target.play().catch(() => {});
      else e.target.pause();
    }
  }, { threshold: 0.25 });

  for (const v of document.querySelectorAll('video[data-auto]')) io.observe(v);
}
