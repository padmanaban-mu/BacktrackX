const express = require('express');
const router = express.Router();
const { getLessons, getLessonById, getQuizForLesson } = require('../controllers/contentController');

router.get('/lessons', getLessons);
router.get('/lessons/:id', getLessonById);
router.get('/lessons/:id/quiz', getQuizForLesson);

module.exports = router;
