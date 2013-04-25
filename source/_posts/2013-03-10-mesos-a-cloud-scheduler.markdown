---
layout: post
title: "Mesos: A Cloud Scheduler (1)"
date: 2013-03-10 20:02
comments: true
categories: 
---

![image](http://farm3.staticflickr.com/2584/4027996707_0378a6145a_z.jpg)

WIRED に "[Return of the Borg: How Twitter Rebuilt Google’s Secret Weapon](http://www.wired.com/wiredenterprise/2013/03/google-borg-twitter-mesos)"
という記事があった。Twitter が Mesos というクラスタ管理のソフトウェアを開発しており、
それは検索会社のなんとかいうシステムみたいなもんらしいよ、という話。

不勉強につきそのなんとかいうシステムのことはよく知らないけれど、
去年の今頃開かれた [Twitter の Open House](http://www.zusaar.com/event/250005) ([ASCII のレポート](http://weekly.ascii.jp/elem/000/000/082/82970/)) をのぞかせてもらった際、
Twitter 社のエライ人 Rob Benson が 「これからインフラは Mesos でいく!!」
と熱心に話していたのを[覚えている](https://plus.google.com/106957273834544340771/posts/EcZPRT2YRXy)。
WIRED の記事によれば、Mesos ベースに移行したマシンは二割。もう全部移行する勢いなのかとおもってたけど、インフラを変えるのは大変なのだろう。
そういえば去年のその講演でも "これは検索会社のなんとかいうシステムみたいなもので..." と Mesos を説明しており、西海岸のオープンカルチャーに笑ってしまった。
みたいなものって言われても困る。赤坂はサンフランシスコじゃないからね。

Mesos は もともと Berkley 大学のクラウド研究所であるところの 
RAD Lab で生まれたリサーチプロジェクト。
けっこう[論文もあったりする](http://incubator.apache.org/mesos/research.html)。
システムの概要を知るには WIRED の記事よりは [NSDI に出された記事](http://incubator.apache.org/mesos/papers/nsdi_mesos.pdf) を読んだほうが良い。

(そういえば RAD Lab は "[Above the Clouds: A Berkeley View of Cloud Computing](http://radlab.cs.berkeley.edu/publication/285)" を書いたところだ、
という紹介を[むかしちょっとだけ書いた](http://stepped.dodgson.org/?date=20090214)。)

Mesos はまた [Apache Incubator](http://incubator.apache.org/mesos/) にホストされたオープンソースプロジェクトでもある。
折しも Twitter が Scala を中心とした JVM スタックに移行した話題で盛り上がっていた私は、
ハイテク化しつつある Rails の会社が検索会社の秘密兵器相当(WIRED 曰く)をオープンソースで開発中だなんて中身を覗かない手はないとチェックアウトした・・・まま文章にしそびれていた。
いい機会なので読み直し中。色々面白いので紹介したい。

Cloud Scheduler?
------------------------

クラウド・スケジューラとは何か。
これは私がカッコつけて呼んでみただけの技術的にはまったく不正確な用語で、
世間的にはクラスタ管理システムなどと呼ぶ方がたぶん正しい。
ただクラスタ管理だと一般的すぎてまぎらわしくもある。
Mesos はクラスタ内で利用可能な計算資源を追跡し、ユーザの求めに応じてそれを割り振る。
スケジューラと呼ぶ方が特徴を捉えてはいると思う。

たとえば Hadoop だと [hadoop](http://hadoop.apache.org/docs/r1.0.4/commands_manual.html) コマンドで
Mapper とかの jar をクラスタに送りつけ色々計算する。
このとき Hadoop は指定された優先度に応じて空きマシンの CPU にタスクを割り振る。
あるいは Heroku なら [Procfile](https://devcenter.heroku.com/articles/procfile) に CPU 数を書いてアプリケーションを push する。
Heroku は空きノードを探して該当アプリケーションをデプロイする。
こういうふうに **このプログラムをこのくらいの計算資源(メモリやCPU)を使って動かしたい** と指定するとよろしくはからってくれるのがスケジューラ、Mesos の仕事だ。

資源割り当ては大きな分散システムにとって一般的な問題。実際 Hadoop の中にはそんな仕組みがあるわけだけれど、同じ事を Hadoop 以外でもやりたい。
それに計算資源を一元管理したい思惑もある。たとえば Hadoop のクラスタがヒマなときにその CPU を他に使いたくても、計算資源が一元管理されていないと柔軟に振り分けられない。
フロントエンドへのアクセスが少ない時間帯に CPU を間借りしてバッチをまわしたい、なんてのも同じ。

資源割り当てはウェブ企業にとって気になる問題らしく、
Facebook も [Corona](http://www.facebook.com/notes/facebook-engineering/under-the-hood-scheduling-mapreduce-jobs-more-efficiently-with-corona/10151142560538920) 
という名前で Hadoop 用のスケジューラを書き直していた。これは単純に性能改善のためだとされている。
Hadoop 本体には内蔵スケジューラの一般化を目指す [YARN](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html) というプロジェクトがあるという。

Hadoop とは別に Mesos を推す Twitter、フォークで Hadoop の性能改善に注力する Facebook、自身を一般化しようとする本家 Hadoop。
Twitter は Scala でバックエンドを構築してみたり買収したストリーム計算のテクノロジ ([Storm](https://github.com/nathanmarz/storm)) が 
Clojure で書いてあったりして Hadoop ばかりを相手にしてもいられず、
Facebook は [Hive](http://hive.apache.org/) だなんだと Hadoop の上で頑張る路線を推し進めた果てに Hadoop のスケーラビリティにしびれを切らし、
本家は吹き荒れるフォークたちに気をもみ...それぞれのスケジューラは開発元の事情を映し出している気もして野次馬的には面白い。

Mesos ツリー概観
------------------------

雑談はこのくらいにして[コード](https://github.com/apache/mesos/)を眺めてみよう。

ぼんやり数えるとコードは 10 万行くらいある。ただ大半はサードパーティのライブラリ。統計情報を見せる Web UI のコードも多い。
そのほかテストや細々したスクリプトを差し引くと、Mesos 本体は 2-3 万行くらいにおさまっている。冷やかすにはちょうどいい大きさだ。
NSDI の記事には 1 万行と書いてあったけれど、プロダクション向けに色々書き足したのだろう。

西海岸&hearts;最新テクノロジーという私の期待に反し、コードの大半は **C++** で書かれている。ビルドは Automake ・・・。
さっそくがっかり。Scala はどうした！と非難したくなるが、もともと RAD Lab のプロジェクトなので仕方ない。

コードは [include](https://github.com/apache/mesos/tree/trunk/include) と [src](https://github.com/apache/mesos/tree/trunk/src) の二箇所が主。
Mesos は Hadoop など既存のシステムと連携してうごくため、`include` 下に組み込み用の API が定義されている。

でもさ、そもそも Hadoop は Java だからヘッダファイルがあってもダメじゃん・・・とおもったら、
[src/java](https://github.com/apache/mesos/tree/trunk/src/java) に Java ポートがあった。JNI 経由で C++ のインターフェイスを呼んでいる。
あちこちのサーバに Jar を送りつける分散システムに JNI をつかっちゃって shared library の扱いは大丈夫なのか。やや不安になる。
まあ Mesos 配下のサーバには Mesos 一式がインストールされているわけだから、バイナリ不在の心配はないのだろう。それでも IPC の方が無難な気がするけれど。

なお他言語バインディングは Java の他になぜか Python がある。Ruby どこいった・・・。


libprocess
------------------------

気を取り直して `src/` 以下の C++ を眺めると、何かフレームワークらしきものが使われているのに気づく。

改めてツリーをしらべなおす。 どうも [third_party/libprocess](https://github.com/apache/mesos/tree/trunk/third_party/libprocess) がそのフレームワークらしい。
**libprocess** って初耳だな・・・と思ったらそれもそのはず。
これは [Mesos の作者がつくったライブラリ](http://www.eecs.berkeley.edu/~benh/libprocess/)だった。事実上 Mesos でしか使われていない。
Mesos 以前の個人プロジェクトでつかったものを流用した様子。コードはまあまあ大きく 1.5 万行くらい。Mesos 本体とおなじくらいの規模感。

libprocess は C++ でノンブロッキングのサーバを書くためのフレームワークだ。
そしてノンブロッキングな流派のなかでも、libprocess は actor スタイルを採用している。
これで libprocess という名前の由来も想像がつくとおもう。libprocess の API は **Erlang の強い影響下にある**。
これは~~中二病こじらせた~~かっこいい。

なお C++ の分散システムで Erlang ごっこをしてしまう現象はときどき見かける。
たとえば [Jubatus](https://github.com/jubatus/jubatus/tree/master/src/jubavisor) にもそんな痕跡があった。
気持ちはわかるけどそれ process じゃないと思うんだぜ・・・。

Process と PID
--------------------

[libprocess の API surface](https://github.com/apache/mesos/tree/trunk/third_party/libprocess/include/process) はけっこう広い。
その中でも中心となるのがアクターとしてユーザ定義のロジックを持つ Process と、Process を特定するための PID だ。

まず **Process** の定義をながめよう。

```c++ process.hpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/include/process/process.hpp
class ProcessBase : public EventVisitor
{
public:
  ...
  UPID self() const { return pid; }
  ...
  virtual void initialize() {}
  virtual void finalize() {}
  virtual void exited(const UPID& pid) {}
  virtual void lost(const UPID& pid) {}
  ...

  // Puts a message at front of queue.
  void inject(
      const UPID& from,
      const std::string& name,
      const char* data = NULL,
      size_t length = 0);
 
  // Sends a message with data to PID.
  void send(
      const UPID& to,
      const std::string& name,
      const char* data = NULL,
      size_t length = 0);
  ...
  UPID link(const UPID& pid);
  
  ...
  typedef std::tr1::function<void(const UPID&, const std::string&)>
  MessageHandler;

  // Setup a handler for a message.
  void install(
      const std::string& name,
      const MessageHandler& handler)
  {
    handlers.message[name] = handler;
  }
  ...

private:
  ...
  
  std::deque<Event*> events;

  // Delegates for messages.
  std::map<std::string, UPID> delegates;

  // Handlers for messages and HTTP requests.
  struct {
    std::map<std::string, MessageHandler> message;
    std::map<std::string, HttpRequestHandler> http;
  } handlers;

  // Active references.
  int refs;

  // Process PID.
  UPID pid;
};
```

メッセージを送受信する API (`send()`, `inject()`)や、ユーザ定義のメッセージ用コールバックを登録する API (`install()`) がある。
Process にメッセージを配送するのはフレームワークの仕事。
そのほか `link()` なんて API に Erlang 愛を見いだせる。libprocess は Erlang 風にアクター (Process) 監視の仕組みを持っている。

オブジェクトが持つ状態は受信したイベント(メッセージ)キューやメソッドハンドラのテーブル、そしてオブジェクトの ID たる PID など。

Process/ProcessBase はよくある [CRTP](http://en.wikipedia.org/wiki/Curiously_recurring_template_pattern) を成す.

```c++ process.hpp
template <typename T>
class Process : public virtual ProcessBase {
public:
  virtual ~Process() {}

  // Returns pid of process; valid even before calling spawn.
  PID<T> self() const { return PID<T>(dynamic_cast<const T*>(this)); }

protected:
  // Useful typedefs for dispatch/delay/defer to self()/this.
  typedef T Self;
  typedef T This;
};
```

`self()` とかもうね...

アプリケーションはこの **Process** クラスを継承して適当なハンドラ関数を実装し、
それを `install()` して受信に備える。そのほか `exited()` などの lifecycle コールバックで後始末などをしてもよい。

`send()` や `install()` といった API のシグネチャから、 libprocess のメッセージは文字列をキーとした文字列なのがわかる。
メッセージの内部表現をみてみると・・・

```c++ message.hpp
...
struct Message
{
  std::string name;
  UPID from;
  UPID to;
  std::string body;
};
...
```

たしかに文字列の名前がついている。それに文字列の `body`。

プロセスを指定する **PID** は, IP アドレスとポート、そして libprocess インスタンス内の名前である ID からなる。

UPID (Untyped PID) と typed PID がわかれているのはちょっとおしゃれ。

```c++ pid.hpp
struct UPID
{
...
  UPID(const std::string& id_, uint32_t ip_, uint16_t port_)
    : id(id_), ip(ip_), port(port_) {}

  UPID(const char* s);

  UPID(const std::string& s);
...
  std::string id;
  uint32_t ip;
  uint16_t port;
};

template <typename T = ProcessBase>
struct PID : UPID
{
...
};
```

直列化のための文字列表現もある。 `id@ip:port` みたいの。

```c++ pid.hpp
ostream& operator << (ostream& stream, const UPID& pid)
{
  // Call inet_ntop since inet_ntoa is not thread-safe!
  char ip[INET_ADDRSTRLEN];
  if (inet_ntop(AF_INET, (in_addr *) &pid.ip, ip, INET_ADDRSTRLEN) == NULL)
    memset(ip, 0, INET_ADDRSTRLEN);

  stream << pid.id << "@" << ip << ":" << pid.port;
  return stream;
}
```

HTTP
--------

`Process` クラスはメッセージベースの通信とは別に HTTP をサポートしている。

```c++ process.hpp
class ProcessBase : public EventVisitor
{
...
  typedef std::tr1::function<Future<http::Response>(const http::Request&)>
  HttpRequestHandler;

  // Setup a handler for an HTTP request.
  bool route(
      const std::string& name,
      const HttpRequestHandler& handler)
  {
    if (name.find('/') != 0) {
      return false;
    }
    handlers.http[name.substr(1)] = handler;
    return true;
  }
...
};
```

RPC-like
-----------------

実際のアプリケーションが `Process` を直接継承することは多くない。
かわりにバイナリからオブジェクトへの復号化をフレームワークにまかせ、 RPC ぽく使う。
オブジェクトの直列化には・・・どういうわけか **Protobuf** をつかう。Thrift どこいった・・・。

```c++ protobuf.hpp
template <typename T>
class ProtobufProcess : public process::Process<T>
{
...
protected:
  void send(const process::UPID& to,
            const google::protobuf::Message& message)
  {
    std::string data;
    message.SerializeToString(&data);
    process::Process<T>::send(to, message.GetTypeName(),
                              data.data(), data.size());
  }
...
  template <typename M>
  void install(void (T::*method)(const M&))
  {
    google::protobuf::Message* m = new M();
    T* t = static_cast<T*>(this);
    protobufHandlers[m->GetTypeName()] =
      std::tr1::bind(&handlerM<M>,
                     t, method,
                     std::tr1::placeholders::_1);
    delete m;
  }
...
  template <typename M>
  static void handlerM(T* t, void (T::*method)(const M&),
                       const std::string& data)
  {
    M m;
    m.ParseFromString(data);
    if (m.IsInitialized()) {
      (t->*method)(m);
    } else {
      LOG(WARNING) << "Initialization errors: "
                   << m.InitializationErrorString();
    }
  }
...
};
```

そして直列化形式はなぜか `SerializeToString()`... もう JSON でよいのではと思わなくもない。まあクラスを生成する仕組みが欲しかったのかもね。

この手の簡易 RPC が簡単につくれるのは protobuf をはじめとする各種直列化ライブラリの便利なところだとはおもう。
なお protobuf の [service](https://developers.google.com/protocol-buffers/docs/proto#services) 宣言は使わない。
メッセージは戻り値なしの 1-way。インストールしたハンドラ名に基づいて分配される。

戻り値のかわりに `reply()` で送信元にメッセージを送ることはできる。
ただし見ての通り、リクエストとレスポンスの対応をとるリクエスト ID みたいのはない。運用でカバーするものらしい。

```c++ protobuf.hpp
template <typename T>
class ProtobufProcess : public process::Process<T>
{
...
  virtual void visit(const process::MessageEvent& event)
  {
    if (protobufHandlers.count(event.message->name) > 0) {
      from = event.message->from; // For 'reply'.
      protobufHandlers[event.message->name](event.message->body);
      from = process::UPID();
    } else {
      process::Process<T>::visit(event);
    }
  }
...
  process::UPID from; // Sender of "current" message, accessible by subclasses.
...
  void reply(const google::protobuf::Message& message)
  {
    CHECK(from) << "Attempting to reply without a sender";
    std::string data;
    message.SerializeToString(&data);
    send(from, message);
  }
};
```

ProcessManager
-------------------------

`Process` クラスを継承して色々できるのはわかったけど、
それをどう使えばいいのだろう。[ちいさいサンプル](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/examples/example.cpp)
が入っていたから眺めてみよう。

```c++ example.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/examples/example.cpp
class MyProcess : public Process<MyProcess>
{
...
};

...

int main(int argc, char** argv)
{
  MyProcess process;
  PID<MyProcess> pid = spawn(&process);
...
  dispatch(pid, &MyProcess::func1);
  dispatch(pid, &MyProcess::func2, 42);
  wait(pid);
  return 0;
}
```

この例はプロセス内通信だけれど、要するに `spawn()` で Process のインスタンスをフレームワークに登録すればいいらしい。
そうすれば登録時に発行される PID を介し `dispatch()` 関数でメッセージやりとりできるようになる。

...と平静を装いつつ、ただよう不穏な気配に眉をひそめる。
誰が Process と PID の対応を管理している？イベントループ、メッセージキューはどこだ？
`spawn()` を覗いてみる・・・

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
...
// Active ProcessManager (eventually will probably be thread-local).
static ProcessManager* process_manager = NULL;
...
UPID spawn(ProcessBase* process, bool manage)
{
  process::initialize();

  if (process != NULL) {
...
    return process_manager->spawn(process, manage);
  } else {
    return UPID();
  }
}
```

**ProcessManager** なる不吉な名前のクラスがあった。しかもグローバル(static)変数。 こいつが管理しているらしい。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
class ProcessManager
{
public:
  ProcessManager(const string& delegate);
  ~ProcessManager();

  ProcessReference use(const UPID& pid);

  bool handle(
      const Socket& socket,
      Request* request);

  bool deliver(
      ProcessBase* receiver,
      Event* event,
      ProcessBase* sender = NULL);

  bool deliver(
      const UPID& to,
      Event* event,
      ProcessBase* sender = NULL);

  UPID spawn(ProcessBase* process, bool manage);
  void resume(ProcessBase* process);
  void cleanup(ProcessBase* process);
  void link(ProcessBase* process, const UPID& to);
  void terminate(const UPID& pid, bool inject, ProcessBase* sender = NULL);
  bool wait(const UPID& pid);

  void enqueue(ProcessBase* process);
  ProcessBase* dequeue();

  void settle();

private:
  // Map of all local spawned and running processes.
  map<string, ProcessBase*> processes;
  synchronizable(processes);

  ...

  // Queue of runnable processes (implemented using list).
  list<ProcessBase*> runq;
  synchronizable(runq);

  // Number of running processes, to support Clock::settle operation.
  int running;
};
```

`ProcessManager` は process.cpp で定義されている。
メンバ変数にはプロセス ID である文字列とプロセスオブジェクトを対応づけるテーブル `ProcessManager::processes`, 
実行可能な(=消化するメッセージがある)プロセス一覧をもつキュー `ProcessManager::runq` などがある。
システム全体でキューが一本だけ。割と素朴なスケジューリングをするのだと想像できる。

メッセージの送受信
--------------------------

さて Actor たる Process クラスがあり、その一覧を管理する ProcessManager クラスがあり、
Process は自分が受け取ったイベントの一覧を持っており、ProcessManager は実行可能な Process のリストを知っている。

![image](http://farm9.staticflickr.com/8094/8553532695_efcf31d50f_z.jpg)

ProcessManager にメッセージを送りつければそれを宛先 Process まで配信してくれるのだろう。
さてどうやってメッセージを送ったものか。というと、 `post()` 関数をつかう。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
void post(const UPID& to, const string& name, const char* data, size_t length)
{
  process::initialize();

  if (!to) {
    return;
  }

  // Encode and transport outgoing message.
  transport(encode(UPID(), to, name, string(data, length)));
}

...

static void transport(Message* message, ProcessBase* sender = NULL)
{
  if (message->to.ip == __ip__ && message->to.port == __port__) {
    // Local message.
    process_manager->deliver(message->to, new MessageEvent(message), sender);
  } else {
    // Remote message.
    socket_manager->send(message);
  }
}
```

`post()` は `transport()` に処理を移譲する。 
`transport()` はメッセージの宛先が同一 OS プロセス内なら `process_manager->deliver()` を、
別プロセスなら `socket_manager->send()` を呼び出す。
あたらしい global な manager 様が登場したけれど恐れ多いのであとまわしにして、
プロセス内メッセージングの `process_manager->deliver()` を調べよう。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
bool ProcessManager::deliver(
    ProcessBase* receiver,
    Event* event,
    ProcessBase* sender)
{
...
  receiver->enqueue(event);

  return true;
}
```

なんてことはない、reciver プロセスのキューにイベントをつめておしまい...

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
void ProcessBase::enqueue(Event* event, bool inject)
{
  CHECK(event != NULL);

  // 事前に登録された条件に基づきメッセージをフィルタする仕組み.
  synchronized (filterer) {
    if (filterer != NULL) {
      bool filter = false;
      struct FilterVisitor : EventVisitor
      {
         ...
      } visitor(&filter);

      event->visit(&visitor);

      if (filter) {
        delete event;
        return;
      }
    }
  }

  lock();
  {
    if (state != FINISHED) {
      if (!inject) {
        events.push_back(event);
      } else {
        events.push_front(event);
      }

      if (state == BLOCKED) {
        state = READY;
        // ProcessManager に通知してワーカスレッドを起こす
        process_manager->enqueue(this); 
      }

      CHECK(state == BOTTOM ||
            state == READY ||
            state == RUNNING);
    } else {
      delete event;
    }
  }
  unlock();
}

```

..かとおもったけど `enqueue()` ではメッセージをフィルタリングしたり ProcessManager を起こしたり、それなりに色々やっていた。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
void ProcessManager::enqueue(ProcessBase* process)
{
  ...
  synchronized (runq) {
    CHECK(find(runq.begin(), runq.end(), process) == runq.end());
    runq.push_back(process);
  }
    
  // Wake up the processing thread if necessary.
  gate->open();
}
```

`ProcessManager::enqueue()` では受信したメッセージによって実行可能になった process を
処理待ちキュー `runq` に詰め、それからキューを消化するワーカースレッドに通知を送っている。(`gate` は `pthread_cond_t` のラッパです。)

キューからメッセージをとりだすのは `ProcessManager::dequeue()`。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
ProcessBase* ProcessManager::dequeue()
{
  ...

  ProcessBase* process = NULL;

  synchronized (runq) {
    if (!runq.empty()) {
      process = runq.front();
      runq.pop_front();
      // Increment the running count of processes in order to support
      // the Clock::settle() operation (this must be done atomically
      // with removing the process from the runq).
      __sync_fetch_and_add(&running, 1);
    }
  }

  return process;
}
```

そしてこれを呼ぶのは `schedule()` 関数。さっき `open()` されていた gate をまっているのはこのループ。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
void* schedule(void* arg)
{
  do {
    ProcessBase* process = process_manager->dequeue();
    if (process == NULL) {
      Gate::state_t old = gate->approach();
      process = process_manager->dequeue();
      if (process == NULL) {
        gate->arrive(old); // Wait at gate if idle.
        continue;
      } else {
        gate->leave();
      }
    }
    process_manager->resume(process);
  } while (true);
}
```

この関数は libprocess の初期化中にワーカスレッドとして起動される。

```c++ process.cpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/process.cpp
void initialize(const string& delegate)
{
  ...
  for (int i = 0; i < cpus; i++) {
    pthread_t thread; // For now, not saving handles on our threads.
    if (pthread_create(&thread, NULL, schedule, NULL) != 0) {
      LOG(FATAL) << "Failed to initialize, pthread_create";
    }
  }
  ...
}
```

ワーカスレッドは CPU の数だけつくられるようだ。
[SEDA](http://www.eecs.harvard.edu/~mdw/proj/seda/) から脈々と生き続ける
ノンブロッキングでマルチスレッドの血筋・・・なのはいいとして、
起動したスレッドを止める様子がないのは心配。
サーバって graceful に停止できないと [Valgrind](http://valgrind.org/) や [ASAN](http://www.chromium.org/developers/testing/addresssanitizer) で
メモリリークをチェックするのが大変だとおもうんだけど、このスレッド自体は何も資源を持っていないので放置してプロセス抜けても大丈夫ということなのかなあ。男らしい・・・。

それはさておき `ProcessManager::resume()` をみると...

```c++ process.cpp
void ProcessManager::resume(ProcessBase* process)
{
  __process__ = process; // __process__ はスレッドローカル変数

  ...
  bool blocked = false;
  ...

  while (!terminate && !blocked) {
    Event* event = NULL;

    process->lock();
    {
      if (process->events.size() > 0) {
        event = process->events.front();
        process->events.pop_front();
        process->state = ProcessBase::RUNNING;
      } else {
        process->state = ProcessBase::BLOCKED;
        blocked = true;
      }
    }
    process->unlock();

    if (!blocked) {
      ...

      // Now service the event.
      try {
        process->serve(*event);
      } catch (const std::exception& e) {
        std::cerr << "libprocess: " << process->pid
                  << " terminating due to "
                  << e.what() << std::endl;
        terminate = true;
      } catch (...) {
        std::cerr << "libprocess: " << process->pid
                  << " terminating due to unknown exception" << std::endl;
        terminate = true;
      }

      delete event;

      if (terminate) {
        cleanup(process);
      }
    }
  }

  __process__ = NULL;

  CHECK_GE(running, 1);
  __sync_fetch_and_sub(&running, 1);
}
```

渡されたプロセスのキューからイベントを `pop_front()` して、排他処理やリトライなどをしつつプロセスにそれを `serve()` するのだった。
この `resume()` が ProcessManager のメソッドである必要がどこにあるのか、
あとスレッドローカルの `operator=()` を定義してるヒマがったらスレッドローカルいらないデザインにしてほしい、
そして `catch(...)` はヤバいだろう・・・など色々と弱音を吐きたくなったりもするけれど私は元気です。

とにかく `post()` されたイベント(メッセージ)は Process のイベントキューに入り、Process は ProcessManager の実行待ちキューに入り、次にワーカスレッド `schedule()` に取り出され、
スレッドはキューから Process をとりだし、Process に溜まっていたイベントをその Process 自身に食わせて消化する。

同一 OS プロセス内 Process のメッセージ通信がどうおこるかはこれでだいたいわかった。
次はプロセスをまたいだ通信に目を向け、見て見ぬふりをしたもう一人のマネージャに話を進めよう。


SocketManger
--------------------

```c++ process.cpp
class SocketManager
{
public:
...
  void send(Encoder* encoder, int s, bool persist);
  void send(const Response& response, int s, bool persist);
  void send(Message* message);
...
  Socket accepted(int s);
  void close(int s);
...

  // Map from UPID (local/remote) to process.
  map<UPID, set<ProcessBase*> > links;

  // Collection of all actice sockets.
  map<int, Socket> sockets;

  // Collection of sockets that should be disposed when they are
  // finished being used (e.g., when there is no more data to send on
  // them).
  set<int> dispose;

  // Map from socket to node (ip, port).
  map<int, Node> nodes;

  // Maps from node (ip, port) to temporary sockets (i.e., they will
  // get closed once there is no more data to send on them).
  map<Node, int> temps;

  // Maps from node (ip, port) to persistent sockets (i.e., they will
  // remain open even if there is no more data to send on them).  We
  // distinguish these from the 'temps' collection so we can tell when
  // a persistant socket has been lost (and thus generate
  // ExitedEvents).
  map<Node, int> persists;

  // Map from socket to outgoing queue.
  map<int, queue<Encoder*> > outgoing;
...
};
```

何種類かのテーブルを管理している。Boost には bimap あるで・・・とかまあそういう姑発言はさておき、
`int` はソケットの fd だとおもえばよい。 `Node` はリモートにある OS プロセスを抽象している。

```c++ process.cpp
class Node
{
public:
  Node(uint32_t _ip = 0, uint16_t _port = 0)
    : ip(_ip), port(_port) {}
...
  uint32_t ip;
  uint16_t port;
};

```

まあ抽象といってもこれだけなのだけれど・・・

ネットワークのイベントループには [libev](http://software.schmorp.de/pkg/libev.html) が使われており、
そこに [encoder.hpp](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/decoder.hpp), 
[decoder.hpp](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/decoder.hpp) からなるマイクロフレームワークがかぶせてある。
このコードはどうでもいい。ただ libprocess 間の通信には HTTP を使っていることがわかる。

なお libev のイベントループも専用のスレッドを持っている。

```c++ process.cpp
void* serve(void* arg)
{
  ev_loop(((struct ev_loop*) arg), 0);

  return NULL;
}
...
void initialize(const string& delegate)
{
  ...
#ifdef __sun__
  loop = ev_default_loop(EVBACKEND_POLL | EVBACKEND_SELECT);
#else
  loop = ev_default_loop(EVFLAG_AUTO);
#endif // __sun__

  ev_async_init(&async_watcher, handle_async);
  ev_async_start(loop, &async_watcher);

  ev_timer_init(&timeouts_watcher, handle_timeouts, 0., 2100000.0);
  ev_timer_again(loop, &timeouts_watcher);

  ev_io_init(&server_watcher, accept, __s__, EV_READ);
  ev_io_start(loop, &server_watcher);
  ...
  pthread_t thread; // For now, not saving handles on our threads.
  if (pthread_create(&thread, NULL, serve, loop) != 0) {
    LOG(FATAL) << "Failed to initialize, pthread_create";
  }
  ...
}
```

SocketManager のコードは特段面白くないのであまり深くは立ち入らない。
ソケットの accept やらなんやらはすっとばしてデータの受信部分だけはながめておこう。

```c++ process.cpp
void recv_data(struct ev_loop* loop, ev_io* watcher, int revents)
{
  DataDecoder* decoder = (DataDecoder*) watcher->data;
  ...
  while (true) {
    ...
    length = recv(s, data, size, 0);
    ...
      // Decode as much of the data as possible into HTTP requests.
      const deque<Request*>& requests = decoder->decode(data, length);

      if (!requests.empty()) {
        foreach (Request* request, requests) {
          process_manager->handle(decoder->socket(), request);
        }
      }
    ...
  }
}
```

受信したデータが Request オブジェクトとして復号化され、ProcessManager に受け渡されているのがわかる。
ここがプロセス間通信の終点。

ProcessManager はソケットみたいな IO に依存しないクラスなのかとおもってたけど `socket` をわたしてるね。
オブジェクトの責任分担がリベラルだ。歌って踊れるクラスたちよ...

```c++ process.cpp
bool ProcessManager::handle(
    const Socket& socket,
    Request* request)
{
  CHECK(request != NULL);

  // Check if this is a libprocess request (i.e., 'User-Agent:
  // libprocess/id@ip:port') and if so, parse as a message.
  if (libprocess(request)) {
    Message* message = parse(request);
    if (message != NULL) {
      delete request;
      // TODO(benh): Use the sender PID in order to capture
      // happens-before timing relationships for testing.
      return deliver(message->to, new MessageEvent(message));
    }

    VLOG(1) << "Failed to handle libprocess request: "
            << request->method << " " << request->path
            << " (User-Agent: " << request->headers["User-Agent"] << ")";

    delete request;
    return false;
  }
  ...
}

```

HTTP のリクエストが libprocess の Message へとパースされ、宛先プロセスに `deliver()` されるのがわかる。

Future
------------------

さて、libprocess にはスレッド周りのクラスが色々はいっている。特にあちこちで使われているのが **Future**。
普通に書くとブロッキングしそうな API は、だいたい Future で非同期化されている。

たとえば libprocess には `Statistics` というメトリクス集計クラスがある。Statistics クラスの API は Future でモデルされている。

``` c++ statistics.hpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/include/process/statistics.hpp
class Statistics
{
public:
  Statistics(const Duration& window);
  ~Statistics();

  // Returns the time series of a statistic.
  process::Future<std::map<Seconds, double> > timeseries(
      const std::string& context,
      const std::string& name,
      const Option<Seconds>& start = None(),
      const Option<Seconds>& stop = None());

  // Returns the latest value of a statistic.
  process::Future<Option<double> > get(
      const std::string& context,
      const std::string& name);
  ...
};
```

ちなみになぜ集計の結果取得みたいのが非同期かというと、
独立した Process である [StatisticsProcess](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/statistics.cpp)が集計処理をしているから。
アクター大活躍。libprocess の中にかぎらず、Mesos 自体の API も Future 主体で書かれている。

その Future を見てみよう:

```c++ future.hpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/include/process/future.hpp
// Definition of a "shared" future. A future can hold any
// copy-constructible value. A future is considered "shared" because
// by default a future can be accessed concurrently.
template <typename T>
class Future
{
public:
  // Constructs a failed future.
  static Future<T> failed(const std::string& message);


  // Helpers to get the current state of this future.
  bool isPending() const;
  bool isReady() const;
  bool isDiscarded() const;
  bool isFailed() const;
  ...
  bool discard();
  ...
  // Waits for this future to become ready, discarded, or failed.
  bool await(const Duration& duration = Seconds(-1.0)) const;

  // Return the value associated with this future, waits indefinitely
  // until a value gets associated or until the future is discarded.
  T get() const;

  // Returns the failure message associated with this future.
  std::string failure() const;

  // Installs callbacks for the specified events and returns a const
  // reference to 'this' in order to easily support chaining.
  const Future<T>& onReady(const ReadyCallback& callback) const;
  const Future<T>& onFailed(const FailedCallback& callback) const;
  const Future<T>& onDiscarded(const DiscardedCallback& callback) const;
  const Future<T>& onAny(const AnyCallback& callback) const;

  // Installs callbacks that get executed when this future is ready
  // and associates the result of the callback with the future that is
  // returned to the caller (which may be of a different type).
  template <typename X>
  Future<X> then(const std::tr1::function<Future<X>(const T&)>& f) const;

  template <typename X>
  Future<X> then(const std::tr1::function<X(const T&)>& f) const;

  // Helpers for the compiler to be able to forward std::tr1::bind results.
  template <typename X>
  Future<X> then(const std::tr1::_Bind<X(*(void))(void)>& b) const
  {
    return then(std::tr1::function<X(const T&)>(b));
  }
...
private:
  friend class Promise<T>;
...
  enum State {
    PENDING,
    READY,
    FAILED,
    DISCARDED,
  };

  int* refs;
  int* lock;
  State* state;
  T** t;
  std::string** message; // Message associated with failure.
  std::queue<ReadyCallback>* onReadyCallbacks;
  std::queue<FailedCallback>* onFailedCallbacks;
  std::queue<DiscardedCallback>* onDiscardedCallbacks;
  std::queue<AnyCallback>* onAnyCallbacks;
  Latch* latch;
};

... // Promise<T> の定義がつづく...
```

この Future は [Java の Future](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Future.html) よりは
[Scala の Future](http://docs.scala-lang.org/overviews/core/futures.html) に近い。ノンブロッキングがメインで、ブロッキングにもなる。

libprocess のようなノンブロッキング主体のフレームワークで、 `Future::get()` のようなブロッキング API を提供するのが良いことなのか、私にはわからない。
あまりカジュアルにブロックされてしまうとループが回らず性能を落としてしまう。Scala 版 Future の API はブロッキングすると目立つ嫌がらせの仕組みがあるが、
この Future にはそれがない。
(ついでに調べてみると、 [Finagle](http://twitter.github.com/finagle/) がつかっている 
[twitter.util の Future](https://github.com/twitter/util/blob/master/util-core/src/main/scala/com/twitter/util/Future.scala) にも
カジュアルブロック API がある。しかもよりによって `apply()`...)

synchronized
-------------

最近の C++ なコードをみると、だいたい Java を模した `synchronized()` マクロが定義されている。
[Facebook Folly](https://github.com/facebook/folly/blob/master/folly/Synchronized.h),
[pficommon](https://github.com/pfi/pficommon/blob/master/src/concurrent/lock.h)...そして libprocess にもちゃんとあった。

```c++ synchronized.hpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/synchronized.hpp
...
class Synchronized
{
public:
  Synchronized(Synchronizable *_synchronizable)
    : synchronizable(_synchronizable)
  {
    synchronizable->acquire();
  }

  ~Synchronized()
  {
    synchronizable->release();
  }

  operator bool () { return true; }

private:
  Synchronizable *synchronizable;
};


#define synchronized(s)                                                 \
  if (Synchronized __synchronized ## s = Synchronized(&__synchronizable_ ## s))
...
```

私の中ではこれがあると若者 C++ に認定される(根拠なし)。
Chromium にはなかった気がする。Boost もざっとみたかんじ見当たらず。

Stout
---------

libprocess のコードで使われている汎用部品の一部は
[Stout](https://github.com/apache/mesos/tree/trunk/third_party/libprocess/third_party/stout) という独立したライブラリに切りだされている。
といっても例のごとく libprocess と Mesos 以外では使われていないぽい。

一年前の記憶にこんなライブラリはなかったので調べてみると、
[数ヶ月前に mesos から libprocess 以下に移動され](https://reviews.apache.org/r/5915/), 
[一週間くらい前に libprocess/third_party に引っ越していた](https://reviews.apache.org/r/9631/)。

コードの中身は boost のラッパやその他雑多なコードを押しこんだ感じ。まあこういう場所がどこかに必要なのはわかる。
揚げ足取りとしては [Owned](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/third_party/stout/include/stout/owned.hpp) クラスが
`shared_ptr` を継承してるのを見てあとずさった。それ own しとらん・・・。

``` c++ owned.hpp https://github.com/apache/mesos/blob/trunk/third_party/libprocess/third_party/stout/include/stout/owned.hpp
// Represents a uniquely owned pointer.
//
// TODO(bmahler): For now, Owned only provides shared_ptr semantics.
// When we make the switch to C++11, we will change to provide
// unique_ptr semantics. Consequently, each usage of Owned that
// invoked a copy will have to be adjusted to use move semantics.
template <typename T>
class Owned : public boost::shared_ptr<T>
{
public:
  Owned(T* t) : boost::shared_ptr<T>(t) {}
};
```

`unique_ptr` にしたいならとりあえず `scoped_ptr` つかっとけとおもうのは年寄りですかね...


libprocess 所感
------------------

つかれた・・・一旦 libprocess だけで感想を書いてみたい。
バランスの取り方がけっこうきわどくて、その不安を打ち明けずにはおれない。

#### アクターとブロッキングの混在

まずワーカスレッドで実装されたアクターとブロックできる Future の組み合わせが不安を誘う。
Mesos のコードをみると、案の定ブロックして Future の結果を待つコードがある。というかノンブロッキングよりブロックする箇所の方が多い。

ブロックするコードはだいたい独立した Process オブジェクトに分離されている。
けれどそういうブロッキング Process が増えると、いずれブロックした Process がワーカスレッドを専有する日が来る。

Actor などを使わないプログラミングスタイルだと、ブロックする処理には専用のスレッドを割り振ったりする。
Chromium なんかだと IO スレッドというのがある。あんどろプログラミングでも似たようなことするよね。
遅い処理は独立したスレッドを与えられるので、くるくる回って欲しい UI スレッドの反応性は保たれる。

けれど libprocess みたいな Actor の実装は個々の Actor がブロックしない前提でデザインされているから、
「ブロックする人向けスレッド」みたいな概念がない。そういう世界で前提に背いてブロッキングするのはトラブルの元に見える。
わかった上で書いてるんだろうけど、傍目にはひやひやする。
いっそシングルスレッドならそういうサボりが即座に症状にあらわれるので規律も働くんだけど、
複数ワーカがあると問題が隠せちゃうのよなー・・・などと心配してしまうのは私が bureaucracy に毒されているからかもしれない。

#### 専用ライブラリの分離

Bureaucracy といえば、ライブラリを分割したがる様子も不安を誘う。Mesos でしか使わないものをなぜ別のライブラリにするのか。
普段いじっているコードと距離が離れるほど、遠くのコードをさわるのは億劫になる。相手を直すかわりに手元でちょろまかしたくなる。
どうせなら近くに置いて、Mesos の一部として育てていけばいいのにと思ってしまう。
そしてライブラリに分離されていると、いらないコードを消しにくい。
誰か（そんな誰かはいないのに）が使っているかもしれないと気になるから。

libprocess 自体の大きさも不安の種だ。どのコードもちゃんと Mesos から使われているのだろうか。
むかしのプロジェクトで足した実験の残骸が残ったままだったりしないか。
(というかけっこう残ってる。[SocketProcess](https://github.com/apache/mesos/blob/trunk/third_party/libprocess/src/net.hpp)とか。)
総アプリケーションに対し大きすぎるライブラリはおおむね不穏だと個人的には思う。
Stout なんて、なんでライブラリをわけたんだろうね？ Mesos 以外に C++ のプロジェクトを始める気なのかしら・・・Scala つかおうよ・・・。

#### 不穏なクラス名と testability

もうちょっと細かいデザインに目をやると、とにかくなんとか manager が多い。それが anecdotal なシグナルに過ぎないとはいえ不安を拭えない。
案の定 manager は絵に描いたような god class で、なんでもつっこんでおこうといった風情。
さらに困ったことに、よくあることではあるけれども、それがグローバル変数(static 変数だけどまあ似たようなもの)になってる。
しかも実装が .cpp ファイルに隠れている。その Manager クラス単体でテストできないじゃん。

実際テストはすくない。「テストはいつでも絶対必要！」と主張する原理主義者じゃないつもりだけど、
インフラの一番下にある手堅く動いてほしいコンポーネントだし、分散システムなんてデバッグも大変なんだから、もうちょっとテストしておいてもいいと思うんだよね・・・。
私の自信のなさがコードをそう読ませるという話はある。でも他人のコードを読みながらそんな内省に浸りたくないのでテストしといてほしいです。

そういえば C++ のグローバルな manager で唐突に思い出したので文脈無関係に八つ当たりしておくと MongoDB! これもひどい。
[DataFileMgr](https://github.com/mongodb/mongo/blob/master/src/mongo/db/pdfile.h) というクラスとその実体 `theDataFileMgr` というグローバル変数があって、
データベース全体からくまなく参照されている。たとえば BTree も `theDataFileMgr` に依存してる。これじゃ単体テストできないじゃん。
そのくせ[データベースエンジニアの求人](http://www.10gen.com/careers/positions/mongodb-database-kernel-engineer)には
"You think writing unit tests is critical for great software" とか書いてあってもうね・・・・そういうことは `theDataFileMgr` をなくしてから言ってほしいものです。
(MongoDB の名誉のためにいっておくと、単体の粒度じゃないけど[それなりにテストはある](https://github.com/mongodb/mongo/tree/master/src/mongo/dbtests)。
BTree をつくってコマンド発行してそれから BTree の変化をチェックする、というかんじでテストをかけるっぽい。)

はー。話がそれた。libprocess にもどると、
数少ない[テスト](https://github.com/apache/mesos/tree/trunk/third_party/libprocess/src/tests)には
[gmock](https://code.google.com/p/gmock/) のようなテストマニア向けツールが使われており、その過剰さが一層切ない。
それ Process を mock するんじゃなくて manager とか IO を mock するのに使おうぜ・・・

それにしても gmock のほか gtest, protobuf, glog, perftools と全体的に検索 C++ ツール満載なのは、
開発者のひとりが検索会社インターン経験者だからだろうか。

#### 太ったスーパークラス

manager にならんで古くからよく知られるダメな C++ のパターン、巨大スーパークラスも健在。Process クラス。
アプリケーションがこいつを継承する必然性ぜんぜんない。
コールバックをインストールすれば済む話でその API まで自分で用意してるのに、なぜ継承させるのか。
composition over inheritance とか今更過ぎてケチをつけるのも気が引ける。

#### delete

コードの細かいところはまあ、ふつう。ただ目につくのは `delete` の多さ。よのなかには smart pointers ってのがございましてな・・・。
寿命の行方が複雑になりがちな非同期のコードで smart pointer や参照カウントを頼らずリークしてないのはそれはそれですごい。
Actor というアイデアのシンプルさがこの堅牢性に寄与しているのは認める。

若さと勢い
------------------

こうやって色々ケチをつけたところで、動いている事実にまさるものはない。

libprocess にせよ Mesos にせよ、 C++ を気に入った brilliant な若者が腕試しに書いてみたコードといった風情が強い。
野心的なデザインを追い求めている。凝った言語機能を使いこなしている。
一方で巨大プロジェクトで苦労しがちな落とし穴をひと通り踏んでいる。
力の入り方がちぐはぐで、必要以上に凝っていると思えばすごく手薄な部分もある。

広く使われている C++ のコードは歴史が長く、過去から積み重なったダメさにあふれるものが多い。
libprocess (や Mesos) のコードにそういう汚れた感じはない。どちらかというとまだ青い。
こういう若々しい C++ のコードって実際それなりにあるけれど、それがハイテク企業のインフラになろうとしている事実が私をそわそわさせるのだろう。
去年コードを読んだ時はそのうちベテランが Finable で書き直すに違いないと思ったけどそんな様子もなく、
やんちゃなコードのまま着々と開発が進んでいる。

普通なら手堅く進めそうなインフラ仕事すら勢い余って若者の手に渡ってくる。
アーキテクチャの整合性がどうこう言わずにあるものを使って乗り切る。
これがスタートアップのダイナミズムってもんなんだろうね。
読者の私が期待してた近未来モダーンインフラコードとはちょっと違ったけど、これはこれで面白い。

Mesos の話をしようと思っていたのにその手前で疲れ果てました。やれやれ・・・万一傷が癒えたらつづく。
Mesos は、だいたい NSDI の記事に書いてあるようなものが実装されている。
書く気が起きなかったときのために実装の見どころを箇条書きしておくと

 * 実行プロセスの資源制御の仕組み (lxc, cgroups)
 * 外部フレームワークとのインテグレーション (Hadoop, Apache, MPI)
 * ジョブの開始方法 (CLI)
 * ZooKeeper の使われ方

など。[ドキュメントも案外揃っている](https://github.com/apache/mesos/tree/trunk/docs)のでその気になれば動かせそうなかんじ。
Hadoop とかに慣れ親しんでいる人は気が向いたらおためしを。

----

 * 写真: http://www.flickr.com/photos/palojono/4027996707/