create or replace function public.consume_quiz_quota(p_user_id uuid, p_kind text)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_rows integer;
begin
  if p_user_id is null or p_kind is null or p_kind not in ('quiz', 'report') then
    return false;
  end if;

  insert into private.quiz_usage as current_usage (user_id, usage_date, quiz_count, report_count, updated_at)
  values (
    p_user_id,
    (timezone('UTC', now()))::date,
    case when p_kind = 'quiz' then 1 else 0 end,
    case when p_kind = 'report' then 1 else 0 end,
    now()
  )
  on conflict (user_id, usage_date) do update
  set quiz_count = current_usage.quiz_count + case when p_kind = 'quiz' then 1 else 0 end,
      report_count = current_usage.report_count + case when p_kind = 'report' then 1 else 0 end,
      updated_at = now()
  where (p_kind = 'quiz' and current_usage.quiz_count < 3)
     or (p_kind = 'report' and current_usage.report_count < 10);

  get diagnostics v_rows = row_count;
  return v_rows = 1;
end;
$$;
revoke all on function public.consume_quiz_quota(uuid, text) from public, anon, authenticated;
grant execute on function public.consume_quiz_quota(uuid, text) to service_role;
