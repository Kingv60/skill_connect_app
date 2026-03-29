abstract class ProfileSetupEvent {}

class UsernameChanged extends ProfileSetupEvent {
  final String username;
  UsernameChanged(this.username);
}

class CheckUsernameAvailability extends ProfileSetupEvent {
  final String username;
  CheckUsernameAvailability(this.username);
}

class SkillInputChanged extends ProfileSetupEvent {
  final String query;
  SkillInputChanged(this.query);
}

class AddSkill extends ProfileSetupEvent {
  final String skill;
  AddSkill(this.skill);
}

class RemoveSkill extends ProfileSetupEvent {
  final String skill;
  RemoveSkill(this.skill);
}