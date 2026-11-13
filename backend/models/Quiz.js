const mongoose = require('mongoose');

const quizSchema = new mongoose.Schema({
  lessonId: { type: mongoose.Schema.Types.ObjectId, ref: 'Lesson', required: true },
  question: { type: String, required: true },
  options: [{ type: String }], // 4 options
  correctIndex: { type: Number, required: true },
  explanation: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Quiz', quizSchema);
