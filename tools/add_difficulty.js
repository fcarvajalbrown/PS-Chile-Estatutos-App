// One-off: adds a "difficulty" field (1=Basico, 2=Intermedio, 3=Avanzado) to each
// question in app/assets/data/quiz.json, in authoring order. Run: node tools/add_difficulty.js
const fs = require('fs');
const p = 'C:/Projects/PS-Chile-Estatutos/app/assets/data/quiz.json';
const q = JSON.parse(fs.readFileSync(p, 'utf8'));

const diff = [
  1,1,2,2,3,1,3,        // I  (7)
  1,2,3,2,              // II (4)
  1,2,3,3,              // III(4)
  2,1,1,2,3,3,          // IV (6)
  1,2,2,2,              // V  (4)
  1,2,3,3,3,            // VI (5)
  2,3,3,3,3,            // VII(5)
  1,1,2,3,2,2,          // VIII(6)
  2,3,                  // IX (2)
  1,2,3,                // X  (3)
  1,2,3,                // XI (3)
  2,3,                  // XII(2)
  1,2,                  // XIII(2)
  1,3,2,2,3,2,3,3,      // XIV(8)
  1,2,2,3,2,2,2,3       // XV (8)
];

if (diff.length !== q.length) {
  console.error('LENGTH MISMATCH', diff.length, q.length);
  process.exit(1);
}
q.forEach((x, i) => { x.difficulty = diff[i]; });
fs.writeFileSync(p, JSON.stringify(q, null, 2) + '\n', 'utf8');

const dist = {};
q.forEach(x => { dist[x.difficulty] = (dist[x.difficulty] || 0) + 1; });
console.log('distribution', JSON.stringify(dist));
console.log('--- sample (idx, T, diff, ref, question) ---');
q.forEach((x, i) => console.log(i, 'T' + x.titulo, 'd' + x.difficulty, x.articleRef, x.question.slice(0, 40)));
