const Lesson = require('../models/Lesson');
const Quiz = require('../models/Quiz');
const { sendSuccess, sendError } = require('../utils/ApiResponse');

const getLessons = async (req, res) => {
  try {
    const lessons = await Lesson.find().sort({ order: 1 });
    sendSuccess(res, { data: lessons, message: 'Lessons fetched successfully.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const getLessonById = async (req, res) => {
  try {
    const lesson = await Lesson.findById(req.params.id);
    if (!lesson) return sendError(res, { statusCode: 404, code: 'NOT_FOUND', message: 'Lesson not found.' });
    sendSuccess(res, { data: lesson });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const getQuizForLesson = async (req, res) => {
  try {
    const quizzes = await Quiz.find({ lessonId: req.params.id });
    sendSuccess(res, { data: quizzes });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

module.exports = { getLessons, getLessonById, getQuizForLesson };
