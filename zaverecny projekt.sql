
-- Historie poskytnutých úvěrů
-- rok, čtvrtletí, měsíc
select
    year(date) as rok,
    quarter(date) as ctvrtleti,
    month(date) as mesic,
     sum(amount) as celkova_vyse_uveru,
     avg(amount) as prumerna_vyse_uveru,
     count(loan_id) as celkovy_pocet_poskytnutych_pujcek
       from loan
group by year(date), quarter(date), month(date)
order by year(date) desc, quarter(date) asc, month(date) asc;


-- rok, čtvrtletí
select
    year(date) as rok,
    quarter(date) as ctvrtleti,
     sum(amount) as celkova_vyse_uveru,
     avg(amount) as prumerna_vyse_uveru,
     count(loan_id) as celkovy_pocet_poskytnutych_pujcek
       from loan
group by year(date), quarter(date)
order by year(date) desc, quarter(date) asc;


-- rok
select
    year(date) as rok,
     sum(amount) as celkova_vyse_uveru,
     avg(amount) as prumerna_vyse_uveru,
     count(loan_id) as celkovy_pocet_poskytnutych_pujcek
       from loan
group by year(date)
order by year(date) desc;

-- celkovy
select
     sum(amount) as celkova_vyse_uveru,
     avg(amount) as prumerna_vyse_uveru,
     count(loan_id) as celkovy_pocet_poskytnutych_pujcek
       from loan;


--  Stav úvěru
--  Status C a A predstavuju splatene pujcky (606)
--  Status D a B predstavuju nesplatene pujcky (76)

select
    status,
    count(*) as pocet_uveru_podle_statusu
from loan
group by status
order by pocet_uveru_podle_statusu desc ;


-- Analýza účtů

select
     account_id,
     status,
    count(loan_id) as pocet_poskytnutych_pujcek,
    sum(amount) as objem_poskytnutych_uveru,
    avg(amount) as prumerna_vyse_uveru
from loan
where status in ('A', 'C')
group by account_id, status
order by pocet_poskytnutych_pujcek desc, objem_poskytnutych_uveru desc;


-- Plně splacené půjčky
-- Muži majú splatené úvery v celkovej výške 55 330 572
-- žemy majú splatené úvery v celkovej výške 54 629 148


select
    gender,
    sum(amount) as splacene_uvary
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where status in ('A', 'C')
group by gender ;


-- Overenie - dokoncit
create temporary table temp_suma_uvery as
select
    gender,
    status,
    sum(amount) as suma_uvery
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
group by gender, status
order by status asc ;

select * from temp_suma_uvery;




--  Analýza klienta - 1. část
-- Kdo má více splacených půjček - ženy nebo muži? ->  Muži majú viac splatených pujček ako ženy

select
    gender,
    sum(amount) as splacene_uvary,
    dense_rank() over (order by sum(amount) desc) as poradi
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where status in ('A', 'C')
group by gender ;

-- Jaký je průměrný věk dlužníka dělený podle pohlaví? (splatene + nesplatene pozicky)
-- Priemerny vek dlznika (splatene + nesplatene pozicky) je pre muzov 67 rokov (zaokruhlene 68 rokov) a pre zeny 66 rokov (zaokruhlene 67 rokov)

create or replace view priemerny_vek_dluznika_vw as
select
    gender,
    year(birth_date) as rok_narozeni,
    2025 - year(birth_date) as vek
    from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id;

select
    gender,
    avg(vek) as priemerny_vek
from priemerny_vek_dluznika_vw
group by gender;



-- Jaký je průměrný věk dlužníka dělený podle pohlaví? (pre splatene pozicky)
-- Priemerny vek dlznika (splatene pozicky) je pre muzov 66 rokov a pre zeny 67 rokov.

create temporary table temp_vek_dlznika_splatene_pujcky as
select
    gender,
    sum(amount) as splacene_uvary,
    year(birth_date) as rok_narozeni
    from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where status in ('A', 'C')
group by gender, year(birth_date);

select
    gender,
    avg(2025 - rok_narozeni) as prumerny_vek
from temp_vek_dlznika_splatene_pujcky
group by gender ;


--  Analýza klienta - 2. část

-- Která oblast má nejvíce klientů?
-- Nejvice klientu ma Hl. mesto Praha.


select
    c.district_id,
    A2,
    count(c.client_id) as pocet_klientu,
    type
from client c
join disp d on c.client_id = d.client_id
join district di on c.district_id = di.district_id
where type = 'owner'
group by c.district_id
order by pocet_klientu desc;
-- limit 1;



-- Ve které oblasti byl splacen nejvyšší počet půjček?
-- Nejvyšší počet pujček byl splacen v Praze.

select
    a.district_id,
    A2,
    count(loan_id) as pocet_pujcek
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join district di on a.district_id = di.district_id
where type = 'owner' and  status in ('A', 'C')
group by a.district_id
order by pocet_pujcek desc
-- limit 1;


-- Ve které oblasti byla vyplacena nejvyšší částka půjček
-- Nejvyšší částka pujček byla vyplacena v Praze.

select
    a.district_id,
    A2,
    sum(amount) as suma_pujcek
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join district di on a.district_id = di.district_id
where type = 'owner'
group by a.district_id
order by suma_pujcek desc;


-- Analýza klienta - 3. část
--


with cte_podil_okresu as(
    select
    a.district_id,
    A2,
    count(c.client_id) as pocet_klientu,
    count(loan_id) as pocet_pujcek,
    sum(amount) as suma_pujcek
from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
join district di on a.district_id = di.district_id
where type = 'owner' and status in ('A', 'C')
group by a.district_id
 )
select *,
       suma_pujcek/sum(suma_pujcek) over() as podil
from cte_podil_okresu
order by podil desc
limit 10;


-- Výběr - 1. část
-- V Databázi neexistujú klienti, ktorých zostatok na účte je vyšší než 1000, majú viac ako 5 pujček a narodili sa po roku 1990.


 select
    c.client_id,
     count(loan_id) as pocet_pujcek,
     sum(amount - payments) as zustatek_na_uctu
     from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where type = 'owner'
  and status in ('A', 'C')
  and year(birth_date) > 1990
 group by c.client_id
 having
     sum(amount - payments) > 1000
     and count(loan_id) > 5;



-- mezivypocty
-- žiaden žiadateľ o pujčku nemá viac ako jednu pujčku
select
    account_id,
    count(loan_id) as pocet_pujcek
from loan
group by account_id
order by pocet_pujcek desc;


-- žiaden klient nie je narodený po roku 1990
select
    client_id,
    year(birth_date) as rok_narozeni
from client
order by rok_narozeni desc;


--  Výběr - 2. část
-- Prázdne výsledky sposobili 2 podmienky: -mají více než 5 půjček,
--                                         - narodili se po roce 1990,

-- žiaden klient nie je narodený po roku 1990
select
    client_id,
    year(birth_date) as rok_narozeni
from client
order by rok_narozeni desc;


-- žiaden klient nemá viac ako jednu pujčku
select
    c.client_id,
     count(loan_id) as pocet_pujcek
     from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where type = 'owner'
  and status in ('A', 'C')
 group by c.client_id
 having
     count(loan_id) > 5;

-- podmienka, že zůstatek na jejich účtu je vyšší než 1000 platí

 select
    c.client_id,
     count(loan_id) as pocet_pujcek,
     sum(amount - payments) as zustatek_na_uctu
     from loan l
join account a on l.account_id = a.account_id
join disp d on a.account_id = d.account_id
join client c on d.client_id = c.client_id
where type = 'owner'
  and status in ('A', 'C')
 group by c.client_id
 having
     sum(amount - payments) > 1000;


-- Karty s vypršením platnosti

with cte_expiracia_kariet as(
    select
    cl.client_id,
    card_id,
    issued,
    date_add(issued,interval 3 year) as datum_expiracie,
    A3 as adresa
from card c
join disp d on c.disp_id = d.disp_id
join client cl on d.client_id = cl.client_id
join district di on cl.district_id = di.district_id
)
Select *
from cte_expiracia_kariet
where datumVydaniaKarty between date_add(datum_expiracie, interval -7 day) and datum_expiracie;


delimiter //
create procedure cards_at_expiration(in datumVydaniaNovejKarty date)
begin
    with cte_expiracia_kariet as(
    select
    cl.client_id,
    card_id,
    issued,
    date_add(issued,interval 3 year) as datum_expiracie,
    A3 as adresa
from card c
join disp d on c.disp_id = d.disp_id
join client cl on d.client_id = cl.client_id
join district di on cl.district_id = di.district_id
)
Select *
from cte_expiracia_kariet
where datumVydaniaNovejKarty between date_add(datum_expiracie, interval -7 day) and datum_expiracie;
    end //

call cards_at_expiration('2001-11-26');















