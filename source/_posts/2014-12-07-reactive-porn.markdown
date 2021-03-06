---
layout: post
title: "Reactive Porn"
date: 2014-12-07 21:37
comments: true
categories: 
---

![porn](https://farm5.staticflickr.com/4135/4738461246_527da9171d_z.jpg)

[Rebuild.fm](http://rebuild.fm/) に[出させてもらいました](http://rebuild.fm/70/)。ありがたいことです。

さっそく録音を聞き直す。自分の声を聞くのは辛い・・・のはさておき、
リアクティブプログラミングの話は我ながら主張がよくわからない。
反省のため何が言いたかったのかを考え直したい。

たぶん趣旨は二つあった:

 * A. [RxJava](https://github.com/ReactiveX/RxJava) や [RxAndroid](https://github.com/ReactiveX/RxAndroid) はなかなかいいやつだ。 
 * B. リアクティブプログラミングは一つのはっきりした概念ではない。

A については試してもらえばわかるはず。ReactiveX のサイトからぽつぽつ資料を読めば済む。ここでは B を補足してみる。

## X 指向は Y みたいなもの

リアクティブプログラミングとは何だろう。どうもつかみどころがない。私は腑に落ちるまでけっこう時間がかかった。

このわかりにくさには大きく二つ理由があると思う。一つはプログラミングの概念をコードなしに説明する一般的な難しさ。オブジェクト指向とは・・・関数型言語とは・・・相手に馴染みのない言葉を短く説明するのは難しい。もう一つの理由は、いくつかの異なった流派が我こそはリアクティブプログラミングだと主張していること。目的意識はみな似てる。でも解決方法が違う。

一つ目の理由、抽象的な話のわかりにくさは、リアクティブプログラミングに限った話ではない。そしてこれもリアクティブに限らず、混乱を招く冴えないメタファが理解の邪魔をする。オブジェクト指向ってのはね、乗り物とクルマ、動物と犬みたいなもんなんだよ。関数型言語は参照が透明で数学みたいなんだよ・・・。

この手のメタファを聞かされて、うるせえエラそうにわけわからんポエム読みやがって・・・と思ったひと。あなたは一人じゃない。冴えないメタファを口にしてしまう病を、私は <[X is like sex](https://www.google.com/?q=is+like+sex#q=is+like+sex) 症候群> と呼んでいる。話す側を高慢に、聞く側を不愉快にする比喩がある。
何かを自慢したい瞬間は誰にでもある。だけどできるものならポエムよりポルノでありたい。

二つ目の理由、いくつかの派閥が違う話をしている現状。これを真面目に相手にするのはしんどいかもしれない。でも入党せずに各党の得意技を冷やかすだけならそれなりに楽しい。あとで私が勝手に分類した派閥たちをざっと紹介し、にわかのリアクティブ語りとしてティーザーを気取ってみたい。

## エクセル小咄

リアクティブプログラミングにとってのまずいメタファ、リアクティブの犬とクルマは何か。それはエクセルだとおもう。リアクティブってのはね、変数がエクセルのセルみたいになってる世界なんだよ・・・リアクティブプログラミングをそんな風に説明することがある。たしかに古典リアクティブプログラミングは値の自動更新を強く押し出したし、嫌われ者のエクセルくんが意外な一面を見せるストーリーも小気味良い。この話を披露したい気持ちはわかる。

一方、このごろ流行っているリアクティブ・プログラミングの実装は特段エクセル的ではない。メタファとしてのエクセルは現実とのズレが大きく、理解を助けるかわりに混乱を招いている気がする。

もう一つわかりにくいのは、エクセルが「リアクティブプログラミングを実現するプログラミング環境」なのか「リアクティブプログラミングを使ったアプリケーションの一例」はっきりとしないところ。たぶんもともとは後者だったのが、前者のような解釈もできると茶々を入れる[人々があとから現れ](http://lambda-the-ultimate.org/node/2710)混乱を招いた。（そしてエクセル自体も驚異の進化を遂げほんとに高性能分散計算プラットホームになってしまった。やばい。)

いずれにせよ今時なリアクティブのメタファとしてエクセルの筋の悪さに変わりはない。リアクティブ・エクセル童話は聞かなかったことにするのが良いとおもう。

## データバインド・リアクティブ

エクセルのメタファはいまいちだ。でも自動で値が更新される変数というコンセプト自体には使い道がある気もする。各種 GUI フレームワークのデータバインディング (特に two-way data binding)と呼ばれる仕組みはまさにそれを実現している。だからデータバインディングは古き良きリアクティブの末裔と言えなくもない。

とはいえデータバインディングは新しいコンセプトではない。そして最近のリアクティブプログラミング実装とデータバインディングは、無関係ではないにせよ毛色が違う。だから今リアクティブについて調べるなら、データバインディングは主流外の別物と見なす方が混乱しない。いつか二つの点が線になる瞬間は来る、かもしれない。でもそれは達観ポエムを書く中年にむけたインスピレーション。わかりやすいポルノじゃないよね。

エクセルのメタファで説明できるリアクティブプログラミングを、今日は乱暴に「ダータバインド・リアクティブ」と呼ぼう。

## アクター・リアクティブ

最近のリアクティブプログラミングって何なのかしら。そうおもってウェブを眺めていると、妙に目に付く資料がある。[Reactive Manifesto](http://www.reactivemanifesto.org/) だ。(どこかに翻訳もあるはず。) Manifesto というだけあって、この文書は自分語りに近い。ポルノじゃなくてポエム。ただしこのポエムに共感する人は多いらしい。

中身に深入りするかわりに、ポルノ・レポーターとして書き手の出自を暴くことにしよう。[原典のレポジトリを見る](https://github.com/reactivemanifesto/reactivemanifesto)。どうやら主著は Scala の Actor フレームワーク [Akka](http://akka.io/) の開発者らしい。つまり Reactive Manifesto は「Actor で書けばスケールして速いコードになるよ、それが流行の Reactive ってもんだよ」と主張するためのプロパガンダとして捉えることができる。ポエムの常として具体的なコードの話はせず、手強い問題や愛すべき形容名詞を並べ幅広い人々に訴える。

・・・と下世話に書いてみたものの、Reactive Manifesto の問題意識はたしかに最近のリアクティブプログラミングが目指す大きなゴールを捉えてはいる。

そして Erlang や Akka をはじめとする Actor ベースのネットワーク・ミドルウェアが最近のリアクティブ・プログラミングに関わっているのは間違いない。
これらをざっくり「アクター・リアクティブ」とでも呼んでおこう。

Actor も特に新しいアイデアではない。ただクラウドに CPU をいっぱいならべてじゃんじゃんデータを処理する新しい文脈でその力が再発見され、
名札と実装を新調し売り出している。

## フューチャー・リアクティブ

理論的背景に興味のないプログラマから見ると、 Actor は非同期なメッセージング機構を中心にコードを組み立てるプログラミング・モデルの一つにすぎない。
なぜ非同期だと性能やスケーラビリティに良い影響があるのか・・・は人々の詩心を誘いがちなので今は目をそらし、
同じ問題に取り組むもう一つの有力なアプローチを眺めてみよう。
それは Twitter の [Finagle](https://twitter.github.io/finagle/) に見られるような、
[Future](http://docs.scala-lang.org/overviews/core/futures.html) を中心に据えたプログラミング・モデル。

Actor も Future も、非同期にとびかうメッセージをノンブロッキングに捌くための抽象化手法だった(※ Erlang のことはひとまず忘れてください)。
要求と応答の対がはっきりしているなら Future が簡潔だし、データがストリームとしてプッシュされてくるなら Actor が強い。

Future 党の人々は自分自身がリアクティブだと強くは主張しない。だから影が薄い。けれど扱う問題領域は似ているし、アプローチも次に紹介する Rx ファミリーに近い。私からみると十分リアクティブに見える。だからこれを「フューチャー・リアクティブ」と数えておくことにしよう。

## ファンクショナル・リアクティブ

Actor と Future は、それぞれ一長一短がある。

Actor のモデルでは、ブロッキングに頼らない限り要求と応答の対を扱うコードが少し不自然になる。Future をつかうと Actor では見えにくかった要求と応答の関係がくっきり姿を見せる。ところが今度はその 1:1 対応が強すぎてストリーム処理がぎこちなくなる。

普段はストリーム処理なんてしないと思うかもしれない。でも、たとえば要求結果が数千数万と大規模になるについれ、返ってきたそばからデータを逐次的に処理するコードが欲しくなる。Actor なら自然にかけるこうした問題が Future にはしんどい。

ストリームと要求応答の両方をうまく扱えるモデルが、もう一つのリアクティブ実装 [Reactive Extension](https://rx.codeplex.com/) 略して Rx ... 正確にはその焼き直しバージョン [ReactiveX](http://reactivex.io/) ... である。Rx は Future に似ている。そして要求応答の対を 1:1 から 1:N に一般化することでストリームが苦手な Future の弱点を乗り越えている。ヘタにやると不便になりそうなこの一般化をデザイン上の工夫で簡潔にとどめ、しかもそれをベースに強力な API を築き上げた Rx は、段々と人気を博すことになる。(私が Rx 好きにつき都合よく書いてます。)

Haskell 発の [Funcitonal Reactive Programming](https://www.haskell.org/haskellwiki/Functional_Reactive_Programming)/FRP なるコンセプトを C# に輸入する形で発明された Rx。
Akka も Erlang も普通に関数型の仲間な点をふまえると強気な命名だけど相手が Haskell じゃ仕方ないかな。
Reactive Manifesto の Actor 一味もデータバインドなどの古典からリアクティブの座を乗っ取った手前文句はいえまい。

Rx スタイルのリアクティブを、ここでは「ファンクショナル・リアクティブ」とでも呼ぶことにしよう。なお今となっては元の FRP と Rx はだいぶ違うものになっているそうな。たしかに[サーベイ](http://www.cs.rit.edu/~eca7215/frp-independent-study/Survey.pdf)を読んでも・・・わかんないね。Haskell むずかし。

### Rx vs. それ以外

モデルの強力さでは Rx が Future をすっかり飲み込んでいる。とはいえ細かいデザインを含め本当に Future より使いやすいのか、それほど自明でない。実装の良し悪しもある。特に C# を前提につくられた Rx を移植先の RxJava で使う収まりの悪さは目立つ。だから 最初から Scala 向けに作られた Future の方が使いやすいと Scala プログラマが言いいだす可能性はある。使ってる人の話がききたいところ。

Actor と Rx の対比はどうか。二つのモデルにはギャップがあるように見える。そして Rx は馴染みぶかい要求/応答モデルからの飛躍が小さい。世間の API とも乖離しにくいし、親しみやすさは上だろう。Actor を選ぶのはストリーム指向を重視する人とサブカル好きくらいかなという印象。(Actor 好きな人は異論があると思うので書いてもらえたらリンクします。)  もっとも Actor と Rx を混ぜて使えばそれで済むのかもしれない。混乱しそうだけどね・・・。

それ以外。名前は違えど Node.js の [Stream](http://nodejs.org/api/stream.html) はだいたい Rx みたいなものだと私は理解している。ただし使っている用語は違うし Rx との整合性にも興味はなさそう。そのうち独自な発展を遂げる予感はある。すると「ストリーム・リアクティブ」は 「ファンクショナル・リアクティブ」 と別に数えるた方がよいのかしら。よくしらないので保留。

## クライアントサイド・リアクティブ

サーバサイドでは性能や堅牢性がリアクティブに取り組む大きな動機だった。
一方リアクティブの隆盛以前からイベント駆動の名で非同期かつノンブロッキングなコーディングを強いられてきたスマホアプリやブラウザなどクライアントサイドのプログラマたちは、
複雑化するコードへの処方箋として最近のリアクティブを受け入れている。

リアクティブをイベント駆動の焼き直しと見る人がいるくらいだから、クライアントプログラミングはもともとある種のリアクティブ性を持っている。
思い返せばデータ・バインディングはかつてクライアントサイド・プログラマの夢だった。
また C# に代表されるクライアントに強いプログラミング言語は非同期をラクにする機能を言語自身に取り込んできた。
アカデミックな FRP ですらもともとは対話的システムの抽象化手法として発明されている。

### 世代交替

けれどウェブ上にバックエンドをもつアプリが当たり前になるにつれ、データバインディングをはじめビュー上の複雑さだけを解決する古いリアクティブネスは領土を失っていった。
それまでクライアント向けプログラミングを先導していた Windows や Flash の劣勢も伝統的リアクティブ手法の力を削いだ。 
Two-way data binding の複雑さを否定し単純さをうたう UI 構築用のフレームワークが [React.js](https://rx.codeplex.com/) を名乗っているのは象徴的だと思う。
React.js がどのようにリアクティブなのか・・・は点を線でつなぐポエムの枕にふさわしい。典型的なリアクティブの手法と直接は関係ない。

ビュー以外の非同期性をどう扱うか、たとえばバックエンドへの API リクエストをどう非同期に待つか。
Windows や Flash のあとからやってきたプログラマたちはデスクトップ世代の伝統とは距離を置きつつ工夫を重ねた。
JavaScript は Future 相当の API たる Promise を言語のコアライブラリに押し込んだ。
Objective-C は同世代の言語には不釣り合いなブロック構文と Java ばりの並列化インフラを取り込んだ。などなど。
言語やプラットホーム本体の外でも多くの実験が続いている。
JavaScript には星の数ほど非同期処理のフレームワークがある。Android にも太陽系の惑星の数くらいはある。たぶん。

この切実さを思えば、クライアント開発者がサーバサイドのリアクティブブームに手を出す気持ちはわかる。
ブロッキングがダメなのはわかってる。でもコールバックを引数に渡すのはもうイヤだ、
そしてナントカリスナーを実装するのはもっとイヤなんだ！

## まとめ

・・・というような話を Rebuild.fm で出来ればよかった気がした。でも考えが整理されてなかったな。ごめんなさいね。
私のも Rx 以外の話は普通なのと [Naoya Ito の回](http://rebuild.fm/people/naoya/)はいつも面白いので http://rebuild.fm/ 
を万一購読してない人はするといいですよ。Android のアプリは [Pocket Casts](http://www.shiftyjelly.com/pocketcasts) がいいですよ。

自主スポンサー業を済ませたところでまとめ: 

 * リアクティブプログラミングは勢力争いとダメなメタファのせいでとっつきにくい。
 * エクセル小咄は聞き流しつつ面白そうな要素技術をつまみ食いしよう。
   * 流行に乗るなら Rx、
   *  カウンターに Actor もいい。
   * データバインディングで古典にたしなみ、
   * Finagle で Twitter ファン活動。
   * Node.js が好きなら Stream と一蓮托生。
 * 要素技術ポルノに満足したらポエムを書いて嫌がられよう。

写真: https://flic.kr/p/8dHRrG
