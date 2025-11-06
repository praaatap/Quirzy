// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://your-backend-url:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void registerUser(String userId) {
    socket.emit('register', userId);
  }

  void sendChallenge(String challengerId, String challengedId) {
    socket.emit('create_challenge', {
      'challengerId': challengerId,
      'challengedId': challengedId,
    });
  }

  void acceptChallenge(String challengeId) {
    socket.emit('accept_challenge', challengeId);
  }

  void startQuizSession(String sessionId) {
    socket.emit('start_quiz', sessionId);
  }

  void submitAnswer(String sessionId, String userId, int questionIndex, int answerIndex) {
    socket.emit('submit_answer', {
      'sessionId': sessionId,
      'userId': userId,
      'questionIndex': questionIndex,
      'answerIndex': answerIndex,
    });
  }

  void onNewChallenge(Function(dynamic) callback) {
    socket.on('new_challenge', callback);
  }

  void onChallengeAccepted(Function(dynamic) callback) {
    socket.on('challenge_accepted', callback);
  }

  void onQuestionReceived(Function(dynamic) callback) {
    socket.on('question', callback);
  }

  void onAnswerResult(Function(dynamic) callback) {
    socket.on('answer_result', callback);
  }

  void onQuizCompleted(Function(dynamic) callback) {
    socket.on('quiz_completed', callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}