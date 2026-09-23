const d = require('../assets/curriculum/english_chapters.json');
d.forEach(c => {
  const fields = [
    c.title,
    c.description,
    ...(c.keyConcepts || []),
    ...(c.rules || []),
    c.exampleQuestion || '',
    c.exampleExplanation || '',
    c.exampleAnswer || '',
    c.funFact || '',
    c.mascotAdvice || ''
  ];
  fields.forEach(f => {
    if (/(Class|Grade)\s*\d/i.test(f)) {
      console.log('LEAK in', c.chapterId, ':', f);
    }
  });
});
