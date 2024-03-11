enum ShopType
{
  none,
  pavilon,
  oneBuilding,
  inHomeShop
}

enum EmptySpace
{
  none,
  many,
  few
}

enum YuridicForm
{
  none,
  IP,
  OsOO,
}

enum PhotoType
{
  tempPhoto,
  none,
  externalPhoto,
  shopLabelPhoto,
  alkoholPhoto,
  kolbasaSyr,
  milk,
  snack,
  mylomoika,
  vegetablesFruits,
  cigarettes,
  kassovayaZona,
  toys,
  butter,
  water,
  juice,
  gazirovka,
  candyVes,
  chocolate,
  korobkaCandy,
  pirogi,
  tea,
  coffee,
  macarons,
  meatKonserv,
  fishKonserv,
  fruitKonserv,
  milkKonserv,
}

class InternalShop
{
  InternalShop(this._id);
  int _id;
  int userId = 0;
  String shopName = '';
  double xCoord = 0, yCoord = 0;
  String address = '';
  ShopType shopType = ShopType.none;
  final Map<String,String> photoMap = {
    'water' : '',
    'juice' : '',
    'gazirovka' : '',
    'candyVes' : '',
    'chocolate' : '',
    'korobkaCandy' : '',
    'pirogi' : '',
    'tea' : '',
    'coffee' : '',
    'macarons' : '',
    'meatKonserv' : '',
    'fishKonserv' : '',
    'fruitKonserv' : '',
    'milkKonserv' : '',
    'externalPhoto' : '',
    'shopLabelPhoto' : '',
    'alkoholPhoto' : '',
    'kolbasaSyr' : '',
    'milk' : '',
    'snack' : '',
    'mylomoika' : '',
    'vegetablesFruits' : '',
    'cigarettes' : '',
    'kassovayaZona' : '',
    'toys' : '',
    'butter' : ''
  };
  String phoneNumber = '';
  double shopSquareMeter = 0;
  int cassCount = 0;
  int prodavecManagerCount = 0;
  bool halal = false;
  int paymanetTerminal = 0;
  EmptySpace emptySpace = EmptySpace.few;
  YuridicForm yuridicForm = YuridicForm.none;
  int millisecsSinceEpoch = 0;
  bool isNeedDrawBySort = true;
  bool hasReport = false;
  bool isSending = false;
  int get id => _id;

  @override
  bool operator ==(Object other) {
    if(other is InternalShop && id == other.id){
      return true;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}