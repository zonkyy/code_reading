# -*- coding: utf-8 -*-

# Unix mbox 形式のメールファイルを解析するライブラリ
class Mail

  # メールファイルを解析し、ヘッダのハッシュとボディの配列を作成する
  # @param f 解析したいメールファイル
  def initialize(f)
    # 引数 f に gets が定義されていなければ
    # ファイルとみなしてオープンする
    unless defined? f.gets
      f = open(f, "r")
      opened = true
    end

    @header = {}
    @body = []
    begin
      # ヘッダの処理
      while line = f.gets()
        line.chop!
        # Fromで始まる行は処理しない
        next if /^From /=~line  # skip From-line
        # 空行でヘッダは終了
        break if /^$/=~line     # end of header

        # ヘッダの各項目をキーとしたハッシュを作成
        if /^(\S+?):\s*(.*)/=~line
          (attr = $1).capitalize!
          @header[attr] = $2
        elsif attr
          # 複数行にまたがる項目の処理
          line.sub!(/^\s*/, '')
          @header[attr] += "\n" + line
        end
      end

      # lineが空行でなくnilならボディはないため処理を終了する
      return unless line

      # ボディの処理
      while line = f.gets()
        break if /^From /=~line
        @body.push(line)
      end
    ensure
      # ファイルを開いたら必ず閉じる
      f.close if opened
    end
  end

  # ヘッダのハッシュを取得する
  # @return [Hash] ヘッダの各項目をキーとしたハッシュ
  def header
    return @header
  end

  # ボディの配列を取得する
  # @return [Array] ボディを改行ごとに分割した配列
  def body
    return @body
  end

  # 項目のキーを用いてヘッダの内容を取得する
  # @param [String] field ヘッダの項目
  # @return [String] ヘッダのその項目の内容
  def [](field)
    @header[field.capitalize]
  end
end
