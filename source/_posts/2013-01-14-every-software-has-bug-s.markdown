---
layout: post
title: "Every Software has Bug(s)"
date: 2013-01-14 00:38
comments: true
categories: 
---

![img](http://farm4.staticflickr.com/3127/3308532489_6a1bbf61fa_b.jpg)

Chromium プロジェクトは [crbug.com](http://crbug.com) というドメインをもっている.

このドメインは Chromium のバグトラッカー (BTS) 専用の URL shortener として使われている.
たとえば [crbug.com/125981](http://crbug.com/125981) にアクセスすると
[https://code.google.com/p/chromium/issues/detail?id=125981](https://code.google.com/p/chromium/issues/detail?id=125981) にリダイレクトされる.
URL shortener といっても t.co や bit.ly みたいに大げさなものではない. 
Apache...じゃなくてなぜか IIS だった...の設定か何かでちょこっと URL を書き換え, そこにリダイレクトするだけ. データベースなし.

オンラインでバグの話をするとき, 多くの Chromium 関係者は crbug.com の URL でバグを表記する.
バグの URL が短いのは都合がいい.
たとえばメールや IRC でお願いごとをするとき, 短い URL は単語になれる. つまりインラインに書いても収まりがいい. こんなかんじ.

> Hi Morrita,
>
> I need to fix [crbug.com/12345](http://crbug.com/12345) before the next branch,
> but it is blocked by your [crbug.com/12330](http://crbug.com/12330) and [crbug.com/12321](http://crbug.com/12321). 
> Could you share the status of these bugs?
>
> I know you're busy to attack [crbug.com/12350](http://crbug.com/12350). I'd be happy to help if you like.
> 
> Bests,

長い URL だとこうはいかない.

> Hi Morrita,
>
> I need to fix a bug (https://code.google.com/p/chromium/issues/detail?id=12345) before the next branch,
> but it is blocked by following bugs which you own. Could you share the status of these bugs?
>
>  * https://code.google.com/p/chromium/issues/detail?id=12330
>  * https://code.google.com/p/chromium/issues/detail?id=12321
>
> I know you're busy to attack Bug 12350. I'd be happy to help if you like.
> 
> Bests,

文面のかったるさが増した.

URL のかわりに短く "Bug 12350" などと書けなくはない. でもこれだとバグへのリンクができない. 
IRC クライアントやメーラは URL をリンクとしてクリック可能にしてくれる. Gmail なんかだと `http://` がなくてもリンクになる.
だから URL を持つ addressable なデータには, できるだけその URL を書き添えたい.

メールや IRC 以外だと, スプレッドシートにさっとバグ一覧をまとめる時もセルに収まる短い URL は重宝する.
そのほかテキストエディタや Wiki でメモを書く時にもよく使う.
アドホックに一覧を作りたいときなんかは Wiki やスプレッドシートの世話になったりするでしょ?

Trac や Github などの BTS 上では, `#12350` みたいなシャープ付きバグ ID がリンクになる.
これはとても便利だけれど, Github や Trac の外で会話したい時には使えない. そういうことは, プロジェクトによってはよくある.

この手の短縮 URL の持つ利便性の結果, crbug.com 以外にもいくつかの短縮 URL が作られた. 
たとえば SVN の特定リビジョンをあらわす [crrev.com](http://crrev.com) なんてのもある. 
Paul Irish が一覧を [まとめてくれていた](http://paulirish.com/2010/bug-tracker-short-urls/).

[wkb.ug](http://wkb.ug/)
--------------------------

WebKit のバグにも `webkit.org/b` という短縮名がある.
たとえば [webkit.org/b/52994](http://webkit.org/b/52994) を [https://bugs.webkit.org/show_bug.cgi?id=52994](https://bugs.webkit.org/show_bug.cgi?id=52994) にリダイレクトしてくれる.
でも crbug.com と比べてちょっと長い. 悔しい. wkbug.com がほしいなあ...

...としばらく考えてからひらめいた. [wkb.ug](http://wkb.ug) というのはどうか? これは短い. crbug.com に勝てる!
喜び勇んだ私は [wkb.ug/52994](http://wkb.ug/52994) と書ける shortener をつくった. 一年くらい前のこと.
それ以来, wkb.ug は私や近所の同僚, 非太平洋時間の愉快な仲間たちによって細々と使われている. オフィシャルな ChangeLog に書いて怒られた猛者もいるらしい. 
怒らなくてもいいじゃんと思いはするけれど, crbug.com は Chromium の古参開発者が持っているのに対し wkb.ug は島国の暇人所有だからねえ.
信頼がおけないのも仕方ない...

[hasb.ug](http://hasb.ug/)
-----------------------------

本題. *バグの URL にオリジナルの ID を含む短い別名を用意する*のは良いアイデアだから, 
みんな自分のいるプロジェクトのバグ用に短縮名ドメインを取るといいよ...という話をしたかったのだけれど, 
ドメインを取るだけでなくサーバも必要なのがちょっとめんどい. 誰もが好きに使えるウェブサーバを持っているとは限らない. 私は持ってない.

wkb.ug にしても, もともとは Heroku の無料枠で動かしていた. でもこんな[しょぼいもの](https://github.com/omo/wkb.ug)に貴重な無料枠を割くのは惜しい.
Apache なら `.htaccess` に二三行書けば済むような話なんだから, みんなでつかえるサーバが一個あればいいじゃん?

と思い立って *[hasb.ug](http://hasb.ug/)* というバグ URL 短縮サービスを作り, wkb.ug もそこに移動した. 
Hasb.ug に

 * Github アカウントでログインして, 
 * 自分が持っているドメインと, リダイレクトしたい BTS の URL を登録,　それから
 * DNS で該当ドメインの A record に `50.19.127.155` を指定すると

自分のバグ用 URL shortener ができあがる. (詳しい説明は [About ページ](http://hasb.ug/about) をみてください. 詳しくないけど.)

登録画面はこんなかんじ:

![img](https://lh5.googleusercontent.com/-2otr1M2YaNk/UPCxutI-rKI/AAAAAAAAVFs/nokyWz-NDPA/s640/0111-hasbug-02.png)

というわけで皆様ふるって素敵ドメインを取得のうえ割り当てて欲しいです. 使い始めると便利だしドメイン名にも愛着が湧いてくるとおもう.

ただドメインを取るのすらめんどくさい人やおためし用途のために *hasb.ug のサブドメインを使える*ようにしておいた. 
たとえば [less.hasb.ug](http://less.hasb.ug/) みたいな shortener をつくれる. (例: [less.hasb.ug/1108](http://less.hasb.ug/1108))
こうした hasb.ug サブドメインはログインして登録すればすぐ使える. 自分ドメイン不要.

あと長い URL を短い URL に直すのはちょっとめんどいので [Bookmarklet](http://hasb.ug/about#bookmarklet) を書いたりもした.

Own and share your short names.
---------------------------------

Hasb.ug を使うかどうかはともかく, バグの URL に短い別名をつけるのは便利. 気が向いたら一度試してみてほしい. 
もし hasb.ug で新しい URL shortener をつくってくれたひとは
Twitter などに [#hasbug](https://twitter.com/search/realtime?q=hasbug) でお知らせしていただけると
使ってもらえた事がわかって喜んだり RT したりするとおもいます.

コードは [github.com/omo/hasb.ug](https://github.com/omo/hasb.ug/) に置きました.
バグや要望は [this.hasb.ug](http://this.hasb.ug/) まで. どうぞよろしくあらあらかしこ.