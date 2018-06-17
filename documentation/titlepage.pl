#!/usr/bin/env perl
# a helper script to make the tikzmark subsitutions for line numbers 
use strict;
use warnings;

# indent titlepage.tex
system('latexindent.pl -w -s -l=titlepage.yaml titlepage.tex');

# add the tikzmark markers
my @lines;
open(MAINFILE,"titlepage.tex");
push(@lines,$_) while(<MAINFILE>);
close(MAINFILE);
my $body = join("",@lines);

my $bodyLineBreaks;

$body =~ s/(\\begin\{lstlisting}\[.*?\]\h*\R)(.*?)(\\end\{lstlisting\})/
            # store begin, middle and end
            my $begin = $1;
            my $listings = $2;
            my $end = $3;
            # count the lines
            my @tikzmarked = split("\n",$listings);
            $bodyLineBreaks = scalar(@tikzmarked);
            my $linecount = 0;
            my $newline; 
            my @tikzmarkedNew;
            foreach (@tikzmarked){
                $linecount++;
                $newline = $_;
                my $tikzmarkBegin = '(*@\tikzmark{linebegin'.$linecount.'}@*)';
                $newline =~ s"^(\h*)"$1$tikzmarkBegin";
                my $tikzmarkEnd = '(*@\tikzmark{linebegin'.(2*$bodyLineBreaks-($linecount-1)).'}@*)';
                $newline =~ s"(\h*)$"$tikzmarkEnd";
                push(@tikzmarkedNew,$newline);
            };
            $begin.join("\n",@tikzmarkedNew)."\n".$end;/xse;

# start the tikzpicture for overlay
my $draw = '\begin{tikzpicture}[overlay,remember picture]
	\draw[opacity=0.75,fill=red!50!white,draw=red,very thick,rounded corners=.5ex]
($(linebegin1)+(0ex,-1ex)$)'."\n";

# loop down the left hand side
foreach (2..$bodyLineBreaks){
    $draw .= '-| ($(linebegin'.$_.')+(0ex,-1ex)$)'."\n";
}

# across the bottom
$draw .= '-- ($(linebegin'.($bodyLineBreaks+1).')+(0ex,-1ex)$)'."\n";

# back up the right side
foreach ($bodyLineBreaks+2..2*$bodyLineBreaks){
    $draw .= '|- ($(linebegin'.$_.')+(0ex,-1ex)$)'."\n";
}

# across the top
$draw .= '|- ($(linebegin'.(2*$bodyLineBreaks).')+(0ex,1ex)$)'."\n";
$draw .= '|- ($(linebegin1)+(0ex,2ex)$)'."\n";
$draw .= '-- ($(linebegin1)+(0ex,-1ex)$);'."\n";

# finish the tikzpicture
$draw .= '\end{tikzpicture}';

# put the tikzpicture in the document
$body =~ s/(\\end\{lstlisting\})/$1\n$draw/;

# output to a new file
open(OUTPUTFILE,">","titlepage-tikzmark.tex");
print OUTPUTFILE $body;
close(OUTPUTFILE);
    
exit; 
