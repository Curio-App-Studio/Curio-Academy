// scripts/build_full_curriculum.js
const fs = require('fs');
const path = require('path');

const { list: baseList } = require('./curriculum_base');
const { list: c1List } = require('./curriculum_c1');
const { list: c2List } = require('./curriculum_c2');
const { list: c3List } = require('./curriculum_c3');
const { list: c4c5List } = require('./curriculum_c4_c5');
const { list: c6List } = require('./curriculum_c6');
const { list: c7c8List } = require('./curriculum_c7_c8');

const allChapters = [
  ...baseList,
  ...c1List,
  ...c2List,
  ...c3List,
  ...c4c5List,
  ...c6List,
  ...c7c8List,
];

console.log('Total English chapters compiled:', allChapters.length);

// Verify unique chapterIds
const idSet = new Set();
for (const ch of allChapters) {
  if (idSet.has(ch.chapterId)) {
    console.error('DUPLICATE ID:', ch.chapterId);
    process.exit(1);
  }
  idSet.add(ch.chapterId);
}

// Summary map of grade | board
const map = {};
allChapters.forEach(c => {
  const k = `${c.grade} | ${c.board}`;
  map[k] = (map[k] || 0) + 1;
});
console.log('Grade | Board distribution:', map);

// Write to assets/curriculum/english_chapters.json
const targetFile = path.join(__dirname, '..', 'assets', 'curriculum', 'english_chapters.json');
fs.writeFileSync(targetFile, JSON.stringify(allChapters, null, 2), 'utf-8');
console.log('Successfully written to', targetFile);
