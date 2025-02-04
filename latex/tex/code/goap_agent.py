FUNCTION update(_delta :real) :void
	vision_component.update()
	if goap_planner.update() then
		this.current_step := 0
		this.action_sequence := goap_planner.get_current_sequence()
	follow_sequence(_delta)
END update()

FUNKTION update(_delta :real) :void
	update andere Komponenten
    WENN goap_planner neue Aktions-Sequenz gefunden DANN 
        lese neue Aktions-Sequenz aus goap_planner
	follow_sequence(_delta)
ENDE update()

FUNCTION follow_sequence(delta :real) :void
    if action_sequence.is_empty() OR current_step >= action_sequence.size() OR action_sequence[current_step] == null OR NOT action_sequence[current_step].is_valid() then
        goap_planner.set_create_sequence(true)
        END follow_sequence()
    if action_sequence[current_step].update(delta) then
        this.current_step := +1
END follow_sequence()

FUNKTION follow_sequence(delta :real) :void
    WENN Aktions-Sequenz leer ODER Aktions-Sequenz fertig durchgeführt ODER NICHT derzeitige Aktion valide DANN 
        goap_planner suchen neue Aktions-Sequenz
        ENDE follow_sequence()
    dezeitige Aktion ausführen
ENDE follow_sequence()

FUNKTION bestensuche(Ausgangszustand) :Zielknoten
    Leere offenen Liste als PriorityQueue erstellen
    Knoten mit Ausgangszustand der offenen Liste hinzufuegen
    SOLANGE offene Liste nicht leer
        Expansions Knoten aus offenen Liste lesen und ihn daraus entfernen
        WENN Expansions Knoten Ziel erfuellt DANN
            Expansions Knoten zurueckgeben
            ENDE bestensuche()
        ENDE WENN
        FUER JEDEN Kindknoten VON expandiere(Knoten)
            Kindknoten der offenen Liste hinzufuegen
        NAECHSTER Knoten
    ENDE SOLANGE
    Kein Zielknoten gefunden
ENDE bestensuche()

FUNKTION expandiere(Knoten) :Kindknoten[]
    Leeres Kindknoten Array erstellen
    Knoten Zustand in s speichern
    FUER JEDE Kante VON ACTION(s)
        Kindknoten durch Kante generieren
        f(Kindknoten) in Kindknoten speichern
        Kindknoten dem Kindknoten Array hinzufuegen
    NAECHSTE Kante
    Kindknoten Array zurueckgeben
ENDE expandiere()