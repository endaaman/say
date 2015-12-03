# Viqoのコメントを読み上げるやつ
簡易的な教育機能を実装しています。ノンブロッキングかつコメントを漏らさず読みきれます。Ubuntu15.10でしかテストしてません。

読み上げるだけなら[Viqoのwiki](https://github.com/diginatu/Viqo/wiki/%E8%AA%AD%E3%81%BF%E4%B8%8A%E3%81%92)のUbuntuの章があるのでそっちを見てください。

## 必要なもの

```
$ sudo apt-get install open-jtalk open-jtalk-mecab-naist-jdic  hts-voice-nitech-jp-atr503-m001
```

動作には[pm2](https://github.com/Unitech/pm2)とCoffeeScriptを使います。

```
$ npm i -g pm2 coffee-script
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

のように配置しています。違うパスを指定するばあいは`./server.coffee`を適当にいじってください。

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

## 教育機能
ほとんど私的ツールということもあって仕様はコロコロ変わると思います。

現状ではコマンドのデリミッターに半角スペースを使用しているので、パラメーターとして与える文字列に半角スペースを含ませることはできません。


### 覚えさせる

```
<add|teach|調教|> <regexp> <replacer>
```

よくある末尾の`wwww`などを`わら`等に置き換えたい場合は

```
add (ｗ|w)+$ わら
```

このようになります。また、

```
調教 Ubuntu うぶんつ
```

というように英語を覚えさせる場合、大文字はすべて小文字に変換されて登録されます。マッチには内部で`new RegExp(..., 'ig')`を使用しているので、`ubuntu`、`UBUNTU`も置換できます。


### 忘れさせる

```
<remover|forget|忘却|> <regexp>
```

登録時に小文字に変換し、探索時も小文字に変換して探索するので、

```
add ubuntu うぶんつ
```

で覚えさせた場合は

`remove ubuntu`、`forget Ubuntu`、`忘却 UBNUTU`のいずれを使用しても登録した単語を削除できます。



## 注意
非同期処理内でエラーが起こるとPromiseによる **エラーの握りつぶし** が発生するので気をつけてください。
