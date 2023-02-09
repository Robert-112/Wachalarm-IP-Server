# Wachalarm-IP-Server
![Logo Wachalarm-IP-Server](https://user-images.githubusercontent.com/19272095/47460320-79bde600-d7de-11e8-8152-302897dc0e11.png)

Hier wird der Quellcode der Server-Anwendung des Wachalarm-IP der Leitstelle Lausitz veröffentlicht.
Die Anwendung wurde mit [Lazarus](https://www.lazarus-ide.org/) programmiert und kann unter Beachtung der Lizenzbedingungen kostenlos genutzt werden.
Der Wachalarm-IP-Server wird dabei i.d.R. durch die einsatzführende Leitstelle betrieben. Er empfängt die Einsatzdaten über eine definierte Schnittstelle aus dem Einsatzleitsystem und übersendet diese dann an die z.B. an den Wachalarm-IP-Client.
Die Leitstelle Lausitz bietet den Wachalarm-IP aktuell nur für ständig besetzte Wachen (Rettungswachen, Feuerwachen mit hauptamtlichen Kräften) an. Freiwillige Feuerwehren werden durch die Leitstelle Lausitz nicht angebunden.

## Funktionsumfang

 - Auslesen der vom Einsatzleitsystem übermittelten Einsatzdaten
 - Senden von Einsatzalarmen an Computer im Netzwerk auf denen der Wachalarm-IP-Client läuft
 - Veröffentlichen Meldungen auf Twitter und Mastodon (sog. Einsatzvorinformationen #EVI) 
 - Weiterleiten von Alarmen an Waip-Web (aktuell in der Entwicklung)
 - Protokollierung der gesendeten Alarme

# Installation

Um den Wachalarm-IP-Server nutzen/testen zu können, muss dieser zunächst für das Ziel-Betriebssystem kompiliert werden. Es wird sowohl Windows als auch Linux unterstützt (getestet mit Windows XP, Windows 7 (x86, x64), Windows 10 (x86, x64), Debian 7, Debian 8, Ubuntu, Raspberry Pi 1).
1. Lazarus installieren (siehe [https://www.lazarus-ide.org/](https://www.lazarus-ide.org/))
2. [OpenSSL-Bibliotheken](https://github.com/Robert-112/Wachalarm-IP-Server/tree/master/lib) installieren (siehe unten) 
3. Quelldateien dieses Repositorys herunterladen
4. *.zip-Datei entpacken und in das Verzeichnis wechseln
5. >Optional: in der Datei *"credentials.res"* die Zugangsdaten anpassen
(diese werden genutzt um die Übertragung der Alarmbilder an den Wachalarm-IP-Client abzusichern)
6. >Optional: eigenes Hintergrundbild ([Vorlage, 910 x 512 px](https://user-images.githubusercontent.com/19272095/47458476-e7b3de80-d7d9-11e8-9726-3002e292b3e1.jpg)) für Twitter erstellen und unter *"/config/twitter_background.jpg"* speichern
7. *"Wachalarm-IP_Server.lpi"* (Projektdatei) mit Lazarus öffnen
8. Anwendung kompilieren (STRG + F9)
9. In das Verzeichnis von Wachalarm-IP-Server wechseln und die erzeugte Anwendung (z.B. *"Wachalarm-IP-Server_win64.exe"*) starten. 
Alternativ kann die Anwendung zuvor auch in ein neues Verzeichnis kopiert werden (z.B. *"C:\Wachalarm"*).

Nachdem der Server gestartet wurde, wartet er auf neue Alarm-Dateien, welche durch das Einsatzleitsystem übermittel werden (siehe Schnittstelle). 

# Netzwerk

Um Alarme an die Wachalarm-IP-Clients senden zu können muss der Wachalarm-IP-Server diese im Netzwerk erreichen können. Dies wird i.d.R. dadurch erreicht, indem sich beide:

 - im selben Subnetz befinden
 - durch Routing "sehen" können
 - per VPN verbunden sind

Außerdem müssen in den Firewalls (Router, Betriebssystemfirewall) die notwendigen Ports freigegeben werden. Für eine korrekte Funktionsweise werden benötigt:

 - 60132 UDP (Wachalarm-IP-Client Daten)
 - 60143 & 60144 TCP (Wachalarm-IP-Client Alarmbild)
 - 60233 UDP (Schnittstelle zu Waip-Web (in Entwicklung))

Sollen zudem auch Twitter-Meldungen versendet werden, muss eine Verbindung zum Internet bestehen. Ein Proxy kann über die Einstellungen gesetzt werden. 

## OpenSSL
Da Twitter-Meldungen stehts verschlüsselt (https) übertragen werden, muss dafür gesorgt werden, dass die notwendigen [OpenSSL-Bibliotheken](https://github.com/Robert-112/Wachalarm-IP-Server/tree/master/lib) vorhanden sind. 
Im Ordner *"[lib/](https://github.com/Robert-112/Wachalarm-IP-Server/tree/master/lib)"* dieses Repositorys sind die notwendigen Dateien bereits hinterlegt:

 - [Windows x86](https://github.com/Robert-112/Wachalarm-IP-Server/tree/master/lib/x86)
 - [Windows x64](https://github.com/Robert-112/Wachalarm-IP-Server/tree/master/lib/x64)
 - [Linux (Debian / Ubuntu)](https://github.com/Robert-112/Wachalarm-IP-Server/blob/master/lib/Linux/install_packages.sh)

Unter Windows müssen die die DLLs entweder im selben Verzeichnis wie die *"Wachalarm-IP-Server_%.exe"*, oder in "*%SystemRoot%\System32*" bzw. "*%SystemRoot%\SysWOW64*" hinterlegt werden. 
Unter Linux muss *opensll* und *libssl-dev* installiert werden.

## cURL

Um Meldungen auf einer Mastodon-Instanz zu veröffentlichen, muss das Betriebssystem auf dem die Server-Anwendung ausgeführt wird, das Programm [curl](https://curl.se/) bereitstellen.

# Schnittstelle
Neue Alarme werden i.d.R. durch das Einsatzleitsystem der Leitstelle an den Wachalarm-IP-Server übertragen. Hierfür wurde vor über 15 Jahren eine Text-Schnittstelle definiert (und fortlaufend weiterentwickelt), in der die zu übergebenden Werte ausgeben werden. Durch das Einsatzleitsystem muss für jeden Alarm eine Textdatei (*.txt) erstellt und in einem festgelegten Verzeichnis abgelegt werden. Der Wachalarm-IP-Server *"lauscht"* auf dieses Verzeichnis und ließt neue Textdateien automatisch ein sobald eine neue Datei vorhanden ist.
### Beispiel einer Textdatei

    ~~Ort~~Musterstadt~~
    ~~Ortsteil~~klein Musterland~~
    ~~Strasse~~Muster-Mann-Straße 123~~
    ~~Objekt~~KH Birnenbaum~~
    ~~Objektnummer~~-1~~
    ~~Objektart~~~~
    ~~Einsatzart~~Sonstiges~~
    ~~Alarmgrund~~I:Testeinsatz~~
    ~~Sondersignal~~[mit Sondersignal]~~
    ~~Einsatznummer~~41600XXXX~~
    ~~Besonderheiten~~Test Wachalarm-IP mit einigen Besonderheiten im Text!~~
    ~~Name~~Mustermann, Test~~
    ~~Status~~Fahrzeug~~Zuget~~Alarm~~Ausgerückt~~
    ~~ALARM~~192.168.1.120,@Twitter-Account-A#~~CB FW Cottbus 1ø~~FL CB 01/82-01~~17:16~~~~
    ~~ALARM~~192.168.1.120,@Twitter-Account-A#~~CB FW Cottbus 1ø~~FL CB 01/83-06~~17:16~~~~
    ~~ALARM~~192.168.1.120,@Twitter-Account-A#~~CB FW Cottbus 1ø~~FL CB T-Dienst~~17:16~~~~
    ~~ALARM~~192.168.1.121,@Twitter-Account-B#~~CB FW Cottbus 2ø~~FL CB 02/83-01~~17:16~~~~
    ~~ALARM~~192.168.1.122#~~CB FW Sachsendorf~~FL CB 14/23-02~~17:16~~~~
    ~~ALARM~~@Twitter-Account-C#~~CB FW Ströbitzø~~FL CB 16/11-01~~17:16~~~~
    ~~Alarmzeit~~19.02.16&17:16~~
    ~~Disponent~~~~
    ~~AP~~99~~
    ~~WachennumerFW~~520201~~
    ~~WGS84_X~~51.75433056~~
    ~~WGS84_Y~~14.63947500~~
### Erläuterung der Felder
Je Zeile wird zunächst das Feld und der dazugehörige Wert definiert:

    ~~Feld~~Wert~~
Folgende eindeutige Feldwerte sind verfügbar:

> Ort, Ortsteil, Strasse, Objekt, Objektnummer, Objektart, Einsatzart, Alarmgrund, Einsatznummer, Besonderheiten, Name, Alarmzeit, Disponent, AP, WachennummerFW, WGS84_X, WGS84_Y

Das Feld `~~Sondersignal~~` kann nur zwei Werte beinhalten

 - [mit Sondersignal]
 - [ohne Sondersignal]

Die Verteilung der Einsatzdaten an die Cleints bzw. an Twitter erfolgt über eine dynamische textuelle Tabelle in der jeder Wert durch zwei ~~ getrennt wird:
`~~ALARM~~192.168.1.120,@Twitter-Account-A#~~CB FW Cottbus 1ø~~FL CB 01/82-01~~17:16~~~~`

| Zeile________________________ | Typ | Alarm-Adresse<br>(durch , getrennt) | Wachnname | Einsatzmittel (nur ein Wert) | Zeitstempel Alarm | Zeitstempel Ausgerückt |
|--|--|--|--|--|--|--|
| 1 (Beschreibung, fester Wert) | Status | Fahrzeug | Zuget | Alarm | Ausgerückt | >leer<
| 2 (erstes Fahrzeug) | ALARM | 192.168.1.10# | CB FW Cottbus 1ø | FL CB 01/82-01 | 11:14 |  |
| 3 (zweites Fahrzeug) | ALARM | 192.168.1.10# | CB FW Cottbus 1ø | FL CB 01/83-01 | 11:14 |  |
| 4 (zweite Wache mit zwei IPs ) | ALARM | 192.168.1.10,192.168.1.11# | CB FW Cottbus 2ø | FL CB 02/83-01 | 11:14 |  |
| 3 (Fahrzeug ausgerückt) | ALARM | 192.168.1.10# | CB FW Cottbus 1ø | FL CB 01/12-01 | 11:01 | 11:10 |
| 3 (Twitter) | ALARM | @Twitter-Account# | CB FW Sachsendorfø | FL CB 14/23-02 | 11:14 |  |

Die Werte für die Alarm-Adresse, die Wache und das Einsatzmittel müssen über die Schnittstelle gesetzt werden. Z.B. über die Datenpflege des Einsatzleitsystems

# Einstellungen
### Einstellungen zur Schnittstelle
Im nachfolgenden wird erklärt, welche allgemeinen Einstellungen am Wachalarm-IP-Server getätigt werden können. Das entsprechende Fenster wird über das Menu *"Programm"* -> *"Einstellungen"* geöffnet. Alle Einstellungen werden im Unterordner *"config"* in der Datei *"config.ini"* gespeichert.
#### Pfad zur Übergabedatei
>Vollständiger Pfad in dem die Text-Dateien durch das Einsatzleitsystem abgelegt werden.
#### Zusammensetzung der Übergabedatei
>Legt fest, wie die Übergabedatei benannt ist. Sie sollte immer je Alarm eindeutig sein. 
>z.B.: waip_12345.txt, waip_23456.txt etc.
#### Bildqualität
>Regelt die Komprimierung des Alarmbildes (0% sehr geringe Qualität, 100% beste Qualität)
#### IP-Adresse für Waip-Web
>An die hier hinterlegte IP-Adresse wird jeder Alarm parallel an die Anwendung Waip-Web übermittelt (JSON-Format, Anwendung in Entwicklung).
#### Proxy-Einstellungen (für Twitter und Mastodon)
>Hier kein Proxy für die Veröffentlichung der Twitter-Nachrichten angegeben werden.

### Einstellungen Wachalarm
Im Reiter *"Wachalarm"* -> *"IP-Replace"* können Alarm-Adressen (die über die Schnittstellen-Datei ausgelesen werden) ersetzt werden. 
Sollten in einer Wache mehrere Clients ausgeführt werden, oder hat die Wache auch einen Twitter-Account, so können hier zusätzliche IP-Adressen hinterlegt werden. Beispiel: 

> 127.0.0.1 -> 127.0.0.1,@Twitter-Account,127.0.0.2

### Programm beenden
Die Anwendung wird über das  Menu *"Programm"* -> *"Beenden"* geschlossen.

# Screenshots
## Anwendung (Statusübersicht)
![Anwendung](https://user-images.githubusercontent.com/19272095/47463344-3c5d5680-d7e6-11e8-8618-5eaff3c05e99.jpg)
## Alarmbild (Vorschau)
![Alarm](https://user-images.githubusercontent.com/19272095/47463988-2b154980-d7e8-11e8-9fe3-60ae368419a4.PNG)
## Einsatzvorinformation (Vorschau)
![Twitter und Mastodon](https://user-images.githubusercontent.com/19272095/47464023-45e7be00-d7e8-11e8-8336-443903508102.PNG)
## Alarm-Simulation
![Simulation](https://user-images.githubusercontent.com/19272095/47464505-ab887a00-d7e9-11e8-98b8-2cc996b29dbe.PNG)
# Lizenz

#### [Creative Commons Attribution Share Alike 4.0 International](https://github.com/Robert-112/Wachalarm-IP-Server/blob/master/LICENSE.md)