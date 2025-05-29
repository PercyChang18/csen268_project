// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserProfile {
  String? gender;
  double? weight;
  double? height;
  int? age;
  List<String> purposes;
  List<String> availableEquiqments;

  UserProfile({
    this.gender,
    this.weight,
    this.height,
    this.age,
    List<String>? purposes,
    List<String>? availableEquiqments,
  }) : purposes = purposes ?? [],
       availableEquiqments = availableEquiqments ?? [];

  void printProfile() {
    print('--- User Profile ---');
    print('Gender: $gender');
    print('Weight: $weight');
    print('Height: $height');
    print('Age: $age');
    print('Purposes: ${purposes.join(', ')}');
    print('Available Equipments: ${availableEquiqments.join(', ')}');
    print('--------------------');
  }
}
