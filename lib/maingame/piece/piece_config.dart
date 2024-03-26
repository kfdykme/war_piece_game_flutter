

class PieceConfig {

  late AttackConfig attackConfig;
  late MoveConfig moveConfig;
  late SkillConfig skillConfig;

  PieceConfig(Map<String, dynamic> config) {
    attackConfig = AttackConfig(config['attack']);
  }

}

class AttackConfig {
  late bool enable;
  AttackConfig(Map<String, dynamic>? config) {
    enable = config?['enable'] ?? true;
  }
}

class MoveConfig {

}
//  'skill': {
//         'target': {
//           'deep': 2,
//           'condition': [
//             'not_empty_piece',
//             'not_friend_piece'
//           ],
//         },
//         'mode': 'hit'
//       }
class SkillConfig {

  late int target_deep;
  List<Function> conditions = [];
  SkillConfig(Map<String, dynamic>? config) {
    final target = config?['target'] ?? {};
    target_deep = target?['deep'] ?? 1;
    conditions = (target?['conditions'] ?? []).map((value) {
      return GetConditionFunc(value);
    });
  }
  
  Function GetConditionFunc(value) {
    if (value == 'not_empty_piece') {

    }
    return () { return false;};
  }
}