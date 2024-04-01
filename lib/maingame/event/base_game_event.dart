import 'dart:async';

class BaseGameEvent {
  int playerId = 0;
  int pieceId = 0;
  Completer<bool> completer = Completer();
}

class OnClickPieceEvent extends BaseGameEvent{
  
}

class RecruitPieceEvent extends BaseGameEvent { 
}

class ArragePieceEvent extends BaseGameEvent {
  int nodeId = 0;
}

class SkipEvent extends BaseGameEvent {
  
}

class ControlEvent extends BaseGameEvent {
  int nodeId = 0;
}