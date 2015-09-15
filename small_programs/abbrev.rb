#!/usr/bin/env ruby
# coding: utf-8

# 与えられた文字列の配列から一意に決まる短縮形を計算する
#
# @example
#   require 'abbrev'
#   require 'pp'
#
#   pp Abbrev.abbrev(%w[ruby rules]).sort
#       # => [["rub", "ruby"],
#       #    ["ruby", "ruby"],
#       #    ["rul", "rules"],
#       #    ["rule", "rules"],
#       #    ["rules", "rules"]]
module Abbrev

  # @param [Array<String>] words 略語を計算する文字列配列
  # @param [String, Regexp] pattern 一致する略語のみを出力。
  def abbrev(words, pattern = nil)
    # どの略語がどの文字列に対応するかを格納するハッシュ
    table = {}
    # 各略語の出現回数を集計するハッシュ
    seen = Hash.new(0)

    # 引数 pattern を正規表現に統一
    if pattern.is_a?(String)
      pattern = /\A#{Regexp.quote(pattern)}/
    end

    # words の全文字列について、先頭を含む全ての部分文字列の出現回数を集計
    # (先頭を含む全部分文字列: 'ruby' なら 'rub', 'ru', 'r')
    # (集計後は seen = {'rub' => 1, 'ru' => 2, 'rul' => 1, ...} のようになる)
    words.each do |word|
      next if word.empty?
      word.size.downto(1) { |len|
        abbrev = word[0...len]

        # パターンに一致しなければ集計せず次へ
        next if pattern && pattern !~ abbrev

        case seen[abbrev] += 1
        when 1
          # 初めて出現した略語を登録
          table[abbrev] = word
        when 2
          # 一意に決まらない (2 回出現した) 略語は削除
          table.delete(abbrev)
        else
          break
        end
      }
    end

    # 文字列そのものを略語登録
    words.each do |word|
      # パターンに一致しなければ登録しない
      next if pattern && pattern !~ word

      table[word] = word
    end

    table
  end

  # abbrev を Abbrev.abbrev で呼び出せるようなモジュール関数とする
  # (引数を書かなければ module_function 以降のメソッドがモジュール関数となる)
  module_function :abbrev
end


# ['ruby', 'rules'].abbrev を使えるように Array にモンキーパッチ
class Array
  # @param [String, Regexp] pattern 一致する略語のみを出力。
  def abbrev(pattern = nil)
    Abbrev::abbrev(self, pattern)
  end
end


# このファイルをクラス利用のために呼ぶときと実行ファイルとして呼ぶときで
# 処理を区別したいときのための定型句
if $0 == __FILE__
  while line = gets
    # 標準入力を半角スペースで区切った文字列それぞれに対して abbrev 実行
    hash = line.split.abbrev

    hash.sort.each do |k, v|
      puts "#{k} => #{v}"
    end
  end
end
