---
layout: post
title: "Hackability - For Whom?"
date: 2012-07-23 20:30
comments: true
categories: 
---

![image](http://farm1.staticflickr.com/142/327742012_edb155456e_z.jpg)

[WEB+DB Press](http://gihyo.jp/magazine/wdpress/archive/2012/vol69) が出てます(だいぶ前に).
前回はあまりに内容がおっさんすぎたと反省し, 今回は若者ぶって JavaScript のビューレイヤの話を書いてみました. 
MVC 用語の定義を気にするのもいいけどもうちょっと細かい所に目を向けても面白いですよ, という話のつもりです. 
しかし最近は JS もおっさん言語であるという指摘をうけ二週遅れな自分を痛感...

おっさん的な話であるところの連載第一回 [Hackability vs. Hackiness](http://gihyo.jp/dev/serial/01/comparators/0001)
はオンラインで読めるようになっていました. お暇のある方はご覧ください.

以下あんまし関係ない話:

Hackability 紛争
---------------------------

先の連載記事にも書いたとおり, WebKit はプロジェクト目標の一つとして [hackability を挙げている](http://www.webkit.org/projects/goals.html).
私が hackability の有無を気にし始めたのもこれを見て以来のことだ.
Hackability という言葉はかっこいい. 少なくともオープンソースの世界でこれに意義を唱える人は多くなかろう. 

Hackability はある種の正義だとおもう. 正義には良いところがある一方で喧嘩にもつながる.
世の国々が正義をめぐって各地で人死を出しているように, hackability もたびたび喧嘩の種になる. 死人は出ないけど.

WebKit も例外でない. WebKit のメーリングリストで嵐を呼んだスレッドを探したければ
[hackability と検索](http://markmail.org/search/webkit-dev+list:org.webkit.lists.webkit-dev+hackability+order:date-backward)すればいい.
私はフレームの類があまり得意でないから, こういうスレッドはいつも遠目に眺めている. 
ところがあるとき自分の書いたコードが誰かの正義に反してしまい, 肝を冷やしたことがあった.

半年ほどまえ, WebKit で [Modularization](http://markmail.org/message/fkiibwrwv3xporxx) と銘打つ大規模なリファクタリングが始まった. 
山ほどある Web ナントカ API の実装を WebKit の "コア" 部分から追いだそうとする大掃除だ.

大半の Web ナントカ API は, DOM やレンダリングといったブラウザ従来の機能とあまり関係がない. 
ところが WebKit は構造上こうした従来の機能と Web ナントカ API のコードが混在しがちで, 太ったコードベースが健康を損ねていた. 
Modularization は, そんな肥満コードの依存関係を整理してダイエットする試みだった. 
主な作業は IDL パーサやビルドシステムといった足回りの拡張と, モジュール化されたファイルの移動. 
たとえば [Geolocation API](http://dev.w3.org/geo/api/spec-source.html) の実装はモジュールとして 
[Modules/geolocation](http://trac.webkit.org/browser/trunk/Source/WebCore/Modules/geolocation) ディレクトリに移されている. 

Modularization のリファクタリングは興味ふかいものだったけれど, 
ふだん "コア" に近い DOM 周辺をさわっている私からすれば他人事でもあった.
後で書くように modularization の提案は反発を受けるのだが, 
自分の提案に反論をうけ唸っている同僚を横目に私はのうのうと仕事をしていた.

Vibration API
--------------------------

ところがそのころ登場した [Vibration API](http://www.w3.org/TR/vibration/) がきっかけで, 
私も modularization の騒ぎに巻き込まれかける. Vibration API はウェブアプリからケータイをブルブルする機能. 
Firefox OS や Tizen など Web 色の強いモバイル環境に支持されている. 

WebKit のコードレビューはレビュアを指名しないボランティア制をとっている. 
現実には非公式な形で同僚なんかにレビューをたのむことが多いんだけれど, 
たとえば同僚の守備範囲を超えたパッチは社外の誰かに見てもらわないといけない. 

こうした外様レビューには大抵時間がかかる. よく待たされて困っている. 私自身も誰かを困らせているかも知れない. 
だからせめてわかる範囲ではさっさとレビューしようと, 
ヒマなときは[レビュー待ちキュー](https://bugs.webkit.org/request.cgi?action=queue&requester=&product=&type=review&requestee=&component=&group=requestee)を眺める. 
そして自分にわかりそうなもの, 持ち場とは違うけれど簡単そうなやつをレビューしたりする. パッチの球拾いってかんじ.

あるとき球拾いをしていると, 件の Vibration API を 
[WebKit に追加する投稿](https://bugs.webkit.org/show_bug.cgi?id=72010) が目についた. 
パッチは誰からも相手にされないまま放置されている. 守備範囲の人がいなかったのだろう. 
中身を覗くと見るからにブラウザ本体とは関係なさそうなコードがある. モジュール化するにはもってこいだ. 
球拾いを兼ねて, modularization のパターンでコードを構成しなおすようパッチの作者に求めた. 
メーリングリストで modularization の議論が活発化する少し前のこと.

そのあともレビューが進み, チェックインして良さそうなコードが出来た. 
ところが Vibration API 自体の WebKit 内評判が[いまいち芳しくない](http://markmail.org/thread/ir4vmndkminuhtmb).
セキュリティどうなの, 他の API で足りるんじゃないのなど, 強い反対ではないものの標準化にありがちな押し戻しがちらほら見られる.
議論を促すもいまいち進まない.

Revert Ready
----------------------------

こいつは面倒そうだ. 議論の決着していないコードをチェックインしたせいで文句を言われたくない.
件のパッチは見なかったことにしよう. 私はそう決めた.
そもそも本業とは全然関係ないパッチだし. 単なる草むしりだし.

ところがパッチの作者は粘り強かった. IRC に現れてレビューをしろと食い下がってくる.
しかも相手は隣の国に住んでおり時差がない. 逃げ場なし. 油断した...

私は以前, まだ定義の不完全な Web API をチェックインしてだいぶ怒られたことがある.
結局そのときのパッチは revert された. それ以来, 評判の不透明な機能をチェックインするのには及び腰になっている. 
かといってレビューの要望にシラを切り通すのもしんどい. 

仕方ない. パッチはとりあえずチェックインして, ケチがついたらさっさと revert しよう.
そう諦めてコードを眺め直すと, いくつか revert しにくそうな箇所が目についた. 
オブジェクトの寿命管理がゴミゴミしたコードに埋もれている.
このままだと(たとえば)一ヶ月後にケチがついても, たぶん機械的には revert できない.
ケチがついた瞬間 "ハイハイすんませんすぐやっときますねー" ってかんじで revert したいのに...

仕方なくその周辺をリファクタリングすることにした.
別のモジュールを生贄に, [オブジェクトの寿命管理を整理するパッチ](http://trac.webkit.org/changeset/107518)を書く. 
そして同じ仕組みに則るよう Vibration API パッチの作者にお願いし, 
歯切れのよいパッチができあがった. これならいつでも revert できる.
ようやくレビューを受理し, パッチは[チェックイン](http://trac.webkit.org/changeset/108272)された. 
今の所 revert されることもなく元気にやっている. 

反対の声
-------------------------------

この revert 対策リファクタリングで追加した抽象が思ったより強力だったため, 
Vibration API 以外のモジュールも同じパターンを踏襲しはじめた.
結局のところ revert のしにくさは modularization 基盤がもつ欠点のあらわれだったのだ. 

抽象といっても大したものじゃない. 
いくつかのオブジェクトにライフサイクルを監視する observer 用 endpoint を追加しただけ.
ただ WebKit は伝統的にこうした pluggability や extesibility を嫌っている.
私も modularization を冠した大規模リファクタリングや
revert の恐怖といった圧力があってようやく, そういうコードを書く気がおきた.

同じような文化的背景から, 件の modularization 提案自体も反発にあった.
Modularization はコードの局所性を下げ, かえって見通しを下げるという苦情. 
先の[提案メール](http://markmail.org/message/fkiibwrwv3xporxx)は長い議論を呼んだ.

私のリファクタリングが追加したような寿命管理のフックについても, 
[それは理解の妨げになりうる](http://markmail.org/message/tpjntgakom5v56ua)と控えめな批判があり, 
おもわず息を飲んだ. とりあえず revert しろとは言われず胸をなでおろしたけれど...

いくらか緊張を孕んだ議論はなんとか妥協にたどりつき収束した.
結果として modularization の仕組みは残しつつ,
モジュールに切り出される機能の数は当初の提案より少なくなった. 
事前にモジュール化されていた機能のいくつかはコアに押し戻された.
Modularization の提案者にはコアをできるだけ小さくするマイクロカーネル的な思惑があったようだが, 
コミュニティ - 特に古参の開発者はそれを受け入れなかった.
([まとめページ](http://trac.webkit.org/wiki/Modules).)

引力の素
-------------------------------

この議論には折り合わない２つの正義=Hackability があった.
Modularization の擁護派は, モジュールを追加しやすくする hackability を求めた. 
古参の開発者は問題追跡のやりやすさやコード全体の見通しをもたらす hackability を求めた. 
一方は WebKit コアの <上> に乗る hackability を求め,
他方は WebKit コアの <中> に潜る hackability を求めたとも言える.

[山のような Web ナントカ API](http://www.w3.org/2012/05/sysapps-wg-charter.html) が実装を待っている
(たぶん. 個人の見解です)以上, 
modularization に類する <上> の hackability を求める声を無視しつづけることはできなかったと個人的には思う.
一方で, extesibility や pluggability に抵抗する WebKit の慣性をノスタルジーと退けるのも抵抗がある.

Web からアクセスできる API を WebKit に足すのはそれなりに面倒な作業だ. 
特に WebKit をフォークして拡張部分を保守しようとした日には大変な苦労が待っている.
API の追加時はどうしても本体のコードに手を入れる必要がある. そして本体のコードはどんどん変わる. 
trunk の外側でコードを追いかける苦労は多い.
だから API の追加を望む人々はパッチを書き、それをなんとか trunk に送り込もうとする. 

もし WebKit が十分に extesible かつ pluggable だったら,
WebKit の組み込み利用者が簡単に API を追加できたら, はたして何がおきるだろう. 
フォークの上で労なく追加機能を保守できるのに, 人々はわざわざ trunk にパッチをよこすか.
わからない. 今ほどの強い圧力は働かないだろう. 

意図的かどうかはともかく, WebKit に通底する反拡張性主義は潜在的な開発者にプロジェクトへの参加を促した. 
それは trunk に戻れないまま死んだたくさんの袋小路フォークを生んだけれど, 
WebKit 自体には求心力をもたらし血肉になったと思う.
Modularization はこの引力を削ぐことにならないか?

一方で, trunk への参加を決めた開発者が API をはじめとする新機能の追加を望んだ時, 
反拡張主義はどれほどその意欲を, hackability を削いでいるのか?

Hackability を謳うとき, その主体は必ずしも明らかでない.

様々な目標
---------------------------------

さて, こう書くと modularization の議論は hackability を軸として交わされたように読める.
私もそう読んでいた. しかしプロジェクトの意志決定にとって hackability は問題の一面でしかない. 
[WebKit のプロジェクト目標](http://www.webkit.org/projects/goals.html) は他にも色々ある. 
特に Performance や Stability, Standards Compliance あたりは modularization のデザインに影響を与えている.

たとえば **Performance**.
性能を下げないため, modularization の仕組みはなるべくコンパイル時にモジュールを解決しようとする. 
IDL パーサの生成するコードもビルドシステムと密着してコンパイル時の解決を助けている.

**Standards Compliance** も影響力がある.
アプリケーションから野良 API を追加しやすい仕組みができると, WebKit でありながら非標準 API を大量搭載したブラウザが登場しうる. 
WebKit のプロジェクトが個々のアプリケーションに口を挟むことはできないけれど, すくなくともそれを後押し仕組みを持ち込む動機はない.
過剰な拡張性は野良 API の追加を助ける.
だから API 実装者の hackability は潜在的に Standards Compliance と衝突しうる.

Modularization によってもたらされる拡張性は **Stability** を損ねうる. 
拡張可能を銘打ったツールを使ったことのある人なら誰でも身に覚えがあると思う. 
ライフサイクル監視用のフックなんかは stability を損ねる常連.
フック同士が暗黙の依存関係を持ってしまい, フックの実行順序によって再現しにくいエラーを起こす, 
なんてのはややこしいシステムでよく見かける光景.

まばゆさ
---------------------------------

![image](http://farm4.staticflickr.com/3181/2289040114_95c8a1eca6_z.jpg?zz=1)

Modularization を議論するスレッドは, 
どのようにこれらのバランスを取るべきかのトレードオフを巡る綱引きでもあった.
けれど, おそらくは "Hackability" という言葉の輝きに目を奪われ,
議論の参加者が他のプロジェクト目標を直接引き合いに出すことはなかった.
反論自体はそうした様々な価値を暗黙の論拠としていたにもかかわらず, 
hackability のまばゆい正義が煌々と舞台を照らし陰影を奪った.
開発者の心を染めているのは淡く重なる色々なのに.

この一件に限らず, これまでも hackability の持つ行き過ぎたまばゆさは
終わらない議論を炊きつけてきたのだろう.
まばゆい正義に価値がないとは思わない. けれどそれを口にする帰結は少し考えていい.
正義の拳を振り上げてしまったら, 誰かに振り下ろさないと収まりがつかないからね.

写真:

 * http://www.flickr.com/photos/pulpolux/327742012/
 * http://www.flickr.com/photos/uditk/2289040114/