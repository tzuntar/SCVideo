<p align="center">
<a href="" rel="noopener">
<img width=120px height=120px style="border-radius: 25px" src="https://github.com/tzuntar/SCVideo/blob/master/SCVideo/Assets.xcassets/AppIcon.appiconset/Icon-4.png?raw=true" alt="ŠCVideo Logo"></a>
</p>

<h3 align="center">ŠCVideo</h3>

---

<p align="center">Družabno omrežje za deljenje videoposnetkov na Šolskemu centru Velenje. 
<br>
</p>

## 📝 Kazalo

<!-- TOC -->

* [📝 Kazalo](#-kazalo)
* [📹 O projektu <a name = "about"></a>](#-o-projektu-a-name--about-a)
* [💎 Funkcije <a name = "features"></a>](#-funkcije-a-name--features-a)
* [🚀 Namestitev aplikacije <a name = "deployment"></a>](#-namestitev-aplikacije-a-name--deployment-a)
    * [✅ Zahteve <a name = "prerequisites"></a>](#-zahteve-a-name--prerequisites-a)
    * [⏳ Postopek izgradnje](#postopek-izgradnje)

<!-- TOC -->

## 📹 O projektu <a name = "about"></a>

V tem repozitoriju se nahaja koda čelnega dela mobilne aplikacije *ŠCVideo*.
Ta je družabno omrežje, namenjeno deljenju kratkih video vsebin med dijaki
na Šolskem centru Velenje.

## 💎 Funkcije <a name = "features"></a>

| Video zid | Posnemi & objavi | Uporabniški profili | Pregled objav | Komentarji |
|-----------|------------------|---------------------|---------------|------------|
|           |                  |                     |               |            |

## 🚀 Namestitev aplikacije <a name = "deployment"></a>

Pred namestitvijo morate aplikacijo »zgraditi« v razvojnem okolju Xcode.

### ✅ Zahteve <a name = "prerequisites"></a>

Za izgradnjo in delovanje aplikacije potrebujete naslednje:

- Xcode različico 12.4 ali novejšo;
- nameščen upravljavec paketov [CocoaPods](https://cocoapods.org/);
- telefon iPhone z operacijskim sistemom iOS 14.4 ali novejšim;
- računalnik za zagon zalednega dela aplikacije (
  glej [repozitorij zalednega dela](https://github.com/tzuntar/SCVideo-Backend)).

### ⏳ Postopek izgradnje

1. Prenesite kodo obeh, čelnega in zalednega dela, vsakega v svoj imenik.
2. Aplikacijo registrirajte na storitvi Azure Active Directory, pri tem pazite, da se bo vaš *Bundle ID* ujemal.
3. Namestite zahtevane pakete z ukazom `pod install`.
4. V imeniku čelnega dela ustvarite datoteko z imenom `Keys.xcconfig` in vanjo napišite naslednje:
   ```
   MSAL_CLIENT_ID = ID vaše aplikacije na storitvi Azure
   DEFAULT_SERVER_IP = privzeti naslov IP računalnika z zalednim delom 
   ```
5. Odprite datoteko `SCVideo.xcworkspace` v razvojnem okolju Xcode.
6. Zaženite zaledni del aplikacije ter priklopite telefon iPhone na računalnik z okoljem Xcode.
7. Odklenite telefon in v okolju Xcode kliknite *Run*, da zaženete aplikacijo.
