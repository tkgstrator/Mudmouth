## Mudmouth

> このレポジトリには任天堂株式会社が権利を保有する一切のコンテンツは含まれていません.

MudmouthはNintendo Switch Onlineのアプリの通信を利用することで外部のAPIを一切利用せずにイカリング3にアクセスするためのトークンを取得します.

取得できる値は、

- Bullet Token
- Game Web Token
- X-Web-View-Ver

の三つです.

### 動作環境

利用しているライブラリの互換性の問題から, 以下のOSで利用可能です.

- iOS 15以上
- macOS 12以上
- Nintendo Switch Onlineのアプリがインストールされていること

> iOSは14以上にまで下げることができると思いますが, サポートする必要性がないと思われるので対応していません.

### Swift Package Manager

```swift
```

### Xcode

```
```

## 起動

Xcodeでビルドしてテストすることができます.

> シミュレータではNintendo Switch Onlineのアプリがインストールできないため, 起動できません.

## 設定

**Signing & Capabilities**からNetwork Extensionsを有効化します.

DemoAppとPacketTunnelの両方で有効化してください.

> デモアプリでは既に有効化されています.

Bundle Identifierを`${DEMO_APP_BUNDLE_IDENTIFIER}`に設定します

> ここは各自好きな値を入力してください

### DemoApp

1. CapalibitiesでPacket Tunnelにチェックを入れます.
2. App Groupsを追加します.

追加したApp GroupsはPacketTunnelのものと同じ値を設定してください.

### Packet Tunnel

Generalから**Frameworks and Libraries**を選択して`Mudmouth`を追加してください.

> デモアプリではこれらは既に追加されています.

**Signing & Capabilities**からBundle Identifierを`${DEMO_APP_BUNDLE_IDENTIFIER}.packetTunnel`に設定してください.

> 末尾が`.packetTunnel`である必要があります.


## 既存の問題

デバイスでおやすみモードが有効化されている場合, 通知が表示されません.

## 謝辞

- [zhxie(Xie Zhihao)](https://github.com/zhxie)