---
layout: post
title: "Polymer と Web Components"
date: 2013-05-19 16:52
comments: true
categories: 
---

![pichai](https://lh4.googleusercontent.com/-9zZUBHxBgGQ/UZQRtN01GRI/AAAAAAAANcU/8LQVNUI4o6U/w772-h515-no/IMG_0046.JPG)

先週はサンフランシスコで勤務先の年次博覧会が催され、中には自分と近いプロジェクトを紹介するセッションもあった。
いい機会なので便乗して宣伝してみたい。自主会社員活動につき勤務先の見解と違っても見逃してください。

さて件の年次博覧会、[ウェブ開発者向けの講演の一つ](http://www.youtube.com/watch?v=0g0oOOT86NY)で
**[Polymer](http://www.polymer-project.org/)** という新しい JavaScript UI フレームワークが公開された。
[Closure](https://developers.google.com/closure/), [GWT](https://developers.google.com/web-toolkit/), [Angular](http://angularjs.org/) ときて
また別のフレームワークかよ...とぼやく人の気持ちもわかる。でもそれほど被るものでもないから見逃してほしい。

なるべく多くのブラウザで動かそうとする既存のフレームワークと違い、
Polymer は新しいブラウザの機能を使い倒すことで強力なフレームワークを作ろうとしている。
別に特定ブラウザでしか動かないわけじゃない。ただ将来そうした新しい機能が各種ブラウザに備わる日を見越し、
そのときベストに動くものを作ろうとしている。

といってもピンとこないとおもうので、まずは Polymer が期待しているブラウザの新しい機能をざっと紹介してみよう。

## Web Components

Web Components は新しく提案されたウェブブラウザ向け API 一式の総称。
[Custom Elements](http://www.w3.org/TR/2013/WD-custom-elements-20130514/), 
[HTML Imports](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/imports/index.html),
[HTML Templates](http://www.w3.org/TR/2013/WD-html-templates-20130214/), 
[Shadow DOM](http://www.w3.org/TR/2013/WD-shadow-dom-20130514/) という各種 W3C 提案をまとめて Web Components という。

なぜこれを Web Components と呼ぶのかはあとで考えるとして、
それぞれの提案がどんな機能をもつ API なのかをざっと眺めてみよう。

**[Custom Elements](http://www.w3.org/TR/2013/WD-custom-elements-20130514/)** は
ウェブ開発者が HTML に独自のタグを追加できる仕組み。
こんなかんじで JavaScript から新しいタグを登録する。

```javascript
document.register('x-greeting', {
    prototype: Object.create(HTMLElement.prototype, {
        hello: {
            get: function() { return "Hello!"; },
        },
        ready: function() {
            this.innerHTML = "<div>Hello, Custom Elements!</div>";
        }
    })
});
```

これで HTML パーサが `<x-greeting>` を処理するようになる。
JavaScript の `document.register()` API を使う代わりに `<element>` タグを使う宣言的な書式もある。
引数に渡されたオブジェクトの `ready` 関数は、タグ(Element)が作られるたびに呼び出される。コンストラクタっぽく使える。

別の見方をすると、
Custom Elements はブラウザの仕組みを使って [Facebook の](http://developers.facebook.com/docs/reference/plugins/like/) `<fb:like>` みたいのを書くための仕組みだと考えてもいい。
ブラウザが手伝うから微妙なイベントのタイミングなどをやりくりする必要はなくなるし、DevTools などでデバッグするのも楽になる。

**[HTML Imports](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/imports/index.html)** は別ファイルに定義した Custom Elements をページ内に読み込む仕組み。
Custom Elements が新しいクラスを定義するとしたら、HTML Imports はプログラミング言語の `require` や `import` みたいなもの。

HTML をインポートするには `<link rel="import" href="mycomponents.html">` などと書く。
なぜ JavaScript ではなく HTML を読み込むのか。それは後述する HTML Templates や Shadow DOM と組み合わせ、HTML や CSS の断片を Custom Elememts の定義に使いたいから。
HTML や CSS の処理をブラウザに任せればそれだけ速く動くし、なにより JavaScript のコードに雑音が混ざらない。
なお HTML Imports で読み込んだ HTML は API で DOM ごと触れるようになる。

**[HTML Templates](http://www.w3.org/TR/2013/WD-html-templates-20130214/)**. 名前からはテンプレートエンジンを想像するけれど、
テンプレートエンジンそのものではない。テンプレートエンジンの実装に使うちょっとしたツール `<template>` タグを定義する。

[Mustache](http://mustache.github.io/) に代表される JavaScript 製テンプレートエンジンには、テンプレートの文字列を `<script>` タグに押しこむハックがある。
これはまあまあ便利なのだけれど、たとえば `<script>` をネストできないなどのしょぼい制限がある。
そして最終的に innerHTML をつかって HTML をパースするためアプリの動きを遅くする。

HTML Templates に定義された `<template>` タグでテンプレート用の HTML を囲んでおくと、
その中身は文字列ではなく HTML として解釈される。要するにブラウザがパースしておいてくれる。おかげで `<script>` ハックにみられる問題がおきない。
そしてテンプレートの HTML はページ本体の DOM とは切り離されており副作用がない。
たとえば `<img>` や `<video>` を書いてもロードはおこらないし、`<style>` は適用されず `<script>` は実行されない。
HTML Templates の助けがあれば、クライアントサイドのテンプレートエンジンをもっとうまく作れる。

**[Shadow DOM](http://www.w3.org/TR/2013/WD-shadow-dom-20130514/)** はちょっとややこしい。
ある DOM 要素のレンダリング結果を、その要素が持つ DOM のサブツリーとは独立に与える仕組み。
見た目を定義するという意味で CSS に似てるけど, 見た目の定義に DOM 自体を使う。まあ野次馬目的には理解しなくても平気です。
興味があるひとは [チュートリアル](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom/) でも眺めてみてください。

Custom Elements, HTML Imports, HTML Templates, Shadow DOM. これを組み合わせると、
DOM とシームレスにつながる UI 部品「コンポーネント」を作れる。だからあわせて Web Components と呼ぶ。

## Model Driven View

Polymer にとって Web Components と並び重要なコンセプトが **[Model Driven View](http://www.polymer-project.org/platform/mdv.html)**、略して **MDV**。
世間では似たような仕組みをよく Data binding と呼んでいる。データ(モデル)を書き換えると自動的に表示(ビュー)が更新され、
更新された UI を操作すると結果がモデルに書き戻されるされる、みたいな仕組み。

MDV 自体は(今のところ)ウェブ標準ではなく単なる JS のライブラリだけれど、それを実現するためのパーツは標準になっている/なりつつある。
まずモデル(JavaScdript オブジェクト)の変更を捉えるための **[Object.observe](http://wiki.ecmascript.org/doku.php?id=harmony:observe)** というJavaScript API がある。
Objective-C の [KVO](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html) みたいなもんだとおもえば大体あってるはず。
逆にビューの変更を見張るには **[Mutation Observer](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver)** を使う。
これは悪名高き DOM の [Mutation Event](https://developer.mozilla.org/en-US/docs/Web/Guide/DOM/Events/Mutation_events) をマシにしたもの。
DOM ツリーの変更をコールバックで監視できる。

MDV ではこうしたフックを使い、ビューとモデルの変更を相互に反映しあう。
記法は馴染みのある二重ヒゲカッコを使う.

...馴染みがありすぎて Octopress の markdown にコピペできませんでした...現物は[リンク先](http://www.polymer-project.org/platform/mdv.html)をみてください。

##  Pointer Events, Web Animations

Web Components と MDV は UI をつくるための枠組みだと言える。
キュンキュン動く UI をつくるためにはもう少し足りないものがある。
**[Pointer Events](http://www.w3.org/TR/pointerevents/)** と **[Web Animations](https://dvcs.w3.org/hg/FXTF/raw-file/default/web-anim/index.html)** がその不足を補う。

**[Pointer Events](http://www.w3.org/TR/pointerevents/)** はタッチとマウスを一つのプログラミングモデルで扱うための提案。
マウスをサポートしている点、リバースエンジニアリングでなくオリジナル書きおろしなところが [Touch Event](http://www.w3.org/TR/touch-events/) と違う。
**[Web Animations](https://dvcs.w3.org/hg/FXTF/raw-file/default/web-anim/index.html)** は CSS Animations と CSS Transitions と SVG Animations を
統合してクールな API にしようという、野心的な標準。

いまどきタッチ UI やアニメーションがしょぼいのは論外...
なんて話をターミナル内の Emacs で書いていると悲しい気持ちになりますね...

## Polyfilled Standards - platform.js

こんな新しい API に依存してしまい、一体どのブラウザなら動くのか。そう不安になるかもしれない。
この不安というか現実的な懸念に応えるため、Polymer は **[platform.js](https://github.com/Polymer/platform)** という Polyfill ライブラリを用意している。
platform.js は該当 API を JavaScript で **再実装(=Polyfill)** し、ブラウザにまだない機能を補ってくれる。
あくまで代替品のためネイティブほど速くないしところどころボロがでる。でもわかって使えば悪くない出来ではあるらしい。
Shadow DOM や Web Animations なんかは傍目から見ると polyfill できそうにないけれど、そのへんは JS ニンジャ技巧でなんとかしているようす。

platform.js はそれ単体でも使える。
だから新しい標準 API には興味があるけど Polymer のフレームワークを使いたくない人は platform.js だけ持って行っても良い。

## Kernel, Elements and Applications

さてここからが本題。Polymer のフレームワークは、 platform.js によって polyfill された新しいブラウザ API の上に作られている。
フレームワークはまず、これらの API 群をうまく一つの枠組みで使うための中核的な API **[polymer.js](https://github.com/Polymer/polymer)** を定義している。
Facade みたいなものだと思えばいい。polymer.js は Kernel とも呼ばれる。

そして色々な UI 部品そのほかはこのカーネルの上に実装されている。
個々の部品(Element) の実装は **[polymer-elements](https://github.com/Polymer/polymer-elements)** や 
**[polymer-ui-elements](https://github.com/Polymer/polymer-ui-elements)** といったサブプロジェクトに含まれている。

Polymer の UI 部品にはサイドバーなんかもあり、まあまあ今風でかっこいい。
検索会社製スマホアプリの雰囲気にちょっと似ている。
コードにはサンプルアプリも入っており、動かしてみると雰囲気がわかる:

```
$ git clone --recursive https://github.com/Polymer/polymer-all.git
$ cd polymer-all
$ python -m SimpleHTTPServer
```

こうしてホストしたファイルから `http://localhost:8000/projects/pica/index.html` を開けば "Pica" というニュースリーダーっぽいデモが動く。

![pica](https://lh4.googleusercontent.com/-kfzeoWAhX1c/UZjBI4ymhWI/AAAAAAAAYv8/g2JQd0DVWXM/w916-h515-no/20130519pica.png)

## Polymer の身の上

大雑把な紹介はこんなところにしておこう。
私のようなレガシー C++ プログラマがヒャッホイ便利だぜーみたいな話を書いてもまったく説得力がなさそうだから、
ヒャッホイしたい人は [Getting Started](http://www.polymer-project.org/getting-started.html) でも読んでください。

かわりに Polymer や Web Components がどんな問題意識に基づいているのか、私の理解を説明してみたい。
なぜわざわざ新しいフレームワークを作ろうとする事情を、少しは納得できるかもしれない。

### Web Components - UIView

さて、話は Web Components からはじまる。

ブラウザの API (DOM) は、もともとアプリケーションの UI を作るためのものではない。
そのせいで JavaScript プログラマは苦労してきた。その苦労をなんとかしたい、ブラウザにまともな UI 開発の API を持たせたい...
そんな願いを叶えるために Web Components が生まれた。

JavaScript プログラマはずっとこの問題に取り組んできたのだけれど、
ブラウザに GUI 開発の基盤がないせいでみなが別々に必要な足場を再発明する羽目になり、
結果として混ぜるな危険のフレームワークが乱立した。ライブラリ同士を混ぜられないせいで、
いくら GUI ツールキットが現れても互いに生態系を作ることができなかった。

足場のある世界を見ると、たとえば iOS なら UIView, あんどろなら View や Activity という拡張可能な UI の単位を持っているのがわかる。
サードパーティはこの単位を足がかりに再利用可能な UI 部品を作ることができる。

ブラウザは DOM が UIView みたいなものだけれど、あいにく後から拡張できない。Web Components はその DOM を拡張可能にする。
そういう意味で、 Web Components は **ウェブの UIView** を目指しているとも言える。
Web Components で作られた GUI 部品は混ぜることができる。非互換の砂漠をライブラリの茂る緑に変えたい、
Web Components にはそんな願いがある。

UIView の比喩を続けるなら、 MDV は KVO を、 Web Animations は Core Animation を目指していると言えなくもない。
これは Objective-C スタックをぱくりたいわけではなく、GUI のプラットホームには最低限必要な機能があるということ。
だから iOS でなくあんどろや .NET の語彙でも対応関係を説明できるとおもう。

HTML や XML のようなマークアップを発展させ拡張可能な UI を作る技術は、
WPF から Flex まで星の数ほどある。中でも Web Components は [XBL](http://www.w3.org/TR/xbl/) という技術を先祖にもっている。
10 年以上前、Mozilla が XUL のお供に作った XML ミタメ定義言語(のようなもの)が XBL だ。
ただ XBL は多機能すぎ、また XML に傾倒しすぎていた。
そこで XBL を簡素化し、10 年来のウェブの変化や JavaScript の隆盛を踏まえ
今風に再発明したものが Web Components である。
API は新しく仕切りなおされたため、先祖の面影を伺うことはほとんどできない。
でも Web Components 関連標準の謝辞は XBL を参照しているし、Shadow DOM のコンセプトも XBL に由来する。

### Polymer - UIKit

話がそれた。

そんなかんじで数年前から Web Components の開発が始まった。
ただ実際に作ってみると案外むずかしい。API の良し悪しを判断する材料がなく、どんな機能が必要かの見通しも悪い。
いってみれば Web Components はフレームワーク作者のためのメタ・フレームワーク。
これほど抽象的なものを具体例なしに開発するのは無理がある。
利用者たるウェブのエンジニアからみても、 Web Components を使ってくださいと言われたところで
抽象的すぎてピンとこない。具体的に使えるモノや指針がほしい。

一方その頃、ブラウザでモバイル向けのアプリケーションを書くのはしんどすぎるという懸念が
ブラウザやウェブ開発の未来を暗く覆っていた。
理由は色々あれど、その一つに開発ツールやフレームワークが乱立するなか
「よいアプリケーションをつくるための定番」の不在が指摘されていた。
これで作ればとさくっとできますよ、といえるツールキットが欲しい。

そのために何ができるか、いっそ定番になれるツールキットを作ればいい？
そう考えた勤務先の一部モバイルウェブ好きは、
ブラウザの連中が作っている Web Components に目をつけた。
これを使って書けば単なる再発明よりマシになりそうだし、
変なワークアラウンドも少なくて済む。それよさそうじゃね？
Web Components にとっても dogfood をしてくれる具体的なプロジェクトは渡りに船だ。
実際のユースケースからフィードバックを受けられる。

...てなかんじで話が進んで(だいぶ想像で補ってますが結論はだいたいあってるはず) Polymer がうまれ、
Web Components の開発者たちもそれを後押しすることになった。
Polymer のコンポーネントは responsive に作られていて、モバイルとデスクトップの両方で動く。

標準技術である Web Components と違い、Polymer は意見を持ったフレームワークだ。
Polymer には通底するデザイン言語がある。そのしきたりに合わせて UI 部品を揃えようとしている。
Polymer の流儀にならってアプリケーションをつくれば簡単に一貫性のある UI ができる、
そんなフレームワーク、ツールキットになろうとしている。
Web Components が UIView だとしたら、Polymer は **Web Components の枠組みで作られた UIKit 相当** だと言えるかも知れない。
まあ UIView と UIKit みたいに一体化してるわけじゃないから、やや大げさ過ぎではある。

## 未来をつくる

![screen](https://lh3.googleusercontent.com/-er5XAl8-KJs/UZlj1FHNwwI/AAAAAAAAYxM/QW53jfoySYs/w745-h559-no/P1090585.JPG)

Polymer は始まったばかりの若いプロジェクトだ。まだ実戦に使えるかんじじゃない。
フレームワーク自体も流動的だし、アセットパイプラインもない。
ブラウザ API の実装も揃っていないし、既にある実装もずっと速くする必要がある。
すぐに使うフレームワークを探しているなら
[Angular.js](http://angularjs.org/) みたいに完成されているものを使う方がいい。

どちらかというと、Polymer は Web Components やその仲間たちと共にウェブ開発の未来を定義しようとしている。
ウェブアプリケーションのフロントエンドはこうやって作るものだ。
ツールキットを通じて、そんな意見を示そうとしている。

まだ荒削りなものを公開したのは、
コミュニティと一緒にプロジェクトを育てていこうとしているのだとおもう。
一方的にポイっと公開されたフレームワークなんて誰も使わないだろうから。
コードもふつうに [Github](http://github.com/Polymer/) にあり、
[pull request 歓迎](https://github.com/polymer/polymer/blob/master/CONTRIBUTING.md)らしい。
[メーリングリスト](https://groups.google.com/forum/?fromgroups=#!forum/polymer-dev)もある。

とはいえ未来がいつまでも未来のままでは困る。これをさっさと現実にするのが開発者の仕事。
私は今の会社に入って以来、バグとり以外の時間はだいたい Web Components の実装を手伝っているんだけれど、
ぶっちゃけフレームワークよりブラウザ API の実装が遅れがちなので申し訳なくおもいつつ日々働いております...
けっこう奥のほうをガチャガチャ書き換えないといけなくて大変なのよね。
Blink になってからは比較的遠慮なくガチャガチャできるようになったので心労は減ったけれども。

## 今をなおす

始まったばかりとはいえ Polymer プロジェクトの影響は大きい。
その影響で Web Components は仕様も実装も大きく磨きがかかった。

たとえばあるとき Polymer の polyfill をネイティブ実装に切り替えて
デモアプリを動かしたところ表示が乱れ、更にはブラウザがクラッシュした。
ページロードが異常に遅いなんて問題もみつかった。
実際のアプリケーションを通じて初めてみつかるエッジケースの数々を Polymer は暴きだし、
私や近隣の同僚は慌ててそれを直した。Polymer の実装が進むたびにそんなバグがやってくる。私達はそれを直す。

また標準で定義された API の不備不足も沢山みつかり、W3C のメーリングリストやバグトラッカーを賑わしている。
頑張って定義した複雑な挙動があっさりダメだしされたり、逆に必要だと思っていた API が実は全然いらなかったり。
実際のユースケースを元にした苦情だけに説得力がある。

ブラウザのダメさを回避するのではなくブラウザを直す。仕様も直す。
ここに従来のフレームワークと Polymer の違いを見ることができる。

## The New Gang of Four

![gangoffour](http://farm4.staticflickr.com/3297/3242771529_f4dd5a2c7e_b.jpg)

Polymer に限らず、ウェブアプリケーションの書き手が標準策定に強く関与する流れが W3C に広まっている。

この新しい動きを象徴する出来事が、少し前に開かれた [W3C Technical Architecture Group](http://www.w3.org/2001/tag/) の選挙で起きた。
JavaScript 界隈の開発者やその一味が新しい TAG のメンバーとして選出されたのだ。
XML 時代を経て歪んでしまったウェブ標準のデザインをアプリ世代のウェブにふさわしく描き直そうと、彼らは息巻いている。

どういう面子が選ばれたのか、野次馬のためにちょっと紹介してみよう。
まずは我らが **[Yehuda Katz](http://yehudakatz.com/2012/12/07/im-running-to-reform-the-w3cs-tag/)** -
Rails, jQuery のコミッタで、最近は [Ember.js](http://emberjs.com/) をやっている。
次が **[Alex Russel](http://infrequently.org/2012/12/reforming-the-w3c-tag/)** - 
[Dojo Toolkit](http://dojotoolkit.org/) を作ったあと、最近は Chromium 関係で色々やっている。
Web Components やるぞオラーとか言い出したのもこのひとだった気がする。
**[Anne van Kesteren](http://annevankesteren.nl/)** はちょっと前まで Opera にいて最近 Mozilla に移ったウェブアプリ寄りの標準書き。
DOM にも詳しい。**[Marcos Cáceres](http://marcosc.com/2012/12/w3c-tag-elections/)** も Opera から Mozilla に行ったエンジニアだそうな。
Opera はもともと HTML5 を始めたくらいだから、実利的ウェブ標準に関して意見のある人が多かったのかも。
Mozilla は昔からウェブアプリを推している。

この四人、[The New Gang Of Four](http://briankardell.wordpress.com/2012/12/07/the-new-gang-of-four/) と
呼ぶ人がいるくらいには活躍が期待されている。 
XML 時代にセマンティック宇宙飛行へ旅立ってしまった W3C と、アンチテーゼとして登場した HTML5。
宇宙飛行向けに盛り過ぎた本体に取り急ぎ必要な API を継ぎ接ぎしてカオスになった Web のアーキテクチャを正し、
アプリケーションプラットホームとしてスケールできるよう立て直していく。
そういう大きな流れの中に Web Components や仲間たちを位置づけると、
今のウェブが...すくなくとも Gang Of Four とその支持者たちが...目指しているところも少しは腑に落ちやすくなるかもしれない。

## 標準の温度

Polymer の依拠する未来の API たち、実装の見込みはどうなのだろう。
ブラウザ開発元の態度は個々の API ごとに温度差がある。

Web Components はもともとも Chromium の人が言い出したものではあるものの、最近はそれなりに受け入れられつつある。
たとえば Mozilla は Web Components の中でも Custom Elements に重きをおいており、既に一部を実装している。
そして実装した API を使うべく [X-Tag](http://www.x-tags.org/) というフレームワークを開発している。
[Mozilla Hacks の blog](https://hacks.mozilla.org/2013/05/speed-up-app-development-with-x-tag-and-web-components/) に簡単な紹介があった。
X-Tag の開発者は Polymer や W3C にある関連メーリングリストの常連で、よく Polymer チームと意見交換をしている。
Polymer のツリーにも X-Tag との相互運用デモが入っている。

[HTML Templates](http://www.quackit.com/html/templates/) のエディタには Microsoft の人が参加している。
そして [Pointer Events](http://www.w3.org/TR/pointerevents/) に至っては仕様のみならず 
[Blink の実装まで](https://groups.google.com/a/chromium.org/d/msg/blink-dev/K1qk6qZWgIc/4PxUvSibPTsJ) Microsoft の手による。
私も便乗で半年くらいシアトル出張して IE に Custom Elements 実装したいなあ行くなら 8-9 月あたり希望です微塵も呼ばれてませんが...

MutationObserver は既に Firefox と Chromium の両方で動いている。
[Web Animations](https://dvcs.w3.org/hg/FXTF/raw-file/default/web-anim/index.html) は Chromium, Mozilla, Adobe が共同策定している。

議論が決着していない仕様もあるし、全体的に慎重な開発元もある。全てが順調というわけではない。
ただウェブアプリの生産性をなんとかしたい点にはみな概ね同意しているから、
人々が polyfill を通じて支持を示せば実装も広がってゆくだろうと私は楽観している。
未来は明るくしとかないとね。

## まとめ

Polymer と Web Components についてやじうま向けに説明してみました:

 * Polymer は新しいブラウザの API を前提にあるべきウェブ開発の姿を示す試み。
 * ブラウザの実装がもたもたしてる(ごめんなさい)分は polyfill でカバー。
 * Polymer と Web Components は互いに励まし合うズッ友。
 * Polymer 周辺の標準はウェブのデザインを時代に引き寄せたいギャングの仕業。
 * 当方クラッシュ直し以外の仕事も少しはやっております。

写真:

 * http://goo.gl/a3I0a
 * http://www.flickr.com/photos/dineshobareja/3242771529/