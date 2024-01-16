reset
# set term png size 960,480
# set output 'data.png'

set title "Pomiary"

set style data line
# set key autotitle columnheader
set tics nomirror

# grid
set style line 12 lc rgb '#808080' lt 0 lw 1
set grid back ls 12

# linestyle
set style line 1 lc rgb '#a10000' pt 1 ps 1 lt 1 lw 2
set style line 2 lc rgb '#00a100' pt 6 ps 1 lt 1 lw 2
set style line 3 lc rgb '#0000a1' pt 3 ps 1 lt 1 lw 2

set xrange [ 0 : 100 ]
set yrange [ 0 : 5 ]

# plot data
plot 'd' using 0:2 w lp ls 1, '' using 0:3 w lp ls 2, '' using 0:4 w lp ls 3
