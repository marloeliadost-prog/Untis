create policy "Deny client access to quiz usage"
on private.quiz_usage
for all
to anon, authenticated
using (false)
with check (false);

create policy "Deny client access to quiz reports"
on private.quiz_reports
for all
to anon, authenticated
using (false)
with check (false);
