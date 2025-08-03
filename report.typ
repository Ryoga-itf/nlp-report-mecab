#let textL = 1.8em
#let textM = 1.6em
#let fontSerif = ("Noto Serif", "Noto Serif CJK JP")
#let fontSan = ("Noto Sans", "Noto Sans CJK JP")

#import "@preview/codelst:2.0.2": sourcecode, sourcefile
#import "@preview/tenv:0.1.2": parse_dotenv
#let env = parse_dotenv(read(".env"))

#let title = "自然言語処理レポート"
#let authors = (
  (
    name: env.STUDENT_NAME,
    id: env.STUDENT_ID,
    affiliation: env.STUDENT_AFFILIATION,
  ),
)
#let date = "2025 年 8 月 4 日"


#set document(author: authors.map(a => a.name), title: title)
#set page(numbering: "1", number-align: center)
#set text(font: fontSerif, lang: "ja")

#show heading: set text(font: fontSan, weight: "medium", lang: "ja")

#show heading.where(level: 2): it => pad(top: 1em, bottom: 0.4em, it)
#show heading.where(level: 3): it => pad(top: 1em, bottom: 0.4em, it)

// Figure
#show figure: it => pad(y: 1em, it)
#show figure.caption: it => pad(top: 0.6em, it)
#show figure.caption: it => text(size: 0.8em, it)

// Title row.
#align(center)[
  #block(text(textL, weight: 700, title))
  #v(1em, weak: true)
  #date
]

// Author information.
#pad(
  top: 0.5em,
  bottom: 0.5em,
  x: 2em,
  grid(
    columns: (1fr,) * calc.min(3, authors.len()),
    gutter: 1em,
    ..authors.map(author => align(center)[
      *#author.name* \
      #author.id \
      所属：#author.affiliation
    ]),
  ),
)

// Main body.
#set par(justify: true)

#show raw: set text(font: "Hack Nerd Font")

== 実行した環境

全学計算機の Linux サーバへ SSH 接続した上で行った。

詳細な環境を以下に示す。

#sourcecode[```
$ cat /proc/version
Linux version 5.15.0-144-generic (buildd@lcy02-amd64-099) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #157-Ubuntu SMP Mon Jun 16 07:33:10 UTC 2025

$ mecab --version
mecab of 0.996

$ sort --version
sort (GNU coreutils) 8.32
Copyright (C) 2020 Free Software Foundation, Inc.
ライセンス GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

作者 Mike Haertel および Paul Eggert。

$ awk --version
GNU Awk 5.1.0, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)
Copyright (C) 1989, 1991-2020 Free Software Foundation.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
```]

== 課題 (1)

=== 概要

本課題は、全学計算機サーバの `/www/yamamoto.mikio.gm/lecture/nlp/sentences` ディレクトリ配下にある
`sen179k.txt` に対し、出現頻度で上位 15 個の形態素（基本形）を品詞と出現頻度と共に抽出し、報告するというものである。

なお、基本形 (`$f[6]`) で区別し、品詞が異なるものは区別するという条件がある。

=== 演習と実行結果

以下のコマンドをシェル上で実行することにより結果を得た。

#sourcecode[```
mecab -F '%f[6]\t%f[0]\n' -U '%f[6]\t%f[0]\n' -E '' sen179k.txt \
  | LC_ALL=C gawk '{
        if($0!="EOS") cnt[$0]++
    }
    END{
        for(k in cnt) print cnt[k], k
    }' \
  | sort -nr \
  | head -n 15 \
  | gawk '{printf "%-10s\t%-6s\t%s\n",$2,$3,$1}'
```]

なお、当初は以下のコマンドで実行を行おうとしていたが、あまりにも遅かったので、`sort | uniq` を 1 度にまとめ、I/O を最小化することで高速化を図った。
また、途中で EOS 行は `-E ''` で抑制できることを知ったため、`grep -v '^EOS'` からそれに書き換えている。

しかし、何をやっているかは、高速化前の以下のコマンドのほうがわかりやすいため、レポートに記載した。

#sourcecode[ ```
mecab -F '%f[6]\t%f[0]\n' -U '%f[6]\t%f[0]\n' sen179k.txt \
  | grep -v '^EOS' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -n 15 \
  | awk '{printf "%-10s\t%-6s\t%s\n",$2,$3,$1}'
```]

- `mecab -F '%f[6]\t%f[0]\n'` によって、基本形 (`%f[6]`) と品詞大分類(`%f[0]`) のみをタブ区切りで出力され、
- `-U ... -E ''` と `grep -v '^EOS'` によって EOS 行を除外、
- `sort` と `uniq -c` により、基本形と品詞で頻度を集計し、
- `sort -nr` により、頻度順に降順にソートされ、
- `head -n 15` により、上位 15 件が抽出され、
- `awk ...` により、表示を基本形, 品詞, 頻度の順にしている。

このコマンドにより、正しくレポートの要件に沿った結果が得られると考えられる。

これにより、以下として以下を得た。

#sourcecode[```
の         	助詞    	223098
、         	記号    	207535
。         	記号    	166468
に         	助詞    	141583
は         	助詞    	140344
を         	助詞    	133805
が         	助詞    	114183
た         	助動詞   	111156
する        	動詞    	103092
て         	助詞    	94171
だ         	助動詞   	79071
と         	助詞    	63572
で         	助詞    	62404
いる        	動詞    	51461
も         	助詞    	39779
```]

== 課題 (2)

=== 概要

本課題は、全学計算機サーバの `/www/yamamoto.mikio.gm/lecture/nlp/sentences` ディレクトリ配下にある
`neko.txt` に対し、出現頻度上位 15 個の名詞とその出現頻度を報告するというものである。

なお、形態素の見出しは `%m` で出力する条件がある。

=== 演習と実行結果

以下のコマンドをシェル上で実行することにより結果を得た。

#sourcecode[```
mecab -F '%m\t%f[0]\n' -U '%m\t%f[0]\n' -E '' neko.txt \
  | LC_ALL=C gawk '$2=="名詞"{cnt[$1]++}
      END{for(k in cnt)print cnt[k],k}' \
  | sort -nr \
  | head -n 15 \
  | gawk '{printf "%-10s\t%s\n",$2,$1}'
```]

また、結果として以下を得た。

#sourcecode[```
の         	1402
事         	1062
主人        	865
もの        	857
君         	850
よう        	618
ん         	595
人         	519
一         	496
何         	479
吾輩        	467
これ        	372
それ        	349
迷亭        	315
時         	290
```]
