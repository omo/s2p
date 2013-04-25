---
layout: post
title: "最近のおっさんたち"
date: 2013-04-24 00:16
comments: true
categories: 
---

![ossan](http://farm1.staticflickr.com/156/423039025_c386b9db38_o.jpg)

[Gisted](http://gisted.in/) のドッグフードをかねて InfoQ のインタビューやプレゼンを見るようになった。
いくつか面白かったのを紹介したい・・・とおもってるうちにバックログを溜めすぎた。一度に紹介するのは諦めて何度かにわけよう。
今日はおっさん、具体的には ThoughtWorks 周辺の面々を追いかけてみます。InfoQ 中心だけどそれ以外も若干あり。

## [When Geek Leaks](http://www.infoq.com/presentations/keynote-geeks)

{% asin_img 0321820800 %}

"{% asin 4873114020,プロダクティブ・プログラマ %}" の著者 [Neal Ford](http://nealford.com/) が
あるキーノートにつけたタイトルは "[When Geek Leaks](http://www.infoq.com/presentations/keynote-geeks)"。
ここでの Leak は前向きだ。Geek の情熱がその主たる関心の外にも影響を与えていくといいですね、という話。

ファインマンが物理学という専門以外で発揮した数々のいたずら心、
"[Now Every Company Is A Software Company](http://www.forbes.com/sites/techonomy/2011/11/30/now-every-company-is-a-software-company/)" という Forbes の煽り記事、
継続的デリバリ、そして自著 "{% asin 0321820800,Presentation Patterns %}" を引き合いにだし、
Neal Ford はギークやプログラマが近隣領域に与える影響について語る。継続的デリバリの話はだいぶ今更感だけれど、
Presentation Pattern はちょっと面白そう。プレゼンがどうプログラミングと関係するのか。要するにデザパタインスパイヤだということらしい。
プレゼンのアンチパターンも紹介している。それにしてもファインマンをギークの代表格にもってくるとは渋い。そして強気だ。

#### DevOps と Jesse Robbins

InfoQ には継続的デリバリの親戚 DevOps の話がけっこうある。継続デリバリよりそっちの方が今風で面白い。
中でも Chef の開発元 [Opscode](http://www.opscode.com/) のエライ人
Jesse Robbins の [インタビュー](http://www.infoq.com/interviews/Awesome-DevOps-Jesse-Robbins) と [講演](http://www.infoq.com/presentations/Hacking-Culture) はよかった。
あふれるカリスマっぽさ。DevOps とは無縁のレガシー開発者な私ですら「インフラストラクチャーをコードしてまうで！」と盛り上がり、
余暇コードも Fabric をやめて Chef Solo に乗り換えようか心が揺れた。サーバ一台しかないけど・・・。
あと Jesse Robbins がもともと Amazon に在籍していたのを私はこのインタビューではじめて知った。
[Opsworks](http://aws.amazon.com/opsworks/) が Chef なのも開発者を知っているが故の信頼関係が支えの一部になったのかもしれないと腑に落ちたのだった。
どっちもシアトルにあるしね。

Jessie Robbins ファンになったら [ACM Queue での対談](http://queue.acm.org/detail.cfm?id=2371297) も読んでみるとよい。
大規模システムでいかに障害にそなえるかが議論されている。

#### デザインパターン

脇道ついでデザパタ関係の読み物をひとつ。
"[Design Patterns 15 Years Later](http://www.informit.com/articles/article.aspx?p=1404056)" というインタビュー書き起こしが面白かった。これは InformIT。
GoF のうち 3 人に話を聞いている。今からデザインパターンを直すとしたらどうする、なんて話も面白いけれど、
個人的に印象的だったのは *デザインパターンはフレームワーク設計者のものになりつつある* というくだり。
即効性のある知識から教養にシフトしたと言ってもいい。15 年の歳月にため息。
まあ専門知識ってのはなくても困らないけどあったら案外使えるから知ってて損はないよね・・・と自分を慰めた。

{% asin_img 4797311126 %}

デザインパターンといえば、InfoQ に "[Functional Design Patterns](http://www.infoq.com/presentations/Functional-Design-Patterns)" という講演があった。
関数型言語によくみられるパターンをいくつか紹介している。
話の冒頭で「先にいっておくと、*いちいちそれモナドじゃんと言うのはうざいからやめろ*。こっちはわかってやってんだ！」みたいに釘をさしてるのが面白かった。
デザインパターンより Haskell を勉強しないといかん・・・過去三回ぐらい挫折してるけど・・・。
書籍 "[Functional Programming Patterns in Scala and Clojure](http://pragprog.com/book/mbfpp/functional-programming-patterns-in-scala-and-clojure)" は無関係のもよう。

## [Software Design in the 21st Century](http://www.youtube.com/watch?v=8kotnF6hfd8)

{% asin_img 0321826620 %}

Martin Fowler による講演 "[Software Design in the 21st Century](http://www.youtube.com/watch?v=8kotnF6hfd8)" は三部構成。

最初の二つは Schemaless と (弱い)Consistency の話。
おおむね Fowler の書いた "{% asin 0321826620,NoSQL Distilled %}" にある内容だった。
まあ本の方がわかりやすい。 Martin Fowler の発音は私からするとだいぶ聞き取りづらい上に話がざっくりすぎる。

この本自体はよい。個々のデータベースの詳細に踏み込むのではなく NoSQL (主に MongoDB みたいな document database) 上でどうコードをデザインすべきかを
うまく説明しており、個人的には学ぶことが多かった。特に [Application Database](http://martinfowler.com/bliki/ApplicationDatabase.html) や
[Incremental Migration](http://martinfowler.com/bliki/IncrementalMigration.html) というコンセプトをきちんと名付けたのはえらい。薄いのもいい。
でも改めて眺めると martinfowler.com の [database タグ](http://martinfowler.com/tags/database.html) にある記事をひと通り読めばそれでよさそう。

そういえば Non-relational なデータのスキーマ(レス)をどう扱うかについては [Twitter Analytics に関する講演](http://www.infoq.com/presentations/Twitter-Analytics) 
も Big Data! というかんじでで面白かった。同じ領域の話ではないし、役立つ指数はひくいけどね。

３つ目のテーマは "The Value of Software Design" と銘打って技術的負債の話。
良いソフトウェアデザインの価値はどこにあるのか。[Uncle Bob](http://blog.8thlight.com/uncle-bob/archive.html) は「それはモラルの問題だ!」と
切って捨てるけど説得力ないよね - そう問題提起しつつ Uncle Bob のモノマネをする Martin Folwer。(しらない人がみると Steve Ballmer のモノマネにみえる。)
設計が悪いとやがて機能追加がしんどくなる。だから長期的には良い設計を保ったほうがいい。そう説明しようと謳いつつ、
その主張に [Design Stamina Hypothesis](http://martinfowler.com/bliki/DesignStaminaHypothesis.html) と名前をつけてみせる。
良い設計が割に合う「長期的」のスパンは数ヶ月ではなく数週間だと Martin Fowler はいう。

次に技術的負債にどんな種類があるのかを分類する。
腕の善し悪し、そして意識的か無意識か。この二つの軸で [４つの象限を定義してみせる](http://martinfowler.com/bliki/TechnicalDebtQuadrant.html)。
「腕が悪く無意識な」負債は良いコードの書き方を知らないゴミコード。「腕が悪く自覚的な」負債は「デザインとか時間の無駄」というやつ。
「腕がよく自覚的な」負債は従来の定義にある「今は出荷優先、でもあとで直す」もの。
そして「腕が良くて無意識な」負債の存在を指さし、これは何かと問う。
それは *振り返ってようやく良いデザインに気づく* こと。避けがたい学びの結果なのだ。
Fowler はそう講演を締めくくった。まあリファクタリングしろってことなんでしょうね。

この人の話は一見ありきたりだけれど、アイデアを整理してうまい名前をつけているのがえらい。

{% asin_img 4894712288 %}

## [The Start-Up Trap](http://blog.8thlight.com/uncle-bob/2013/03/05/TheStartUpTrap.html)

{% asin_img 4797347783 %}

Martin Fowler のモノマネがあまりにひどかったので Uncle Bob の近況が気になってしまい [Blog](http://blog.8thlight.com/uncle-bob/archive.html) を眺めてみた。
すると少し前に "[The Start-Up Trap](http://blog.8thlight.com/uncle-bob/2013/03/05/TheStartUpTrap.html)" という記事を書き炎上させている。
[Hacker News](https://news.ycombinator.com/item?id=5325491) をみるとコメント数が 144。
[Blink のアナウンスが 325 コメント](https://news.ycombinator.com/item?id=5489025)だからわるくないヒートアップだ。

記事の内容は要するに「スタートアップのやつらはなんだかんだと理由をつけて TDD をしない。そのせいで失敗しておりまったく嘆かわしい」というもの。
Martin Fowler のモノマネが脳裏をよぎる。だいたいあってるな・・・。

Uncle Bob はフォローアップ記事をふたつ書いている。
ひとつめの追伸 "[The Pragmatics of TDD](http://blog.8thlight.com/uncle-bob/2013/03/06/ThePragmaticsOfTDD.html)" では、
別に全部のコードをテストしろとは言わないよ俺も GUI のテストは書かないよ、という話をする。
続く "[The Frenzied Panic of Rushing](http://blog.8thlight.com/uncle-bob/2013/03/11/TheFrenziedPanicOfRushing.html)" は、
テストを書くと開発速度が落ちるって言うけどそんなことないよと訴える。なんて既視感あふれる展開・・・。

若者に噛み付かれるとは、TDD も今や権威になったのだとため息がでる。
HN のコメント欄を眺めた私の個人的な見立てでは、
この炎上の根にあるのは内容への異議よりむしろ Uncle Bob や TDD というおっさん/権威に対する反発ではなかろうか。

芸風があるとはいえ、Uncle Bob のフォローアップは挑発的だ。
件の "[The Frenzied Panic of Rushing](http://blog.8thlight.com/uncle-bob/2013/03/11/TheFrenziedPanicOfRushing.html)" の中で、
Uncle Bob は TDD の威力を示すこんなエピソードを紹介する: 
会社の同僚達とカンファレンスに参加し、面白いアルゴリズムの話を聞いた帰り道のこと。
ヒコーキの出発をまつ空港のロビー、同僚の若者たちはそのアルゴリズムを実装しようと画面に向かっていた。
それを見たおっさん Bob と James は、ジンを一杯ひっかけつつペアプロをはじめる。
しばらくのち、アルゴリズムが動きだして乾杯する二人。若者たちに目をやるとまだ四苦八苦している。
年寄りだって若者に勝てるんだぜ。*そう、TDD ならね！*

・・・ってうぜえーーーーー！これを読んで説得されるスタートアッププログラマがいるとはまったく思えん。
そういえば "{% asin 4048676881,Clean Code %}" と "{% asin 4048860690,Clean Coder %}" を読んでないな。
もうちょっと説得力ある議論が載ってるんだろうか・・・。

TDD やアジャイルが脚光を浴びた 10 年前、それはウォーターフォールや RUP などの権威に挑む若者たちのアナーキズムでもあった。
時が流れ、かつて重量プロセスが担っていたメインストリームの位置にアジャイルがいる。
[Yahoo! Japan の CEO がアジャイルを口にする](http://business.nikkeibp.co.jp/article/NBD/20120329/230368/)時代。
スタートアップをはじめてしまう血気盛んな人々がスタイルとしてアンチアジャイルになる気持ちもちょっとわかる。
私や同世代のおっさんが「設計レビューするからドキュメント出してよ」と言われたとき脊髄に走った F ワードの血潮と同じものが、
「TDD しろよ」と言われた若者の体を駆け抜けるのではないか。
私達が「おまえに漸近的設計のなにがわかる！？」と口走りたくなるように、
Uncle Bob に苛立つ人々は「おまえにリーンでモバイルなピボットの何がわかる！？」
とかなんとか言いたいんじゃないですかね。（セリフは捏造です。）

XP みたいな個別のプロセスについては割と早くから権威化への反発が見られたけど、
TDD はそこそこ粘っていた気がする。それも今は昔なのだろう。
リーンや DevOps みたいな比較的新しい動きもアジャイルの発展形なんだから、
旧友たる TDD もスタートアップ文化にまぜてあげれば良いのに。おっさんとしては同情を禁じ得ない。
でも自分たちと同じ痛みをわかちあっている仲間か否か、読み手は嗅ぎ分けるんだね。

## [Technical Debt, Process and Culture](http://www.infoq.com/presentations/Technical-Debt-Process-Culture)

{% asin_img 4873115116 %}

Uncle Bob がいまいち支持されないのは、彼がコンサルタントだからという面もあるだろう。
現実はさておきスタートアップのナラティブにおいてコンサル業は日銭を稼ぐ必要悪とされている。
だからポール・グラハムから出資を受けサンフランシスコでスマホアプリやメガネアプリを作りつつ何か言うくらいでないと
スタートアップ従事者には響かないのではないか。響かなくていい気もするけど。

ところでアジャイル世代のおっさんは多くがコンサル業を勤めていた。
でもこのスタートアップブームのご時世、もうちょっと西海岸ぽい仕事をしている人はいないのか。
と眺めていると、我らがレガシーコードの王 [Michael Feathers](https://twitter.com/mfeathers) が Groupon に勤めていた。
おお西海岸！そしてすげーレガシーコードありそう！（※偏見です。）

Michael Feathers 御大、実際のところ別に倒すべきレガシーコードを求めて Groupon に入ったわけではなく、
勤めていた Rails コンサル会社が買収された結果として入社したようす。
ちょっとがっかり・・・最近退職し、今はフリーのコンサルタントをしているようだ。
([比較的あたらしいプロフィール情報](http://skillsmatter.com/expert-profile/agile-testing/michael-feathers)。)

その Groupon 時代に行われた講演がいくつか InfoQ に公開されている。
中でも "[Technical Debt, Process and Culture](http://www.infoq.com/presentations/Technical-Debt-Process-Culture)" は面白かった。

技術的負債とは何なのか。この比喩を[使いはじめた](http://c2.com/doc/oopsla92.html) Ward Cunningham は、
一時的に品質を犠牲にして開発速度を稼ぐ決断をこう呼んでいた。
ところが昨今、技術的負債という言葉はより広い意味で使われている。
具体的には、技術的負債を *止めることのできないソフトウェアの膨張や慣性がもたらす影響*
(The Effect of Unavoidable Growth and the Remnants of Inertia) だとする考えが広まりつつある - 
講演はそんな風に始まる。そういえばエントロピーなんてメタファを使うこともあるよね。

さて、この慣性はどこから来るのか。Feathers はコンウェイの法則にひとつの原因を見出している。
組織のありかたがソフトウェアに与える影響はとても大きい。コンパイラのパスの数はサブチームの数で決まる。
そしてソフトウェア開発が組織によって行われる以上、ある程度の慣性/負債は避けがたい。
また人間の習性がもつバイアスからくる歪みもある。
組織はチームやプロセスをデザインするとき、その影響を自覚すべきである...と、Feathers による講演の骨子はそんなところ。

結論だけ聞くとどうってことないけれど、話の細部は面白い。
Feathers は組織やプロセスがうみだすソフトウェアの影響をコードやレポジトリから観測できると考えており、様々な調査を紹介している。
レガシーコードとの戦いの果てに人は統計的アプローチや実証的(Empirical)ソフトウェア工学にたどり着くのだなあ。
[別の講演](http://www.infoq.com/presentations/Software-Naturalism-Embracing-the-Real-Behind-the-Ideal) を見た感じだと、
オライリーの "{% asin 4873115116,Making Software %}" には影響されている様子。
積読してある・・・。そのほかアジャイル/反復的な開発がソフトウェアのデザインにもたらす綻びの話なども面白かった。

フリーランスになったあと、最近では 
"[The Design Principle that sneaks through your code, your system, and your life](http://skillsmatter.com/podcast/agile-testing/the-design-principle-that-sneaks-through)"
という講演をしている。
今度は Postel's Law (のような考え方)がソフトウェアのデザインに与えている影響を論じている。これはいまいちピンとこなかった。
もうちょっとアイデアが整理されるのを待ちたい。

Feathers の話をすると長くなるのは私が彼のファンすぎるせいなので見逃してください・・・。

### Kent Beck

さて Feathers 以外で西海岸デビューしたアジャイル業界人といえば Kent Beck。 いつの間にか Facebook にいた。
ぜひ Uncle Bob のかわりに Move fast and break things 世代の TDD についてスタートアップのやつらにガツンと言ってほしい・・・と期待しつつ
最近書いたものを眺めていると [単体テストの関数名](https://www.facebook.com/notes/kent-beck/shorts-not-always-sweet-the-case-for-long-test-names/564493423583526) 
なんて話をしている。盤石の安定感。どこにいても Kent Beck は Kent Beck なのだなあ。

これ以外にもそこそこな数の [notes](https://www.facebook.com/kentlbeck/notes) が公開されている。ちゃんと Facebook を使っていてエラい。
[PHP も書いてる](https://www.facebook.com/notes/kent-beck/crossing-the-beams-reassurance-testing/489563101076559)・・・

{% asin_img 4894717115 %}

## [Eric Evans on How Technology Influences DDD](http://www.infoq.com/interviews/Technology-Influences-DDD)

最後は Eric Evans. けっこう InfoQ に登場している。
ちょっと前のやつだと
"[Eric Evans and Brian Foote discuss the state of Software Design](http://www.infoq.com/interviews/eric-evans-brian-foote-design-discussion)" という対談が面白い。
対談相手の Brian Foote は "[Big Ball of Mud](http://www.laputan.org/mud/)" というダメなコードに関する論考で知られるおっさんで、
理想主義者(だと私がおもっている)の Eric Evans と話すことあるんかな・・・
と思っていたがそれなりに盛り上がっていた。レガシーコードと DDD ってのは面白いテーマなのかもしらん。Anti-Corruption Layer について長々と話している。

ところで Anti-Corruption Layer, 訳語では "腐敗防止層" だけど、英語のままの方がなんとなく Absolute Terror Field みたいでかっこいい。
A.C レイヤーと呼びたい。やたらとラッパーを書きたがるプログラマがいたら "A.C レイヤーは心の壁なんだよ" とか諭すわけです。まあどうでもいい。
そもそも A.C レイヤーは別にアンチパターンじゃないしね・・・。

{% asin_img 4798121967 %}

話がそれた。最近だと "[Eric Evans on How Technology Influences DDD](http://www.infoq.com/interviews/Technology-Influences-DDD)" という
インタビューが公開されている。こちらはいまいち歯切れが悪かった。けれどその歯切れの悪さが印象的でもあった。

新しいテクノロジーの登場によって DDD はどう変わるのか？
基本は変わらないと Evans はいう。ドメインの専門家と話し合い、モデルを練り上げていく。
その成熟の果てに生まれるパターンは今より進化したものになるだろう。でも核にあるのは Ubiquitous Languages なんだ。

Evans のそんな答えをよそに、インタビュアは次々と言葉をあびせる。NoSQL はどうおもう？
ブラウザベースのアプリは？リアルタイムデータ、SOA、関数型言語、インメモリデータベースと DDD はどう関係する？
質問への答えはいまいちピリっとしない。人々が新しいテクノロジーを使うのに手一杯な昨今、
抽象的なデザインはまだ深く議論できないのかもしれない。
一方でこうした変化についていかないと、デザインの議論が再燃したとき舞台に立つことが出来ない。
おっさんはどうすればいいんだろうな・・・Eric Evans の煮え切らなさに自らの不安を重ねてしまう。

インタビューの最後に「最近影響をうけたものは何か」と問われ、
Evans はこう答えている: かつて人々は「パターン」「契約による設計」などアイデアに名前をつけて論じたけれど、
このごろの新しいアイデアはフレームワークやプログラミング言語、データベースエンジンなどを通じて表現されるようになった。
今は*書籍ではなく実装が思想を表現する手段になっている*。だからそういうのに気をつけてみるようにしているよ。

これは的をいた指摘だとおもう。そして Evans 自身がどことなく所在なさげな理由もわかる。
Eric Evans は本で思想を語り名声を得た。だからコードが強い今の世界では心細さがあるのだろう。
コードより日本語優勢な半端プログラマの私も同じ不安がある。
むしろその不安が Evans に対する私の視線に影を落としているのかもしれない。
これが [Software Is Eating The World](http://online.wsj.com/article/SB10001424053111903480904576512250915629460.html) な時代の帰結だとしたら胃が痛い。

このインタビューと対になっている講演 "[Acknowledging CAP at the Root -- in the Domain Model](http://www.infoq.com/presentations/CAP-DDD)" は
新しい世代のデザインを議論しようとしており、Evans のがんばりに励まされた。

## まとめ

 * Neal Ford は "{% asin 0321820800,Presentation Patterns %}" を書いていた
 * Martin Fowler は NoSQL ファンになっていた
 * Uncle Bob は Hacker News で叩かれていた
 * Michael Feathers は実証的ソフトウェア工学に目覚めていた
 * Kent Beck は Facebook で PHP を書いてるっぽい
 * Eric Evans は将来が不安(な気がする)
 * Amazon プラグインを書いたため書影多めでアフィリエイトあり。

 * 写真: http://www.flickr.com/photos/adewale_oshineye/423039025/
