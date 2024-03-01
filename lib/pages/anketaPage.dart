import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';


EmptySpace? emptySpace;
ShopType? shopType;
bool? halal;
YuridicForm? yuridicForm;



class AnketaPage extends StatelessWidget
{
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController shopSquare = TextEditingController();
  final TextEditingController cassCount = TextEditingController();
  final TextEditingController prodavecCount = TextEditingController();
  final TextEditingController terminals = TextEditingController();


  @override
  Widget build(BuildContext context)
  {
    var args = ModalRoute.of(context)!.settings.arguments as CustomArgument;
    InternalShop shop = sqlFliteDB.shops[args.shopId]!;
    phoneNumber.text = shop.phoneNumber;
    shopSquare.text = shop.shopSquareMeter.toString();
    cassCount.text = shop.cassCount.toString();
    prodavecCount.text = shop.prodavecManagerCount.toString();
    terminals.text = shop.paymanetTerminal.toString();
    emptySpace = shop.emptySpace;
    shopType = shop.shopType;
    halal = shop.halal;
    yuridicForm = shop.yuridicForm;

    return Scaffold(
      appBar: AppBar(
          title: Text('Анкета для ${shop.shopName}'),
          automaticallyImplyLeading: false,
          actions: [IconButton(
            icon: const Icon(Icons.check),
            onPressed: (){
              shop.emptySpace = emptySpace ?? EmptySpace.few;
              shop.shopType = shopType ?? ShopType.none;
              shop.halal = halal ?? false;
              shop.yuridicForm = yuridicForm ?? YuridicForm.none;
              shop.phoneNumber = phoneNumber.text;
              shop.shopSquareMeter = double.tryParse(shopSquare.text) ?? 0;
              shop.cassCount = int.tryParse(cassCount.text) ?? 0;
              shop.prodavecManagerCount = int.tryParse(prodavecCount.text) ?? 0;
              shop.paymanetTerminal = int.tryParse(terminals.text) ?? 0;
              sqlFliteDB.updateShop(shop);
              Navigator.of(context).popAndPushNamed('/shopPage',arguments: CustomArgument(shopId: args.shopId));
            }
          )],
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: ()async {
            bool? isExit = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: const Text('Выйти не сохранив?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Нет'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Да'),
                  ),
                ],
              ),
            );
            if(isExit != null && isExit){
              Navigator.of(context).popAndPushNamed('/shopPage',arguments: CustomArgument(shopId: args.shopId));
            }

          }
          )
      ),
      body: ListView(
          children: [
            const Text('Телефонный номер', textAlign: TextAlign.center,),
            TextFormField(
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                filled: true, // Needed for adding a fill color
                fillColor: Colors.orange[200],
                isDense: true,  // Reduces height a bit
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,              // No border
                  borderRadius: BorderRadius.circular(12),  // Apply corner radius
                ),
              ),
              controller: phoneNumber,
            ),
            const Text('Площадь магазина', textAlign: TextAlign.center,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                filled: true, // Needed for adding a fill color
                fillColor: Colors.orange[200],
                isDense: true,  // Reduces height a bit
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,              // No border
                  borderRadius: BorderRadius.circular(12),  // Apply corner radius
                ),
              ),
              controller: shopSquare,
            ),
            const Text('Количество касс', textAlign: TextAlign.center,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                filled: true, // Needed for adding a fill color
                fillColor: Colors.orange[200],
                isDense: true,  // Reduces height a bit
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,              // No border
                  borderRadius: BorderRadius.circular(12),  // Apply corner radius
                ),
              ),
              controller: cassCount,
            ),
            const Text('Количество продавцов', textAlign: TextAlign.center,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                filled: true, // Needed for adding a fill color
                fillColor: Colors.orange[200],
                isDense: true,  // Reduces height a bit
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,              // No border
                  borderRadius: BorderRadius.circular(12),  // Apply corner radius
                ),
              ),
              controller: prodavecCount,
            ),
            const Text('Количество терминалов', textAlign: TextAlign.center,),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                filled: true, // Needed for adding a fill color
                fillColor: Colors.orange[200],
                isDense: true,  // Reduces height a bit
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,              // No border
                  borderRadius: BorderRadius.circular(12),  // Apply corner radius
                ),
              ),
              controller: terminals,
            ),
            const Divider(),
            const EmptySpaceRadio(),
            const Divider(),
            const YuridicRadio(),
            const Divider(),
            const ShopTypeRadio(),
            const Divider(),
            const HalalRadio(),
            const Divider(),
          ]
      ),
    );
  }
}

class ShopTypeRadio extends StatefulWidget
{
  const ShopTypeRadio({super.key});
  @override
  State<ShopTypeRadio> createState() => _ShopTypeRadioState();
}

class _ShopTypeRadioState extends State<ShopTypeRadio>
{
  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('В жилом доме'),
          leading: Radio<ShopType>(
            value: ShopType.inHomeShop,
            groupValue: shopType,
            onChanged: (ShopType? value) {
              setState(() {
                shopType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Отдельное строение'),
          leading: Radio<ShopType>(
            value: ShopType.oneBuilding,
            groupValue: shopType,
            onChanged: (ShopType? value) {
              setState(() {
                shopType = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Павильон в магазине'),
          leading: Radio<ShopType>(
            value: ShopType.pavilon,
            groupValue: shopType,
            onChanged: (ShopType? value) {
              setState(() {
                shopType = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class EmptySpaceRadio extends StatefulWidget
{
  const EmptySpaceRadio({super.key});
  @override
  State<EmptySpaceRadio> createState() => _EmptySpaceRadioState();
}

class _EmptySpaceRadioState extends State<EmptySpaceRadio>
{
  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Нет пустого места'),
          leading: Radio<EmptySpace>(
            value: EmptySpace.none,
            groupValue: emptySpace,
            onChanged: (EmptySpace? value) {
              setState(() {
                emptySpace = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Мало пустого места'),
          leading: Radio<EmptySpace>(
            value: EmptySpace.few,
            groupValue: emptySpace,
            onChanged: (EmptySpace? value) {
              setState(() {
                emptySpace = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Много пустого места'),
          leading: Radio<EmptySpace>(
            value: EmptySpace.many,
            groupValue: emptySpace,
            onChanged: (EmptySpace? value) {
              setState(() {
                emptySpace = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class YuridicRadio extends StatefulWidget
{
  const YuridicRadio({super.key});
  @override
  State<YuridicRadio> createState() => _YuridicRadioState();
}

class _YuridicRadioState extends State<YuridicRadio>
{
  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Не ясно'),
          leading: Radio<YuridicForm>(
            value: YuridicForm.none,
            groupValue: yuridicForm,
            onChanged: (YuridicForm? value) {
              setState(() {
                yuridicForm = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('ИП'),
          leading: Radio<YuridicForm>(
            value: YuridicForm.IP,
            groupValue: yuridicForm,
            onChanged: (YuridicForm? value) {
              setState(() {
                yuridicForm = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('ОсОО'),
          leading: Radio<YuridicForm>(
            value: YuridicForm.OsOO,
            groupValue: yuridicForm,
            onChanged: (YuridicForm? value) {
              setState(() {
                yuridicForm = value;
              });
            },
          ),
        ),
      ],
    );
  }
}

class HalalRadio extends StatefulWidget
{
  const HalalRadio({super.key});
  @override
  State<HalalRadio> createState() => _HalalRadioState();
}

class _HalalRadioState extends State<HalalRadio>
{
  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Халал (есть сигареты и алкоголь)'),
          leading: Radio<bool>(
            value: true,
            groupValue: halal,
            onChanged: (bool? value) {
              setState(() {
                halal = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Не халал'),
          leading: Radio<bool>(
            value: false,
            groupValue: halal,
            onChanged: (bool? value) {
              setState(() {
                halal = value;
              });
            },
          ),
        ),
      ],
    );
  }
}