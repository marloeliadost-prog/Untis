create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

create table private.quiz_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null,
  quiz_count smallint not null default 0 check (quiz_count between 0 and 3),
  report_count smallint not null default 0 check (report_count between 0 and 10),
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_date)
);
alter table private.quiz_usage enable row level security;
revoke all on table private.quiz_usage from public, anon, authenticated;
grant select, insert, update, delete on table private.quiz_usage to service_role;

create table private.quiz_reports (
  report_id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  subject text not null,
  grade smallint not null check (grade between 1 and 13),
  question text not null check (char_length(question) between 1 and 600)
);
alter table private.quiz_reports enable row level security;
revoke all on table private.quiz_reports from public, anon, authenticated;
grant select, insert, update, delete on table private.quiz_reports to service_role;

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
  where (p_kind = 'quiz' and usage.quiz_count < 3)
     or (p_kind = 'report' and usage.report_count < 10);

  get diagnostics v_rows = row_count;
  return v_rows = 1;
end;
$$;
revoke all on function public.consume_quiz_quota(uuid, text) from public, anon, authenticated;
grant execute on function public.consume_quiz_quota(uuid, text) to service_role;

create or replace function public.record_quiz_report(p_subject text, p_grade integer, p_question text)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_subject is null or char_length(p_subject) > 40
     or p_grade is null or p_grade < 1 or p_grade > 13
     or p_question is null or char_length(p_question) < 1 or char_length(p_question) > 600 then
    return false;
  end if;

  insert into private.quiz_reports (subject, grade, question)
  values (p_subject, p_grade::smallint, p_question);
  return true;
end;
$$;
revoke all on function public.record_quiz_report(text, integer, text) from public, anon, authenticated;
grant execute on function public.record_quiz_report(text, integer, text) to service_role;
