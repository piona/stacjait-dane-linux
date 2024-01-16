reset
# set term png size 960,480
# set output 'data.png'

set title "Temperatura"

set style data line
# set key autotitle columnheader
set tics nomirror

# grid
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12

# linestyle
set style line 1 lc rgb '#a1a100' pt 1 ps 1 lt 1 lw 2

set xrange [ 0 : 100 ]
set yrange [ -30 : 30 ]

set autoscale xfix

# plot data
plot 'd' using 0:3 w lp ls 1
