---
layout: post
title: "Rx で Koan した"
date: 2014-10-01 21:31
comments: true
categories: 
---

![zen](https://farm5.staticflickr.com/4116/4776232863_e0c3ab7348_b.jpg)

Android 入門にあわせて Java も勉強しなおすかと {% asin 4621066056, Effective Java %} を読みはじめたらすっかり疲れてしまった。Java... 昔 Effective Java 初版を読んだ頃は結構好きだった気がするけれど、いま二版を読むとこれ Bureaucratic Java じゃないのという気がしてしまう。まあ {% asin 4621066099, Effective C++ %} を読んだ人も多くは Wicked C++ だと感じるだろし {% asin 4798131113, Effective JavaScript %} は Ridiculous JavaScript だろう。文句は言うまい。何事も慣れるには時間がかかる。Java 8 はだいぶマシと伝え聞くものの、Effective Java の三版がでるのはいつになることやら。

そんな日々の現実逃避に [@Scale Conference](http://atscaleconference.com/) の[ビデオ](https://www.youtube.com/channel/UCd9I8ZkgoR1d7GeSj_wi_LQ)を眺めていたところ、Netflix が RxJS でクライアントサイドの JavaScript を書き直したという[講演](https://www.youtube.com/watch?v=gawmdhCNy-A)があった。そういえば Reactive Programming ってかっこよさそうだけどよくわかってない。この Rx とやらをさわれば Reactive 入門できるのだろうか。でもどうせなら JS じゃなくて Android で Rx したいなあ。調べてみると [NYTimes が RxJava と Groovy で Android アプリを書き直しているという記事](http://open.blogs.nytimes.com/2014/08/18/getting-groovy-with-reactive-android/)がある。Groovy と Rx で Android! ちょっとかっこよさそう。これは Java がかったるくて Android に重い腰をあげそこねつつ Reactive Programming が気になる年頃な自分の進む道なのではないか。

やる気がでてきたところでまず Rx に入門したい。ちょうど RxJava をはじめとする Rx ライブラリ群を売り込み中の Netflix が [reactivex.io](http://reactivex.io/) というサイトを立ち上げており、その中に入門者向けの[チュートリアルリンク集](http://reactivex.io/tutorials.html)があった。いくつか読んで雰囲気をつかんだあと、評判の良い {% asin B008GM3YPM, Introduction to Rx %} なる Kindle 本を読んでみる。[ブログ記事](http://www.introtorx.com/) をひとまとめにして売ってるらしい。 値段($1)の割に良く書けていた。一見ページ数は多そうだけど中身はだいたいコード。すぐ読める。コードは C# だけどこの本の範囲ではだいたい Java みたいなものなので問題なし。

さて理屈はわかった。そろそろ手を動かしたい。でも [Android のプロジェクトにインテグレート](https://github.com/ReactiveX/RxAndroid)するのは面倒そうだなあそもそも Android よくわかんないし・・・。ふたたび怖じ気づきぶらぶらしていたら、 Microsoft が公開している [RxKoans](http://rxkoans.codeplex.com/) なる練習問題セットをみつけた。 C# で書かれている。現実逃避の現実逃避にこれを RxJava (と Groovy) で[解いてみた](https://github.com/omo/hello/tree/master/gradle-groovy/src/test/groovy)。

こんな C# のコードを:

```c#
public void SplittingUp()
{
    var oddsAndEvens = new[] {"", ""};
    var numbers = Observable.Range(1, 9);
    var split = numbers.GroupBy(n => n% ____);
    split.Subscribe((IGroupedObservable<int, int> group) => group.Subscribe(n => oddsAndEvens[group.Key] += n));
    var evens = oddsAndEvens[0];
    var odds = oddsAndEvens[1];
    Assert.AreEqual("2468", evens);
    Assert.AreEqual("13579", odds);
}
```

こんな感じにする:

```groovy
  void splittingUp() {
    def oddsAndEvens = ["", ""] as String[]
    def numbers = Observable.from(1..9)
    def split = numbers.groupBy({ it % 2 })

    split.subscribe(
      { GroupedObservable<Integer, Integer> group ->
        group.subscribe({ oddsAndEvens[group.key] += it.toString() })
      }
    )

    assert oddsAndEvens[0] == "2468"
    assert oddsAndEvens[1] == "13579"
  }
```

Groovy はよくわからないままカンとウェブを頼りに書いておりますゆえ idiomatic じゃなかったらごめんなさい。それにしても Groovy, むかし触ったときは遅いしエラーが起こるとインタープリタのスタックトレースが見えるしでしょぼい言語だと馬鹿にしてたけど、クロージャも部分的な型推論もあり静的コンパイルオプションをつければ生成されるバイトコードもコンパクト。今あらためて触ると結構かわいいやつな気がする。年を経て良くなったのかも。えらい。

## Koans

Koans を解くのはちょっと楽しい。Rx に限らず入門目的のちょっとしたコーディング問題集を Koan とよぶのはある種のならわしらしい。[Code Koans](https://www.google.com/#q=code+koans) などを検索すると色々みつかる。語源はたぶん「公案」なのだろう。本来の意味とは外れている気もするけれど気にしないでおこう。Koan だの Kata だのの Zen terminology を好む Kamikaze Ninjas はなぜか一定数いるからね。

Koan の難度はものによる。ふつうは入門向けなので難しくない。RxKoans もちょっと試せばすぐ解ける。(ただし RxJava だとライブラリの機能不足で解けないものもある。) とはいえ少なくとも穴を埋めて動かさないと先に進まない。この「ちょっとだけ頭を使い」「実際のコードをちょっとだけ書き」「動かして結果を見る」という手順がコンテンツの力で強制されるのは助かる。

たとえば Rx Koans は Visual Studio のプロジェクトがついてくる。コードはコンパイルできる。ただしテストは通らない。そのテストを通すようコードを穴埋めする過程で Rx の動作を体験する。新しいテクノロジについていくのが年々辛くなる中年にとって Koans のように入門の敷居を下げる教材はありがたい。

## 手をうごかす入門

新技術の入門に際し手を動かそうとするとき、おおきく２つの流派をよく目にする: 一つ目は実際になにかアプリを書いてみるトップダウンな「アプリ派」。もう一方は教科書のコードを書き写しては動かすボトムアップな「写経派」。ただ私からすると前者は手強すぎ、後者は退屈すぎる。間が欲しいと思っていた。

高価な授業料を払うことで「アプリ派」の敷居を下げる事はできる。有償のワークショップに参加すればいい。ただ授業料は本当に高いし身近にクラスがあるとも限らない。そうはいっても今はオンラインの講義なんかも有償無償いろいろあるから、トップダウンな入門法はとっつきやすいものになりつつあるのだろう。

Koans は「写経派」のようなボトムアップなアプローチのマシなバージョンと言えるかもしれない。写経といってもただサンプルを書き写すだけだと頭を使わない。だからコードをいじって頭を使え。写経派はそう説く。言いたい事はわかる。でも高すぎる自由度に戸惑ってしまうのが冴えない中年。クリエイティビティのないおっさんでも Koans のフォーマットを頼れば頭を使える。このアプローチにはもっと市民権を得てほしい。今のところ Koans は守備範囲が狭すぎて心細い。

Koans ではないにせよ章末問題のついている教科書は多い。書籍というフォーマットの制限を受けすぎているのが伝統的な章末問題の残念なところだ。たとえば答え合わせが面倒だったり、体裁だけが問題風で答えの無いエセ禅問答だったりする。問題とは別にサンプルコードを公開している本もある。でもそれは頭を使う余地の少ない完成したプログラムが大半。願わくば教科書には試せるコードの形で問題を用意してほしい。手を動かせるコンテンツの価値をもっと重く見てほしい。そのフォーマットの一つとして Koans を使えばいいと思う。

教科書だけでなく草の根のコンテンツが増えればもっと嬉しい。[Code Kata](https://www.google.com/?gws_rd=ssl#q=code+kata) や [Code Reterat](http://coderetreat.org/about), あとは各種競技プログラミングなど、手を動かすアイデアは色々ある。トップダウン派のために [プロジェクトのアイデア一覧](https://github.com/karan/Projects) を集めている人までいる。こういうやつの特定要素技術バージョンがもっと増えればいい。[A Tour of Go](http://tour.golang.org/) なんかは事前準備なくその場で実行できる上に練習問題も混じっている。攻めてる。

Coursera みたいなオンライン講義でトップダウンにアプリの作り方を教わりつつ Github の教科書アカウントから Koans レポジトリを フォークして解く。そんな風に新技術を入門できるとおっさんも延命できるのになあ。なんて夢を見つつ現実逃避はおしまい。

写真: https://flic.kr/p/8h4rCt