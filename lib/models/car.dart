class Car {
  static const tblCars = 'cars';
  static const colId = 'id';
  static const colVin = 'vin';
  static const colNickname = 'nickname';
  static const colPlate = 'plate';
  static const colMileage = 'mileage';

  Car({this.id, this.vin, this.plate, this.nickname, this.mileage});

  Car.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    vin = map[colVin];
    nickname = map[colNickname];
    plate = map[colPlate];
    mileage = map[colMileage];
  }

  int? id;
  String? vin;
  String? plate;
  String? nickname;
  int? mileage;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colVin: vin,
      colPlate: plate,
      colNickname: nickname,
      colMileage: mileage,
    };
    // if (id != null) {
    // map[colId] = id; //not sure https://www.youtube.com/watch?v=tj7Lj9a3fyM
    // }
    return map;
  }

/*   <String, dynamic> toString() {
    const output = """nickname: $colNickname, id: $colId, vin: $colVin, 
      plate: $colPlate, mileage: ($colMileage.runtimeType) $colMileage """;
    return output;
  } */
}
