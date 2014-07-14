---
layout: post
title: "Life of Touch"
date: 2014-07-05 14:04
comments: true
categories: 
---

![touch](https://farm3.staticflickr.com/2923/14638870994_4802da98e5_b.jpg)

いいかげんあんどろでも勉強するかと 6 年遅れくらいで重い腰を上げかけている。気が重い。スマホとか知らないっすよ・・・。

あんどろ、というかスマホ固有の話題は色々あれど、その一つがタッチベースの UI なのは間違いない。そういえばタッチというのはどうやって実装されているんだろうか。それを一通り眺めれば、少しは気の重さが晴れるかもしれない。ということで今日はタッチイベントの実装を眺めてみたい。実装といっても静電容量だの電磁誘導だのではなくユーザー空間の話です。そして老人の勉強記録であり目新しい話はありません。間違ってたら教えてください。

参照するコードは何も考えず [`repo sync`](http://source.android.com/source/using-repo.html) で降ってくる AOSP master。たぶんだいたい 4.4.x 相当(だよね？)

## View#onTouchEvent()

あんどろプログラマからみたタッチイベントはふつう [`View#onTouchEvent()`](http://developer.android.com/reference/android/view/View.html#onTouchEvent%28android.view.MotionEvent%29) にやってくる [`MotionEvent`](http://developer.android.com/reference/android/view/MotionEvent.html) だと理解している。[`ListView`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/widget/AbsListView.java) なんかも `onTouchEvent()` で色々やっているからこれはきっと正しい。

さっそく [`frameworks/base`](https://github.com/android/platform_frameworks_base) の [`View.java`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/View.java) を見てみると、`onTouchEvent()` にはそれなりに長いデフォルト実装がある。(150 行くらい。)

```java View.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/View.java
...
    public boolean onTouchEvent(MotionEvent event) {
        final int viewFlags = mViewFlags;

        if ((viewFlags & ENABLED_MASK) == DISABLED) {
            ...
            // A disabled view that is clickable still consumes the touch
            // events, it just doesn't respond to them.
            return (((viewFlags & CLICKABLE) == CLICKABLE ||
                    (viewFlags & LONG_CLICKABLE) == LONG_CLICKABLE));
        }
        ...
        if (((viewFlags & CLICKABLE) == CLICKABLE ||
                (viewFlags & LONG_CLICKABLE) == LONG_CLICKABLE)) {
            switch (event.getAction()) {
....
                case MotionEvent.ACTION_DOWN:
                    mHasPerformedLongPress = false;
...
                    // Walk up the hierarchy to determine if we're inside a scrolling container.
                    boolean isInScrollingContainer = isInScrollingContainer();

                    // For views inside a scrolling container, delay the pressed feedback for
                    // a short period in case this is a scroll.
                    if (isInScrollingContainer) {
                        mPrivateFlags |= PFLAG_PREPRESSED;
                        if (mPendingCheckForTap == null) {
                            mPendingCheckForTap = new CheckForTap();
                        }
                        postDelayed(mPendingCheckForTap, ViewConfiguration.getTapTimeout());
...
                    }
                    break;
...
     }
...
```

たとえば Long press や Tap の判定なんかがさらっと書いてある。判定方法は `Runnable` を実装してそれをタイマーから呼び、状態の差を見るだけ。
こういうのをさらっとかけるプラットホームはいいなあ...とおもうのだった。(C++比。Swift 書いてる人は鼻で笑っといてください。)
それにしてもたくさんの責務をばりっと同じクラスに書いてしまうのは伝統的な Java ぽくない。 `View.java` だけで 1.7 万行くらいある...

## ViewGroup

さて `onTouch()` はどこから呼ばれるのか。主なパスは二つある。

一つは View ツリーの親からやってくるパスで、親たる [`ViewGroup`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewGroup.java) の `ViewGroup#dispatchTransformedTouchEvent()` から呼ばれる。このメソッドは `ViewGroup::dispatchTouchEvent()` から使われている。子の View のうちイベントの座標に重なるものにイベントを配信する。よくある親から子への event propagation。 

```java ViewGroup.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewGroup.java
...
    private boolean dispatchTransformedGenericPointerEvent(MotionEvent event, View child) {
        final float offsetX = mScrollX - child.mLeft;
        final float offsetY = mScrollY - child.mTop;

        boolean handled;
        if (!child.hasIdentityMatrix()) {
            MotionEvent transformedEvent = MotionEvent.obtain(event);
            transformedEvent.offsetLocation(offsetX, offsetY);
            transformedEvent.transform(child.getInverseMatrix());
            handled = child.dispatchGenericMotionEvent(transformedEvent); // これとか
            transformedEvent.recycle();
        } else {
            event.offsetLocation(offsetX, offsetY);
            handled = child.dispatchGenericMotionEvent(event); // これ
            event.offsetLocation(-offsetX, -offsetY);
        }
        return handled;
    }
...
```

名前が "Transformed" なのは子 `View` のローカル座標系に位置を変換するからだけど、よくみると位置にオフセットを足すだけでなくだけでなく変換行列をかけている。`View` には回転やらスケールやらの行列をセットできるらしい。たぶんアニメーションのためだろう。イベントの衝突計算にもちゃんと反映されるんだな。Material Design なんかだと色々派手に動くのであんなものが実装できるのかと密かに怪しんでいたけれど、下地は案外ちゃんとしていた。当たり前かもしれませんが・・・。

## ViewRootImpl

もう一つのパスは、同じクラスの `View#dispatchTouchEvent()` と `View#dispatchPointerEvent()` を介し [`ViewRootImpl`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java) から呼ばれるもの。

`ViewRootImpl` も 0.7 万行くらいあるそこそこ大きなクラスで、コメントによれば `View` ツリーとウィンドウシステム (`WindowManager`) をとりもつのが仕事らしい。名前から察するにこれがツリーのルートなのだろう。ただし `ViewGroup` が `View` を継承しているのに対し `ViewRootImpl` は継承していない。ツリーのルートというよりコンテナという方が実態に近い。そして `ViewRootImpl::mView` がルートのようだ。この値は Activity が表示されるときにどこかからセットされる。 `MotionEvent` を最初にうけとる `View` はこの `mView`。`mView` がセットされるまでの道のりは長いので省略。

![View Tree](https://farm4.staticflickr.com/3845/14640491152_e68fbcfa80_b.jpg)

なおクラス名から予期される Impl でない `ViewRoot` は見当たらない。昔のコードにはあるから、どこかでこの不思議な名前に変わったようだ。


## InputStage

さて `View#dispatchPointerEvent()` および `View#dispatchGenericMotionEvent()` は `ViewPostImeInputStage#processPointerEvent()` から呼ばれる。 `ViewPostImeInputState` をはじめとする `InputStage` のサブクラスはみな `ViewRootImpl` の内部クラスで、タッチやキーボードなどの入力イベントを処理するための小さなフレームワークを構成している。

この InputStage フレームワークはいわゆる [Chain of responsibility](http://en.wikipedia.org/wiki/Chain-of-responsibility_pattern) のパターン。一つのイベントを処理するために一連の stage 実装が参加し、自分が処理できないイベントを別の stage に先送りしたり、ちょっとタイミングや中身を書き換えて委譲したりする。まあ UI まわりで chain of responsibility ってよくあるよね。 Cocoa の responder chain とか。

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java
...
    /**
     * Base class for implementing a stage in the chain of responsibility
     * for processing input events.
     * <p>
     * Events are delivered to the stage by the {@link #deliver} method.  The stage
     * then has the choice of finishing the event or forwarding it to the next stage.
     * </p>
     */
    abstract class InputStage {
        private final InputStage mNext;
...
        /**
         * Forwards the event to the next stage.
         */
        protected void forward(QueuedInputEvent q) {
            onDeliverToNext(q);
        }

        /**
         * Called when an event is being delivered to the next stage.
         */
        protected void onDeliverToNext(QueuedInputEvent q) {
            if (mNext != null) {
                mNext.deliver(q);
            } else {
                finishInputEvent(q);
            }
        }
    }
...
```

`InputStage` が面倒を見る入力イベントは `KeyEvent` (キーボード)と `MotionEvent` (タッチ)の二種類。Stage の実装は 6 種類(`ViewPreImeInputStage`, `ImeInputStage`, `NativePostImeInputStage`, `EarlyPostImeInputStage`, `ViewPostImeInputStage`, `SyntheticInputStage`) 。`MotionEvent` については委譲の果てに `ViewPostImeInputStage` が呼び出されて `View` に届く。

タッチ紀行の主役 `MotionEvent` だけを追いかけると `InputStage` のフレームワークはやりすぎに見える。でも `KeyEvent` のコードパスを調べると事情がわかる。`KeyEvent` は IME にリダイレクトされる必要がある。そして処理の結果は非同期に、別のプロセスから戻ってくる。そんな非同期性やメッセージングの複雑さを局所化するための仕組みなのだろう。

そのほか NDK 対応のためとみられる Native なんとかという stage もあるけど、`NativeAcitivity` のコードをひやかした印象だともう機能してないレガシーな印象。

## QueuedInputEvent

本題に戻る。 `InputStage` へのイベントはどこからやってくるのだろう。読み進めると `ViewRootImpl#doProcessInputEvents()` が `deliverEvent()` 経由で `InputStage` を呼び出している。

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java
    void doProcessInputEvents() {
        // Deliver all pending input events in the queue.
        while (mPendingInputEventHead != null) {
            QueuedInputEvent q = mPendingInputEventHead;
            mPendingInputEventHead = q.mNext;
            if (mPendingInputEventHead == null) {
                mPendingInputEventTail = null;
            }
            q.mNext = null;
            ...

            deliverInputEvent(q);
        }
        ...
    }
```

名前のとおり `doProcessInputEvents()` は複数のイベントを処理する。そのイベントは `ViewRootImpl#mPendingInputEventHead` という線形リストから取り出している。型は `QueuedInputEvent`.
名前の通り、このリストは intrusive なキューとして機能している。

イベントやメッセージの配信について調べるとき、*どんなキューをいつ通過するか* はわかりやすい道程になる。その一つ目が現れた。
このキューにはどこからイベントが詰め込まれるのか・・・というと、`ViewRootImpl#enqueueInputEvent()` なる大変わかりやすい名前のメソッドがあるのだった。

イベント配信について調べるとき気にする事がもう一つある。
その配信は*同期*的に処理される(同じコールスタックの中で即座に配信される)か、それとも*非同期*(タイマーやイベントループで先送りされる)か。非同期配信はコードの堅牢さを助ける一方、遅延の原因にもなる。`MotionEvent` みたいに反応時間が大切そうなものを非同期化していいの？

などと思いつつよく見ると、`enqueueInputEvent()` には `processImmediately` なんてパラメタがある。

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java

    void enqueueInputEvent(InputEvent event,
            InputEventReceiver receiver, int flags, boolean processImmediately) {
         
        // ... put |event| into the queue
        
        if (processImmediately) {
            doProcessInputEvents();
        } else {
            scheduleProcessInputEvents();
        }
 
    }

```

呼び出しが `processImmediately` なら即座に `doProcessInputEvents()` が呼ばれ、キューに詰めたばかりのイベントが同期的に掃き出される。そうでなければメインループにメッセージを投げ (`scheduleProcessInputEvents()`)、非同期に `doProcessInputEvents()` を呼び出すよう指示する。つまり `ViewRootImpl` はキューをもっているが、それを同期的に掃き出すオプションを用意している。（そしてだいたいは同期的に処理している。)

## WindowInputEventReceiver#onInputEvent()

`enqueueInputEvent()` はあちこちから呼ばれている。ただし、その多くはキーボードのイベントや、「合成」イベントを発行するためのもの。

`SyntheticTrackballHandler` や `SyntheticTouchNavigationHandler` といったクラスが、`SyntheticInputStage` から「合成された」 InputEvent を送り出す。たとえばトラックボール由来の `MotionEvent` をスクロールのための矢印キーのイベントに、`MotionEvent` 全般を十字キーイベントに変換/合成(synthesis)したりする。トラックボールのあんどろデバイスとかあるんかいな・・・。

こうした脇道はさておくと、内部クラスである `WindowInputEventReceiver` が実質上唯一の `MotionEvent` 送付元のようだ。`processImmediately` は `true`. 同期配信。

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java
...
    // WindowInputEventRecever は ViewRootImpl の内部クラス.
    final class WindowInputEventReceiver extends InputEventReceiver {
        public WindowInputEventReceiver(InputChannel inputChannel, Looper looper) {
            super(inputChannel, looper);
        }

        @Override
        public void onInputEvent(InputEvent event) {
            enqueueInputEvent(event, this, 0, true);
        }
        ....
    }
    WindowInputEventReceiver mInputEventReceiver;
...
```

クラス名から判断すると、この `WindowInputEventReceiver` およびスーパークラスの [`InputEventReceiver`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/InputEventReceiver.java) は `MotionEvent` などの入力イベントを処理するのに特化した専用の仕組みなのだろう。イベントを扱う他のコードは `ViewRootImpl#mHandler` という [`Handler`](http://developer.android.com/reference/android/os/Handler.html) オブジェクトを介するのが流儀に見える。わざわざ特別な `WindowInputEventReceiver` を使うのは不思議な気もする。性能上の事情があるのかもね。

## InputEventReceiver, InputChannel, Looper

`ViewRootImpl` は `InputEventReceiver` を介して `MotionEvent` を受け取っているようだ、ということがわかった。

[`InputEventReceiver`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/InputEventReceiver.java) は [Template Method](http://en.wikipedia.org/wiki/Template_method_pattern) パターンでサブクラスの `onInputEvent()` を呼びだし、`InputEvent` (`MotionEvent`をふくむ) の到着を知らせる。でもいつどこからこれを呼び出すのだろう。ぱっと見ただけではよくわからない。 `onInputEvent()` を呼び出す `dispatchInputEvent()` は C++ 側から呼び出されるからだ。Java はこのへんで切り上げ、JNI のむこうにある C++ コードに駒を進めよう。

`InputEventReciever.java` に対応する JNI の実装は [`android_view_InputEventReceiver.cpp`](https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputEventReceiver.cpp)。このファイルは `NativeInputEventReceiver` という (C++) クラスを定義している。Java 側のクラス構造をおおまかにマップした C++ クラスを作るのはあんどろ JNI 実装のイディオムらしく、目についた JNI のコードはだいたい似たようなパターンに従っていた。オブジェクトモデルを Java 側に任せきる伝統的な Java スタイルとは違い、どちらかというとブラウザの C++ と JS の関係っぽい。

参考までに `NativeInputEventReceiver` の定義はこんなかんじ:

```c++ android_view_InputEventReceiver.cpp https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputEventReceiver.cpp
...
class NativeInputEventReceiver : public LooperCallback {
public:
    NativeInputEventReceiver(JNIEnv* env,
            jobject receiverWeak, const sp<InputChannel>& inputChannel,
            const sp<MessageQueue>& messageQueue);

    status_t initialize();
    ....
    status_t consumeEvents(JNIEnv* env, bool consumeBatches, nsecs_t frameTime,
            bool* outConsumedBatch);

    ...
private:
    struct Finish {
        uint32_t seq;
        bool handled;
    };

    jobject mReceiverWeakGlobal;
    ...
    int mFdEvents;
    ...
    virtual int handleEvent(int receiveFd, int events, void* data);
};
...
```

`jobject` 型の `mReceiverWeakGlobal` が Java のオブジェクトをさしている。

Java 側はこんなの:

```java InputEventReciever.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/InputEventReceiver.java
...
public abstract class InputEventReceiver {
...
    private static native long nativeInit(WeakReference<InputEventReceiver> receiver,
            InputChannel inputChannel, MessageQueue messageQueue);
    private static native void nativeDispose(long receiverPtr);
    private static native void nativeFinishInputEvent(long receiverPtr, int seq, boolean handled);
    private static native boolean nativeConsumeBatchedInputEvents(long receiverPtr,
            long frameTimeNanos);
...
  public InputEventReceiver(InputChannel inputChannel, Looper looper) {
        ...
        mInputChannel = inputChannel;
        mMessageQueue = looper.getQueue();
        mReceiverPtr = nativeInit(new WeakReference<InputEventReceiver>(this),
                inputChannel, mMessageQueue);
        ...

    }
...
 @Override
    protected void finalize() throws Throwable {
        try {
            nativeDispose(true);
        } finally {
            super.finalize();
        }
    }
    ...
    private long mReceiverPtr;

    // We keep references to the input channel and message queue objects here so that
    // they are not GC'd while the native peer of the receiver is using them.
    private InputChannel mInputChannel;
    private MessageQueue mMessageQueue;

...

    // Called from native code.
    @SuppressWarnings("unused")
    private void dispatchInputEvent(int seq, InputEvent event) {
        mSeqMap.put(event.getSequenceNumber(), seq);
        onInputEvent(event);
    }

    // Called from native code.
    @SuppressWarnings("unused")
    private void dispatchBatchedInputEventPending() {
        onBatchedInputEventPending();
    }
...
}
```

`native` とマークされたメソッドが複数。また `long` な `mReceiverPtr` に C++ 側オブジェクトへのポインタを持っている。Finalizer があるのも JNI っぽい。こうやって C++ と Java のクラスをミラーする流儀なんだね。

さて一瞬 Java に戻ると、`InputEventReceiver` には共に働くクラスが二つある: [`InputChannel`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/InputChannel.java) と [`Looper`](http://developer.android.com/reference/android/os/Looper.html) だ。 `InputEventReceiver` はこの二つのオブジェクトをコンストラクタの引数に受け取る。

### InputChannel

`InputChannel` も `Looper` も C++ にミラーしたオブジェクトのある C++ backed なクラス。

`InputChannel` の JNI コード [`android_view_InputChannel.cpp`](https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputChannel.cpp) は `NativeInputChannel` クラスを定義している。でもこのクラスはほとんどなにもせず、別のクラス `android::InputChannel` をラップしているだけ。`android::InputChannel` が Java 側 `android.os.InputChannel` の実体だと言える。`InputChannel`(Java) -> `NativeInputChannel`(C++) -> `android::InputChannel`(C++) と間接化が二段階ある。この冗長さはきっと、 Java クラスの実装を C++ で書くのではなく C++ のクラスを Java 側に公開するという形で物事がデザインされ、中間の JNI にしわ寄せが来た結果だろうな、などと想像した。まあどうでもいい。

C++ 版 `InputChannel` は [InputTransport.h](https://android.googlesource.com/platform/frameworks/native.git/+/master/include/input/InputTransport.h) に定義されている。

```c++ InputTransport.h https://android.googlesource.com/platform/frameworks/native.git/+/master/include/input/InputTransport.h
/*
 * An input channel consists of a local unix domain socket used to send and receive
 * input messages across processes.  Each channel has a descriptive name for debugging purposes.
 *
 * Each endpoint has its own InputChannel object that specifies its file descriptor.
 *
 * The input channel is closed when all references to it are released.
 */
class InputChannel : public RefBase {
    ...
    static status_t openInputChannelPair(const String8& name,
            sp<InputChannel>& outServerChannel, sp<InputChannel>& outClientChannel);
    inline String8 getName() const { return mName; }
    inline int getFd() const { return mFd; }
    ...
    status_t sendMessage(const InputMessage* msg);
    ...
    status_t receiveMessage(InputMessage* msg);
    ...   
private:
    String8 mName;
    int mFd; // ファイルデスクリプタ
};
```

コメントや定義からわかるように、`InputChannel` は UNIX ドメインソケットをカプセル化し、そのソケット上で `InputMessage` 構造体を送受信するもののようだ。`InputEventReceiver` はこの `InputChannel` を通じ、どこかから届くイベントを受け取る。

ブラウザに似ていると書いたけれど、実際にはだいぶ違う。ブラウザでは(今のところ) DOM なんかの実装を JS で書く事はない。ぜんぶ C++ にコードがあって JS はそれをラップするだけ。オブジェクトグラフも C++ 側にある。あんどろのこのへんのコードは割と Java 側にもコードがあり、オブジェクトグラフにしても Java 側と C++ 側の両方がそれぞれ自分に必要なものをもっている。

![Java and JNI](https://farm4.staticflickr.com/3842/14617932566_4411d153b9_b.jpg)

一見グラフの同期が大変そうだけれど、いま見ているのは実装の詳細である非公開なクラスな上にグラフはおおむね immutable 。だから多少冗長でも大丈夫、ということらしい。いずれにせよフレキシブルというかアドホックというか、面白いね。

などと周辺事情をおさらいしたところで本題の `InputEventReceiver` に戻ろう。

C++ 側のコードに目をやると、`NativeInputEventReceiver` は `LooperCallback` なるクラスを継承している。

```c++ android_view_InputEventReceiver.cpp https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputEventReceiver.cpp
class NativeInputEventReceiver : public LooperCallback {
public:
...
    virtual int handleEvent(int receiveFd, int events, void* data);
}
```

`LooperCallback` は [`Looper.h`](https://github.com/android/platform_system_core/blob/master/include/utils/Looper.h) に定義されている。名前の通り `Looper` から通知を受け取るためのインターフェイス。引数にはファイルデスクリプタらしい整数値が渡されている。

このことから察しがつくように、`NativeInputEventReceiver` は `Looper` に自分自身を登録する。コードをみてみよう。

```c++ android_view_InputEventReceiver.cpp https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputEventReceiver.cpp
void NativeInputEventReceiver::setFdEvents(int events) {
    if (mFdEvents != events) {
        mFdEvents = events;
       // mInputConsumer.getChannel() は InputChannel を返す
        int fd = mInputConsumer.getChannel()->getFd();
        if (events) {
            // ここで登録。
            mMessageQueue->getLooper()->addFd(fd, 0, events, this, NULL);
        } else {
            mMessageQueue->getLooper()->removeFd(fd);
        }
    }
}
```

`InputChannel` のソケットデスクリプタを自分自身に紐づけ `Looper::addFd()` を呼び出している。 

## Looper

この `Looper` とは何だろう。

Java の世界、アプリケーションの側からみると、`android.os.Looper` はスレッドのイベントループを抽象化したオブジェクトだ。といっても公開された機能はすくなく、[API](http://developer.android.com/reference/android/os/Looper.html) はループの開始終了くらいしかない。

C++ の世界から見ると、`android::Looper` は要するに [`select()`](http://linux.die.net/man/2/select) (または [`epoll`](http://linux.die.net/man/4/epoll)) だ。ファイルデスクリプタを登録しておき、読み書きの準備ができた際にコールバックを受け取る。

GUI のイベントループは OS の多重化 IO と同期機構の上に組み立てられる。だから `epoll` とイベントループが同じ名前で抽象化されるのは自然といえば自然だ。そして GUI プログラミングが `epoll` で非同期サーバーを書くようなものなら、ブロックするコードを書いて怒られるのも無理はない。今更ながら襟首をただす。

あんどろをはじめとする多くの GUI ツールキットは、足下に隠された多重化 IO をアプリケーションから隠している。Java や NDK から直接 `android::Looper` にアクセスすることはできない。

一方 Mac OS/iOS の [Run Loop](https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html) は多重化 IO としてのイベントループをアプリケーションプログラマに公開している。アプリケーションは多重化したいチャネル(ポート)をメインループに追加できる。これはきっと足下の Mach という OS がメッセージパッシングを重視している現れだろう。意外なところに出自が見えて面白い。

### 届いたイベントの処理

また脇道にそれた。ここまでのあらすじを振り返ると...

 * `ViewRootImpl` は `InputEvent` (`MotionEvent` を含む) を受け取るために `InputEventReceiver` を使う。このクラスは `InputChannel` が持つソケットデスクリプタを `Looper` に登録し、そのソケットに届いたバイト列をイベントに変換して利用者 (`ViewRootImpl`) に知らせる。
 * `Looper` はイベントループの多重化 IO に参加する手段として `LooperCallback` を提供している。`LooperCallback` を使うとメインスレッドのイベントループに便乗してソケットのデータを待つ事が出来る。自分でスレッドを持たなくてよい。

![InputEventReceiver](https://farm4.staticflickr.com/3864/14459379568_d5341f9acb_b.jpg)

`NativeInputEventReceiver` がソケットに届いたデータをどうやって処理するか、少し覗いてみよう。エントリポイントは `handleEvent()`. 

```c++ android_view_InputEventReceiver.cpp https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputEventReceiver.cpp
int NativeInputEventReceiver::handleEvent(int receiveFd, int events, void* data) {
....

    if (events & ALOOPER_EVENT_INPUT) {
        JNIEnv* env = AndroidRuntime::getJNIEnv();
        status_t status = consumeEvents(env, false /*consumeBatches*/, -1, NULL);
        mMessageQueue->raiseAndClearException(env, "handleReceiveCallback");
        return status == OK || status == NO_MEMORY ? 1 : 0;
    }

    if (events & ALOOPER_EVENT_OUTPUT) {
        for (size_t i = 0; i < mFinishQueue.size(); i++) {
            const Finish& finish = mFinishQueue.itemAt(i);
            status_t status = mInputConsumer.sendFinishedSignal(finish.seq, finish.handled);
            ...
        }
    ...
    }
}
```

この `handleEvent()` は fd の準備ができると `Looper` から呼び出される。
その準備の結果、fd が読み出し可能 (`ALOOPER_EVENT_INPUT`) なら届いたデータを処理し(`consumeEvents()`)、 
書き出し可能 (`ALOOPER_EVENT_OUTPUT`) なら ACK を送り返す。特に何も面白くない...

まあ ACK(`Finish` オブジェクト) の送付があるのは面白いといえば面白い。イベント配信なんて一方向通信で良さそうなものだけれど、なにか事情があるんだろうね。

一歩進んでデータを読み出す `conumeEvents()` を眺めてみると...

```c++ android_view_InputEventReceiver.cpp
status_t NativeInputEventReceiver::consumeEvents(JNIEnv* env,
        bool consumeBatches, nsecs_t frameTime, bool* outConsumedBatch) {

    ....
    ScopedLocalRef<jobject> receiverObj(env, NULL);
    bool skipCallbacks = false;
    for (;;) {
        uint32_t seq;
        InputEvent* inputEvent;
        status_t status = mInputConsumer.consume(&mInputEventFactory,
                consumeBatches, frameTime, &seq, &inputEvent);
        if (status) {
            ...
            env->CallVoidMethod(receiverObj.get(),
                            gInputEventReceiverClassInfo.dispatchBatchedInputEventPending);
            if (env->ExceptionCheck()) {
                ALOGE("Exception dispatching batched input events.");
                mBatchedInputEventPending = false; // try again later
            }
            ...
            return status;
        }

        if (!skipCallbacks) {
            ...
            jobject inputEventObj;
            switch (inputEvent->getType()) {
            ...
            case AINPUT_EVENT_TYPE_MOTION: {
                ...
                MotionEvent* motionEvent = static_cast<MotionEvent*>(inputEvent);
                if ((motionEvent->getAction() & AMOTION_EVENT_ACTION_MOVE) && outConsumedBatch) {
                    *outConsumedBatch = true;
                }
                inputEventObj = android_view_MotionEvent_obtainAsCopy(env, motionEvent);
                break;
            }
            ...
            }

            if (inputEventObj) {
                ...
                env->CallVoidMethod(receiverObj.get(),
                        gInputEventReceiverClassInfo.dispatchInputEvent, seq, inputEventObj);
                ...
            } ...
        }

        ...
    }
}
```

C++ のイベントを `mInputConsumer.consume()` でソケットから読み出し、それを Java のオブジェクトに変換して Java 側のレシーバ (`InputEventReceiver`) に通知していた。
Command-Query separation などと厳しく躾けられた身には厳しいコードですな...

### InputConsumer と Event Batching

新たに登場した `mInputConsumer` は `InputConsumer` クラス。`InputChannel` を補助している。なぜこんな間接化が必要なのか。`InputConsumer::consume()` を覗いてみよう:

```c++ InputTransport.cpp https://android.googlesource.com/platform/frameworks/native.git/+/master/libs/input/InputTransport.cpp
status_t InputConsumer::consume(InputEventFactoryInterface* factory,
        bool consumeBatches, nsecs_t frameTime, uint32_t* outSeq, InputEvent** outEvent) {
    ...
    *outSeq = 0;
    *outEvent = NULL;
    // Fetch the next input message.
    // Loop until an event can be returned or no additional events are received.
    while (!*outEvent) {
        if (mMsgDeferred) {
            ...
        } else {
            // Receive a fresh message.
            status_t result = mChannel->receiveMessage(&mMsg);
            if (result) {
                // Consume the next batched event unless batches are being held for later.
                if (consumeBatches || result != WOULD_BLOCK) {
                    result = consumeBatch(factory, frameTime, outSeq, outEvent);
                    if (*outEvent) {
                        ...
                        break;
                    }
                }
                return result;
            }
        }
        switch (mMsg.header.type) {
        ...
        case AINPUT_EVENT_TYPE_MOTION: {
            ssize_t batchIndex = findBatch(mMsg.body.motion.deviceId, mMsg.body.motion.source);
            if (batchIndex >= 0) {
                Batch& batch = mBatches.editItemAt(batchIndex);
                if (canAddSample(batch, &mMsg)) {
                    batch.samples.push(mMsg);
                    ...
                    break;
                } else {
                    // We cannot append to the batch in progress, so we need to consume
                    // the previous batch right now and defer the new message until later.
                    mMsgDeferred = true;
                    status_t result = consumeSamples(factory,
                            batch, batch.samples.size(), outSeq, outEvent);
                    mBatches.removeAt(batchIndex);
                    ...
                    break;
                }
            }
            // Start a new batch if needed.
            if (mMsg.body.motion.action == AMOTION_EVENT_ACTION_MOVE
                    || mMsg.body.motion.action == AMOTION_EVENT_ACTION_HOVER_MOVE) {
                mBatches.push();
                Batch& batch = mBatches.editTop();
                batch.samples.push(mMsg);
                ...
                break;
            }
            MotionEvent* motionEvent = factory->createMotionEvent();
            if (! motionEvent) return NO_MEMORY;
            updateTouchState(&mMsg);
            initializeMotionEvent(motionEvent, &mMsg);
            *outSeq = mMsg.body.motion.seq;
            *outEvent = motionEvent;
            ...
            break;
        }
        default:
            ...
            return UNKNOWN_ERROR;
        }
    }
    return OK;
}
```

`InputChannel::receiveMessage()` で `InputMessage` 型のオブジェクトを読み出す。そして `InputEventFactoryInterface` の助けを借り `InputMessage` を `InputEvent` に変換する。

型の変換以外にも見所はある。届いたメッセージを *batch* している。

一回のイベントループで届いた複数の `InputMessage` を単一の `InputEvent` にまとめる操作を、ここでは batch と呼んでいる。Batch されるのは特定のメッセージ、具体的には `AMOTION_EVENT_ACTION_MOVE` と `AMOTION_EVENT_ACTION_HOVER_MOVE` だけ。要するにまとめて届いた一連のタッチ軌道を一つの `MotionEvent` にまとめるのが batch 化だ。

Batch してできた軌跡は Java の世界にある [`MotionEvent`](http://developer.android.com/reference/android/view/MotionEvent.html) から取り出せる。そういえばお絵描きアプリを作っている友人がこの話をしていたなあ。イベントの情報は捨てずオーバーヘッドを減らす batch はタッチならでは。面白い。デスクトップとマウス相手なら間引いちゃえばいいからね大概・・・。

なお `MotionEvent` も C++ backed なクラスだった。[`Input.h`](https://android.googlesource.com/platform/frameworks/native.git/+/master/include/input/Input.h) に定義がある。別に JNI なんて使わずコピーで実装しても良さそうな気がするけど、それはゆとり世代なおっさんの考えなのだろう。`MotionEvent` 周辺コードではメモリ節約への気配りが見られる。まず先に登場した `InputEventFactoryInterface` からしてサブクラスの名前が `PreallocatedInputEventFactory` と `PooledInputEventFactory`. アロケーションを細工するための factory だった。batch のコードにも工夫がある。たとえばまとめるタッチ点の数が多すぎてメモリ確保に失敗するとタッチ点を "再サンプリング" して点数を減らす。芸が細かい。

## InputChannel::receiveMessage()

`receiveMessage()` はソケットからデータを読むと書いた。念のため確認しとこう。

```c++ InputTransport.cpp
status_t InputChannel::receiveMessage(InputMessage* msg) {
    ssize_t nRead;
    do {
        nRead = ::recv(mFd, msg, sizeof(InputMessage), MSG_DONTWAIT);
    } while (nRead == -1 && errno == EINTR);
    ... // エラーチェック
    return OK;
}
```

構造体を sizeof() して読むだけ。よしよし。素朴でいいよ。

## InputChannel の対

ここまでは `InputChannel` のソケットに届いたデータが `InputMessage`, `InputEvent` と姿を変えつつ `ViewRootImpl` に届くところを見届けた。

ではそもそも `InputChannel` のソケットに届くデータはどこからやってくるのだろう。`ViewRootImpl` に戻って `InputChannel` ができる様子を調べよう。

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java
...
    /**
     * We have one child
     */
    public void setView(View view, WindowManager.LayoutParams attrs, View panelParentView) {
                ...
                if ((mWindowAttributes.inputFeatures
                        & WindowManager.LayoutParams.INPUT_FEATURE_NO_INPUT_CHANNEL) == 0) {
                    mInputChannel = new InputChannel();
                }
                try {
                    ...
                    res = mWindowSession.addToDisplay(mWindow, mSeq, mWindowAttributes,
                            getHostVisibility(), mDisplay.getDisplayId(),
                            mAttachInfo.mContentInsets, mInputChannel);
                } catch (RemoteException e) {
                    ...
                }

                ...
                if (mInputChannel != null) {
                    if (mInputQueueCallback != null) {
                        mInputQueue = new InputQueue();
                        mInputQueueCallback.onInputQueueCreated(mInputQueue);
                    }
                    mInputEventReceiver = new WindowInputEventReceiver(mInputChannel,
                            Looper.myLooper());
                }

                ...
      }
...
```

`setView()` という巨大な関数に一連の初期化があった。まず空の `InputChannel` をインスタンス化し、それを `mWindowSession.addToDisplay()` に渡したあと `WindowInputEventReceiver` のコンストラクタに届けている。
`InputChannel` のコンストラクタは何もしない空関数だから、怪しいのは `addToDisplay()` だ。 `mWindowSession` はどんなオブジェクトなのだろう。

## WindowSession と Binder

`mWindowSession` は `IWindowSession` インターフェイス型のフィールド。
あんどろの世界で `I` から始まる型は IPC 機構の Binder が [AIDL](http://developer.android.com/guide/components/aidl.html) ファイルから生成したプロキシだ。
この `IWindowSession` にも対応する [`IWindowSession.aidl`](https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/IWindowSession.aidl) がある。
つまり `mWindowSession` は IPC のプロキシで、実体はたぶん別のプロセスにある。いちおう変数の出所を確認すると...

```java ViewRootImpl.java https://github.com/android/platform_frameworks_base/blob/master/core/java/android/view/ViewRootImpl.java
  ...
  public ViewRootImpl(Context context, Display display) {
        mContext = context;
        mWindowSession = WindowManagerGlobal.getWindowSession();
        ...
  }
  ...
```

コンストラクタの冒頭でグローバルの方から来た様子がわかる。そして...

```java WindowManagerGlobal.java
    public static IWindowSession getWindowSession() {
        synchronized (WindowManagerGlobal.class) {
            if (sWindowSession == null) {
                try {
                    InputMethodManager imm = InputMethodManager.getInstance();
                    IWindowManager windowManager = getWindowManagerService();
                    sWindowSession = windowManager.openSession(
                            imm.getClient(), imm.getInputContext());
                    float animatorScale = windowManager.getAnimationScale(2);
                    ValueAnimator.setDurationScale(animatorScale);
                } catch (RemoteException e) {
                    Log.e(TAG, "Failed to open window session", e);
                }
            }
            return sWindowSession;
        }
    }
```

`IWindowSession` のインスタンスは `IWindowManager` という別の binder proxy から `openSession()` で取り出していた。
名前から察するに、`IWindowSession` はアプリケーションと WindowManager の接続単位として振る舞い、
その WindowManager とデータをやり取りするのだろう。`InputChannel` もやりとりされるデータの一部というわけだ。

...という仮説を確認すべく WindowSession の実装を探してみよう。

```java Session.java https://github.com/android/platform_frameworks_base/blob/master/services/java/com/android/server/wm/Session.java
...
/**
 * This class represents an active client session.  There is generally one
 * Session object per process that is interacting with the window manager.
 */
final class Session extends IWindowSession.Stub
        implements IBinder.DeathRecipient {
....
 @Override
    public int addToDisplay(IWindow window, int seq, WindowManager.LayoutParams attrs,
            int viewVisibility, int displayId, Rect outContentInsets,
            InputChannel outInputChannel) {
        return mService.addWindow(this, window, seq, attrs, viewVisibility, displayId,
                outContentInsets, outInputChannel);
    }
...
}
...
```

`InputChannel` を `mService` に引き渡している。それっぽい。このコードはどこか別のプロセスで動いている(はず)なのを思い出してほしい。 

## Parcel とファイルデスクリプタ

`WindowSession` が binder のサービスなのはいいとして、一つ気になる事がある。
`InputChannel` は C++ のオブジェクトをラップしており、
そのオブジェクトはソケットのデスクリプタを持っていた。

```c++ InputTransport.h
/*
 * An input channel consists of a local unix domain socket used to send and receive
 * input messages across processes.  Each channel has a descriptive name for debugging purposes.
 *
 * Each endpoint has its own InputChannel object that specifies its file descriptor.
 *
 * The input channel is closed when all references to it are released.
 */
class InputChannel : public RefBase {
   ...
private:
    String8 mName;
    int mFd; // これ
};
```

この fd, プロセスをまたいで送れるものなんだろうか。
Binder ではオブジェクトを [Parcel](http://developer.android.com/reference/android/os/Parcel.html)という形式でバイト列に書き出す。
`InputChannel` の直列化コードを覗いてみよう。

```c++ android_view_InputChannel.cpp https://github.com/android/platform_frameworks_base/blob/master/core/jni/android_view_InputChannel.cpp
static void android_view_InputChannel_nativeWriteToParcel(JNIEnv* env, jobject obj,
        jobject parcelObj) {
    Parcel* parcel = parcelForJavaObject(env, parcelObj);
    if (parcel) {
        NativeInputChannel* nativeInputChannel =
                android_view_InputChannel_getNativeInputChannel(env, obj);
        if (nativeInputChannel) {
            sp<InputChannel> inputChannel = nativeInputChannel->getInputChannel();

            parcel->writeInt32(1);
            parcel->writeString8(inputChannel->getName());
            parcel->writeDupFileDescriptor(inputChannel->getFd());
        } else {
            parcel->writeInt32(0);
        }
    }
}
```

`parcel->writeDupFileDescriptor()` なんて API を使っている。どうも Binder はふつうにファイルデスクリプタを送れるらしい。

私の記憶によれば、Linux で別プロセスに fd を送るには複雑怪奇なシステムコールが必要なはず。
Parcel のバイト列に埋もれた fd をどうやってその手のシステムコールにつないでいるのだろうか。
答えを求め [`Parcel.cpp`](https://android.googlesource.com/platform/frameworks/native.git/+/master/libs/binder/Parcel.cpp) を覗く。

```c++ Parcel.cpp https://android.googlesource.com/platform/frameworks/native.git/+/master/libs/binder/Parcel.cpp
status_t Parcel::writeFileDescriptor(int fd, bool takeOwnership)
{
    flat_binder_object obj;
    obj.type = BINDER_TYPE_FD;
    obj.flags = 0x7f | FLAT_BINDER_FLAG_ACCEPTS_FDS;
    obj.binder = 0; /* Don't pass uninitialized stack data to a remote process */
    obj.handle = fd;
    obj.cookie = takeOwnership ? 1 : 0;
    return writeObject(obj, true);
}
...
status_t Parcel::writeObject(const flat_binder_object& val, bool nullMetaData)
{
    const bool enoughData = (mDataPos+sizeof(val)) <= mDataCapacity;
    const bool enoughObjects = mObjectsSize < mObjectsCapacity;
    if (enoughData && enoughObjects) {
restart_write:
        *reinterpret_cast<flat_binder_object*>(mData+mDataPos) = val;
        // Need to write meta-data?
        if (nullMetaData || val.binder != 0) {
            mObjects[mObjectsSize] = mDataPos;
            acquire_object(ProcessState::self(), val, this);
            mObjectsSize++;
        }
        ....
        return finishWrite(sizeof(flat_binder_object));
    }
    ...
}
```

んー。構造体 `flat_binder_object` として適当なタグをつけた fd をつくり、それをバイト列に書き込んでいるだけ...のように見える...

その後 [libs/binder/](https://android.googlesource.com/platform/frameworks/native.git/+/master/libs/binder/) のコードをしばらく眺めたものの、
結局そのバイト列は `/dev/binder` というファイルに `ioctl()` で渡されるだけだとわかった。

細工はこの `/dev/binder` にある。

Binder にはカーネルドライバがある。そしてそのドライバがカーネル空間の力でファイルデスクリプタを別プロセスに引き渡している。だから変なシステムコールに頼る必要もない。
(自分で変なシステムコールを実装しているとも言える。) 
よく見ると先に登場した `flat_binder_object` もカーネルの中、[binder.h](https://github.com/torvalds/linux/blob/master/drivers/staging/android/uapi/binder.h) に定義がある。

そういえば Binder はクロスプロセスなオブジェクトの寿命管理なんかもカーネルにやらせていてクール、みたいな話をどこかで聞いたことがある。
ファイルデスクリプタ受け渡しもそういうクールな何かの一部なのですね。

カーネルのドライバ [binder.c](https://github.com/torvalds/linux/blob/master/drivers/staging/android/binder.c) をみると...

``` c++ binder.c https://github.com/torvalds/linux/blob/master/drivers/staging/android/binder.c
static void binder_transaction(struct binder_proc *proc,
                               struct binder_thread *thread,
                               struct binder_transaction_data *tr, int reply)
{
...
        off_end = (void *)offp + tr->offsets_size;
        for (; offp < off_end; offp++) {
            struct flat_binder_object *fp;
            ...
            fp = (struct flat_binder_object *)(t->buffer->data + *offp);
...
            switch (fp->type) {
...
            case BINDER_TYPE_FD: {
                fp = (struct flat_binder_object *)(t->buffer->data + *offp);
                file = fget(fp->handle);
                ...
                target_fd = task_get_unused_fd_flags(target_proc, O_CLOEXEC);
                ...
                task_fd_install(target_proc, target_fd, file);
                ....
             } break;
             ...
             }
...
        }
...
}
...
/*
 * copied from fd_install
 */
static void task_fd_install(
       struct binder_proc *proc, unsigned int fd, struct file *file)
{
	if (proc->files)
	   __fd_install(proc->files, fd, file);
}
...
```

ふつうにプロセスのデスクリプタテーブルをいじっているのだった。ドライバ書くの便利だな・・・。

なお素の Linux ではファイルデスクリプタを送受信するのに [recvmsg()](http://man7.org/linux/man-pages/man2/recvmmsg.2.html)/[sendmsg()](http://man7.org/linux/man-pages/man2/sendmmsg.2.html) 
という API を使うのだけれど、その事実は man を読んでも全然わからない。{% asin B004OEJMZM, The Linux Programming Interface %} ({% asin 487311585X, 日本語訳 %}) というシステムコールマニア向け読み物には説明がある。が、知らないよそんなの・・・。Mac OS/Mach は [Port](https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/KernelProgramming/Mach/Mach.html) という IPC の仕組みにけっこうな労力を割いており、その Port はプロセス間で難なく受け渡す事ができる。{% asin B004Y4UTLI, Mac OS X Internals %} とかにも説明があったはず。IPC には OS の個性が見える、かも。

{% asin_img 487311585X, 日本語訳 %}

{% asin_img B004Y4UTLI, Mac OS X Internals %}

## 前半の道のり

話がそれた。

ここまでの道のりを振り返ると:

 * `View` に届く `MotionEvent` は親の `ViewGroup` か `ViewRootImpl` から届く。
 * `ViewRootImpl` は `InputStage` フレームワークで配信前のイベントに細工をする。ただし `MotionEvent` に大きな影響はない。
 * `ViewRootImpl` は `InputEventReceiver` を介し `InputChannel` のソケットから `MotionEvent` を読み出す。
   * ソケットには `InputMessage` 構造体が書き込まれている。
   * `Looper` を使いメインスレッドのイベントループに便乗してソケットを監視。
   * `MotionEvent` には複数の `InputMessage` を batch する。
 * `InputChannel` は Binder オブジェクトの `IWindowSession` から取り出す。ソケットの反対側は別プロセス。

![Application process](https://farm4.staticflickr.com/3909/14664868043_618fe5ec38_b_d.jpg)

イベントやメッセージの配信を調べるときはキューの存在が一里塚になると先に書いた。
ここまでだと、まず `ViewRootImpl` が `QueuedInputEvent` というキューを持っていた。
ただし `MotionEvent` がこのキューに長くとどまる事はなく、だいたい同期的に配信される。

もう一つのキューは `InputChannel` のソケット。共有メモリでも使わない限りプロセス間には何らかの通信経路が必要だから、
ここにキューがあるのは自然だ。つまりプロセスの中に限ると、主要なパスでは `MotionEvent` を同期的に配信している。結構がんばってるとおもう。

## WindowManagerService

というわけで View のあるプロセスを離れ、 `InputChannel` の反対側にあるプロセスに話を進めよう。
Window Manager が住むそのプロセスで、誰が `InputChannel` にデータを送り込むのだろう。

`WindowSession` の実装である `Session` クラスは, 
`InputChannel` を初期化する `addToDisplay()` の処理を
`WindowManagerService#addWindow()` に委譲している。
その `addWindow()` はというと:

```java WindowManagerService.java https://github.com/android/platform_frameworks_base/blob/master/services/java/com/android/server/wm/WindowManagerService.java
...
    public int addWindow(Session session, IWindow client, int seq,
            WindowManager.LayoutParams attrs, int viewVisibility, int displayId,
            Rect outContentInsets, InputChannel outInputChannel) {
...
            if (outInputChannel != null && (attrs.inputFeatures
                    & WindowManager.LayoutParams.INPUT_FEATURE_NO_INPUT_CHANNEL) == 0) {
                String name = win.makeInputChannelName();
                InputChannel[] inputChannels = InputChannel.openInputChannelPair(name);
                win.setInputChannel(inputChannels[0]);
                inputChannels[1].transferTo(outInputChannel);

                mInputManager.registerInputChannel(win.mInputChannel, win.mInputWindowHandle);
            }
...
    }
...
```

`InputChannel#openInputChannelPair()` で通信の両端となる `InputChannel` の対を作り、一端を `mInputManager` に、もう一旦を呼び出し元に返している。

いちおう確認しておくと `openInputChannelPair()` は `InputChannel` を `socketpair()` の糖衣にすぎない。特段すごい何かではない。

```c++ InputTransport.cpp
status_t InputChannel::openInputChannelPair(const String8& name,
        sp<InputChannel>& outServerChannel, sp<InputChannel>& outClientChannel) {
    int sockets[2];
    if (socketpair(AF_UNIX, SOCK_SEQPACKET, 0, sockets)) {
        ...
    }

    ...
    serverChannelName.append(" (server)");
    outServerChannel = new InputChannel(serverChannelName, sockets[0]);
    ...
    clientChannelName.append(" (client)");
    outClientChannel = new InputChannel(clientChannelName, sockets[1]);
    return OK;
}
```

万一 `socketpair()` などを勉強したい人がいたら {% asin 4894712059, Stevens の本 %} でも読んでおけばいいんじゃないでしょうか。

{% asin_img 4894712059, Stevens の本 %}

さて新たに作られた `InputChannel` の一端を担う `mInputManager`。クラスは `InputManagerService` だった。いかにも `InputEvent` がらみの気配がする名前。
これも C++ backed なクラスで、 `registerInputChannel()` の実装も
[C++ 側](https://github.com/android/platform_frameworks_base/blob/master/services/jni/com_android_server_input_InputManagerService.cpp) にある。

```c++ com_android_server_input_InputManagerService.cpp
...
status_t NativeInputManager::registerInputChannel(JNIEnv* env,
        const sp<InputChannel>& inputChannel,
        const sp<InputWindowHandle>& inputWindowHandle, bool monitor) {
    return mInputManager->getDispatcher()->registerInputChannel(
            inputChannel, inputWindowHandle, monitor);
}
...
```

backing class たる 'android::InputManager` が持つ [`InputDispatcher`](https://github.com/android/platform_frameworks_base/blob/master/services/input/InputDispatcher.cpp) に丸投げ。
でもこの名前、いかにもイベント配信してそうなクラスじゃないですか...

## InputDispatcher

```c++ InputDispatcher.cpp
...
status_t InputDispatcher::registerInputChannel(const sp<InputChannel>& inputChannel,
        const sp<InputWindowHandle>& inputWindowHandle, bool monitor) {
    { // acquire lock
        AutoMutex _l(mLock);
        ...
        sp<Connection> connection = new Connection(inputChannel, inputWindowHandle, monitor);

        int fd = inputChannel->getFd();
        mConnectionsByFd.add(fd, connection);
        ...
        mLooper->addFd(fd, 0, ALOOPER_EVENT_INPUT, handleReceiveCallback, this);
    } // release lock
    ...
    // Wake the looper because some connections have changed.
    mLooper->wake();
    return OK;
}
...
```

この `InputDispatcher` は `InputChannel` を `Connection` オブジェクトでラップした上で `mConnectionsByFd` に保存し、かつそのファイルデスクリプタを自身の持つ `Looper` に登録していた。
やはり `InputDispatcher` ... または仲間の `Connection` がソケットの一端であるのは間違いなさそうだ。

InputDispatcher の定義をみるとイベントループ `Looper` を持っている。
そしてそれらしいキューもある。

```c++ InputDispatcher.h
class InputDispatcher : public InputDispatcherInterface {
...
    sp<Looper> mLooper;

    EventEntry* mPendingEvent;
    Queue<EventEntry> mInboundQueue;
    Queue<EventEntry> mRecentQueue;
    Queue<CommandEntry> mCommandQueue;
...
}
```

この `Connection` は `InputDispatcher` 内の nested class. `InputChannel` に加え、キューも持っている。

```c++ InputDispatcher.h
    class Connection : public RefBase {
    protected:
        virtual ~Connection();

    public:
        ...
        sp<InputChannel> inputChannel; // never null
        sp<InputWindowHandle> inputWindowHandle; // may be null
        ...
        InputPublisher inputPublisher;
        ...
        // Queue of events that need to be published to the connection.
        Queue<DispatchEntry> outboundQueue;
        ...
        // Queue of events that have been published to the connection but that have not
        // yet received a "finished" response from the application.
        Queue<DispatchEntry> waitQueue;
        ...
    };
```

そして更によくみると `InputDispatcherThread` なんてクラスまである。

```c++ InputDispatcher.cpp
/* Enqueues and dispatches input events, endlessly. */
class InputDispatcherThread : public Thread {
public:
    explicit InputDispatcherThread(const sp<InputDispatcherInterface>& dispatcher);
    ~InputDispatcherThread();

private:
    virtual bool threadLoop();

    sp<InputDispatcherInterface> mDispatcher;
};

// InputManager.cpp
void InputManager::initialize() {
    mReaderThread = new InputReaderThread(mReader);
    mDispatcherThread = new InputDispatcherThread(mDispatcher);
}
```

`InputDispatcher::Connection::outboundQueue`, `InputDispatcher::inboundQueue`, `InputDispatcher::mLooper` そして `InputDispatcherThread`。
`InputDispatcher` は自身のスレッドとイベントループをもち、キューにため込んだデータをいくつかの `InputChannel` に書き出すようなクラスだ...と想像できる。
疲れてきたので詳しくは調べないけれど、読んでみるとだいたいそんなかんじだった。

## InputReader

では `InputDispatcher` のキューにデータを詰めるのは誰か。
というとすぐ隣に [`InputReader`](https://github.com/android/platform_frameworks_base/blob/master/services/input/InputReader.cpp) なるクラスがある。

```c++ InputReader.cpp https://github.com/android/platform_frameworks_base/blob/master/services/input/InputReader.cpp
...
class InputReader : public InputReaderInterface {
public:
    ...
    sp<EventHubInterface> mEventHub;
    KeyedVector<int32_t, InputDevice*> mDevices;
    ...
};
...
```

いかにも怪しい名前のオブジェクト `InputDevice` を持っている。加えて `InputReaderThread` まであり、つまりこの `InputReader` も自分のスレッドを持っている。
そして自分のスレッドで `EventHub` や `InputDevice` としてカプセル化された入力デバイスからの入力を待つ。

`InputManager`, `InputReader`, `InputDispatcher`。ざっと眺めたけれど、これらのクラスはいま以上に細かく見ても面白くない。
各クラスやスレッドとキューの関係をながめ、さっさと先に進みたい。

 * *InputDispatcher*: `InputDispatcher` は自分のスレッドで `Looper` をまわし、`InputChannel` にデータを書き込む。`InputDispatcher` への入力は `InputDispatcher::mInboundQueue` に詰められる。そしてこのキューをとりだし、配送先をみて適切な `InputChannel` (フォーカスのある Window に紐づいた `InputChannel`) に書き込む。
 * *InputReader*: `InputReader` も自分でスレッドを持っている。そのスレッドで `EventHub` からデータを読み出す。読み出したデータは `InputDispatcher` に通知される。
 * *InputManager*: `InputDispatcher` と `InputReader` の寿命を管理する。
 * `InputDispatcher` と `InputReader` の間には `QueuedInputListener` と呼ばれるキューが挟まっている。ただしこのキューにイベントが長居することはない。

図で書いてお茶を濁すとこんなかんじ:

![Input related classes](https://farm3.staticflickr.com/2917/14454313768_a0d76eb355_b_d.jpg)

## EventHub

`InputReader` が持つ `EventHub` はカーネルからユーザランドにタッチを届ける最初のオブジェクト。
ようやく下には Linux しかない階にたどり着いた。コンストラクタからしてそれっぽい。

```c++ EventHub.cpp
EventHub::EventHub(void) : ...
{
    ....
    mEpollFd = epoll_create(EPOLL_SIZE_HINT);
    ...
    mINotifyFd = inotify_init();
    int result = inotify_add_watch(mINotifyFd, DEVICE_PATH, IN_DELETE | IN_CREATE);
    ...
    struct epoll_event eventItem;
    memset(&eventItem, 0, sizeof(eventItem));
    eventItem.events = EPOLLIN;
    eventItem.data.u32 = EPOLL_ID_INOTIFY;
    result = epoll_ctl(mEpollFd, EPOLL_CTL_ADD, mINotifyFd, &eventItem);
    ...
    int wakeFds[2];
    result = pipe(wakeFds);
    ...
    mWakeReadPipeFd = wakeFds[0];
    mWakeWritePipeFd = wakeFds[1];
    ...
    result = fcntl(mWakeReadPipeFd, F_SETFL, O_NONBLOCK);
    ...
    result = fcntl(mWakeWritePipeFd, F_SETFL, O_NONBLOCK);
    ...
    result = epoll_ctl(mEpollFd, EPOLL_CTL_ADD, mWakeReadPipeFd, &eventItem);
    ...
}
```

`inotify`, `fcntl`, `epoll` に `pipe`... なんとなくサーバのコードを読んでるみたいで落ち着く。
`inotify` を使っているのはデバイスの動的な追加や削除に対応するため。
`Looper` を使わず `epoll` を直接呼んでいるのはなぜ？とかは気にしないでおく。たぶんたいした理由はなかろう。

肝心なデバイスたちを追加するコードは `EventHub::scanDirLocked()`.

```c++ EventHub.cpp
status_t EventHub::scanDirLocked(const char *dirname)
{
    char devname[PATH_MAX];
    char *filename;
    DIR *dir;
    struct dirent *de;
    dir = opendir(dirname);
    if(dir == NULL)
        return -1;
    strcpy(devname, dirname);
    filename = devname + strlen(devname);
    *filename++ = '/';
    while((de = readdir(dir))) {
        if(de->d_name[0] == '.' &&
           (de->d_name[1] == '\0' ||
            (de->d_name[1] == '.' && de->d_name[2] == '\0')))
            continue;
        strcpy(filename, de->d_name);
        openDeviceLocked(devname);
    }
    closedir(dir);
    return 0;
}
```

なんというか、C++ というより C なかんじのコードですな。
`openDeviceLocked()` の中身はひたすら `ioctl()` してデバイスの種別を検出する
コードがだらだらと書かれている。読むと疲れるから省略。
こうして開かれたデバイスたちが epoll 経由で監視され、状態を読み出される。それだけ知っていればいい気がする。

## input_event

`epoll_wait()` をラップする `EventHub::getEvents()` を見ると、
デバイスたちとどんなデータ形式で情報をやり取りするのか垣間みる事ができる。

```c++ EventHub.cpp https://github.com/android/platform_frameworks_base/blob/master/services/input/EventHub.cpp
...
size_t EventHub::getEvents(int timeoutMillis, RawEvent* buffer, size_t bufferSize) {
    ...
    struct input_event readBuffer[bufferSize];
        ...
            const struct epoll_event& eventItem = mPendingEventItems[mPendingEventIndex++];
            ssize_t deviceIndex = mDevices.indexOfKey(eventItem.data.u32);
            ...
            Device* device = mDevices.valueAt(deviceIndex);
            if (eventItem.events & EPOLLIN) {
                ...
                int32_t readSize = read(device->fd, readBuffer,
                        sizeof(struct input_event) * capacity);
                ...
            }
        ...
}
```

`input_event` なる構造体を読み出している。

これは Linux が定義する構造体。入力デバイス用ドライバ仕様の一部として[文書化されている](https://www.kernel.org/doc/Documentation/input/input.txt)。

Linux 側だけでなく、あんどろ側でも `InputReader` 周辺のコードについては[簡単な説明](http://source.android.com/devices/tech/input/overview.html)がある。
自分のデバイスにあんどろを移植したい人が読む資料のひとつらしい。コード読まなくてもよかったじゃん...
アプリケーションの奥に潜ったつもりが反対側の玄関に出てしまった気分。

今回の主題タッチイベントについても[きちんと説明があり](http://source.android.com/devices/tech/input/touch-devices.html)、
しかも結局のところ [Linux のドライバの仕様](https://www.kernel.org/doc/Documentation/input/multi-touch-protocol.txt) に従いましょう、という結論のよう。
なるほどこれが Linux をベースにするということかとやや感心した。もうちょっと変な事をやってるもんだと勝手に思ってた・・・。

デバイスファイルというそこそこ標準的なインターフェイスを使っているおかげで、
unlocked なデバイスでは [外部からイベントを注入することもできるらしい](http://www.pocketmagic.net/2013/01/programmatically-injecting-events-on-android-part-2/)。
その仕組みをテストの自動化に使う話などをみかけた。こんなレイヤで自動化をするのが良いアイデアなのかはさておき、おもしろい話ではあるね。

## そのほか InputManager の仕事

この `InputManager` と仲間たちの周辺は面倒な問題をまとめて押し込んだ風情。あちこちで細々とした問題に対処している。
たとえデバイスの傾きに応じ画面の向きが回転すると、デバイスから届く座標を回転変換してからアプリケーションに知らせる。
またあんどろはある時期から画面上の仮想ボタンで物理ボタンを代替できるようになった。その仮想ボタン(virtual key)も `InputReader` が面倒を見る。
そういう雑多な責務を押し付けられた結果、 [`InputReader.cpp`](https://github.com/android/platform_frameworks_base/blob/master/services/input/InputReader.cpp) は 6500 行、
[`InputDispatcher.cpp`](https://github.com/android/platform_frameworks_base/blob/master/services/input/InputDispatcher.cpp) は 4500 行にふくれあがっている。気の毒。

## まとめなど

というわけで `View#onTouchEvent()` に `MotionEvent` がとどくまでの道程を眺めてみた。

スタート地点である `View` を含むプロセスでは、余分なスレッドに寄り道することなく `Looper` に便乗した `InputEventReceiver` が `InputChannel` から `InputMessage` を読み出し、
バッチ化した上で `ViewRootImpl` にイベントをよこす。Binder ではなく `InputChannel` のような別の経路を使うのは、メインループに処理をくっつけるためでもあろうだろう。

`ViewRootImpl` が受け取ったイベントは `InputStage` マイクロフレームワークを通過してから `View` ツリーに送り込まれる。
ツリーの中では座標変換や衝突判定などをしつつ親から子へイベントが伝播する。

`View` のあるプロセスにイベントのデータを送りつけるのは Window Manager のサービスが住むプロセス。 
`IWindowManager` binder オブジェクトが `View` のある ... というか Window を持つプロセスに `InputChannel` を付与する。
`InputChannel` の実体は `socketpair()` で作った UNIX ドメインソケットだった。

Window Manager のプロセスには送付先 `InputChannel` を複数束ねる `InputDispatcher` と、デバイスファイルを束ねる `InputReader` がいる。
この２つのオブジェクトはそれぞれ自分のスレッドを持っている。`InputManager` がこの２つのオブジェクトをまとめた facade として機能している。
`InputReader` は `EventHub` オブジェクトにデバイスファイルのデスクリプタを預け、 `EventHub` は `epoll` や `inotify` でこれらのファイルやファイルのディレクトリを監視、
データを読みだす。読み出されたデータは `InputReader` が `InputDispatcher` に手渡す。`InputDispatcher` はそのデータを適当な `InputChannel` に書き出す。

![life of touch](https://farm3.staticflickr.com/2926/14638745414_618c56034c_b_d.jpg)

オブジェクトやプロセスをまたいだイベントの受け渡しには何らかのキューが使われる。キューには処理を非同期化するものとしないものがある。
`View` のあるプロセスの中に限るとキューは一つ、 `ViewRootImpl` がもつ `QueuedInputEvent` だけ。このキューは(多くの場合)処理を非同期化せず、その場で同期的に消化された。

`View` のあるプロセスと Window Manager のプロセスの間には `InputChannel` に隠された UNIX ドメインソケットというキューがある。
これは非同期。プロセスをまたぐ以上同期的に動きようがない。

Window Manager の中にはたくさんのキューがある。 `InputDispatcher` がもつ `inboutQueeue`, `InputDispatcher::Connection` の `outboundQueue`, `InputDispatcher` と
`InputReader` をつなぐ `QueuedInputListener`. 中でも `InputDispatcher::inboundQueue` はスレッドをまたぐ非同期化に使われている。
あとはカーネルのなかに追加のキューがあっても驚かないけれど、調べていない。ユーザ空間の中では非同期化されるキューは２つだけ。
反応性への配慮という点で、これはがんばってるとおもう。

### わからないこと

入力やイベント処理というのは一般に abstraction が leak しやすい分野。ここでも例にもれず読むのに疲れる雑然としたコードがあちこちに顔を出し、読むのは疲れた。
とはいえあんどろ入門という当初の目的には悪くなかった気がする。`View` ツリー内へのディスパッチをひやかして `View` のイベントモデルに入門し、
`Looper` を通じてスレッドモデルをちらりとのぞき、`InputChannel` の周辺をさまよい Binder と Parcel に触れ、 
Window Manager のはじっこを通り過ぎて最後は Linux の表面に降り立った。あんどろよくわからん、という気分は若干薄れた気がする。

とはいえ当然ながらわからないことも沢山ある。Activity や最初の View はどうやって作られたのか。
特に IWindowManager のようなサービスはどのプロセスで動いていて、アプリケーションはその binder オブジェクトをどう手に入れるのか。
そんな bootstrap は全然わかっていない。

Binder といえばスレッドモデルもよくわからない。proxy 経由のメソッド呼び出しはホスト側のどのスレッドに届くのか。

イベントをうけとったあと、画面がどう描かれるのか・・・は、 [Graphics System-Level Architecture](https://source.android.com/devices/graphics/architecture.html) という
よく書かれた資料があり、このおかげでそこそこわかった気になれた。今回タッチイベントについて書こうと思ったのもこの文書に刺激されたから。
まあ素人のラクガキなので比べ物にはならないけどね・・・。

あとはそもそもどうやってアプリを構成するのがよいのかなど常識的な話がわかってない。
すいすい動くアプリはどうしたら作れるのか、とかさ。まあ手を動かさないとわからないことだろうし、ぼちぼちやっていこうとおもいます。

間違いそのほかは気が向いたらついったなどで訂正していただけると助かります、と繰り返し教えを乞うて今日はおしまい。

![feeling sleepy](https://farm6.staticflickr.com/5508/14617931856_31533cd133_b.jpg)