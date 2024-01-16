reset
set term png size 960,480
set output 'count.png'

set style data histograms
set key autotitle columnheader
set style fill solid

set yrange [ 0 : 20]
plot 'count.dat' using 2:xtic(1)
