# GroqCloud-Qwen-Lernquiz

Die Edge Function `generate-quiz` erstellt ein Quiz nur für angemeldete Untis-Spielkonten. Sie prüft Thema und optionales Foto, erstellt anschließend zehn Fragen mit `qwen/qwen3.8-27b` und kontrolliert die Ausgabe erneut. Pro Konto sind höchstens drei neue Quizrunden pro UTC-Kalendertag möglich. Meldungen sind auf zehn pro Konto und Tag begrenzt; sie speichern die gemeldete Frage ohne Konto-ID oder Foto in `private.quiz_reports`.

Qwen auf GroqCloud unterstützt Texte, Bilder und JSON-Schema-Ausgaben. Die Funktion sendet optionales Foto als Bildinhalt zur Verarbeitung an Groq. Untis selbst speichert das Foto nicht. Groq gibt an, Inferenzanfragen standardmäßig nicht zu speichern; bei Fehleranalyse oder Missbrauchsprüfung können Eingaben und Antworten bis zu 30 Tage protokolliert werden. Groqs Datenkontrollen bieten Zero Data Retention (ZDR). Groq verarbeitet gespeicherte Kundendaten in den USA. Details: [Groq-Datennutzung](https://console.groq.com/docs/your-data), [Qwen-Modell](https://console.groq.com/docs/model/qwen/qwen3.8-27b).

## Einrichtung ausschließlich durch eine erwachsene Person

1. Eine erwachsene Person erstellt und verwaltet das GroqCloud-Konto und den API-Schlüssel. Groqs Bedingungen erlauben den direkten Zugang zu Cloud Services erst ab 18 Jahren; sie erlauben die Einbindung der API in eine Kundenanwendung für Endnutzer. Siehe [Groq Services Agreement](https://console.groq.com/docs/legal/services-agreement).
2. Hinterlege den Schlüssel im Supabase-Projekt unter **Edge Functions → Secrets** mit dem Namen `GROQ_API_KEY`. Den Schlüssel niemals in `index.html`, GitHub oder Chat einfügen.
3. Die Function nutzt `verify_jwt = false`, weil sie die angemeldete Person selbst gegen Supabase Auth prüft und das Projekt den neuen Publishable-Key verwendet. Diese Prüfung in der Function nicht entfernen.
4. Vor öffentlicher Nutzung prüft die erwachsene betreuende Person Datenschutz, Zustimmung, Meldungen und die geltenden Regeln für Angebote mit Minderjährigen. API-Nutzung kann Kosten verursachen.

Die Funktion fragt nur nach festgelegten Schulfächern, Klasse, optionalem Thema und optional einem komprimierten Lernfoto. Das ist kein offener Chat. Sicherheitsfilter vor und nach der Erstellung verwenden ebenfalls Qwen; sie ersetzen keine Aufsicht durch eine erwachsene Person.
