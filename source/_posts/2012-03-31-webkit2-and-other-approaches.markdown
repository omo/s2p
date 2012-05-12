---
layout: post
title: "WebKit2 と愉快な仲間たち"
date: 2012-03-28 21:44
comments: true
categories: 
---

![irrelevant](http://farm4.staticflickr.com/3013/2452068666_2756cac273_z.jpg)

ある [ニュース記事](http://monoist.atmarkit.co.jp/mn/articles/1203/26/news001.html)を同僚に教わった。
この記事によるとタッチデバイスの会社は WebKit2 に対応しているのに検索の会社は旧バージョンにとどまっており、HTML5 に課題は多いのだそうな。
そりゃ課題は常に山積みだよね...と思っていたら[記事は誤解だと別の同僚が説明を書いている](https://plus.google.com/116445437433162945363/posts/26zsqLSvA9g)。

リンク先の記事はさておき、世間の関心をいまいち集められていない気がする WebKit2 についてざっと説明をしてみたいとおもう。
この記事を読み終われば WebKit2 と Chromium WebKit, Webkit1 の違いを知ったかぶれるようになる予定。

WebKit2
-------------

WebKit2 は [2010 年の 4 月にアナウンスされた](https://lists.webkit.org/pipermail/webkit-dev/2010-April/012235.html) 
WebKit の新しい API レイヤで、Mac 版 Safari などが使っている。
大きな特徴はレンダリングエンジンを別プロセスで動かせること。 Chromium でやっているのと同じようなものだと思えばいい。

WebKit2 は WebKit プロジェクト全体の書き直しやメジャーバージョンアップではない。
プロジェクト名の WebKit (WebKit Open Source Project) と API レイヤの WebKit (WebKit API) はまぎらわしく、よく人々を混乱させている。
同様に WebKit2 は WebKit2 API であり, WebKit2 Open Source Project というものはない。 
API の下にはレンダリングなんかを担当する WebCore や JavaScript 処理系の JavaScriptCore がある。
従来の WebKit API も WebKit2 API もこれらを変わらず使っている。

![diagram](https://lh4.googleusercontent.com/-nWC3lcOc48E/T3fDgvHisOI/AAAAAAAAEfc/rMwa1CPQyDo/s640/P1010424.JPG)

ついでに従来の WebKit API ...便宜上 WebKit1 と呼んでおこう... は無くなってはいない。引き続き保守されている。
WebKit1 は MacOS でいうと [WebView](http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/WebKit/Classes/WebView_Class/Reference/Reference.html),
iOS でいうと [UIWebView](http://developer.apple.com/library/ios/#documentation/uikit/reference/UIWebView_Class/) なんかのこと。
WebKit2 の API は WebKit1 の API と全く互換性がない。 
各種 SDK に含まれる WebKit1 が WebKit2 にとって代わられることは当面無さそうに見える。
だから自分の書いた iOS アプリが OS アップデートで突然マルチプロセスになったりはしない...とおもう。しばらくは。

WebKit1
---------

登場した時系列で話を進めるのが腑に落ちやすいと思うので、まずは WebKit1 と Chromium WebKit の違いからはじめたい。

先に書いたとおり、 WebKit1 は WebView などのクラスをふくむ API を指す。
伝統的に WebKit1 は各プラットホーム/ライブラリの一部としてすんなり動くようデザインされてきた。
たとえば iOS や OSX での WebKit1 は Cocoa にかっちりと組み込まている。
C++ で書かれた WebCore を Objective-C が包み込み、 `NSView` や `UIView` を継承した表皮を形作る。
API も完全に Cocoa. `NSURL` や `NSURLRequest` みたいな Cocoa オブジェクトを受け付ける。
Cocoa プログラマは Interface Builder で並べた `WebView` に URL を渡すだけで
自分のアプリケーションに WebKit を組み込める。かんたん便利。

Qt, GTK といった OSX 以外の WebKit1 もこの流儀に従っている。 
Qt には Qt C++ で書かれ [QWidget](http://qt-project.org/doc/qt-4.8/QWidget.html) を継承した外殻がある。
Qt Designer をつかえば自前の Qt アプリケーションに組み込むのも簡単だ。たぶん。ためしたことないけど。
同様に GTK ならシグナルを張り巡らせた GObject C の(中略)で Glade を(以下略)。

このプラットホーム親和性は他のブラウザに対する WebKit を特徴づけている。
Firefox のエンジンである Gecko はどちらかというとそれ自体がプラットホームぽくなっており、
既存の GUI アプリに組み込むのは WebKit ほど簡単でない。端的にいうと Cocoa や Qt についてこない。
その対価として Gecko というプラットホームの上で作られたアプリケーションは OS を問わずだいたい動く。

自身の OS を強化したいタッチデバイスの会社とブラウザのレイヤで OS をコモディティ化したかった[かつてのブラウザ会社](http://en.wikipedia.org/wiki/Netscape)。
WebKit と Gecko の違いはスポンサーおよび元スポンサーの意向をそのまま反映しているように見える。
(※昔話です。現在の[ブラウザ法人](http://www.mozilla.org/foundation/)の方針を説明するものではありません。)

Chromium WebKit
---------------------

Chromium が自分用に定義した WebKit の API ... Chromium WebKit と呼ぼう ... は、
プラットホームにくっつける WebKit1 の流儀をすっかり無視している。
Chromium はライブラリとしての Chromium WebKit を広く人々に使って欲しいとは思っていない。特定ブラウザのためだけに WebKit を使っている。 
だから安定した API はなく、 クラスやメソッドが必要に応じて足し引きされていく。
一週間バージョンがずれた WebKit と Chromium はたぶん一緒にビルドできない。

WebKit1 と違い、 Chromium WebKit はアプリケーションと別のプロセスで動かすべく作られている。
WebKit のプロセス (Chromium 用語では renderer) は OS のサンドボックス機構に閉じ込められていて、
ファイルアクセス、通信、 GPU による描画といった OS のきわどい機能はプロセス間通信で別のプロセス (browser プロセス) に依頼する。

Chromium WebKit の仕事は別のプロセスから届いたデータを解釈し、JS やら HTML やらを色々動かしてメモリ上のオフスクリーンに結果を描くだけ。
だから Chromium WebKit 単体には HTTP すらついてない。 HTTP は Chromium のコードに入っている。
私は Chromium WebKit で [phantom.js](http://www.phantomjs.org/) みたいのを作れないかなーと四半期に一回くらい空想するのだけれど、
そうだ HTTP ないんだったと繰り返し目を覚ましている。
[File API](http://www.w3.org/TR/FileAPI/) なんかもプロセス間通信のスタブだけが入っおり、 
実際のファイルは browser プロセスが読み書きする。

そしてプロセス管理の仕組みは Chromium が面倒を見ている。
browser プロセスが renderer プロセスを作って、その renderer プロセスが Chromium WebKit の API を使う。

![diagram](https://lh4.googleusercontent.com/-lV2PfeU58x8/T3fDglVug8I/AAAAAAAAEfY/vec-MVPDwiY/s640/P1010423.JPG)

自分自身がプロセス管理の仕組みを持ってない点で Chromium WebKit は WebKit2 より WebKit1 に近い...と言えなくもない。
一方で WebKit1 のように特定プラットホーム向けのライブラリとして使える代物でもないから WebKit1 の仲間に数えるのも気が引ける。

Chromium はもともと Chromium WebKit のような API レイヤを持たず、 WebCore のクラスを直接使っていた。
WebKit (Project) のリビジョンを固定して開発する分にはそれでもよかったけれど、
最新版の WebKit に追従しつづけようとした途端に WebCore 直接方式は成り立たなくなる。 
Chromium チームではない誰かの変更で簡単にビルドが壊れてしまうから。 
Chromium WebKit API は Chromium と WebKit(WebCore) の間に挟まって変更のショックをやわらげる緩衝材としてうまれた。

WebKit2
---------

WebKit2 は WebKit (Project) にプロセス分離モデルを持ち込む WebKit (API) の試みである。
Chromium が WebKit の外側でプロセス分離を実現したのに対し、
WebKit2 は WebKit の中、 API の内側にプロセス分離の仕組みを持つ。
Chromium WebKit が特定ブラウザのためだけに開発されているのに対し、
従来の WebKit はブラウザだけでなく音楽プレイヤやメーラといったアプリケーションに広く埋め込まれている。
これらのアプリケーションがそれぞれプロセス分離を実装しなおすのはムダだから、 WebKit の中に持つことにしたのだろう。

![diagram](https://lh4.googleusercontent.com/-DHsy5_0cZc8/T3fMsCxwEGI/AAAAAAAAEg4/N-j7nH7gIT8/s640/P1010433.JPG)

この判断のおかげで、 GTK や Qt といった Mac 以外の WebKit ポートも WebKit2 に参加して
プロセス分離の恩恵を受けられるようになった。 WebKit2 自体、なるべくポートをまたいでコードを使いまわせるようデザインされている。
もともと Mac に特化してはじまった WebKit1 とはつくりが違う。

WebKit1 と WebKit2
--------------------

WebKit2 の API は WebKit1 と互換性がない。
プラットホーム密着に密着した WebKit1 に対し、 WebKit2 はプラットホームとの接点を小さく保っている。
具体的には大半の API が C で定義されている。 
ウィンドウをつくるなど、アプリケーションへの埋め込みに必要な最低限の接点は Cocoa や Qt-C++ といったプラットホーム固有の語彙で定義されている。
でもそれ以外の API は[だいたい C](http://trac.webkit.org/browser/trunk/Source/WebKit2/UIProcess/API/C)。

プラットホーム密着の WebKit1 ではポート同士がまったくコードを共有していなかった。
Objective-C を GObjcect-C や Qt-C++ などプラットホーム毎の言葉に移植しただけの類似コードがポートの数だけある非機械的コピペ地獄。
WebKit2 は多くの API を C(実装は C++) の共通部分に追い出すことで重複を避けている。

![diagram](https://lh5.googleusercontent.com/-dCX7cVzXeEE/T3fDl_faNUI/AAAAAAAAEgI/gnekDM9odw8/s640/P1010428.JPG)

WebKit2 はプロセスを切り離した時点で WebKit1 との互換性を諦めている。それも共通部分の多い作りを後押ししたと思う。
ウェブページの中身が別のプロセスにあると、たとえば WebKit1 ではアプリケーションから触ることのできた DOM を WebKit2 では触ることができない。
ほかにも Mac WebKit は Cocoa のウィンドウ階層 (NSView) とウェブページのフレーム階層をシームレスにつなぐため大きな労力を割いていたけれど、
プロセスが違う時点でこの構造にも意味がなくなった。

要するにそれまで API 越しにさらけ出していた中身がプロセスのむこうにいってしまった。
アプリケーションから見た WebKit の性質は WebKit2 で大きく様変わりした。
この移行がおきた Safari 5.1 はきっと大変なリリースだったろう。
それでも UX の変化が小さいせいかマイナーバージョンしかあげないあたりに
タッチデバイス会社のこだわりを感じた。

WebKit2 と Chromium WebKit
----------------------------

WebKit2 と Chromium WebKit ではプロセスモデルのレイヤリング以外にも違いがある。
大きな違いの一つは WebKit (API) ではなく WebCore の中に埋まっている。

従来の WebKit ポートでは、WebKit1 も WebKit2 も同じ WebCore を使う。
なので WebCore はプロセスモデルによらず WebKit1, WebKit2 の両方で動かなければいけない。

一方 Chromium WebKit は Chromium のプロセス分離モデルだけを相手にすればいいので、 
WebCore の中にある Chromium 固有部分もその前提を頼って色々細工をしている。
この細工が一番はっきりと現れるのはサンドボックス機構だろう。
Chromium WebKit はファイルやネットワーク、 GPU といったシステムの微妙なところに触れるコードをプロセスの外に追い出している。
そして WebKit の入った renderer プロセス自体は OS によって絞りこまれた権限(=サンドボックス)の下で動く。
おかげで WebKit の脆弱性をついてウェブからヘンなコードが潜り込んでも簡単には悪さができない。
サンドボックスの中でも動けるよう、 WebCore の Chromium 固有部分では微妙な仕事をするかわりにプロセス間通信用のコールバックを呼び出す。

それに対し、従来の WebCore は自分の手で HTTP やクッキーといった微妙な資源をさわる。(コードはプラットホーム毎に適当なライブラリを使う。)
アプリケーションはなるべく WebKit に仕事を押し付けたいわけだから、これは自然な成り行きだ。
ただ　WebCore 自身が色々やっているせいで、厚いサンドボックスに入れるとその色々が動かなくなってしまう。
だから WebKit2 のサンドボックスは Chromium WebKit よりちょっと弱い。

![diagram](https://lh5.googleusercontent.com/-s2ARCDsfnoE/T3fDndqQftI/AAAAAAAAEgM/uPjD6Z0tnXM/s640/P1010430.JPG)

とはいえ Mac WebKit2 を[覗いてみる](http://trac.webkit.org/browser/trunk/Source/WebKit2/WebProcess/mac/WebProcessMac.mm)と、
[Darwin の sandbox](http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man3/sandbox_init.3.html)で
ファイルアクセスを特定のディレクトリに限るくらいはやっている。恥ずかしい `/etc/hosts` を悪意ある第三者に見られる心配はしなくてよさそう。
ネットワークアクセスを制限するコードは見当たらなかった。

WebKi1 との互換性はデザインを制約するだけでなく保守の面倒にもなる。 
WebKit1 と WebKit2 の両方を保守する手間は馬鹿にならない。
そのためか、今のところ WebKit2 API は WebKit1 のように文書化されておらず、そこらへんのアプリケーション開発者がさっと使える風にはできていない。
今のところ Safari のように OSX 標準のアプリケーションだけで使われているんじゃないかな。もしかすると Mobile Safari も使ってるかもしれない。

というわけで WebKit API レイヤにはそれぞれ良いところも苦労もあるから、
末尾の数字のみならず中身も見た方が面白いと思うのでした。

まとめ:

 * WebKit1 はプラットホーム密着型のライブラリ。
 * Chromium WebKit はプラットホームも再利用も気にしない。
   * プロセスの分離は WebKit の外でやる。
 * WebKit2 はプロセス分離を WebKit の中にもつ。
   * プラットホーム密着度は下がった。 API 文書なし。
   * WebKit1 との互換性のためサンドボックスはちょい弱め

----

Isis
------

![isis](http://farm1.staticflickr.com/1/104587_081a7d5066_z.jpg)

自主会社員ごっこが終わったところで以下本題。

プロセス分離ができる WebKit ベースのブラウザは Chromium と WebKit2(Safari) しか無いとおもっていたら、
最近公開された次世代 WebOS のブラウザ [Isis](http://isis-project.org/) もプロセス分離に対応していた。
これがちょっと面白いつくりなので紹介したい。

Isis は WebOS 用のブラウザで、 WebOS 全体のオープンソース移行にともない一足先に[公開](https://github.com/isis-project)された。 
レンダラには QtWebKit を採用している。これまでの WebOS が WebKit のフォークを独自の構成で使っていたことを考えると、これは大きな方向転換に見える。
QtWebKit は Qt にあわせて割と保守的なリリースをしているけれど、 
Isis はそのペースに付き合わず最新版のフォークを [GitHub にミラーしている](https://github.com/isis-project/WebKit). 割とこまめにマージしている様子。

そしてプロセス分離の仕組みは WebKit2 を使わず自分たちで実装しなおしている。
Isis は QtWebKit の外側でプロセス分離を実装する。そういう意味で Chromium に近い。

Isis が面白いところの一つは、ブラウザの UI を HTML で実装しようとしているところだ。
Gecko で XUL が担っている役割を HTML にやらせるイメージでだいたいあってると思う。
他の WebKit ブラウザがプラットホーム毎のツールキットで UI を描いているのとは対照的。
UI は WebOS が公開する [Enyo](http://enyojs.com/) という JS ライブラリの上に作られている。

それにしても HTML でブラウザの UI をつくるってどういう感じなんだろう。
ウェブページは `<iframe>` でホストするの？ でも WebKit は `<iframe>` を独立したプロセスで動かすことができない。
レイアウトの仕組みが複数フレームにまたがっているし、そもそも WebCore がプロセスについて何もしらないからだ。
せっかくプロセス分離を実装しても、ブラウザの UI ごとクラッシュしてしまうなら全然ありがたみがなさそうに見える。

首をかしげつつコードを眺めると謎が解けた: Isis は *QtWebKit でブラウザのプラグインを実装している*。
プラグインの中でブラウザ・・・WebKit が動く。プロセス分離もその中で扱っている。
要するにページの中に `<object ...>` とか書いておくとその中にプロセスが作られてページが表示されるわけ。
アクロバティックな方法を考えたもんだなあ。たしかにプラグインの中で WebKit が動くならページのプロセスを分離しつつ HTML で UI を書ける。
もちろんプラグインをホストしている UI の HTML 自体も WebKit で動くのだろう。

![diagram](https://lh6.googleusercontent.com/-2SvMKAHycvk/T3fDoqac7pI/AAAAAAAAEgc/K5K3WWoQZCs/s640/P1010431.JPG)

[ドキュメント](https://developer.palm.com/content/api/dev-guide/enyo/web-view.html)を見る限り
WebOS はこのプラグインブラウザ方式を以前から踏襲していた様子。全然知らなかった。
さすがにプロセスは切り離してなかったろうけれど・・・。

B2G
------

WebKit 以外に目を向けると、 Mozilla が推し進めるモバイルプラットホームの [B2G](https://wiki.mozilla.org/B2G) ではアプリケーションを HTML で書くことになっている。
XUL がどうなったのか気になるけれど、タッチデバイス向けには使いまわしたい資産もないし HTML でいいんじゃね、くらいの判断だろうと想像している。

そして B2G で動くアプリケーションの中にはもちろん[ブラウザ](https://github.com/andreasgal/gaia/tree/master/apps/browser)がある。
つまり B2G は WebOS と同じく HTML でブラウザの UI をつくろうとしている。

ブラウザが表示するウェブページは `<iframe>` にホストされる。
B2G はプロセス分離を諦めたのだろうか? というとさすが Mozilla に抜かりはない。
Gecko で `<iframe>` のプロセスを分離しようと準備を進めている。

もともと Mozilla には Firefox のために [Electrolysis](https://wiki.mozilla.org/Electrolysis)と呼ばれるプロセス分離のプロジェクトがあり、
既にプラグインは別プロセスへ駆逐済。 
ドメイン単位でのプロセス分離は[諸事情により一時停止しているらしい](http://lawrencemandel.com/2011/11/15/update-on-multi-process-firefox-electrolysis-development/)
けれど仕組みは準備ができていて、 `<xul:browser>` という XUL のウェブページ表示用要素に `@remote` という属性を与えればプロセスが切り離される...らしい。
B2G ではこの仕組みを `<iframe>` にも[持ち込もうとしている](https://bugzilla.mozilla.org/show_bug.cgi?id=714861)。

このプロセス分離がどういう仕組みで実現されているのか、たとえばネットワークスタックはどのプロセスで動くのか、私はよくしらない。
ただ手持ちのピースがパチパチと組みあわさって B2G に結集してく感じは傍目にちょっとかっこいい。

デスクトップの覇権をめぐる Netscape 戦役を消え行く記憶の隅に抱く長老 XUL が、たくましく成長した HTML に道を明け渡そうとしている。
この [flexbox](http://www.w3.org/TR/css3-flexbox/) はもうお前のものだ - HTML の肩にそっと触れる XUL の目はそう語っていた。
一方で戦いのあと遠い国へと姿を消したかつての宿敵 Windows 家がタッチデバイス特需に沸くタブレット連邦に突然の帰国、
全てを統べるはずの WPF 卿が新バージョンでは一線を退き [Windows Runtime と HTML を JS でハイブリッドした](http://msdn.microsoft.com/library/windows/apps/br211386) 
ブラウザ風の容貌をもつ不思議な若者 [Metro](http://msdn.microsoft.com/library/windows/apps/br211386) が脚光を浴びている。
しかし背後には [XAML の影](http://msdn.microsoft.com/en-us/library/windows/apps/windows.ui.xaml.aspx)が...
再会の運命を背負う二人のマークアップ、そして失われた時代に生まれた理想主義者 Isis の物語はどこで交差するのか。胸騒ぎを抑えきれない。
あとはもうちょっと他人事なら気もラクなんだけど・・・

プロセスモデルの色々
--------------------

だいぶ話がそれた。

ブラウザが HTML の中で動く時代への感慨はさておき、
ブラウザのプロセスモデルに見られる色々なバリエーションを紹介してみました。

この手の提案や実装は割と色々あって、たとえば 
[Illinois Browser Operating System](http://static.usenix.org/event/osdi10/tech/full_papers/Tang.pdf)
なんてのは更に極端に話を推し進めてネットワークスタックのプロセスもドメインごとにわけた方がいい、なんて主張する。
Microsoft Research にも[似たような話](http://research.microsoft.com/apps/pubs/?id=79655)があった気がする。
（中身はよく覚えてない。）

現実世界のブラウザにはなかなかアカデミックな飛躍を期待できないけれど、
かわりに既に書かれたコードや周囲をとりまく制約の中からあるべき姿をみつけだすパズルの面白さがある。
Isis が見せたプラグイン・アプローチのハックは痛快だし、 
Chromium の GPU プロセス(というのがあるのです)はアカデミアが取り組んでいない課題を垣間見せている。

ブラウザはどんな単位でプロセスを分離すればいいのか、そのためにどのような抽象が可能か。
それほど自明な問題でもないことが伝われば幸いでございます。

----

写真

 * http://www.flickr.com/photos/pinksherbet/2452068666/
 * http://www.flickr.com/photos/selva/104587/