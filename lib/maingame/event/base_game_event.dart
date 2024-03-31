import 'dart:async';

class BaseGameEvent {
  int playerId = 0;
  Completer<bool> completer = Completer();
}

class OnClickPieceEvent extends BaseGameEvent{
  int pieceId = 0;
}

class ArragePieceEvent extends BaseGameEvent {
  int pieceId = 0; 
  int nodeId = 0;
}

class RecruitPieceEvent extends BaseGameEvent {
  int pieceId = 0; 
  
}

class SkipEvent extends BaseGameEvent {
  int pieceId = 0; 
  
}