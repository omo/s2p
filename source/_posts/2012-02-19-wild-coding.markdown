---
layout: post
title: "殺伐荒野コーディング"
date: 2012-02-19 15:52
comments: true
categories: 
---

![image](http://farm4.staticflickr.com/3209/2809782040_31797330bb_z.jpg?zz=1)

ある朝会社にいくと git.webkit.org がダウンしている。仕事にならない・・・。
意気消沈したが ~~くだを巻く口実ができたとウェブをひやかしていた~~
少し距離をおいて日々の業務を見直すいい機会だと調べものをしていたところ
[ソーシャルコーディングの講演で使われたスライド](http://speakerdeck.com/u/a_matsuda/p/social-coding)
が紹介されておりふんふんと眺めた。

ソーシャルコーディングというのは　GitHub なんかで fork と pull request みたいな対話を通じ
友達百人できるかんじですすめる民主的で人類賛歌なソフトウェア開発のことを指す(と私はおおまかに理解した)。
たしかに GitHub で送った pull request が "Nice! Thanks!!" とかいって受け入れられるとうれしいよね。
プログラマやっててよかった気分になる。

私が仕事でやっているのはコミッタレビュアそれ以外の身分差別と中央集権型 SCM, 
キメてもセキュリティホールができるだけのプログラミング言語からなるプロジェクトで、
ソーシャルコーディング講演の文脈ではルネサンス以前、
いわば暗黒時代の荒野みたいなソフトウェア開発にあたる。

そんな殺伐プロジェクトだけれど、一方でけっこうソーシャルぽさを感じるところもある。
ただここでいうソーシャルはソーシャルは人間賛歌というよりウェブ用語のソーシャルで、要するにグラフがあったりするあれ。
暗黒時代の西洋人もたぶん人付き合いはしてたろうから殺伐としたプロジェクトにソーシャルグラフがあっても不思議ではない。
そして私がかんじるソーシャルぽさの原泉にはプロジェクトの [Bugzilla](https://bugs.webkit.org/) がある。
ソーシャルぽさ...もうちょっと具体的には Twitter ぽさが、
20 世紀の [BTS](http://en.wikipedia.org/wiki/Bug_tracking_system) である Bugzilla からなぜか流れ出している。妙な話ではある。

Bugzilla Stream
============================

多くの BTS 同様、 Bugzilla にはメール通知が備わっている。
自分に関係するバグに変更がおこるとメールが飛んでくる。
このメールを Gmail で jjjkjjj と消化する気分がなんとなく Twitter ぽい。
大半のどうでもいい通知のなかに、ぽつりと興味ぶかいものが混じっている。

モダンな BTS が大抵そうであるように、 Bugzilla は単なる BTS ではなくタスク管理ツールでありコードレビューツールでありパッチマネジメントツールでもある。
原則として全てのチェックインには対応するバグがあり、そのバグにはコードレビューの記録が残っている。
古いソフトウェアなので UX は最悪なものの、依存関係をもつバグやタスク、パッチをはじめとする各種添付ファイル、コードレビューまでが統合された Bugzilla のデータモデルはなかなか本格的だと思う。

そんなツールの性質上、各開発者の動向は多くの部分が Bugzilla 上にあらわれる。
作業をはじめるならバグ(チケット)をつくるし、大きな作業ならそれに加え依存関係の中心に「メタバグ」を登録する。
(["meta" と検索すれば具体例がみつかる。](https://bugs.webkit.org/buglist.cgi?quicksearch=meta))
パッチを書いたらアップロードする。アップロードしたパッチがレビューされコメントがつく。
そのフィードバックを反映してアップロードしなおす。同意、賞賛、罵り合い。
パッチが合意に至るとどこからともなく bot がやってきてパッチをツリーにコミットする。
コミットしたパッチがツリーを壊すとパッチは revert され、テストやビルドの失敗がコメントに記録される。

この一連の出来事が逐一メール通知で届く。

Follow
----------------------------

Bugzilla には誰かのアカウントを *watch* する機能がある。誰かを watch リストに登録すると、
その人の Bugzilla での行動が逐一通知されるようになる。これは Twitter の *follow* にちょっと似ている。
私はチームの同僚のほか、作業範囲が被るよその会社の人数名を watch している。
一時期は有名人を watch していたけれど流量が多すぎて挫けた。このへんも Twitter ぽいかもしれない。

Watch した結果、たとえば follow 相手が投稿したパッチをすかさずレビューしたりできる。
まわりの人の仕事の様子がなんとなくわかる効果もある。
たとえばチームのミーティングでは細かい実装の順番なんて話をしなくても、
登録されるバグから予定が透けて見える。

野次馬としては follower 数のランキングやグラフ構造に興味がある。
残念ながら Bugzilla はその情報を公開していない。

Favorite / RT
----------------------------

それぞれのバグには報告者や担当者のほかに *CC リスト* がある。
コメントやパッチなどバグに動きがあると CC リストの面々に通知がいく。
CC リストは誰でも変更できる。だからあるバグの進展を見届けたいなら CC リストに自分を入れておけばいい。

CC リストにはバグへの関心を示す意味があり、その意味で *favorite* に似ている。
CC リストに入った事実は follower にも知らされるから同時に RT 的といえなくもない。
ホットなバグの CC リストは 10 人 20 人と膨らんでいく。

Google Code など最近の BTS によっては star をつける favorite 機能そのものを備えているけれど、
暗黒の荒野にそんな優しさはない。 CC リストに並ぶのも善意や好意だけとは限らず、やんちゃな変更に睨みを聞かせる用心棒の視線かもしれない。

Mention
----------------------------

CC リストには自分のアカウントだけでなく、他の誰かを登録してもいい。
パッチのレビューをたのむときは、レビュアの候補を CC リストに登録した上で、「すまんがレビューたのむ」とコメントを書く。
意見を求めるとき、持ち主の決まらないバグの担当を探すときなど、レビュー相手以外も CC リストに追加される。
誰かをよびだすこのかんじは *mention* に似ている。

多くのコードレビューシステム同様、 Bugzilla にも明示的にパッチのレビュアを指名する機能がある。
けれど件のプロジェクトでは意図的にその機能を外している。これは指名された人間以外にレビューの機会を与える利点がある。
一方で面倒そうなパッチは誰もレビューしたがらず放置される欠点もある。
ただ組織をまたいだ誰かにレビューを課すのはどのみち現実的ではないから、この判断は妥当な気もしている。

Hashtag
----------------------------

Hashtag... に直接該当するような機能は Bugzilla にない。さすがにね・・・。

特定の話題に関する発言をまとめるという意味では、 *metabug* (master bug) は遠からずなかんじ。
関連のあるバグ/タスクを統括する metabug を個々の具体的なバグに依存させておけば、
その metabug の CC リストに入るだけで依存先バグの変更が通知される。これを hashtag 的に使うことはある。
実際には一部の状態変更しか通知されないのだけれど、あまり困ることはない。

Bot
----------------------------

Twitter 上には多くの *bot* アカウントがある。 Bugzilla にも多数の bot が生息している。
日頃お世話になっているのはアップロードしたパッチのビルドが通るかをチェックしてくれる親切 bot と
レビューの済んだパッチをコミットしてくれる commit bot。
そのほかパッチの中身から妥当なレビュアを割り出して CC リストに追加するおせっかい bot などがいる。

普段は IRC にいる bot がたまに Bugzilla にやってきて伝言を残すこともある。
「このパッチはビルドを壊したので revert したよっ」などと言い残していく。

Discover
----------------------------

さいきん Twitter の UI に追加されたはやりの話題がわかるやつ。も、 やはり Bugzilla にはない・・・

もっとも Twitter と違い、プロジェクトの Bugzilla に何億人ものユーザはいない。
だからプロジェクトの *[コミットログ](http://trac.webkit.org/)* を読めば、
ハイテクデータマイニングがなくても割となんとかなる。
コードレビューとの兼ね合いから、プロジェクトにはコミットログを詳しく書く習慣がある。
おかげでひと通り目を通すと熱心に開発されている箇所がわかる。

専用クライアント(がほしい)
----------------------------

このように Bugzilla は荒野でおきた身辺事情をくまなく伝える暗黒時代のソーシャルメディアとして機能しているのだけれど、
あいにく UX がぱっとしない。 この通知は誰かが私を mention したのだろうか、それとも follow している誰かの動向か。
一日数百通届く通知からはそうした文脈がわからず、ひたすら未読メールとして降り積もっていく。
当初はフィルタやラベルづけをがんばろうとしたけれど音を上げた。 各人の Dashboard, BugzilDeck があればどれだけ救われるか。
ソーシャルコーディング本家の GitHub が羨ましい。ダッシュボードもあるし、コメントではアットマークつきの mention だってできる。

最近は通知メールを処理しきれず無視することが増えた。
かわりに隣の同僚などから物理的にレビューをつつかれている。ごめんなさい・・これが Bugzilla 疲れってやつか・・・。

GitHub ほどの個人志向でなくても、 BTS はもっとソーシャル風味を強めることでよくなるだろう。
[Teambox](http://teambox.com/) などグループウェアの中にはチームプレイの対話的側面を強調したものが増えてきた。
ソフトウェア開発向けツールもはやくそうなってほしいとおもう。

その他のメディアたち
=========================

プロジェクトでは Bugzilla 以外にもいくつかのメディアが対話を担っている。
真っ先に思い浮かぶのは [メーリングリスト](http://lists.webkit.org/mailman/listinfo.cgi/webkit-dev)。
ただメーリングリストに流れる話は重要ではあるものの、議論として面白い投稿はそれほど多くない。
リストへの投稿はプロジェクト全体に向けられたメッセージだから、誰かと対話しようという意思が薄いのだろう。
それに参加者が多いほど立ち入ったことは話しにくくなる。野次馬にとって白いのは圧倒的に Bugzilla だと私は思っている。

もうひとつの対話チャネルは IRC. IRC は逆にとてもソーシャル・・・というかくだをまいてる感じがして、
有益さはともかく私はけっこう好き。挨拶や雑談がとびかうのは IRC だけだ。
常連が Bugzilla の URL を交換しレビューをせがみあっている様子もみられる。
ちょっとずるい・・・実際、 Bugzilla 上ではなかなか反応のないレビュアをつかまえる裏口として IRC を使うことはある。
東京からだと時差でしんどいのが欠点。

気楽さが過ぎてお互いのパッチにケチをつけあっているうち険悪なムードになる場面もあるが、
そういうのがすぐ流れて消えてしまうのも IRC のいいところ。
ウェブブラウザの開発者が HTTP 以外のプロトコルに依存している事実だけは若干後ろめたい気もしている。

最後の対話パスは [オフラインの meetup](https://www.webkit.org/meeting/). 
こういうところで普段話せない人と話すのは楽しいし、
オンラインだと険悪になりがちな話題に決着をつけるなら顔を合わせて議論するほかない。
そういえば [GitHub の東京 Drinkup](https://github.com/blog/960-github-drinkup-tokyo-%E9%A3%B2%E3%81%BF%E6%94%BE%E9%A1%8C) 
は行きたかったなあ. Rails も Node.js もわかんないのでハブられそうだけど...

荒野の人情
----------------------------

Bugzilla 通知の消化、メーリングリスト購読、 git log 閲覧, IRC での世間話... 
こう並べてみると、私は結構な時間をプロジェクトのソーシャルメディアに費やしている。

Twitter をやらなくても日々を暮らしていけるように、
プロジェクトのソーシャルメディアと距離をおいて仕事をすることはできる。
会社員生命に関わる情報は向うからやってくる。
くだをまいてるヒマがあったらコードをかいた方が、たぶんだいぶ仕事ははかどる。

私は目の前に読むものがあるとついひやかしてしまう。あげくの果てにそれで疲れてしまう。だいぶ中毒っぽい。
ただこの中毒的メディアにも少しはいいことがある。

まず、メディアの中に身を投げれば流れがわかる。いま泳ぎやすい場所がわかる。

たとえば Bugzilla をぶらぶらしていると、
いつか直したいと思いつつ放置していたダメなコードに誰かが手をつける場面にでくわすかもしれない。
これはチャンスだ。一人だと手に負えない仕事でも二人ならさっと片付くことがある。
プロジェクト固有の事情もある： お互いレビュアだと相互レビューができてるから仕事の進みがいい。

後回しにして積んでおいた未実装の機能に誰かがパッチをよこすこともある。
そんなときはささっとレビューしてしまおう。仕上がったパッチがチェックインされれば私の仕事は少し進む。
書き手の成果は少し増える。おたがいうれしい。通知を無視していたらしばらくは見逃していたことだろう。

流れに身を任せるだけでなくちいさく声をあげると、流れ自体がかわることもある。

たとえば私はときどき冷やかしで、仕事とは関係ないパッチもレビューしている。
するとたぶん相手から反応のあるレビュアだとみなされるのか、次のパッチでもふたび CC されたりする。
勤務先が同じとおぼしき別の開発者からも CC されはじめる。何かが伝播している。
同業者の性格やレビューへの反応はプロジェクト参加者にとっていい話の肴だろうから、
なにがおきたかは想像がつく。私もよくその手のゴシップで同僚と盛り上がっているし。

色々な事情で本業にヒマができると、適当にみつけた面白そうなバグをなおす。
仕事や寄り道の途中でみつけた見るに耐えないコードを手直しすることもある。
こういう雑用では勤務先以外の人からもよくレビューをうけるため、段々とある種の顔見知りになる。

顔見知りになると、大きな変更の初手のような一見自明でない変更も相手にしてもらえることが増える。
たぶん同じパッチを通りがかりの身で書いても放置されるとおもう。
信頼を得た、グラフの次数が増えた、そう感じる瞬間がやってくる。

もうすぐ今のプロジェクトで働き始めて二年になる。
今は最初のころよりもだいぶ自由に身動きできる。今のほうがずっと楽しい。
それはコードベースへの理解が深まったのと同時に、人々の中に自分の根が広がったからでもある。
バグとパッチで切り結ぶ荒くれものばかりとおもってた荒野の根城に居場所がみつかる。
ソーシャルコーディングというよりワイルドコーディングってかんじだけど、それも悪くない。

写真: http://www.flickr.com/photos/jay_que/2809782040/