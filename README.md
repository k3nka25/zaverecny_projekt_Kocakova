Cieľom tohto projektu bolo stiahnuť aktuálne inzercie zo stránky www.sreality.cz pomocou webscrapingu, vyčistiť ich a zanalyzovať. 
Ja som si vybrala podnájmy v meste Zlín. Pomocou knižnice BeautifulSoup som získala všetky aktuálne inzercie podnájmov z www.sreality.cz. Dáta sú uložené v súbore Katarina_Kocakova_surova_data.csv
Následne som surové dáta načítala do DataFramu knižnice Pandas a vyčistila som ich. To znamená, že som vymazala riadky s nulovou hodnotou, čo boli v podstate reklamy, ktoré sa na webovej stránke tvárili ako inzeráty, ale pre nás nemali žiadnu výpovednú hodnotu. V 3 inzerátoch bola namiesto ceny uvedená "Cena na vyžiadanie", ktoré som odfiltrovala/ vymazala a takisto som vymazala aj jednu inzerciu pokoje, nakoľko robím analýzu celých bytov. Takže po vyčistení dát mám 153 inzerciíí bytov, ktoré môžem ďalej analyzovať.
Hlavné zistenia: 
   1)   Priemerná cena bytov je 15 425 Kč a medián je 14 200Kč.

   2)  Priemerná cena bytu pre každú dispozíciu bytu
            Dispozice bytu	Priemerná cena bytu v kč
               4+kk	        26000.0
               3+kk	        21783.0
               3+1	        18112.0
               4+1	        17300.0
               2+kk	        16343.0
               2+1	        14758.0
               1+1	        12171.0
               1+kk	        12047.0

    3)  Priemerná veľkosť bytu pre každú dispozíciu bytu
                    Dispozice bytu	Priemerná veľkosť bytu
                          4+kk	        106.0
                          3+kk	         86.0
                          4+1	           85.0
                          3+1	           72.0
                          2+1	           60.0
                          2+kk	         54.0
                          1+1    	       35.0
                          1+kk	         34.0

    4) Ulica Nad Stráněmi je ulica, kde je vyššia koncentrácia drahíšch bytov (8 bytov).
    5) Najčastejšie sú inzerované dispozične malé byty 1+kk. Dôvodom je, že sú najlacnejšie a vačšinou si bývanie hľadajú single ľudia, ktorí preferujú menšie byty práve kvôli nižšej cene.
    6) Existujú tu aj inzercie bytov, ktoré stoja viac ako 20 000kč a v tejto cenovej hladine sú inzerované aj tri maximálne dvojpokojové byty (2+1/2+kk).
    7) Najväčší rozptyl medzi minimálnou a maximálnou inzerovanou cenou ma dispozícia 3+kk a to 20 500 kč.
