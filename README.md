# Oslosykkel

Test app for sanntidsdata fra Oslo Bysykkel

## Installasjon og kjøring

Python 3 og [pipenv](https://github.com/pypa/pipenv) må være satt opp. (Alle
instruksjoner er skrevet for Linux, men burde fungere ganske likt på alle
Unix-like systemer)

```sh
# Opprett et python 3 miljø
$ pipenv --three
# aktiver miljøet
$ pipenv shell
# installer pakker
(repo-name) $ pipenv install
# migrere databasen (bare for å unngå feilmeldinger)
(repo-name) $ python manage.py migrate
# Start serveren
(repo-name) $ python manage.py runserver
```

Gå til [localhost:8000/sykkel](http://localhost:8000/sykkel/) for å se listen.

---

## Om oppsettet

### Django + Wagtail

Dette oppsettet er litt overkill, med en full Wagtail installasjon som jeg ikke
bruker. Hadde egentlig tenkt å bare sette opp en tom django server, men av en
eller annen grunn gav opstart skriptet meg et oppsett med masse feil (tror
kanskje jeg på en eller annen måte kjørte python 2 utgaven scriptet av en eller
annen grunn), så isteden for å bruke masse tid på å debugge dette, satte jeg
isteden opp en wagtail side; siden jeg viste at wagtail oppstart skriptet virket
ok for ikke lenge siden. All koden i `home`, `mysite` og `search` er bare
standard kode slik Wagtail oppstart skriptet lager dem. Jeg har bare flyttet
litt på mappene, og lagt til "appen" `oslosykkel` i settings, og urlen
`/sykkel/`. Ellers er all relevant kode i oslosykkel mappa.

Strengt tatt er kanskje en webserver i seg selv litt overkill, men ved å bruke
en webserver kan jeg både unngå en del rare problemer som kan oppstå ved å kjøre
javascript direkte fra en html fil, og også bruke serveren til å kalle API'et
som unngår alle potensielle cross site request problemer. Har også lagt til lit
caching på 30 sekunder for å ikke floode API'et med forespørsler mens jeg
tester.

### Coffescript

Jeg bruker coffescript som har litt mer python-aktig syntaks som jeg liker. Fila
common.coffee er bare et et mini-bibliotek jeg har laget for meg selv opp
gjennom årene med en håndfull utility funksjoner som primært er bare gjør DOM
spørringer mer kompakt, f.eks. `elById(id)` istedenfor
`document.getElementById(id)`; eller fungerer som en "polyfill" som gjør ting
som å sette opp en event listnener til et enkelt funsjonskall (noen av disse er
kanskje ikke lenger nødvendige da de er ment for eldgamle versjoner av Internet
Explorer).

For å kompilere coffescript koden trenger man også å ha
[coffescript satt opp](https://coffeescript.org/#installation).

```sh
# gå til mappen hvor scriptet er
$ cd oslosykkel/static/scripts/
# kompiler begge scriptene til js
$ coffee -c common.coffee sykkel.coffee
```

### CSS

Normalt bruker jeg også LESS CSS for CSS og setter opp et script som automatisk
bygger og minifiserer både css og js, men jeg tenkte det allerede var overkill
nok med en unødvendig Wagtail installasjon, så jeg bruker bare ren css og
manuell bygging av coffeescript her.
