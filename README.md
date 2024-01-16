# Analiza danych z wykorzystaniem narzędzi GNU/Linux

Repozytorium zawiera materiały z warsztatu [Stacja.IT](https://stacja.it/).

## Przygotowanie do warsztatu

Do wykonania ćwiczeń będą potrzebne narzędzia z pakietów `coreutils`, `grep`,
`make`, `gnuplot` i `wget`. Zazwyczaj mają identyczne nazwy w różnych
dystrybucjach Linux.

Warsztat najlepiej wykonać z wykorzystaniem systemu Linux, choć powyższe
narzędzia dostępne są również dla Windows oraz macOS.

## Warsztat

**UWAGA!** W poniższych poleceniach i skryptach przyjętych jest szereg założeń
związanych z formatem danych wejściowych i parametrów. Podane przykłady niekiedy
mogą nie działać lub być niebezpieczne (popsucie danych, błędne wyniki).

### Idea działania narzędzi

Pakiet `coreutils` dostarcza wiele narzędzi, które robią małe rzeczy. Idea
polega na sprytnym połączeniu ich działania.

Większość narzędzi przygotowanych jest z uwzględnieniem opisanych poniżej
*konwencji działania*.

Programy domyślnie korzystają ze *standardowego wejścia* i *standardowego
wyjścia*. Można je przekierować z/do pliku. Zazwyczaj przetwarzają dane linia po
linii (separatorem jest znak nowej linii)

```
    $ cat
    Hej
    Hej
    (wciśnij Ctrl+D)
    $ cat > plik
    Hej
    (wciśnij Ctrl+D)
    $ cat < plik
```

Należy zachować ostrożność przy używaniu tego samego pliku jako wejścia
i wyjścia. Zazwyczaj prowadzi to do utraty danych.

Wyjście jednego programu może stać się wejściem kolejnego programu. Można do
tego wykorzystać pliki tymczasowe lub *potoki*

```
    $ cat > dane
    2
    8
    1
    4
    0
    2
    (wciśnij Ctrl+D)
    $ sort dane | uniq
    $ # wypisanie danych w odwrotnej kolejności
    $ sort dane | uniq | tac
    $ sort -r dane | uniq
```

Bardzo często potoki są nadużywane, np. nie powinno się nadużywać `cat`

```
    $ cat dane | sort | uniq
```

Programy obsługują parametry, które wpływają na ich działanie. Występują w
formie długiej rozpoczynającej się od `--` i krótkiej rozpoczynającej się od
`-`. Parametry są oddzielone spacjami (spacja ma znaczenie specjalne i nie można
jej używać zupełnie dowolnie)

```
    $ seq 10 | shuf
    $ seq 10 | shuf --repeat
    (działanie można przerwać za pomocą Ctrl+C)
    (krócej)
    $ seq 10 | shuf -r -n 30
    (polecenie można przywrócić z historii za pomocą Ctrl+P lub strzałki w górę)
    $ seq 10 | shuf -r -n 30 | more
```

Programy przyjmują jako parametry również nazwy plików, które mają być
przetwarzane. Powłoka może pomóc w przygotowaniu tych parametrów. Aby nazwy
plików nie były interpretowane jako opcje programu należy podawać je po `--`.
Jest to szczególnie ważne w skryptach

```
    $ echo 1 > plik1
    $ echo 2 > plik2
    $ echo 3 > plik3
    $ cat plik1 plik2 plik3
    $ cat plik*
    $ cat plik{3,2,1}
    $ cat plik{1..3}
    $ cat -- plik*
```

Dostępna jest podręczna pomoc

```
    $ whatis shuf
    $ man shuf
    $ info shuf
```

Dokumentacja jest również dostępna [online](https://www.gnu.org/software/coreutils/manual/coreutils.html).

### Przykład: pomiary

Pobierzmy pliki z pomiarami

```
    wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/00/d1
    wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/00/d2
    wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/00/d3
```

Co jest w środku

```
    $ cat d1
    $ more d2
    $ less d3
    $ head d1
    $ tail d2
```

Połączmy wyniki i narysujmy wykres

```
    $ seq 100 > s
    $ paste s d1 d2 d3 > d
    $ # lub krócej
    $ paste <(seq 100) d1 d2 d3 > d
    $ # albo
    $ paste <(nl -n ln d1) d2 d3 > d
```

Jeśli są kłopoty ze znakiem tabulacji można użyć poleceń `expand` i `unexpand`.

Wizualizacja

```
    $ wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/00/data.plt
    $ gnuplot -p data.plt
```

Więcej o Gnuplot

Gnuplot: <http://gnuplot.info/>

Przykładowe wykresy: <http://gnuplot.info/demos/>

Poprawmy wykres zmieniając format danych, zakresy, dodając tytuł i zapisując go
do pliku graficznego.

```
    $ dtmp=$(mktemp)
    $ tr ',' '.' < d3 > $dtmp
    $ mv $dtmp d3
```

Wszystkie wykonywane polecenia można zapisać w postaci skryptu w pliku

```
    #!/bin/bash
    (polecenia)
```

W niektórych przypadkach wada tego rozwiązania będzie polegała na ponownym
przetwarzaniu danych, mimo iż pliki źródłowe się nie zmieniły.

Polecenia można uruchamiać okresowo (np. do pobierania danych) używając `watch`,
choć lepiej skorzystać z usług systemowych (np. `systemd` lub `crontab`).

Aby badać zależności pomiędzy plikami można wykorzystać program `make`. W pliku
opisującym zadania jakie ma wykonać wpisuje się zależności pomiędzy plikami
źródłowymi i docelowymi oraz polecenia do wykonania. `make` najczęściej
wykorzystują programiści do szybszego budowania aplikacji.

Przykładowy `Makefile`

```
all : data.png
data.png : d data.plt
    gnuplot data.plt
d : d1 d2 d3
    paste <(seq 100) d1 d2 d3 > d
```

Polecenie możemy wołać za pomocą

```
    $ make all
```

Jeśli dane pomiarowe są nieposortowane lub niekompletne powinniśmy je połączyć
po wspólnym kluczu. Przygotujmy takie dane (sortowanie zazwyczaj rozumiane jest
jako sortowane tekstowe, spróbujmy bez `-w`)

```
    $ paste <(seq -w 100) d1 | shuf > r1
    $ paste <(seq -w 100) d2 | head -n 90 > r2
    $ paste <(seq -w 100) d3 | tail -n +11 > r3
    $ sort r1 > r1s
    $ join r1s r2 | join - r3 > d
```

Narysujmy wykres ponownie, dane względem osi x nie są dobrze ułożone.

### Przykład: wyniki egzaminów

Pobierzmy dane

```
    wget http://git.savannah.gnu.org/cgit/datamash.git/plain/examples/scores_h.txt
```

Ile osób zdawało egzaminy z danego przedmiotu?

```
    $ grep Arts scores_h.txt | wc -l
```

Nie chcemy tego analizować ręcznie

```
    $ # lista przedmiotów
    $ cut -f 2 scores_h.txt | tail -n +2 | sort | uniq
    $ # wczytujemy przedmioty i dla każdego robimy zliczenie
    $ for key in `cat lp`; do grep $key scores_h.txt | wc -l >> count; done
    $ # łączymi wyniki z dwóch plików linia po linii i dodajemy nagłówek
    $ paste lp count > count.sum
    $ echo major count | cat - count.sum > count.dat
    $ # inaczej
    $ cat <(echo major sum) <(paste lp count) > count.dat
```

Wizualizacja

```
    $ wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/01/count.plt
    $ gnuplot -p count.plt
```

Możemy uzupełniać narzędzia dodając skrypty np. zliczające podane klucze w pliku

```
#!/bin/bash
file=$1
shift
for key in "$@"
do
    grep "$key" "$file" | wc -l
done
```

Przykład

```
    $ ./ck scores_h.txt Arts Engineering
```

### Przykład: pytania testowe

Zadaniem jest przygotowanie i sprawdzenie testu, w którym pytania mają zostać
wymieszane.

Pobierzmy pytania

```
    $ wget https://raw.githubusercontent.com/piona/stacjait-dane-linux/main/02/pytania.txt
```

#### Rozwiązanie 1

```
    $ # łączymy pytania w jedną linię
    $ paste -d: - - - - - - < pytania.txt > p01
    $ # mieszamy pytania
    $ shuf p01 > p02
    $ # rozdzielamy pytania na wiele linii
    $ tr ':' '\n' < p02 > p03
    $ # wydzielamy pytania i odpowiedzi
    $ awk '(NR%6)' p03 > pytania # tu mamy kłopot...
    $ split -n r/6/6 < p03 > odp # r/i/n zwraca linie k dla których (k % n) + 1 = i
```

Rozdzielenie pytań i odpowiedzi innym sposobem

```
    $ cut -f 1,2,3,4,5 -d: < p02 | tr ':' '\n' > pytania
    $ cut -f 6 -d: < p02 > odp
```

Sprawdzenie odpowiedzi z pliku `roz`

```
    $ # wyczyszczenie danych
    $ tr -cd '[:alpha:]\n' < roz | cut -c 1 | tr '[:lower:]' '[:upper:]' > croz
    $ # zaszyfrowanie odpowiedzi ROT13 (przesunięcie o 13 liter)
    $ tr ABCDEFGHIJKLMNOPQRSTUVWXYZ NOPQRSTUVWXYZABCDEFGHIJKLM < croz > zroz
    $ tr 'A-MN-Z' 'N-ZA-M' < croz > zroz
    $ # porównanie
    $ diff zroz odp
    $ # liczba błędnych odpowiedzi
    $ diff -y --suppress-common-lines zroz odp | wc -l
```

#### Rozwiązanie 2

Poniższe rozwiązanie pozwala wymieszać pytania o różnym rozmiarze

```
    $ # dzielimy plik z pytaniami na oddzielne pliki
    $ split -l 6 < pytania.txt # powstają pliki o nazwach xaa, xab, ...
    $ # mieszamy nazwy plików
    $ pliki=`ls -1 x* | shuf | tr '\n' ' '`
    $ head -n 5 -q $pliki > pytania
    $ tail -n 1 -q $pliki > odp
```

`shuf` z opcją `-z` pozwala również na użycie znaku `\0` zamiast znaku nowej
linii.

#### Ciekawostka

Można przekazać odpowiedzi bez ujawniania ich

```
    sha256sum <<< ciagdopozniejszegoujawnieniaA
```

Dopiero po ujawnieniu `ciagdopozniejszegoujawnienia` odpowiadający będą mogli
zweryfikować swoje odpowiedzi.

### Przykład: dane klimatyczne

Skorzystamy z danych udostępnionych pod adresem <https://danepubliczne.imgw.pl/data/dane_pomiarowo_obserwacyjne/dane_meteorologiczne/miesieczne/klimat>.

Automatyczne pobranie interesujących plików

```
    wget --accept '20*.zip' --mirror --no-directories --adjust-extension \
        --convert-links --no-parent \
        https://danepubliczne.imgw.pl/data/dane_pomiarowo_obserwacyjne/dane_meteorologiczne/miesieczne/klimat
```

Przydatne mogą być również opcje `--user-agent=Mozilla`, `--random-wait`
i `robots=off`, które nieco odwzorowują ręczne pobieranie danych.

Zdekompresujmy pliki i obejrzyjmy ich zawartość

```
    $ unzip "*.zip"
```

Wyciągamy średnią temperaturę dla wybranego miasta

```
    grep PSZCZYNA k_m_t* | tr -d '"' | cut -f 3,4,5 -d, | tr "," " " > t
```

Rysujemy wykres

```
    wget https://github.com/piona/stacjait-dane-linux/blob/main/03/temp.plt
    gnuplot -p temp.plt
```

### Przykład: oceny

W katalogu `04` znajdują się pliki z ocenami z różnych przedmiotów. Celem jest
przygotowanie plików z ocenami ze wszystkich przedmiotów dla każdego ucznia
oddzielnie.

### Co dalej: przegląd innych narzędzi

Pakiet `moreutils` zawiera dodatkowe narzędzia takie jak

- `sponge` - zapisuje standardowe wejście do pliku
- `ts` - dodaje znaczniki czasowe,
- `parallel` - pozwala zrównoleglać wykonywane operacje,
- `combine` - łączenie plików z wykorzystaniem operatorów logicznych (np. linie
  występujące w obu plikach lub tylko w jednym.

Rodzina narzędzi `dos2unix`, `unix2max`, ... pozwala na konwersję znaków końca
linii.

Edytor strumieniowy `sed` pozwala na przetwarzanie danych (*edycję*) linia po
linii z wykorzystaniem wyrażeń regularnych.

Do obliczeń i analiz statystycznych można wykorzystać `datamash`.

Język skryptowy `awk` pozwana na zaawansowane przetwarzanie danych tekstowych.

Program `mlr` (pakiet `miller`) może być wykorzystany do przetwarzania plików CVS i JSON.

Dane można pobierać za pomocą `curl` i `scp`.

