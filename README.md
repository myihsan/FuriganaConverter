# ルビ変換

## 仕様

- IDEバージョン：Xcode 11.2.1
- 言語バージョン：Swift 5
- ターゲット：iOS 13.2

## 準備

### 開発環境構築

```bash
sh bootstrap.sh
```

### gooラボ アプリケーションID設定

`FuriganaConverter/PrivateInfo.plist` にgooラボのアプリケーションIDを設定<a id="a1" href="#f1"><sup>1</sup></a>

### ワークスペースを開く

CocoaPodsを使用しているため、`FuriganaConverter.xcworkspace`を開く

## その他

念のため、`master`ブランチは`Pods`を`.gitignore`に入れていませんので、クローンが遅い場合、`develop`ブランチをクローンしてください。

---

<b id="f1">1.</b> 私のアプリケーションIDが必要な場合、連絡してください。 [↩](#a1)