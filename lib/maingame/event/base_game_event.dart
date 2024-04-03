import 'dart:async';

class BaseGameEvent {
  int playerId = 0;
  int pieceId = 0;
  Completer<bool> completer = Completer();

  @override
  String toString() {
    // TODO: implement toString
    return runtimeType.toString();
  }
}

class OnClickPieceEvent extends BaseGameEvent{
  
}

class RecruitPieceEvent extends BaseGameEvent { 
  int targetPieceId = 0;
}

class ArragePieceEvent extends BaseGameEvent {
  int nodeId = 0;
}

class SkipEvent extends BaseGameEvent {
  
}

class ControlEvent extends BaseGameEvent {
  int nodeId = 0;
}