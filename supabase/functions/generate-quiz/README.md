# Anthropic-Lernquiz

Die Edge Function `generate-quiz` erstellt ein Quiz nur für angemeldete Spielkonten. Sie prüft zuerst Thema und optionales Foto, lässt anschließend die zehn Fragen erzeugen und kontrolliert die Ausgabe erneut. Pro Konto sind höchstens drei neue Quizrunden pro UTC-Kalendertag möglich. Meldungen sind auf zehn pro Konto und Tag begrenzt; sie speichern die gemeldete Frage ohne Konto-ID oder Foto in `private.quiz_reports`.

## Einrichtung durch eine erwachsene betreuende Person

1. Lege in einer von einem Elternteil/Erziehungsberechtigten verwalteten Anthropic-Organisation einen API-Schlüssel an. API-Nutzung kann Kosten verursachen.
2. Hinterlege ihn im Supabase-Projekt unter **Edge Functions → Secrets** mit dem Namen `ANTHROPIC_API_KEY`. Den Schlüssel nie in `index.html`, GitHub oder Chat einfügen.
3. Die Function nutzt `verify_jwt = false`, weil sie die angemeldete Person selbst gegen Supabase Auth prüft und das Projekt den neuen Publishable-Key verwendet. Diese Prüfung in der Function nicht entfernen.
4. Vor öffentlicher Nutzung müssen Erwachsene den Altersnachweis, die Zustimmung der Erziehungsberechtigten, den Umgang mit Meldungen und die geltenden Datenschutzregeln für den Einsatz mit Minderjährigen prüfen. Das Quiz fragt nur nach festen Schulfächern, Klasse, optionalem Thema und optional einem komprimierten Lernfoto; es ist kein offener Chat.

Das Quiz verwendet Anthropic Claude Haiku 5.5 mit strukturierten JSON-Antworten und Sicherheitsprüfungen vor und nach der Erstellung. Siehe Anthropic [Richtlinien für Angebote mit Minderjährigen](https://support.claude.com/en/articles/9307344-responsible-use-of-anthropic-s-models-guidelines-for-serving-minors).
