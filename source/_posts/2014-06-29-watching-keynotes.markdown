---
layout: post
title: "趣味はキーノート鑑賞"
date: 2014-06-29 19:33
comments: true
categories: 
---

趣味は何かときかれたらインターネット企業ウォッチですと答えるかもしれない。そのへんの企業ゴシップに気を取られるよりコードでも書いてた方が百倍くらい有意義だとわかってはいる。でもついニュースを眺めて過ごしてしまう。職業上の便益を損ねるくらいだからこれは趣味と呼んで差し支えなかろう。中でも各種企業イベントのキーノート・スピーチ鑑賞はそんなおっかけ業のハイライトだ。

インサイダーからすると、キーノートは学芸会みたいなもの。隣のクラスの出来映えにやきもきすると同時に、自分のコードの晴れ舞台、たった一つの台詞を見守る。

インサイダーでないキーノート・・・つまり大半のキーノートは、言って見れば近所の高校の文化祭に行くようなものだろうか。あ、こういう学校なんだ、これが流行ってるんだ、なんてのが透けて見える気がして面白い。メディアが報じるキーノートは空気を伝えない。自分でビデオをみてこそ愛好家というものだろう。イベント行けって話もあるけどそこは見逃してほしい。

あと {% asin B00KGVN140, Chromecast %} を買ったはいいけど見るものが無い、とかいってる人はキーノートでも見るといいんじゃないですかね。元々テレビをみなかった私は引っ越した勢いでテレビを買ったもののケーブルテレビも Netflix も結局ほとんどみておらず、テックトークやキーノート、あと Coursera ばかり見ている。

というわけで新機能や新製品の紹介ではなく学園祭の来訪者として、キーノートのビデオをいくつか紹介してみたい。

## Google I/O

この話を書こうとおもったのは例のごとく [I/O](https://www.youtube.com/watch?v=wtLJPvx7-ys) があったから。

<iframe width="560" height="315" src="//www.youtube.com/embed/wtLJPvx7-ys" frameborder="0" allowfullscreen></iframe>

個人的に面白かったのは [Android One](http://www.theverge.com/2014/6/26/5845562/android-one-google-the-next-billion). 途上国向けに廉価版あんどろスマホの参照実装を提供し、各国のメーカーと提携して電話機を出してもらう、というものだと理解している。話をしている [Sundar Pichai](http://en.wikipedia.org/wiki/Sundar_Pichai) はインド出身で、最初の提携先メーカーもインドにある。途上国の開拓がスマホマーケットの行方を左右すると報じられる中、あんどろのボスがインド出身というのは実は結構意味のあることかもしれない。インドなまりのしゃべりを聞きつつそんなことを思った。まあ気のせいかもしれないけど、勝手に色々な妄想を働かせるのがキーノート鑑賞を楽しむコツです。

## WWDC

みんな大好き Apple の発表会。

<iframe width="560" height="315" src="//www.youtube.com/embed/w87fOAG8fjk" frameborder="0" allowfullscreen></iframe>

今年は Swift なんかの大型発表があったせいもあり色々な人が色々書いている。中でも登壇者がみな威勢がよく元気だった、という感想をよく見かけた。私もそう思う。

個人的な見所は彼らが "Continuity", 要するに MacOS と iOS の連携を強調していたところ。私から見ると、これは連携という対等な関係というより Mac OS を iOS に従わせたように見えた。世間の老舗ウェブ企業は mobile first だの mobile only などと良いながら四苦八苦している。その時代を作った Apple は Mac を iPhone にぶら下げるという形で Mobile というか iPhone 中心の時代を押し進めようとしている。そう解釈して勝手に感心した。

あんどろユーザたる身からすると iOS がどうなろうと現実にはどうでもいい。でも妄想の題材としてはゴージャスだ。私は近々 iOS と MacOS がくっつくと思っていたけれど、Mac OS は卓上用 iOS 向け周辺機器としてどんどん簡素にしていけば無理にくっつけて混乱を招く必要もないのかも・・・そう考え(妄想)を改めた。まず x86-32 を完全に滅ぼし universal binary のサイズを小さくしたあとで A 系 CPU に移行、それから OS 統合ってかんじかなー。

## F8

Facebook の開発者向けイベント。数年ぶりに開催された。

<iframe width="560" height="315" src="//www.youtube.com/embed/0onciIB-ZJA?list=PLb0IAmt7-GS188xDYE-u1ShQmFFGbrk0v" frameborder="0" allowfullscreen></iframe>

スマホ OS 開発元たちほどは注目されてない気がするので内容を補足しておくと、Facebook はモバイルアプリのプラットホームになるので使ってね、と売り込むイベント。 iOS の会社もあんどろの会社も足並みをそろえる気は無い中で両方相手にするのは大変だから、差分はこっちでよろしくやっとくよ、と主張している。

個人的な見所は二つ。一つ目は社長の話す時間が長いところ。開発者向けイベントに社長がでてくるのはよい。WWDC も最初と最後では Tim Cook が出てくるもののすぐひっこむし、I/O に至っては社長全然でてこない。Zuckerberg はかつて [Memcached のテックトークをした](https://www.youtube.com/watch?v=UH7wkvcf0ys)くらいにはプログラマである自分をアピールしたいタイプ。ここではそれがうまく働いている。ただそのぶん [VP of Engineering](http://www.crunchbase.com/person/mike-shroepfer) のひとは影が薄くて気の毒。

もう一つは "Move Fast and Break Thinkgs" という有名なモットーを撤回し "[Move Fast with Stable Infra](http://www.businessinsider.com/heres-facebooks-new-motto-2014-4)" と言い出したところ。プラットホームを売り込む方便という面はあるにしろ、企業の成熟を見ている気もして感慨深い。Facebook Paper なんかの完成度も "[Done is Better than Perfect](http://techcrunch.com/2012/02/01/facebook-ipo-letter/)" とは趣が違うしねえ。まあ [Slingshot](http://www.sling.me/) は Done よりか...

ちなみに stable の論拠は SLA と API の保証期間ができますよ、という話で、それみんな普通にやってるで・・・という気がしなくもない。それにしてもプラットホーム企業へのシフトを印象づける発言ではあった。

## Amazon Fire Phone

Amazon の電話機発表イベント。キーノートどころか開発者向けイベントじゃないけど、面白かったので紹介。

<iframe width="560" height="315" src="//www.youtube.com/embed/w95kwXy_MOY" frameborder="0" allowfullscreen></iframe>

スマホ OS 各社が音声ガイドにしのぎを削る中、画像認識ベースの検索 [Firefly](https://developer.amazon.com/public/solutions/devices/fire-phone/overview/firefly-sdk-for-fire-phone) を軸に据えてきた Fire Phone。電話機自体はさておき、Bezos 社長が新機能を紹介する際にテクノロジーを強調する様子が興味深かった。AWS が支える無限の計算資源、お抱えの研究者が作り出した機会学習アルゴリズムの数々・・・。すごい技術が使われていて、すごい技術を作れるチームやインフラがある。それをたびたび強調していた。

WWDC や I/O を振り返るとここまでハイテク面を強調しない。たぶん強調しなくてもテクノロジ企業としてのイメージがあるからだろう。一方 Amazon に対する世間のイメージはそこまでテクノロジ感が強くなく、だからハイテク機器(電話)を売るのにあわせてイメージを補正したかったのかもなあ。もっともこれもやはり妄想どまり。プログラマからみた Amazon はぶっちぎりでテクノロジー企業だしね。

あとどうでもいい話としては Bezos 社長は笑い声が怖いです。ミーティングでこんな風に笑われたら逃げ出したくなりそう。でもちょっとモノマネしたくもなる。

## Re:invent

プログラマからみた Amazon すなわち AWS のイベント Re:invent のキーノートを見てみよう。去年は二日にわけて二回キーノートがあった。

<iframe width="560" height="315" src="//www.youtube.com/embed/8ISQbdZ7WWc" frameborder="0" allowfullscreen></iframe>

<iframe width="560" height="315" src="//www.youtube.com/embed/Waq8Y6s1Cjs" frameborder="0" allowfullscreen></iframe>

二日に分けるのは今風じゃねえな、と思ったが、実際に見ると理由がわかる。初日は保守的なエンタープライズの人を相手に、翌日はあたらしもの好きなウェブっ子相手に構成されている。

一日目のキーノートでは、ひたすら「オンプレミスのシステムをクラウドに移行しましょう！やるなら今です！みんなやってます！Amazon だから安い！アジャイル！」みたいな話をする。そして途中で銀行や伝統的メディア企業などなどエンタープライズぽい会社の CEO が出てきては、やはり「うちは移行したぜ！アジャイル！」とか自慢話をする。悪口でこき下ろす競合は IBM。AWS のユーザに今更こんな話してもしょうがねえだろ・・・と思うでしょう。でもきっと保守的な会社から視察に送り込まれてくる参加者なんかもいて、それが想定聴衆なのだろう。興味深い。たとえば新機種の発表でもない限り WWDC で登壇者が "iPhone を買おう! ゴージャス!" とか参加者を煽る姿は想像できない。安定性を強調したいためか、初日は新製品の発表もわずか。

驚くほどつまんねえなーと思いつつ二日目に進むとトーンが反転する。登壇者は 分散システムの専門家にして訛のきつい CTO の Werner Vogels。Amazon のテクノロジーはすごい、開発ペースも速い。なぜなら小さいチームが自立的に開発し、顧客志向でリーンにやっているからだ！[まずプレスリリースを書くんだ！](http://www.allthingsdistributed.com/2006/11/working_backwards.html) みたいな話をしたあと、いいかおまえら分散システムは predictability が重要だ！などのちょっとかっこいい話に進む。登壇するゲストは Netflix, AirBnB, Parse, Dropcam と軒並みウェブ企業やスタートアップ。新機能もじゃんじゃか発表。おーこれだよこれ！[Kinesis](http://aws.amazon.com/kinesis/) ヒャッホイ！イノベーション！みたいな気分で俄然盛り上がる。でも新参者にとっては内輪臭がきつすぎる恐れもある。

要するに Re:invent では聴衆をエンタープライズとウェブ企業とできっぱり区別し、それぞれ別々にメッセージを送っている。多くの企業が自分の立ち位置で暗黙のうちに聴衆をバイアスしているなか、自覚的にフレーミングしているのがすごい。なおここで「開発チームも二派にわかれてるんじゃないか」などと妄想を進めるのがウォッチ業のお約束です。

## BUILD

Microsoft のイベント。昔は PDC という名前だった気がするけれど、いつの間にか BUILD という名前になっていた。これも二日ある。一日目がクライアントサイドで、二日目がクラウド。

<iframe src="http://channel9.msdn.com/Events/Build/2014/KEY01/player?h=540&w=960" style="height:540px;width:960px;" allowFullScreen frameBorder="0" scrolling="no"></iframe>

<iframe src="http://channel9.msdn.com/Events/Build/2014/KEY02/player?h=540&w=960" style="height:540px;width:960px;" allowFullScreen frameBorder="0" scrolling="no"></iframe>

Chromecast で見たい人は [VidCast](https://dabble.me/cast/) を使うとよい。

見所は初日の最後にでてくる新社長 [Satya Nadella](http://www.microsoft.com/en-us/news/ceo/index.html)。クラウド部門の出身らしく、そのへんのテクニカルタームをすらすら話す様子はかっこいい。インド出身でプログラマ上がりの社長。しまった筋肉からも前任者との違いは歴然。昔からの MS ファンは懐疑的だけど、これは Microsoft 変わるかもしらん、とおもわせる頼もしさがあった。最後に社長自ら開発者からの質問こたえるパートがある。これは[去年の I/O](http://www.businessinsider.com/larry-page-google-io-speech-2013-5) へのオマージュだろうか...など役に立たない connecting dots をするのが外野のたしなみ。

そういえば PDC/BUILD はかつて MS 本社やロサンゼルスあたりでやっていたれど、2013 年からは I/O や WWDC とおなじサンフランシスコに場所を移した。産業の重心が動く様を感じずにはおれない。といいつつ Re:invent はラスベガスだったりする。

## JavaOne 

[埋め込みしにくい形式につきリンクのみ...](http://medianetwork.oracle.com/video/player/2685720528001)

初めての海外旅行は JavaOne だった。十年以上前のこと。デスマに巻き込まれ参加するヒマがないという会社員に代わり、当時バイト中だった学生の私はどさくさで連れて行ってもらったのだった。そんな経緯もあり私にとっての JavaOne はどこか特別。今では Oracle World なるどうでもいいイベントの一部になってしまったけれど・・・。

キーノート自体はなかなかよい。巨大な会場で幾千の聴衆を前にラムダの話とかしてるのよ。こんなコード短くなるぜ、みたいな。これでこそ開発者イベントってもんじゃないですか。WWDC の Swift パートなんて新言語の発表なのに文法紹介より Playground を使ったデモをがんばっていて、あれはすごく良いデモではあるのだけれど、この JavaOne の地味な感じも結構すき。まあ中年のノスタルジーかもしれない。

後半には自作タブレットに JavaFX を載せてオレオレ Java OS だぜ！みないな趣味プロジェクトにしか見えないデモがあったりする。そういえば BUILD 初日にも Windows を Raspberry Pi 的ハードに移植して巨大な鍵盤の電子ピアノをつくり Internet of Things! と主張するデモがあった。このへんをみるとキーノートを学芸会や文化祭にたとえたい私の気持ちが少しはわかってもらえると思う。

## ロングテール

ここまでは大手のキーノートを紹介してきた。世の中には開発者向けプラットホームたろうとしている会社は他にも色々あって、そういう会社のビデオも見たら面白いのだろうと思う。ただ量が多くてキリがない。私も見れないまま積んであるビデオが山ほどある。というわけで細かいカンファレンスたちをちまちまリンクし、あとで自分のブックマーク代わりに使おうと思います。

 * [Heroku Waza](http://vimeo.com/herokuwaza/videos) - 細かいなんていうと怒られそうではある。親会社の [Dreamforce](https://www.youtube.com/user/dreamforce) より楽しそう。
 * [Parse Developer Day](http://blog.parse.com/2013/09/17/parse-developer-day-video-series-keynote-and-developer-show-and-tell/) - もう Facebook に買収されたから F8 だけ見とけば良い気もする。でも見比べると Facebook のプラットホーム戦略における Parse の重要性がわかる。
 * [DockerCon](https://www.youtube.com/watch?v=_DOXBVrlW78) - 会社じゃないという話もあるけどまあまあ会社じゃん、ということで。
 * [Futurestack](https://www.youtube.com/watch?v=6CRnMB36US8) - NewRelic のカンファレンス...なんてものがあるのか...
 * [Core OS meetup](http://coreos.com/blog/video-from-meetup/) - Fleet とかきになる.
 * [GopherCon](https://www.youtube.com/playlist?list=PLE7tQUdRKcyb-k4TMNm2K59-sVlUJumw7) - ほんと企業じゃないなこれは. まあどさくさで. 

そういえば企業主催じゃないカンファレンス動画は他にもいっぱいあるよね。それもまた開拓しがいのあるジャンル。

あとは例のごとく [Youtube の O'Reilly チャネルを購読したり](https://www.youtube.com/channel/UC3BGlwmI-Vk6PWyMt15dKGw) ... と新着を眺めていたら [Jeff Dean のトーク](https://www.youtube.com/watch?v=1-3Ahy7Fxsc&list=PL055Epbe6d5aFXqs5UPAyQxs3D-1tHVCy) がある！見逃すところだったあぶないあぶない... だとか、最近は [Facebook のチャネル](https://www.youtube.com/channel/UCP_lo1MFyx5IXDeD9s_6nUw) も F8 以外のイベントがぼこぼこあって油断できなかったりだとか、いいかげん Watch Later リストがあふれているので YouTube アプリは Watch Later を新しい順に並べる機能を付けてほしいとか、[InfoQ](http://www.infoq.com/) のビデオはほんとにサイトの出来が悪くて辛いと思っていたが実は [Pocket Casts](https://play.google.com/store/apps/details?id=au.com.shiftyjelly.pocketcasts&hl=en) あたりの Podcast アプリでフィードを購読し Chromecast に飛ばせば問題解決だったとか、やはり趣味はほどほどにしてコード書いた方が良いのではとか、朝５時に起きればすべて円満かもとか、特にオチはありません。
