const mongoose = require('mongoose');

const lessonSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  description: { type: String, required: true },
  content: { type: String, required: true }, // JSON lines format
  order: { type: Number, required: true },
  category: { type: String, default: 'backtracking' },
  tags: [{ type: String }],
}, { timestamps: true });

module.exports = mongoose.model('Lesson', lessonSchema);
