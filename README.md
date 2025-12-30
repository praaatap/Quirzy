# Quirzy - AI-Powered Quiz Generation App

<p align="center">
  <img src="assets/icon.png" width="120" height="120" alt="Quirzy Logo" style="border-radius: 24px; box-shadow: 0 10px 30px rgba(139, 92, 246, 0.3);">
</p>

<p align="center">
  <strong>Transform any content into interactive quizzes and flashcards using AI.</strong>
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#gallery">Gallery</a> •
  <a href="#contact">Contact</a>
</p>

<div align="center">

  ![License](https://img.shields.io/badge/License-Proprietary-red.svg?style=for-the-badge)
  ![Status](https://img.shields.io/badge/Status-Showcase%20Only-orange.svg?style=for-the-badge)
  ![Platform](https://img.shields.io/badge/Platform-Flutter%20%7C%20iOS%20%7C%20Android-blue.svg?style=for-the-badge&logo=flutter)

</div>

---

> ⚠️ **PROPRIETARY SOFTWARE - READ BEFORE VIEWING**
>
> This repository is **PUBLIC FOR SHOWCASE PURPOSES ONLY**. All rights are reserved by the author.
>
> ❌ **YOU MAY NOT:** Copy, modify, distribute, sell, or use any part of this code in any commercial or non-commercial project.
>
> ✅ **YOU MAY:** View the code to evaluate the technical skills, architecture, and coding standards of the developer.

---

## 📱 About Quirzy

**Quirzy** is a cutting-edge educational tool designed to revolutionize how students and professionals study. By leveraging advanced Artificial Intelligence, Quirzy takes static content—PDFs, text notes, or topic keywords—and instantly converts them into interactive study materials.

Whether you are preparing for a certification like AWS SAA-C03, studying for university exams, or learning a new language, Quirzy adapts to your learning style with gamified quizzes and smart flashcards.

## ✨ Key Features

### 🧠 **AI-Driven Content Generation**
* **Topic-to-Quiz:** Simply type a topic (e.g., "Mitosis", "Flutter State Management") and get a tailored quiz instantly.
* **Document Parsing:** Upload PDFs or paste text notes to generate questions directly from your source material.

### 📚 **Smart Study Modes**
* **Flashcard Flip Mode:** A Tinder-like interface for rapid review. Swipe left/right to mark cards as "Mastered" or "Review Again."
* **Gamified Quizzes:** Multiple-choice questions with timers, streaks, and score tracking to keep engagement high.
* **Spaced Repetition:** The app remembers what you struggle with and surfaces those questions more frequently.

### 🎨 **Modern & Fluid UI/UX**
* **Glassmorphism Design:** Beautiful, translucent UI elements built with custom Flutter painters.
* **60 FPS Animations:** Optimized `RepaintBoundary` and `Transform` animations for butter-smooth transitions on all devices.
* **Dark/Light Theme:** Fully adaptive theming with a signature Violet & Deep Purple palette.

## 🛠️ Tech Stack

This project is built using a modern, scalable architecture to ensure performance and maintainability.

| Category | Technologies |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **State Management** | [Riverpod](https://riverpod.dev/) |
| **Backend** | Node.js, Express |
| **Database** | MongoDB / Redis (for caching) |
| **AI Integration** | OpenAI API / Custom LLM Pipelines |
| **Cloud Infrastructure** | Azure VM, Docker, GitHub Actions (CI/CD) |
| **Architecture** | Clean Architecture (MVVM) |

## 📸 Gallery

| **Home Dashboard** | **Flashcard Study** | **Quiz Interface** |
|:---:|:---:|:---:|
| <img src="assets/screenshots/home.png" width="200" alt="Home Screen"> | <img src="assets/screenshots/flashcard.png" width="200" alt="Flashcard Screen"> | <img src="assets/screenshots/quiz.png" width="200" alt="Quiz Screen"> |

*> Note: Screenshots are placeholders. Actual app UI features detailed glassmorphism and animations.*

## 🚀 Performance Optimization

Quirzy is engineered for smoothness, even on mid-range devices. Key optimizations include:
* **Layout Thrashing Avoidance:** Zero animation of `width`/`height` properties. All motion uses `Transform.scale` and `Transform.translate`.
* **Smart Repainting:** Heavy widgets like Flashcards are wrapped in `RepaintBoundary` to isolate render cycles.
* **Lazy Loading:** Cached network images and paginated lists ensure low memory footprint.

## 📬 Contact & Portfolio

This project is part of my personal portfolio. If you are interested in my work or would like to discuss a potential collaboration (hiring/freelance), please reach out!

* **Developer:** Pratap Singh Sisodiya
* **Role:** Full Stack Developer (Flutter, Node.js, Next.js)
* **LinkedIn:** [Your LinkedIn Profile Link]
* **Email:** [Your Email Address]

---
<p align="center">
  Created with ❤️ by Pratap Singh Sisodiya
</p>
