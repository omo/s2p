---
layout: post
title: "Gisted: Ideas Worth Pasting"
date: 2013-02-17 21:46
comments: true
categories: 
---

![talk](http://farm9.staticflickr.com/8505/8450686285_e86a993e9d_c.jpg)

[TED](http://www.ted.com/) の動画はまあまあ面白いのでときどき暇つぶしに見るのだけれど,
動画ではなく音だけ (mp3) で聴きたいことがある. 動画ばかりは疲れる.
あとあんどろ機器や iPod に入れて持ち出すのも音声がいい.
動画だとサイズが大きい上にバッテリーの減りも速いからね.

幸い TED は多くの動画にダウンロード用の mp3 を用意してくれている. あとは transcript (原稿) があればいうことない. 
実際, TED のサイトには transcript もある. ただサイトのつくりが持ち出し派につらい. 
持ち出しビューがないし, サイトから手元に切り出そうもコピペがやりにくい.
それに切り出したテキストを Instapaper なんかのテキスト表示機に取り込むのは, いずれにせよ面倒がある.
私は移動中に原稿つきでスピーチ聴きたいだけなんよ. 音声だけで足りるほど英語できない...

というわけでこの面倒を自動化し, ついでにウェブをつけてみた. [Gisted](http://gisted.in/) と命名.

![gisted](https://lh4.googleusercontent.com/-z6aWdfuTo94/USDkN02sfHI/AAAAAAAAV8w/zuomhQ91tcY/s640/02170-gisted-01.png)

やってることはたいしたことない. 指定した URL にある TED の transcript をもってきて整形するだけ. 
TED transcript 専用の Instapaper だと思えばだいたいあってる.
正確には Instapaper やその仲間たちに保存するためのページをつくる. 

TED の URL を渡すと, たとえばこんなページができる:

![capure](https://lh6.googleusercontent.com/-M0siw3q3n9k/USDkN81CR3I/AAAAAAAAV80/I-rctt-zSHU/s640/02170-gisted-02.png)

たいしたことないなりに便利ではあった.
TED 愛好家のみなさまは気が向いたらお試しください: http://gisted.in/

そういえばついでに [InfoQ](http://www.infoq.com/) interviews も対応しておいた. 
このサイトも MP3 があるのに transcript がよみにくい ...
ただしあとから気づいたけど InfoQ interviews の transcript は Instapaper でも十分綺麗にとれるのだった! なんてこと. 
まあ Instapaper ユーザじゃないひとには嬉しい, かもしれない.
他にも対応したほうがいい音声と原稿があったらご一報を.
おもしろしゃべりコンテンツ, 他にもまだあるとおもうんだよなー.

名前のとおりバックエンドに [gist をつかっている](https://gist.github.com/omo/4970352)ため, 
利用に際しては GitHub アカウントが必要です. 

ストレージを自分で持たずにすむのは余暇プログラマにとって大変ありがたい.
Gist に blog ぽいものを書く [gist.io](http://gist.io/) というのも似たようなノリ. 
Gist はサイトを直接見る以外にも使いでがあってよいね. 

----

 * コード: https://github.com/omo/gisted
 * 写真: http://www.flickr.com/photos/75445641@N05/8450686285/

----

Update (2013/2/21): 新しく作る gist を private に変更しました. 
Public gist だと 生成された gist がうっかり gist.github.com に並んでしまうため.
そして private gist って URL が cryptic なだけで認証ないのね...
