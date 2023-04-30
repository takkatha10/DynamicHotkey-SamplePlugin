/*
	Sample plugin

	プラグインの基本的な機能を実装したサンプル
*/
class Sample	; クラス名はファイル名と同じ名前にする必要がある
{
	/*
		変数

		ここで宣言したものはコンストラクターよりも早く初期化される
	*/
	static instance := ""	; 変数を共有するためのインスタンスを保持する変数
	str := ""				; 文字列を保持する変数
	cnt := 0				; 関数を実行した回数を保持する変数
	selfKeys := {}			; 自身の辞書キーを保持するオブジェクト変数
	funcNew := ""			; NEWメッセージを受信した時に実行する関数オブジェクトを保持する変数
	funcDelete := ""		; DELETEメッセージを受信した時に実行する関数オブジェクトを保持する変数

	/*
		コンストラクター

		基本的になくても良いが、インスタンスを共有したり、メッセージを受信したりなどする場合に必要
	*/
	__New()
	{
		If (Sample.instance)											; クラスインスタンスが存在するかどうかのチェック
		{
			OnMessage(DHKMessages.HOTKEY_NEW, Sample.instance.funcNew)	; クラスインスタンスが存在するなら、NEWメッセージを受信した時に実行する関数オブジェクトの登録
			Return Sample.instance										; クラスインスタンスを返す（この時点でこれを実行しているthisインスタンスの参照がなくなる）
		}
		Sample.instance := this 										; クラスインスタンスが存在しないなら、thisインスタンスをクラスインスタンスに設定する
		str := "Hello, World!"											; 出力する文字列を設定する
		this.Private_SetStr(str)										; 文字列を設定するプライベートメソッドの呼び出し
		this.funcNew := ObjBindMethod(this, "Private_New")				; メソッドをバインド
		this.funcDelete := ObjBindMethod(this, "Private_Delete")		; 〃
		OnMessage(DHKMessages.HOTKEY_NEW, this.funcNew)					; NEWメッセージを受信した時に実行する関数オブジェクトの登録
		OnMessage(DHKMessages.HOTKEY_DELETE, this.funcDelete)			; DELETEメッセージを受信した時に実行する関数オブジェクトの登録
	}

	/*
		デストラクター

		基本的になくても良いが、デバッグ時に役立つ
	*/
	__Delete()
	{
		DisplayTrayTip("Instance deleted!")	; インスタンスの参照がなくなると通知が表示される
	}

	/*
		パブリックメソッド

		ホットキーに割り当てて使用する関数
		Direct sendで使用したい場合はメソッド名に"Direct_"という接頭辞をつける必要がある
	*/
	; 文字列を出力する
	HelloWorld(title := "")
	{
		this.cnt++										; 呼び出し回数を加算する
		DisplayTrayTip(this.str " x" this.cnt, title)	; 表示内容を設定した通知を表示する
	}

	; 指定したウィンドウに対して文字列を出力する
	Direct_HelloWorld(winTitle)
	{
		ControlSend,, % "{Text}" this.str, % winTitle
	}

	/*
		プライベートメソッド

		ホットキーに割り当てない関数
		プライベートメソッドはメソッド名に"Private_"という接頭辞をつける必要がある
	*/
	; 文字列を設定する
	Private_SetStr(str)
	{
		this.str := str	; 文字列を保持する変数に新たな値を代入する
	}

	; NEWメッセージを受信した時に実行する
	Private_New(wParam, lParam)
	{
		key := Object(lParam).GetKey()						; パラメーターにはホットキーオブジェクトのアドレスが入っており、そこからオブジェクトを取得し、辞書キーを取り出す
		If (this.selfKeys.HasKey(key))						; 自身の辞書キーの一覧に辞書キーが存在するかどうかのチェック
		{
			Return											; 辞書キーが存在するなら、何もしない
		}
		this.selfKeys[key] := True							; 辞書キーが存在しないなら、新たに登録する
		OnMessage(DHKMessages.HOTKEY_NEW, this.funcNew, 0)	; NEWメッセージに対する関数オブジェクトの登録を解除
	}

	; DELETEメッセージを受信した時に実行する
	Private_Delete(wParam, lParam)
	{
		key := Object(lParam).GetKey()								; 辞書キーを取り出す
		If (!this.selfKeys.HasKey(key))								; 自身の辞書キーの一覧に辞書キーが存在するかどうかのチェック
		{
			Return													; 辞書キーが存在しないなら、何もしない
		}
		this.selfKeys.Delete(key)									; 辞書キーが存在するなら、その辞書キーを削除する
		If (this.selfKeys.Count())									; 自身の辞書キーの数のチェック
		{
			Return													; 辞書キーが残っているなら、何もしない
		}
		OnMessage(DHKMessages.HOTKEY_NEW, this.funcNew, 0)			; 辞書キーが残っていないなら、NEWメッセージに対する関数オブジェクトの登録を解除
		OnMessage(DHKMessages.HOTKEY_DELETE, this.funcDelete, 0)	; DELETEメッセージに対する関数オブジェクトの登録を解除
		this.funcNew := ""											; メソッドのバインドを解除
		this.funcDelete := ""										; 〃
		Sample.instance := ""										; クラスインスタンスを削除（この時点でクラスインスタンスの参照がなくなる）
	}
}
