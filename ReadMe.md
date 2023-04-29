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

* [📹 O projektu](#about)
* [💎 Funkcije](#features)
* [🚀 Namestitev aplikacije](#deployment)
    * [✅ Zahteve](#prerequisites)
    * [⏳ Postopek izgradnje](#compiling)

<!-- TOC -->


## 📹 O projektu <a name = "about"></a>

V tem repozitoriju se nahaja koda čelnega dela mobilne aplikacije *ŠCVideo*.
Ta je družabno omrežje, namenjeno deljenju kratkih video vsebin med dijaki
na Šolskem centru Velenje.

## 💎 Funkcije <a name = "features"></a>

| Video zid                                                                                                                     | Posnemi & objavi                                                                                                              | Uporabniški profili                                                                                                           | Komentarji                                                                                                                    |
|-------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| <img src="https://user-images.githubusercontent.com/35228139/233382967-d725a1bd-0c26-4324-bc5a-394b3f09b447.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382977-5fabeae9-ac51-44cd-a652-a4e1d5ab21ec.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382944-96ea335d-f88a-4fd3-b18e-3684052fdc9c.PNG" width=120px> | <img src="https://user-images.githubusercontent.com/35228139/233382955-aad7942b-2781-442d-8414-5b55dace1803.PNG" width=120px> |

## 🚀 Namestitev aplikacije <a name = "deployment"></a>

Pred namestitvijo morate aplikacijo »zgraditi« v razvojnem okolju Xcode.

### ✅ Zahteve <a name = "prerequisites"></a>

Za izgradnjo in delovanje aplikacije potrebujete naslednje:

- Xcode različico 12.4 ali novejšo;
- nameščen upravljavec paketov [CocoaPods](https://cocoapods.org/);
- telefon iPhone z operacijskim sistemom iOS 14.4 ali novejšim;
- računalnik za zagon zalednega dela aplikacije (
  glej [repozitorij zalednega dela](https://github.com/tzuntar/SCVideo-Backend)).

### ⏳ Postopek izgradnje <a name = "compiling"></a>

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
