---
layout: post
title: "祝: Atom の Web Components 導入、ついでに Atom Shell の話。"
date: 2014-12-21 16:54
comments: true
categories:
---

GitHub 謹製 [Atom エディタ](http://atom.io/)が
[Shadow DOM を使い始めた](http://blog.atom.io/2014/11/18/avoiding-style-pollution-with-the-shadow-dom.html)という。
めでたい。せっかくだから私も Atom を使ってみよう。
起動してテキスト書きもそこそこにインスペクタで DOM を眺める。
するとあら素敵。Shadow DOM のみならず Custom Elements もばりばり使われているじゃありませんか。
ためしにステータスバーをつついてみるとわかる。

Atom は UI を [React に書き直した](http://blog.atom.io/2014/07/02/moving-atom-to-react.html)ものと思いこんでいたけれど、
React になったのはテキスト編集領域だけの様子。周辺の UI は Custom Elements ベースになりつつあるらしい。
もともと [space-pen](https://github.com/atom/space-pen) という jQuery ベースの内製フレームワークで書いていたものを、
徐々に [Custom Elements 化していくという](https://github.com/atom/atom/issues/4673#issuecomment-67402158)。
Atom, 意外と Web Components だな。知らなかったよ。

![screenshot](https://farm8.staticflickr.com/7533/16076345992_dc751d4016_c.jpg)

まずは Markdown エディタとして使っていこうと思う。書いたメモを簡単に公開する仕組みが欲しいと試行錯誤してきた、その延長で試したい。
公開できるメモは Markdown で書き、そのテキストを GitHub に push しておく。
ただし GitHub pages など整形の手間はかけず GitHub 本体の Markdown プレビューで読めるだけ。
一人 Qiita ごっこ...と呼ぶのすらはばかられる手抜き。

わざわざ共有するほどではないけど隠しておくまでもなく、
ただ整形されたものをどこからでも読みたい。
そんなメモならこの仕組みでいい...かもしれない。

習作も兼ね、ファイル保存時にファイルを commit+push するがさつなパッケージ
[sync-on-save](https://atom.io/packages/sync-on-save) をつくった。メモとり支援。
これを使うとテキストがじゃんじゃんコミットされ、
GitHub の contributions チャートが全面緑になり、
虚栄心が満たされ、
GitHub を見て impressed なリクルータを煙にまくこともできます。

ステータスバーの表示に Shadow DOM と Custom Elements を使ってます。
記念にね。

## Atom Shell と Chromium

Atom は Chromium をベースにした [Atom Shell](https://github.com/atom/atom-shell)
と呼ばれる実行環境の上で動く。記念ついでに眺めてみよう。

CoffeeScript で書かれた沢山の細かいモジュール群が読む気を挫く Atom 本体に対し、
Atom Shell はけっこう小さい。しかも C++ が多くおっさんにやさしい。
Chromium 本体を [libchromiumcontent](https://github.com/brightray/libchromiumcontent) という別プロジェクトに切り出しバイナリ配布しているためビルドも速い。

Chromium にはウェブページを表示する機能をまとめた
[Content API](http://www.chromium.org/developers/content-module/content-api) がある。
Atom Shell はこの Content API の上に作られている。
Chromium の構造をよく理解した上で JavaScript の実行環境を作ろうと、
コンパクトながらよく練られている。

C++ で最低限のブートストラップを済ませ、
あとはアプリケーションから与えられた JavaScript を走らせる。
Atom Shell は Content API のうち必要そうな部分を [JavaScript の API](https://github.com/atom/atom-shell/tree/master/docs/api) として公開しているので、
アプリケーションはその API を使ってウィンドウを開いたりなんだりする。
また Atom Shell には Node.js がリンクされている。
だから Atom Shell の上で動くプログラムは Node.js と Atom Shell 両方の API を使える。

雰囲気をつかむには入門ページの[サンプルコード](https://github.com/atom/atom-shell/blob/master/docs/tutorial/quick-start.md) を眺めると良い。

```js
var app = require('app');
var BrowserWindow = require('browser-window');

...

var mainWindow = null;

app.on('window-all-closed', function() {
  if (process.platform != 'darwin')
    app.quit();
});

app.on('ready', function() {
  mainWindow = new BrowserWindow({width: 800, height: 600});
  mainWindow.loadUrl('file://' + __dirname + '/index.html');
  mainWindow.on('closed', function() {
    mainWindow = null;
  });
});  
```

この例だとあまり node っぽさがないけど、それでも `rquire()` がネイティブに動くのは
Node.js のおかげ。

GUI プログラムの定めとして Atom Shell のメインループは Chromium 側が握ってしまう。
なので Node.js でサーバを書くように自分でループを始めることはできない。
かわりにイベント駆動で書く。つまり Atom アプリケーションの基本的なパターンは、

 * 初期化が終わったタイミングの `ready`イベントでウィンドウを作り、好きな HTML を表示する。
 * HTML の中から飛んでくるメッセージに応じてなんかするコードを書く。

となる。

さて、念のため復習: Chromium ベースのアプリケーションはページの中身を独立したプロセスで動かす。
そのプロセスを *renderer* と呼ぶ。
renderer プロセスを起動するのは browser プロセス…だけれど、
ブラウザでない Atom はこれを *server* と呼んでいる。

Atom Shell のアプリケーションは、というか Atom は、
おおむね JavaScript の [SPA](http://en.wikipedia.org/wiki/Single-page_application) として書かれている。
だから大半のコードはページの中、renderer 側で動く。Server 側のコードは小さい。

これはブラウザである Chrome と比べると面白い。
Chrome の中を見ると、renderer で動くコードはほとんどが Blink。
残りのコードはだいたい browser (Atom Shell の server) 側で動く。
Blink 以外は renderer の外が多い。

この違いはどこからくるのか。まず Chrome の UI は renderer の外側で、C++ を使い書かれている。renderer の中に HTML と JS で UI を作る Atom とはまずそこが違う。
たとえば Atom のタブは renderer の中の HTML で、
Chrome のタブは browser 側の C++ だ。
結果として Atom のタブは切り離して他のウィンドウに移したりできない。
その前提でアプリケーションが作られている。

もう一つの違いは sandbox. Chrome の renderer は OS の sandbox によって保護されており、ファイルやソケットを読み書きするなど OS の機能をほとんど使えない。
Atom Shell は sandbox を使っておらずしかも Node.js がリンクされている。
だから renderer の裁量が大きい。割となんでもできる。
なにしろ DOM と Node.js を両方同時につかえる。ちょうべんり。
Atom の package (プラグイン) は基本的に renderer 側で動くコードしか書けない。
けれど野放しな Node.js のおかげで特に不自由しない。

## Node.js とイベントループ

Chromium に偏った目で Atom Shell を見ると、いくつかの疑問が頭をよぎる。
思いついた順に三つ調べてみたので記録しておく。

その１: どうやって Node.js を Chromium に繋いでいるんだろう?

Node.js は [libuv](https://github.com/joyent/libuv) をイベントループに使う。
Chromium のメインスレッドはプラットホーム毎の UI ツールキットがイベントループを握っている。
二つのイベントループをどう共存させたものか。素朴に考えるとそれぞれにスレッドを持たせたくなるけれど、
Node.js と Chromium が別のスレッドで動いてしまうと
Node.js のスレッドから Content API を呼んだりその逆をしたりできなくなる。

そこで Atom Shell は Node.js のイベントループを二つのフェーズにわけ、
一部の処理だけを別スレッドに移すことで二つのイベントループを単一スレッドに押し込んだ。
具体的には libuv でファイルハンドルを待ちブロックする部分だけを専用のスレッドに追い出す。
そしてハンドルがシグナルされブロックから抜けた直後にメインスレッドへ処理を戻して
続きの処理、つまり JavaScript のコードを動かす。

要するに別スレッドで `epoll_wait()` して続きはメインスレッドで引き取る。
そしてメインスレッドの処理が終わったらふたたび別のスレッドでハンドルを待つ。

[結果のコード](https://github.com/atom/atom-shell/blob/master/atom/common/node_bindings.cc)は簡単なものだけど、
そもそもこう書けると思いもしなかった外野の私は驚いた。
ループしたらさいご戻ってこないフレームワークが多い中、
libuv や Node の API はループを自分で持たず切り出しており、
おかげでこんな小細工ができる。えらい。

## IPC

疑問その２: IPC はどうしてるの？

プロセスがわかれている以上、renderer と server の連絡には工夫が求められる。
Chrome はパイプでプロセスを繋ぎ、その上を流すメッセージで連絡すなわちプロセス間通信(IPC)をする。
Chromium はプロセスの間に一本しかパイプを持たない。多重化はユーザ空間が頑張る。

Chromium の C++ レイヤはいまいち頑張りが足らず、
マクロとかでなんとなく多重化や直列化を扱っている。けっこうめんどい。
なぜ Protobuf を使わない...と Chromium 開発者の二人に一人くらいは思っている(気がする)。

もうひとつの面倒。Chromium の IPC は基本的に 1-way である。メッセージに戻り値がない。
ただし例外として *SyncMessage* という仕組みがあり、
この特別なメッセージだけが戻り値を扱える。

`SyncMessage` には性能上の懸念がある。
値が戻ってくるまで呼び出し側プロセスのイベントループを止まてしまうからだ。
そのためどうしても必要な時だけ使う荒技扱いされている。
たとえば JavaScript からクッキーの値を読むなんてのは `SyncMessage` のわかりやすいユースケース。
クッキーの値は browser(server) 側にあるから IPC が必要だけれど、
JS 側の API が同期的なためブロックして待たざるを得ない。

Atom Shell の `ipc` モジュールは Chromium の IPC を JavaScript に公開する。
概ね下のレイヤと同じデザインに倣っている。ただし JS のおかげで色々ラク。
たとえば多重化は Node.js の `EventEmitter` 風に書けるし、直列化は JSON を使えばいい。

Atom Shell の `ipc` も `SyncMessage` をサポートしている。
だからその気になれば `SyncMessage` をブロックして待てばよい。
Atom のパッケージなら性能にうるさいレビュアがでてきて非同期に直せと怒られはするまい。
遅くなりますけどね・・・。

## Remoting

怒られるどころか、Atom Shell には `SyncMessage` の利用を後押しする機能がある。
[remote](https://github.com/atom/atom-shell/blob/master/docs/api/remote.md) モジュールだ。

Atom Shell の `remote` モジュールは、低レベルな `ipc` モジュールの上に分散オブジェクトを実装している。
21 世紀のエディタを名乗るアプリケーションの中で
分散オブジェクトのような古代のテクノロジーを目にするとびびる。
[dRuby](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/drb/rdoc/DRb.html)
が最後だとおもってたよ...

ただ JS らしく力の抜けた作りなのはよい。コードは 1000 行もない。シンプル。
JS の `object` と `function` にはスタブを作り、
それ以外 (`string` や `number`) はコピーする。`array` は浅いコピー。
(実装: [rpc-server.coffe](https://github.com/atom/atom-shell/blob/master/atom/browser/lib/rpc-server.coffee), [remote.coffee](https://github.com/atom/atom-shell/blob/master/atom/renderer/api/lib/remote.coffee))

面白いのは実装の一部に素の JavaScript にない v8 の機能を使っていること。
たとえば JavaScript には Java の finalizer にあたる機能がない。
でも分散 GC をするならスタブの寿命を別プロセスに伝えたい。finalizer が欲しい。
そして v8 には finalizer 相当の機能がある。
Atom Shell は v8 の C++ API を JS に公開し、`remote` からそれを使っている。
拡張部分は [v8util](https://github.com/atom/atom-shell/blob/master/atom/common/api/atom_api_v8_util.cc) モジュールにまとめられている。

この `remote` モジュールのおかげで renderer でしか動かないはずの Atom パッケージも browser の API を呼びたい放題。ちょうべんり。特に Atom パッケージのコードを書いている限り server 側ではコードを動かせないから自然と `remote` モジュールを使うことになる。 `ipc` を使いたくても server 側を書けないからね。

そして `remote` 経由で取得したオブジェクトへのメソッド呼び出しは値を返すことができる。ここで `SyncMessage` が使われる。Chrome の開発者が満身創痍になりながら C++ で非同期なコードを書いている一方、
Atom の開発者はらくらく非同期言語 JavaScdript から容赦なく IPC をブロックしているのだった。
世間は厳しい。Server 専用の API は少ないので、実際の出番は少ないと思うけど。

それにしてもかつて [Mico](http://www.mico.org/) を読もうとして分散オブジェクトわかんねーと絶望したのち
dRuby を読みこれならわかると感動したのも昔の話、いまは 1000 行未満か。
プロセス間通信とマシンをまたぐ分散じゃだいぶ複雑さが違うとはいえ、
世の中進歩してるなあ・・・と JavaScript を読んで思うとは想像しなかったなあ・・・。
見事でしたと[書いた人](https://github.com/zcbenz)を讃えておこう。

## セキュリティ

さいごの疑問: セキュリティはどうなってるの？

結論からうと、Atom Shell は特にセキュアでない。テキストエディタのセキュリティについてどうこう言うのは不毛な気もするけれど、ベースとなっている Chromium はまあまあセキュリティにうるさい子。Atom や Atom Shell がそれをどう解釈したかは
一度くらい気にしても良かろう。

Node.js が使えることからもわかるように、Atom Shell は renderer のサンドボックスをつかっていない。だから悪意のあるページを renderer で表示するのは安全でない。
セキュリティホールを突くまでもなく Node.js の機能でファイルが読める。

エディタで悪意のあるページってなんだよ、と思うかもしれない。
でも Atom の UI は HTML で作られているので、
たとえば `iframe` を使って別のページを表示することができる。
そういうことをするパッケージもちらほらある。
実際に Atom のリリース直後は `iframe` の中でも容赦なく Node.js の API が使えた模様。
今はさすがに直っている。

`iframe` より厄介な XSS も一応おこりうる。最近の Atom は [CSP](http://www.html5rocks.com/en/tutorials/security/content-security-policy/) に対応した。

Atom Shell は `iframe` よりもう少し融通の利く `webview` タグも[用意している](https://github.com/atom/atom-shell/blob/master/docs/api/web-view-tag.md)。
`webview` は表示しているページが別プロセスで動く。なのでちょっとマシ。
セキュリティはさておき性能上の利点はあるとおもう。

ちなみにこの `webview` は Custom Elements として実装されており、
Shadow DOM の中にある `object` タグでは browser plugin というなんだそれ的コードが動いている。
Atom Shell の発明ではなく、Chrome Apps 由来の機能。

個人的には Atom Shell で Phantom.js のようなスクリプタブルブラウザを作れないかと思っていた。
この `webview` をがんばって育てれば何か楽しいことができるかもね。




以上三点、面白かったところ中心に書いてみました。
とくにオチはありません。強いて言うならみんなもつかおう Web Components.
