/* Kairo — layered vector character rig.
   <kairo-char view="front|quarter|side|back" expression="happy" pose="standing"
               anim="idle|walk|run|wave|celebrate|think|sleep|stretch|drink|jump|dance|look|talk|none"
               size="220" flip follow phase="0.25" hoodie="#3E7C4F">
   Every body part is a named <g data-part> — Live2D/Spine/Rive-ready. */
(function () {
  const C = {
    forest: '#3E7C4F', forestD: '#2F5E3C', mint: '#A9D9BB', cream: '#F8F5EF',
    gray: '#C8CCC8', coal: '#2C302E', skin: '#F9DFC4', skinD: '#EAC19E',
    hair: '#28201B', hairHi: '#4A3A2E', iris: '#26332B', irisHi: '#4C6B54',
    mouth: '#8A4B3C', tongue: '#E58A74', cheek: '#F2AE93', line: '#5A4638', jean: '#23262A'
  };

  /* ---------- face pieces ---------- */
  function eye(cx, cy, type) {
    const lash = (ry) => `<path d="M${cx - 10} ${cy - ry + 1.5} Q${cx} ${cy - ry - 4} ${cx + 10} ${cy - ry + 1.5}" stroke="${C.hair}" stroke-width="3" fill="none" stroke-linecap="round"/>`;
    const open = (rx, ry, px, py) => `<g class="eyeball">
      <ellipse cx="${cx}" cy="${cy}" rx="${rx + 1.8}" ry="${ry + 1.2}" fill="#fff"/>
      <ellipse cx="${cx + px * 0.6}" cy="${cy}" rx="${rx}" ry="${ry}" fill="url(#irisG)"/>
      <ellipse cx="${cx + px * 0.8}" cy="${cy + py * 0.5 + 0.5}" rx="${rx * 0.42}" ry="${ry * 0.42}" fill="#161D18"/>
      <circle cx="${cx + px - 2.8}" cy="${cy + py - 3.8}" r="2.8" fill="#fff"/>
      <circle cx="${cx + px + 2.6}" cy="${cy + py + 3.2}" r="1.3" fill="#fff" opacity=".9"/>
      <path d="M${cx - rx + 1} ${cy + ry + 2} Q${cx} ${cy + ry + 4} ${cx + rx - 1} ${cy + ry + 2}" stroke="${C.skinD}" stroke-width="1.6" fill="none" stroke-linecap="round" opacity=".7"/>
      ${lash(ry + 1.2)}</g>`;
    switch (type) {
      case 'open': return open(7, 9, 0, 0);
      case 'wide': return open(8.2, 10.2, 0, 0);
      case 'side': return open(7, 9, 3, -1.5);
      case 'half': return open(7, 9, 0, 1) +
        `<path d="M${cx - 10} ${cy - 3} Q${cx} ${cy - 6.5} ${cx + 10} ${cy - 3} L${cx + 10} ${cy - 14} L${cx - 10} ${cy - 14} Z" fill="${C.skin}"/>` +
        `<path d="M${cx - 10} ${cy - 3} Q${cx} ${cy - 6.5} ${cx + 10} ${cy - 3}" stroke="${C.hair}" stroke-width="2.6" fill="none" stroke-linecap="round"/>`;
      case 'droop': return open(6.2, 7.6, 0, 1.5);
      case 'star': return `<g class="eyeball">
        <ellipse cx="${cx}" cy="${cy}" rx="9.2" ry="10.6" fill="#fff"/>
        <ellipse cx="${cx}" cy="${cy}" rx="7.4" ry="9.2" fill="url(#irisG)"/>
        <path d="M${cx} ${cy - 5.5} L${cx + 1.5} ${cy - 1.5} L${cx + 5.5} ${cy} L${cx + 1.5} ${cy + 1.5} L${cx} ${cy + 5.5} L${cx - 1.5} ${cy + 1.5} L${cx - 5.5} ${cy} L${cx - 1.5} ${cy - 1.5} Z" fill="#fff"/>
        ${lash(10.4)}</g>`;
      case 'closedUp': return `<path d="M${cx - 8.5} ${cy + 2} Q${cx} ${cy - 7} ${cx + 8.5} ${cy + 2}" stroke="${C.hair}" stroke-width="2.8" fill="none" stroke-linecap="round"/>`;
      case 'closedDown': return `<path d="M${cx - 8} ${cy - 1} Q${cx} ${cy + 5} ${cx + 8} ${cy - 1}" stroke="${C.hair}" stroke-width="2.6" fill="none" stroke-linecap="round"/>`;
      default: return open(8, 10, 0, 0);
    }
  }
  function eyes(type) {
    const l = type === 'wink' ? 'open' : type, r = type === 'wink' ? 'closedUp' : type;
    return `<g class="eyes" data-part="eyes">${eye(80, 88, l)}${eye(120, 88, r)}</g>`;
  }
  function brows(type) {
    const s = `stroke="${C.hair}" stroke-width="3" fill="none" stroke-linecap="round"`;
    const m = {
      flat: [`M70 72 Q78 69.5 86 72`, `M114 72 Q122 69.5 130 72`],
      up: [`M70 69 Q78 64 86 68`, `M114 68 Q122 64 130 69`],
      sad: [`M70 74 Q79 69 86 68`, `M114 68 Q121 69 130 74`],
      down: [`M70 68 Q78 71 86 74`, `M114 74 Q122 71 130 68`],
      asym: [`M70 66 Q78 62 86 66`, `M114 72 Q122 69.5 130 72`]
    }[type] || [];
    return `<g class="brows" data-part="brows"><path d="${m[0]}" ${s}/><path d="${m[1]}" ${s}/></g>`;
  }
  function mouth(type) {
    const s = `stroke="${C.line}" stroke-width="2.6" fill="none" stroke-linecap="round"`;
    let d;
    switch (type) {
      case 'smile': d = `<path d="M91 106 Q100 114 109 106" ${s}/>`; break;
      case 'smallsmile': d = `<path d="M95 107 Q100 111.5 105 107" ${s}/>`; break;
      case 'bigsmile': d = `<path d="M90 105 Q100 119 110 105 Q100 111 90 105 Z" fill="${C.mouth}"/><path d="M90 105 Q100 111 110 105" ${s}/>`; break;
      case 'laugh': d = `<path d="M90 104 Q100 124 110 104 Q100 109 90 104 Z" fill="${C.mouth}"/><path d="M94 114 Q100 120 106 114 Q100 116 94 114 Z" fill="${C.tongue}"/>`; break;
      case 'o': d = `<circle cx="100" cy="108" r="3.4" fill="${C.mouth}"/>`; break;
      case 'oo': d = `<ellipse cx="100" cy="109" rx="4.4" ry="6" fill="${C.mouth}"/>`; break;
      case 'flat': d = `<path d="M94 108.5 L106 108.5" ${s}/>`; break;
      case 'frown': d = `<path d="M92 111 Q100 104.5 108 111" ${s}/>`; break;
      case 'wavy': d = `<path d="M92 109 Q96 106.5 100 109 Q104 111.5 108 109" ${s}/>`; break;
      case 'det': d = `<path d="M93 109 L107 109" stroke="${C.line}" stroke-width="3.2" fill="none" stroke-linecap="round"/>`; break;
      case 'small': d = `<path d="M97 108 Q100 110 103 108" ${s}/>`; break;
      default: d = `<path d="M91 106 Q100 114 109 106" ${s}/>`;
    }
    return `<g class="mouth" data-part="mouth">${d}</g>`;
  }
  function extras(kind) {
    const green = C.forest;
    switch (kind) {
      case 'q': return `<text x="146" y="52" font-size="26" font-weight="800" fill="${green}" class="float">?</text>`;
      case 'ex': return `<text x="146" y="50" font-size="26" font-weight="800" fill="${green}" class="float">!</text>`;
      case 'dots': return `<g class="dots" fill="${green}"><circle cx="140" cy="48" r="2.6"/><circle cx="149" cy="44" r="3.2"/><circle cx="159" cy="40" r="3.8"/></g>`;
      case 'tear': return `<path d="M66 98 Q62 106 66 109 Q70 106 66 98 Z" fill="#9CC7E8" class="float"/>`;
      case 'sweat': return `<path d="M142 58 Q137 68 142 72 Q147 68 142 58 Z" fill="#9CC7E8" class="float"/>`;
      case 'zzz': return `<g class="zzz" fill="${C.coal}" font-weight="800"><text x="140" y="52" font-size="18">z</text><text x="152" y="40" font-size="14">z</text><text x="161" y="31" font-size="11">z</text></g>`;
      case 'spark': return `<g class="spark" fill="${C.mint}"><path d="M52 52 l2 5 5 2 -5 2 -2 5 -2 -5 -5 -2 5 -2 Z"/><path d="M148 40 l1.6 4 4 1.6 -4 1.6 -1.6 4 -1.6 -4 -4 -1.6 4 -1.6 Z"/></g>`;
      default: return '';
    }
  }

  const EXPR = {
    happy: { eye: 'open', brow: 'up', mouth: 'smile' },
    thinking: { eye: 'side', brow: 'asym', mouth: 'flat', extra: 'dots' },
    curious: { eye: 'wide', brow: 'up', mouth: 'o', extra: 'q' },
    excited: { eye: 'star', brow: 'up', mouth: 'bigsmile' },
    proud: { eye: 'closedUp', brow: 'up', mouth: 'bigsmile' },
    sad: { eye: 'droop', brow: 'sad', mouth: 'frown', extra: 'tear' },
    concerned: { eye: 'open', brow: 'sad', mouth: 'wavy', extra: 'sweat' },
    waiting: { eye: 'half', brow: 'flat', mouth: 'flat' },
    sleeping: { eye: 'closedDown', brow: 'flat', mouth: 'small', extra: 'zzz' },
    laughing: { eye: 'closedUp', brow: 'up', mouth: 'laugh' },
    celebrating: { eye: 'star', brow: 'up', mouth: 'laugh', extra: 'spark' },
    shy: { eye: 'side', brow: 'sad', mouth: 'smallsmile', blush: 1.7 },
    encouraging: { eye: 'wink', brow: 'up', mouth: 'smile', extra: 'spark' },
    surprised: { eye: 'wide', brow: 'up', mouth: 'oo', extra: 'ex' },
    focused: { eye: 'half', brow: 'down', mouth: 'det' },
    neutral: { eye: 'open', brow: 'flat', mouth: 'smallsmile' }
  };

  /* pose = joint rotations in deg. Negative = counter-clockwise.
     armL origin (74,132), armR (126,132), legL (90,172), legR (110,172), head (100,124). */
  const POSES = {
    standing: {},
    waving: { armR: -122, head: -4 },
    walking: { armL: 18, armR: -18, legL: -16, legR: 16 },
    running: { armL: 38, armR: -38, legL: -32, legR: 32, rootRot: 7 },
    sitting: { legL: -78, legR: -78, rootY: 24, armL: -6, armR: 6 },
    stretching: { armL: 140, armR: -140, head: -6 },
    pointing: { armR: -95, head: -3 },
    'holding water': { armR: 140, prop: 'bottle' },
    'holding coffee': { armR: 95, prop: 'cup' },
    reading: { legL: -78, legR: -78, rootY: 24, armL: -35, armR: 35, prop: 'book', head: 7 },
    typing: { legL: -78, legR: -78, rootY: 24, armL: -40, armR: 40, prop: 'laptop', head: 6 },
    sleeping: { head: 10, armL: -3, armR: 3 },
    jumping: { rootY: -16, armL: 125, armR: -125, legL: -10, legR: 10 },
    celebrating: { armL: 125, armR: -125, head: -4 },
    'thumbs up': { armR: -110, prop: 'thumb', head: -3 },
    'hands behind back': { armL: 14, armR: -14, head: -3 },
    'looking up': { head: -9, eyeY: -2.5 },
    'looking down': { head: 8, eyeY: 2.5 },
    thinking: { armR: 138, head: 5 }
  };

  const ANIMS = ['idle', 'walk', 'run', 'wave', 'celebrate', 'think', 'sleep', 'stretch', 'drink', 'jump', 'dance', 'look', 'talk'];

  function props(kind) {
    // drawn inside armR group near default hand pos (133,170); rotates with arm
    switch (kind) {
      case 'bottle': return `<g data-part="prop"><rect x="128" y="146" width="10" height="24" rx="4" fill="${C.mint}" stroke="${C.forestD}" stroke-width="1.4"/><rect x="129.5" y="142" width="7" height="6" rx="2" fill="${C.forestD}"/></g>`;
      case 'cup': return `<g data-part="prop"><path d="M126 152 L140 152 L138 170 L128 170 Z" fill="${C.cream}" stroke="${C.gray}" stroke-width="1.4"/><rect x="125" y="152" width="16" height="4" rx="2" fill="var(--hood)"/></g>`;
      case 'thumb': return `<g data-part="prop"><rect x="130" y="158" width="6" height="10" rx="3" fill="${C.skin}"/></g>`;
      case 'book': return `<g data-part="prop"><path d="M84 150 L100 156 L116 150 L116 172 L100 178 L84 172 Z" fill="${C.cream}" stroke="${C.gray}" stroke-width="1.5"/><path d="M100 156 L100 178" stroke="${C.gray}" stroke-width="1.5"/></g>`;
      case 'laptop': return `<g data-part="prop"><path d="M82 148 L118 148 L118 168 L82 168 Z" fill="${C.coal}"/><path d="M84 150 L116 150 L116 165 L84 165 Z" fill="#3D4A44"/><path d="M78 168 L122 168 L124 174 L76 174 Z" fill="${C.gray}"/></g>`;
      default: return '';
    }
  }

  function shoe(cx, dir) { // dir 1 = toe right, -1 = toe left
    const t = dir;
    return `<g data-part="shoe">
      <path d="M${cx - 9} 197 Q${cx - 10} 208 ${cx - 7} 209 L${cx + 8 + 7 * t} 209 Q${cx + 11 + 7 * t} 208 ${cx + 9 + 6 * t} 204 Q${cx + 5 * t} 199 ${cx + 2} 196 Z" fill="var(--hood)"/>
      <path d="M${cx - 5} 200 L${cx + 4} 203 M${cx - 5} 204 L${cx + 3} 206" stroke="${C.cream}" stroke-width="1.5" stroke-linecap="round"/>
      <path d="M${cx - 10} 208 L${cx + 10 + 7 * t} 208 Q${cx + 13 + 7 * t} 208 ${cx + 13 + 7 * t} 212 Q${cx + 13 + 7 * t} 216 ${cx + 9 + 7 * t} 216 L${cx - 9} 216 Q${cx - 13} 216 ${cx - 13} 212 Q${cx - 13} 208 ${cx - 10} 208 Z" fill="${C.cream}" stroke="${C.gray}" stroke-width="1"/>
      <circle cx="${cx + 7 * t}" cy="204" r="1.1" fill="${C.cream}" opacity=".9"/></g>`;
  }

  function frontSVG(a) {
    const e = EXPR[a.expression] || EXPR.neutral;
    const p = Object.assign({}, POSES[a.pose] || {});
    const rot = (el, ang) => ang ? `style="transform:rotate(${ang}deg)"` : '';
    const blushOp = 0.5 * (e.blush || 1);
    const q = a.view === 'quarter';
    const fx = q ? -7 : 0; // face shift for 3/4
    const eyeOff = p.eyeY ? `transform="translate(0 ${p.eyeY})"` : '';
    const armL = `<g class="arm-l j" data-part="arm-left" ${rot('', p.armL)}>
    <path d="M75 130 C68 142 66 155 67 165" stroke="var(--hood)" stroke-width="13" stroke-linecap="round" fill="none"/>
    <path d="M63.5 158 L71.5 160" stroke="var(--hoodD)" stroke-width="4.5" stroke-linecap="round"/>
    <circle cx="67" cy="169" r="6" fill="${C.skin}" data-part="hand-left"/></g>`;
    const armR = `<g class="arm-r j" data-part="arm-right" ${rot('', p.armR)}>
    <path d="M125 130 C132 142 134 155 133 165" stroke="var(--hood)" stroke-width="13" stroke-linecap="round" fill="none"/>
    <path d="M128.5 160 L136.5 158" stroke="var(--hoodD)" stroke-width="4.5" stroke-linecap="round"/>
    <circle cx="133" cy="169" r="6" fill="${C.skin}" data-part="hand-right"/>
    ${p.prop && p.prop !== 'book' && p.prop !== 'laptop' ? props(p.prop) : ''}</g>`;
    const lRaised = Math.abs(p.armL || 0) > 60 || ['celebrate', 'stretch', 'dance', 'jump'].includes(a.anim);
    const rRaised = Math.abs(p.armR || 0) > 60 || ['wave', 'celebrate', 'stretch', 'drink', 'dance', 'jump', 'think'].includes(a.anim);
    return `
<g class="slide"><g class="root" data-part="root" ${p.rootRot ? `style="transform:rotate(${p.rootRot}deg)"` : ''}>
 <g ${p.rootY ? `transform="translate(0 ${p.rootY})"` : ''}>
 <g class="breathe">
  <g class="leg-l j" data-part="leg-left" ${rot('', p.legL)}>
    <path d="M83 168 L97 168 L95 200 L86 200 Z" fill="${C.jean}"/>
    <path d="M86 185 Q90 187 94 185" stroke="#000" stroke-width="1.3" opacity=".3" fill="none"/>${shoe(90, -1)}</g>
  <g class="leg-r j" data-part="leg-right" ${rot('', p.legR)}>
    <path d="M103 168 L117 168 L114 200 L105 200 Z" fill="${C.jean}"/>
    <path d="M106 185 Q110 187 114 185" stroke="#000" stroke-width="1.3" opacity=".3" fill="none"/>${shoe(110, 1)}</g>
  <g class="torso" data-part="torso">
    <path d="M94 110 L106 110 L106 124 L94 124 Z" fill="${C.skinD}" data-part="neck"/>
    <path d="M72 126 C69 118 84 112 100 112 C116 112 131 118 128 126 C126 131 74 131 72 126 Z" fill="var(--hoodD)" data-part="hood"/>
    <path d="M75 121 C70 148 71 166 76 176 L124 176 C129 166 130 148 125 121 C112 114 88 114 75 121 Z" fill="var(--hood)"/>
    <path d="M92 118 L88 176 L112 176 L108 118 Q100 115 92 118 Z" fill="${C.cream}" data-part="tee"/>
    <path d="M92 118 Q100 124 108 118 L108 123 Q100 128 92 123 Z" fill="#E6E0D4"/>
    <path d="M92 118 L87 176 M108 118 L113 176" stroke="var(--hoodD)" stroke-width="3" fill="none"/>
    <path d="M92 117 L98 125 L91 129 Q87 122 92 117 Z M108 117 L102 125 L109 129 Q113 122 108 117 Z" fill="var(--hoodD)" data-part="collar"/>
    <path d="M95 122 L95 132 M105 122 L105 132" stroke="${C.mint}" stroke-width="2.4" stroke-linecap="round"/>
    <path d="M79 140 Q82 145 80 152 M121 140 Q118 145 120 152 M83 168 Q88 170 92 169" stroke="var(--hoodD)" stroke-width="1.5" opacity=".5" fill="none"/>
    <path d="M77 171 L123 171" stroke="var(--hoodD)" stroke-width="2.2" opacity=".55"/>
    <path d="M80 158 L88 158 L86 173 L79 173 Z M120 158 L112 158 L114 173 L121 173 Z" fill="var(--hoodD)" opacity=".35" data-part="pocket"/>
  </g>
  ${lRaised ? '' : armL}${rRaised ? '' : armR}
  ${p.prop === 'book' || p.prop === 'laptop' ? props(p.prop) : ''}
  <g class="head j" data-part="head" ${rot('', p.head)}>
    <g ${q ? 'transform="translate(-3 0) scale(.98 1)" transform-origin="100 80"' : ''}>
    <path d="M100 28 C60 28 43 55 45 87 C46 104 54 116 65 121 L135 121 C146 116 154 104 155 87 C157 55 140 28 100 28 Z" fill="${C.hair}" data-part="hair-back"/>
    <circle cx="${54 + fx * 0.4}" cy="94" r="6.5" fill="${C.skin}" data-part="ear-left"/>
    <circle cx="${146 + fx * 0.4}" cy="94" r="6.5" fill="${C.skin}" data-part="ear-right"/>
    <ellipse cx="${100 + fx * 0.3}" cy="88" rx="46" ry="42" fill="${C.skin}" data-part="face-base"/>
    <path d="M55 84 C50 46 72 28 100 28 C128 28 150 46 145 84 Q141 71 136 82 Q132 62 126 77 Q120 58 113 73 Q107 56 100 71 Q93 56 87 73 Q80 58 74 77 Q68 62 64 82 Q59 71 55 84 Z" fill="${C.hair}" data-part="hair-front"/>
    <path d="M62 78 Q76 66 100 66 Q124 66 138 78" stroke="${C.skinD}" stroke-width="4" opacity=".28" fill="none"/>
    <path d="M55 82 Q48 96 52 111 Q58 113 61 106 Q56 94 58 84 Z M145 82 Q152 96 148 111 Q142 113 139 106 Q144 94 142 84 Z" fill="${C.hair}" data-part="hair-sides"/>
    <path d="M97 30 C94 20 104 15 109 21 C104 20 99 25 101 30 Z" fill="${C.hair}" data-part="hair-tuft"/>
    <path d="M70 46 Q83 35 100 34 M114 36 Q127 40 135 50" stroke="${C.hairHi}" stroke-width="3.2" fill="none" stroke-linecap="round" opacity=".75"/>
    <g class="face" data-part="face" ${q ? `transform="translate(${fx} 0)"` : ''}>
      ${brows(e.brow)}
      <g ${eyeOff}>${eyes(e.eye)}</g>
      <path d="M98 99 Q100 102 102 99" stroke="${C.skinD}" stroke-width="2" fill="none" stroke-linecap="round" data-part="nose"/>
      ${mouth(e.mouth)}
      <ellipse cx="66" cy="102" rx="6.5" ry="3.6" fill="${C.cheek}" opacity="${blushOp}" data-part="blush"/>
      <ellipse cx="134" cy="102" rx="6.5" ry="3.6" fill="${C.cheek}" opacity="${blushOp}" data-part="blush"/>
    </g>
    <g class="extras" data-part="extras">${e.extra ? extras(e.extra) : ''}</g>
    </g>
  </g>
  ${lRaised ? armL : ''}${rRaised ? armR : ''}
 </g></g>
 <g class="confetti" data-part="confetti">
   ${[0, 1, 2, 3, 4, 5, 6, 7].map(i => {
      const x = 30 + i * 20, col = [C.forest, C.mint, C.cheek, C.gray][i % 4];
      return i % 2 ? `<rect x="${x}" y="6" width="5" height="8" rx="1" fill="${col}" style="animation-delay:${i * 0.17}s"/>`
        : `<circle cx="${x}" cy="8" r="3.2" fill="${col}" style="animation-delay:${i * 0.13}s"/>`;
    }).join('')}
 </g>
</g>`;
  }

  function sideSVG(a) {
    const e = EXPR[a.expression] || EXPR.neutral;
    return `
<g class="slide"><g class="root" data-part="root"><g class="breathe">
  <g class="leg-far j" data-part="leg-far"><path d="M93 168 L107 168 L105 200 L96 200 Z" fill="#363B3E"/>
    <path d="M92 200 L92 212 L118 212 L118 206 Q106 202 108 200 Z" fill="var(--hoodD)"/><rect x="91" y="211" width="28" height="6" rx="3" fill="${C.gray}"/></g>
  <g class="arm-far j" data-part="arm-far"><path d="M104 132 C100 144 99 156 100 165" stroke="var(--hoodD)" stroke-width="13" stroke-linecap="round" fill="none"/><circle cx="100" cy="169" r="6" fill="${C.skinD}"/></g>
  <g class="torso" data-part="torso">
    <path d="M88 122 C82 148 83 166 88 176 L120 176 C125 166 126 148 122 121 C112 115 96 115 88 122 Z" fill="var(--hood)"/>
    <path d="M86 124 C78 128 76 140 80 150 C84 142 85 132 88 126 Z" fill="var(--hoodD)" data-part="hood"/>
    <path d="M90 158 L114 158 L112 173 L90 173 Z" fill="var(--hoodD)" opacity=".3"/>
  </g>
  <g class="leg-near j" data-part="leg-near"><path d="M99 168 L113 168 L111 200 L102 200 Z" fill="${C.jean}"/>
    <path d="M98 200 L98 212 L124 212 L124 206 Q112 202 114 200 Z" fill="var(--hood)"/><rect x="97" y="211" width="28" height="6" rx="3" fill="${C.cream}" stroke="${C.gray}" stroke-width="1"/></g>
  <g class="arm-near j" data-part="arm-near"><path d="M108 132 C112 144 113 156 112 165" stroke="var(--hood)" stroke-width="13" stroke-linecap="round" fill="none"/><circle cx="112" cy="169" r="6" fill="${C.skin}"/></g>
  <g class="head j" data-part="head">
    <ellipse cx="104" cy="88" rx="45" ry="42" fill="${C.skin}" data-part="face-base"/>
    <path d="M104 28 C64 28 46 55 48 88 C49 106 58 118 70 122 C64 108 62 96 64 84 C70 88 76 86 80 76 C90 82 118 80 130 60 C138 52 146 60 148 74 C150 50 136 28 104 28 Z" fill="${C.hair}" data-part="hair"/>
    <path d="M130 60 C140 56 148 64 148 78 C146 90 142 96 138 98 C140 86 138 72 130 60 Z" fill="${C.hair}"/>
    <circle cx="104" cy="94" r="6.5" fill="${C.skin}" data-part="ear"/>
    <path d="M101 32 C98 22 108 17 113 23 C108 22 103 27 105 32 Z" fill="${C.hair}"/>
    <g class="face" data-part="face">
      <path d="M120 70 Q128 66 136 69" stroke="${C.hair}" stroke-width="3" fill="none" stroke-linecap="round"/>
      ${eye(129, 88, e.eye === 'closedDown' || e.eye === 'closedUp' ? e.eye : 'open').replace(/cx="129"/g, 'cx="129"')}
      <path d="M148 96 Q152 99 149 102" stroke="${C.skinD}" stroke-width="2.2" fill="none" stroke-linecap="round" data-part="nose"/>
      <path d="M136 108 Q141 111 145 107" stroke="${C.line}" stroke-width="2.4" fill="none" stroke-linecap="round" data-part="mouth"/>
      <ellipse cx="122" cy="102" rx="6" ry="3.4" fill="${C.cheek}" opacity=".5"/>
    </g>
  </g>
</g></g></g>`;
  }

  function backSVG(a) {
    return `
<g class="slide"><g class="root" data-part="root"><g class="breathe">
  <g class="leg-l j" data-part="leg-left"><path d="M83 168 L97 168 L95 200 L86 200 Z" fill="${C.jean}"/>
    <rect x="79" y="200" width="22" height="11" rx="4" fill="var(--hood)"/><rect x="78" y="210" width="24" height="6" rx="3" fill="${C.cream}" stroke="${C.gray}" stroke-width="1"/></g>
  <g class="leg-r j" data-part="leg-right"><path d="M103 168 L117 168 L114 200 L105 200 Z" fill="${C.jean}"/>
    <rect x="99" y="200" width="22" height="11" rx="4" fill="var(--hood)"/><rect x="98" y="210" width="24" height="6" rx="3" fill="${C.cream}" stroke="${C.gray}" stroke-width="1"/></g>
  <g class="torso" data-part="torso">
    <path d="M75 121 C70 148 71 166 76 176 L124 176 C129 166 130 148 125 121 C112 114 88 114 75 121 Z" fill="var(--hood)"/>
    <path d="M78 122 C84 112 116 112 122 122 C124 136 118 148 100 148 C82 148 76 136 78 122 Z" fill="var(--hoodD)" data-part="hood"/>
  </g>
  <g class="arm-l j" data-part="arm-left"><path d="M75 130 C68 142 66 155 67 165" stroke="var(--hood)" stroke-width="13" stroke-linecap="round" fill="none"/><circle cx="67" cy="169" r="6" fill="${C.skin}"/></g>
  <g class="arm-r j" data-part="arm-right"><path d="M125 130 C132 142 134 155 133 165" stroke="var(--hood)" stroke-width="13" stroke-linecap="round" fill="none"/><circle cx="133" cy="169" r="6" fill="${C.skin}"/></g>
  <g class="head j" data-part="head">
    <path d="M100 28 C60 28 43 55 45 88 C46 108 58 122 74 126 L126 126 C142 122 154 108 155 88 C157 55 140 28 100 28 Z" fill="${C.hair}" data-part="hair"/>
    <path d="M100 40 C90 44 84 52 84 60 C90 54 98 50 108 50 C116 50 122 54 126 60 C124 50 114 42 100 40 Z" fill="${C.hairHi}" opacity=".45" data-part="hair-whorl"/>
    <circle cx="53" cy="94" r="5" fill="${C.skin}"/><circle cx="147" cy="94" r="5" fill="${C.skin}"/>
  </g>
</g></g></g>`;
  }

  const CSS = `
:host{display:inline-block;--hood:${C.forest};--hoodD:color-mix(in oklab, var(--hood) 72%, black)}
svg{display:block;overflow:visible}
.j{transform-box:view-box}
.arm-l{transform-origin:74px 132px}.arm-r{transform-origin:126px 132px}
.arm-near{transform-origin:108px 132px}.arm-far{transform-origin:104px 132px}
.leg-l{transform-origin:90px 172px}.leg-r{transform-origin:110px 172px}
.leg-near{transform-origin:106px 172px}.leg-far{transform-origin:100px 172px}
.head{transform-origin:100px 124px}
.root{transform-box:view-box;transform-origin:100px 218px}
.breathe{transform-box:view-box;transform-origin:100px 176px}
.eyes,.mouth,.eyeball{transform-box:fill-box;transform-origin:center}
.slide{transform-box:view-box}
.confetti{display:none}
.zzz text,.float,.dots circle{transform-box:fill-box;transform-origin:center}
svg *{animation-delay:var(--ph,0s) !important}
:host([paused]) svg *{animation-play-state:paused !important}

@keyframes breathe{0%,100%{transform:scaleY(1) translateY(0)}50%{transform:scaleY(1.02) translateY(-1.6px)}}
@keyframes blink{0%,93.5%,100%{transform:scaleY(1)}96%{transform:scaleY(.07)}}
@keyframes bob{0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}
@keyframes bobHi{0%,100%{transform:translateY(0) scaleY(1)}25%{transform:translateY(-6px)}50%{transform:translateY(0) scaleY(.97)}75%{transform:translateY(-6px)}}
@keyframes swingA{0%,100%{transform:rotate(22deg)}50%{transform:rotate(-22deg)}}
@keyframes swingB{0%,100%{transform:rotate(-22deg)}50%{transform:rotate(22deg)}}
@keyframes swingA2{0%,100%{transform:rotate(38deg)}50%{transform:rotate(-38deg)}}
@keyframes swingB2{0%,100%{transform:rotate(-38deg)}50%{transform:rotate(38deg)}}
@keyframes waveArm{0%,100%{transform:rotate(-124deg)}50%{transform:rotate(-94deg)}}
@keyframes headTiltL{0%,100%{transform:rotate(-3deg)}50%{transform:rotate(3deg)}}
@keyframes celebL{0%,100%{transform:rotate(128deg)}50%{transform:rotate(104deg)}}
@keyframes celebR{0%,100%{transform:rotate(-104deg)}50%{transform:rotate(-128deg)}}
@keyframes hop{0%,100%{transform:translateY(0) scaleY(1)}12%{transform:translateY(2px) scaleY(.95)}45%{transform:translateY(-16px) scaleY(1.03)}80%{transform:translateY(0) scaleY(1)}}
@keyframes thinkHead{0%,100%{transform:rotate(3deg)}50%{transform:rotate(7deg)}}
@keyframes dotPulse{0%,100%{opacity:.25}50%{opacity:1}}
@keyframes sleepSway{0%,100%{transform:rotate(-1.5deg)}50%{transform:rotate(1.5deg)}}
@keyframes zzzFloat{0%{opacity:0;transform:translate(0,6px)}40%{opacity:1}100%{opacity:0;transform:translate(8px,-14px)}}
@keyframes stretchL{0%,100%{transform:rotate(15deg)}50%{transform:rotate(142deg)}}
@keyframes stretchR{0%,100%{transform:rotate(-15deg)}50%{transform:rotate(-142deg)}}
@keyframes stretchBody{0%,100%{transform:scaleY(1)}50%{transform:scaleY(1.045)}}
@keyframes drinkArm{0%,25%,100%{transform:rotate(60deg)}45%,75%{transform:rotate(128deg)}}
@keyframes jumpBig{0%,100%{transform:translateY(0) scaleY(1)}10%{transform:translateY(3px) scaleY(.93)}40%{transform:translateY(-22px) scaleY(1.05)}70%{transform:translateY(0) scaleY(.96)}85%{transform:translateY(0) scaleY(1)}}
@keyframes danceRock{0%,100%{transform:rotate(-5deg) translateX(-3px)}50%{transform:rotate(5deg) translateX(3px)}}
@keyframes danceL{0%,100%{transform:rotate(126deg)}50%{transform:rotate(15deg)}}
@keyframes danceR{0%,100%{transform:rotate(-15deg)}50%{transform:rotate(-126deg)}}
@keyframes lookHead{0%,100%{transform:rotate(-8deg)}50%{transform:rotate(8deg)}}
@keyframes lookEyes{0%,100%{transform:translateX(-2.5px)}50%{transform:translateX(2.5px)}}
@keyframes talkMouth{0%,100%{transform:scaleY(1)}50%{transform:scaleY(.45)}}
@keyframes talkHead{0%,100%{transform:rotate(0)}50%{transform:rotate(1.6deg)}}
@keyframes confFall{0%{transform:translateY(-10px) rotate(0);opacity:1}100%{transform:translateY(210px) rotate(240deg);opacity:0}}
@keyframes sparkPulse{0%,100%{transform:scale(.7);opacity:.5}50%{transform:scale(1.15);opacity:1}}
@keyframes floatUp{0%,100%{transform:translateY(0)}50%{transform:translateY(-4px)}}

.breathe{animation:breathe calc(3.8s*var(--sp,1)) ease-in-out infinite}
.eyes{animation:blink calc(4.6s*var(--sp,1)) infinite}
.spark path{animation:sparkPulse 1.2s ease-in-out infinite;transform-box:fill-box;transform-origin:center}
.float{animation:floatUp 1.8s ease-in-out infinite}
.dots circle{animation:dotPulse 1.4s infinite}
.dots circle:nth-child(2){animation-delay:.25s}.dots circle:nth-child(3){animation-delay:.5s}
.zzz text{animation:zzzFloat 2.6s ease-in-out infinite}
.zzz text:nth-child(2){animation-delay:.8s}.zzz text:nth-child(3){animation-delay:1.6s}

.a-walk .arm-l,.a-walk .arm-far{animation:swingA calc(.74s*var(--sp,1)) ease-in-out infinite}
.a-walk .arm-r,.a-walk .arm-near{animation:swingB calc(.74s*var(--sp,1)) ease-in-out infinite}
.a-walk .leg-l,.a-walk .leg-far{animation:swingB calc(.74s*var(--sp,1)) ease-in-out infinite}
.a-walk .leg-r,.a-walk .leg-near{animation:swingA calc(.74s*var(--sp,1)) ease-in-out infinite}
.a-walk .root{animation:bob calc(.37s*var(--sp,1)) ease-in-out infinite}
.a-run .arm-l,.a-run .arm-far{animation:swingA2 calc(.42s*var(--sp,1)) ease-in-out infinite}
.a-run .arm-r,.a-run .arm-near{animation:swingB2 calc(.42s*var(--sp,1)) ease-in-out infinite}
.a-run .leg-l,.a-run .leg-far{animation:swingB2 calc(.42s*var(--sp,1)) ease-in-out infinite}
.a-run .leg-r,.a-run .leg-near{animation:swingA2 calc(.42s*var(--sp,1)) ease-in-out infinite}
.a-run .root{animation:bobHi calc(.42s*var(--sp,1)) ease-in-out infinite;rotate:6deg}
.a-wave .arm-r{animation:waveArm calc(.9s*var(--sp,1)) ease-in-out infinite}
.a-wave .head{animation:headTiltL calc(1.8s*var(--sp,1)) ease-in-out infinite}
.a-celebrate .arm-l{animation:celebL calc(.5s*var(--sp,1)) ease-in-out infinite}
.a-celebrate .arm-r{animation:celebR calc(.5s*var(--sp,1)) ease-in-out infinite}
.a-celebrate .root{animation:hop calc(1s*var(--sp,1)) ease-in-out infinite}
.a-celebrate .confetti{display:block}
.a-celebrate .confetti *{animation-name:confFall;animation-duration:1.8s;animation-timing-function:linear;animation-iteration-count:infinite;transform-box:fill-box}
.a-think .head{animation:thinkHead calc(2.4s*var(--sp,1)) ease-in-out infinite}
.a-sleep .root{animation:sleepSway calc(4s*var(--sp,1)) ease-in-out infinite}
.a-sleep .eyes{animation:none}
.a-stretch .arm-l{animation:stretchL calc(3s*var(--sp,1)) ease-in-out infinite}
.a-stretch .arm-r{animation:stretchR calc(3s*var(--sp,1)) ease-in-out infinite}
.a-stretch .breathe{animation:stretchBody calc(3s*var(--sp,1)) ease-in-out infinite}
.a-drink .arm-r{animation:drinkArm calc(2.6s*var(--sp,1)) ease-in-out infinite}
.a-jump .root{animation:jumpBig calc(1.3s*var(--sp,1)) ease-in-out infinite}
.a-dance .root{animation:danceRock calc(.55s*var(--sp,1)) ease-in-out infinite}
.a-dance .arm-l{animation:danceL calc(1.1s*var(--sp,1)) ease-in-out infinite}
.a-dance .arm-r{animation:danceR calc(1.1s*var(--sp,1)) ease-in-out infinite}
.a-look .head{animation:lookHead calc(4s*var(--sp,1)) ease-in-out infinite}
.a-look .eyes{animation:blink calc(4.6s*var(--sp,1)) infinite,lookEyes calc(4s*var(--sp,1)) ease-in-out infinite}
.a-talk .mouth{animation:talkMouth calc(.28s*var(--sp,1)) ease-in-out infinite}
.a-talk .head{animation:talkHead calc(1.4s*var(--sp,1)) ease-in-out infinite}
`;

  class KairoChar extends HTMLElement {
    static get observedAttributes() { return ['view', 'expression', 'pose', 'anim', 'size', 'flip', 'follow', 'phase', 'hoodie', 'speed', 'shadow']; }
    constructor() { super(); this.attachShadow({ mode: 'open' }); this._onMove = this._onMove.bind(this); }
    connectedCallback() { this._render(); }
    attributeChangedCallback() { if (this.isConnected) this._render(); }
    disconnectedCallback() { document.removeEventListener('mousemove', this._onMove); }
    get _a() {
      return {
        view: this.getAttribute('view') || 'front',
        expression: this.getAttribute('expression') || 'neutral',
        pose: this.getAttribute('pose') || 'standing',
        anim: this.getAttribute('anim') || 'idle',
        size: parseFloat(this.getAttribute('size')) || 200
      };
    }
    _render() {
      const a = this._a;
      let body;
      if (a.view === 'side') body = sideSVG(a); else if (a.view === 'back') body = backSVG(a); else body = frontSVG(a);
      const flip = this.hasAttribute('flip');
      const shadow = this.getAttribute('shadow') !== 'none'
        ? `<ellipse cx="100" cy="222" rx="38" ry="6" fill="${C.coal}" opacity=".1" data-part="ground-shadow"/>` : '';
      const hood = this.getAttribute('hoodie');
      const sp = this.getAttribute('speed');
      const ph = this.getAttribute('phase');
      this.shadowRoot.innerHTML = `<style>${CSS}</style>
<svg class="a-${a.anim}" viewBox="0 0 200 236" width="${a.size}" height="${a.size * 1.18}"
     style="${flip ? 'transform:scaleX(-1);' : ''}${hood ? `--hood:${hood};` : ''}${sp ? `--sp:${sp};` : ''}${ph ? `--ph:${-parseFloat(ph) * 0.74}s;` : ''}"
     xmlns="http://www.w3.org/2000/svg" data-character="kairo" data-view="${a.view}">
${shadow}<defs><radialGradient id="irisG" cx="50%" cy="35%" r="75%"><stop offset="0%" stop-color="#6B9A72"/><stop offset="55%" stop-color="#3E6B4A"/><stop offset="100%" stop-color="#243A2C"/></radialGradient></defs>${body}</svg>`;
      if (this.hasAttribute('follow')) document.addEventListener('mousemove', this._onMove);
      else document.removeEventListener('mousemove', this._onMove);
    }
    _onMove(ev) {
      const eyesEls = this.shadowRoot.querySelectorAll('.eyes, .face');
      if (!eyesEls.length) return;
      const r = this.getBoundingClientRect();
      const dx = Math.max(-1, Math.min(1, (ev.clientX - (r.left + r.width / 2)) / 300));
      const dy = Math.max(-1, Math.min(1, (ev.clientY - (r.top + r.height * 0.35)) / 300));
      const eyes = this.shadowRoot.querySelector('.eyes');
      if (eyes) eyes.style.translate = `${dx * 3}px ${dy * 2.5}px`;
      const head = this.shadowRoot.querySelector('.head');
      if (head && !this.getAttribute('anim').match(/look|sleep/)) head.style.rotate = `${dx * 4}deg`;
    }
    getLayeredSVG() {
      const svg = this.shadowRoot.querySelector('svg').cloneNode(true);
      svg.removeAttribute('class'); svg.removeAttribute('style');
      svg.setAttribute('width', '400'); svg.setAttribute('height', '472');
      let s = svg.outerHTML;
      s = s.replace(/var\(--hood\)/g, this.getAttribute('hoodie') || C.forest);
      s = s.replace(/var\(--hoodD\)/g, C.forestD);
      return `<?xml version="1.0" encoding="UTF-8"?>\n<!-- Kairo character - layered for Rive/Spine/Live2D import. Each data-part group is a separable layer. -->\n` + s;
    }
  }
  if (!customElements.get('kairo-char')) customElements.define('kairo-char', KairoChar);
  window.KAIRO_META = { expressions: Object.keys(EXPR), poses: Object.keys(POSES), anims: ANIMS, colors: C };
})();
