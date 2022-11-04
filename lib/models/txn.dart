class Txn {
  static const tblTxns = 'txns';
  static const colId = 'id';
  static const colType = 'txntype';
  static const colDatetime = 'datetime';
  static const colCost = 'cost';
  static const colMileage = 'mileage';
  static const colNote = 'note';
  static const colCarId = 'carid';

  Txn(
      {this.id,
      this.txntype,
      this.datetime,
      this.cost,
      this.mileage,
      this.note,
      this.carid});

  Txn.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    txntype = map[colType];
    datetime = map[colDatetime];
    cost = map[colCost];
    mileage = map[colMileage];
    note = map[colNote];
    carid = map[colCarId];
  }

  int? id;
  String? txntype;
  int? datetime; // store as integer unix time
  double? cost;
  int? mileage;
  String? note;
  int? carid;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colType: txntype,
      colDatetime: datetime,
      colCost: cost,
      colMileage: mileage,
      colNote: note,
      colCarId: carid,
    };
    return map;
  }
}
