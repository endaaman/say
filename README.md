# Viqoのコメントを読み上げやつ
簡易的な教育機能を実装しています。ノンブロッキングかつコメントを漏らさず読みきれます。Ubuntu15.10でしかテストしてません。

読み上げるだけなら[Viqoのwiki](https://github.com/diginatu/Viqo/wiki/%E8%AA%AD%E3%81%BF%E4%B8%8A%E3%81%92)のUbuntuの章があるのでそっちを見てください。

## 必要なもの

```
$ sudo apt-get install open-jtalk open-jtalk-mecab-naist-jdic  hts-voice-nitech-jp-atr503-m001
```

動作には[pm2](https://github.com/Unitech/pm2)を推奨しています。

```
$ npm i -g pm2
```

で入ります。

メイちゃんボイスを使っているので[MMDAgent Example](http://sourceforge.net/projects/mmdagent/files/MMDAgent_Example/)から音声データをダウンロードしておいてください。
作者の環境では

```
~/voices
├── mei_angry.htsvoice
├── mei_bashful.htsvoice
├── mei_happy.htsvoice
├── mei_normal.htsvoice
└── mei_sad.htsvoice
```

のように配置しています。

## 起動方法
```
$ npm start
```

で`say-server`という名前でpm2デーモンが立ち上がります。

```
$ ./client 'テストコメント'
```

でサーバーにHTTPリクエストが飛んで、サーバー側でコメントを読み上げてくれます。

`client`が`/path/to/client`というパスに配置されていれば、Viqo のコマンドのタブの[コメント受信時]にチェックを入れて

```
/path/to/talk "%comment%"
```

と設定すればコメントを読んでくれるはずです。

## 注意
非同期処理内でエラーが起こるとPromiseによる **エラーの握りつぶし** が発生するので気をつけてください。
