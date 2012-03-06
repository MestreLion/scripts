# ruby
l=92.chr;eval s="s=s.dump[r=1..-2].gsub(/("+l*4+"){4,}(?!\")/){|t|'\"+l*%d+\"'%(t
.size/2)};5.times{s=s.dump[r]};puts\"# python\\nprint(\\\"# perl\\\\nprint(\\\\\\
\"# lua"+l*4+"nprint("+l*7+"\"(* ocaml *)"+l*8+"nprint_endline"+l*15+"\"-- haskel
l"+l*16+"nimport Data.List;import Data.Bits;import Data.Char;main=putStrLn("+l*31
+"\"/* C */"+l*32+"n#include<stdio.h>"+l*32+"nint main(void){char*s[501]={"+l*31+
"\"++intercalate"+l*31+"\","+l*31+"\"(c(tail(init(show("+l*31+"\"/* Java */"+l*32
+"npublic class QuineRelay{public static void main(String[]a){String[]s={"+l*31+"
\"++intercalate"+l*31+"\","+l*31+"\"(c("+l*31+"\"brainfuck"+l*64+"n++++++++[>++++
<-]+++++++++>>++++++++++"+l*31+"\"++(concat(snd(mapAccumL h 2("+l*31+"\"110"+l*31
+"\"++g(length s)++"+l*31+"\"22111211100111112021111102011112120012"+l*31+"\"++co
ncatMap("+l*32+"c->let d=ord c in if d<11then"+l*31+"\"21002"+l*31+"\"else"+l*31+
"\"111"+l*31+"\"++g d++"+l*31+"\"22102"+l*31+"\")s++"+l*31+"\"2100211101012021122
2211211101000120211021120221102111000110120211202"+l*31+"\"))))))++"+l*31+"\","+l
*63+"\""+l*64+"n"+l*63+"\"};int i=0;for(;i<94;i++)System.out.print(s[i]);}}"+l*31
+"\")))))++"+l*31+"\",0};int i=0;for(;s[i];i++)printf("+l*63+"\"%s"+l*63+"\",s[i]
);puts("+l*63+"\""+l*63+"\");return 0;}"+l*31+"\");c s=map("+l*32+"s->"+l*31+"\""
+l*63+"\""+l*31+"\"++s++"+l*31+"\""+l*63+"\""+l*31+"\")(unfoldr t s);t[]=Nothing;
t s=Just(splitAt(if length s>w&&s!!w=='"+l*31+"\"'then 501else w)s);w=500;f 0=Not
hing;f x=Just((if x`mod`2>0then '0'else '1'),x`div`2);g x= reverse (unfoldr f x);
h p c=let d=ord c-48in(d,replicate(abs(p-d))(if d<p then '<'else '>')++"+l*31+"\"
."+l*31+"\");s="+l*31+"\"# ruby"+l*32+"n"+l*31+"\"++"+l*31+"\"l=92.chr;eval s=\"+
(z=l*31)+\"\\\"\"+s+z+\"\\\""+l*31+"\"++"+l*31+"\""+l*32+"n"+l*31+"\""+l*15+"\""+
l*7+"\")"+l*4+"n\\\\\\\")\\\")\"########### (c) Yusuke Endoh, 2009 ###########\n"
