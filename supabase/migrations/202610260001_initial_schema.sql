-- LeafLedger initial schema for Supabase PostgreSQL.
-- Apply in Supabase SQL editor after reviewing; RLS protects user-owned rows.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  business_type text not null default 'Small business',
  created_at timestamptz not null default now()
);
create table if not exists public.organization_members (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','accountant','staff','member')),
  created_at timestamptz not null default now(),
  primary key (organization_id,user_id)
);
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  email text,
  phone text,
  address text,
  gstin text,
  created_at timestamptz not null default now()
);
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  invoice_number text not null,
  client_name text not null,
  service_description text not null default '',
  invoice_date date not null default current_date,
  due_date date,
  subtotal numeric(14,2) not null default 0 check (subtotal >= 0),
  tax_amount numeric(14,2) not null default 0 check (tax_amount >= 0),
  total_amount numeric(14,2) not null default 0 check (total_amount >= 0),
  amount_paid numeric(14,2) not null default 0 check (amount_paid >= 0),
  status text not null default 'Pending' check (status in ('Draft','Sent','Pending','Partially paid','Paid','Overdue')),
  created_at timestamptz not null default now(),
  unique(owner_id,invoice_number)
);
create table if not exists public.invoice_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  description text not null,
  quantity numeric(12,3) not null default 1 check (quantity > 0),
  unit_price numeric(14,2) not null default 0 check (unit_price >= 0),
  tax_rate numeric(6,3) not null default 0 check (tax_rate >= 0 and tax_rate <= 100),
  created_at timestamptz not null default now()
);
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  amount numeric(14,2) not null check (amount > 0),
  paid_on date not null default current_date,
  method text,
  reference text,
  created_at timestamptz not null default now()
);
create table if not exists public.income_entries (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  category text not null default 'General',
  amount numeric(14,2) not null check (amount >= 0),
  entry_date date not null default current_date,
  created_at timestamptz not null default now()
);
create table if not exists public.expense_entries (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  category text not null default 'General',
  amount numeric(14,2) not null check (amount >= 0),
  entry_date date not null default current_date,
  document_path text,
  created_at timestamptz not null default now()
);
create table if not exists public.tax_calculations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  tax_type text not null,
  financial_year text not null,
  input_data jsonb not null default '{}'::jsonb,
  result_data jsonb not null default '{}'::jsonb,
  is_estimate boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.tax_scenarios (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  scenario_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table if not exists public.itr_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  financial_year text not null,
  assessment_year text,
  answers jsonb not null default '{}'::jsonb,
  suggested_form text,
  created_at timestamptz not null default now()
);
create table if not exists public.compliance_tasks (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'General',
  due_date date,
  status text not null default 'Pending' check (status in ('Pending','In progress','Completed')),
  created_at timestamptz not null default now()
);
create table if not exists public.tax_deadlines (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users(id) on delete cascade,
  title text not null,
  tax_type text not null,
  due_date date not null,
  financial_year text,
  source_url text,
  verified_at timestamptz,
  created_at timestamptz not null default now()
);
create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  file_name text not null,
  storage_path text not null,
  document_type text not null default 'Other',
  related_record_id uuid,
  created_at timestamptz not null default now()
);
create table if not exists public.advisor_conversations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'Tax question',
  created_at timestamptz not null default now()
);
create table if not exists public.advisor_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.advisor_conversations(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user','assistant')),
  content text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.notification_preferences (
  owner_id uuid primary key references auth.users(id) on delete cascade,
  email_enabled boolean not null default false,
  in_app_enabled boolean not null default true,
  created_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists invoices_owner_date_idx on public.invoices(owner_id, invoice_date desc);
create index if not exists expenses_owner_date_idx on public.expense_entries(owner_id, entry_date desc);
create index if not exists tasks_owner_due_idx on public.compliance_tasks(owner_id, due_date);
create index if not exists messages_conversation_created_idx on public.advisor_messages(conversation_id, created_at);

alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.clients enable row level security;
alter table public.invoices enable row level security;
alter table public.invoice_items enable row level security;
alter table public.payments enable row level security;
alter table public.income_entries enable row level security;
alter table public.expense_entries enable row level security;
alter table public.tax_calculations enable row level security;
alter table public.tax_scenarios enable row level security;
alter table public.itr_profiles enable row level security;
alter table public.compliance_tasks enable row level security;
alter table public.tax_deadlines enable row level security;
alter table public.documents enable row level security;
alter table public.advisor_conversations enable row level security;
alter table public.advisor_messages enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.audit_logs enable row level security;

-- Single-user ownership policies. Extend carefully if enabling organization sharing.
do $$
declare t text;
begin
  foreach t in array array['profiles','organizations','clients','invoices','payments','income_entries','expense_entries','tax_calculations','tax_scenarios','itr_profiles','compliance_tasks','documents','advisor_conversations','advisor_messages','notification_preferences','audit_logs'] loop
    if t='profiles' then
      execute format('create policy "profile owner access" on public.%I for all using (id = auth.uid()) with check (id = auth.uid())',t);
    elsif t='notification_preferences' then
      execute format('create policy "notification owner access" on public.%I for all using (owner_id = auth.uid()) with check (owner_id = auth.uid())',t);
    else
      execute format('create policy "owner access" on public.%I for all using (owner_id = auth.uid()) with check (owner_id = auth.uid())',t);
    end if;
  end loop;
end $$;

create policy "member sees own memberships" on public.organization_members
  for select using (user_id = auth.uid());
create policy "owner manages own memberships" on public.organization_members
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- invoice_items are only accessible through an invoice owned by the authenticated user.
create policy "invoice item owner access" on public.invoice_items
  for all using (exists(select 1 from public.invoices i where i.id=invoice_id and i.owner_id=auth.uid()))
  with check (exists(select 1 from public.invoices i where i.id=invoice_id and i.owner_id=auth.uid()));

-- Global deadline rows can be read by authenticated users; own rows can be managed.
create policy "read global and own deadlines" on public.tax_deadlines
  for select using (owner_id is null or owner_id=auth.uid());
create policy "manage own deadlines" on public.tax_deadlines
  for all using (owner_id=auth.uid()) with check (owner_id=auth.uid());
