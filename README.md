# AI-CA — Indian CA & Tax Workspace

A responsive React + Vite app prototype for Indian tax workflows: ITR guidance, GST and TDS calculators, invoice tracking, expenses, tasks, reports, and a rule-based demo advisor.

## Run locally

```bash
npm install
npm run dev
```

## Build

```bash
npm run build
npm run preview
```

## Database and authentication

The interface currently works in **local demo mode** and persists demo invoices, expenses, tasks, and workspace settings in the browser. This is not a production database.

To enable Supabase authentication:
1. Create a Supabase project.
2. Copy `.env.example` to `.env`.
3. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
4. Restart the development server.

The client detects configured Supabase credentials and enables account sign-in/sign-up. Before storing customer tax information, implement and verify the SQL schema, Row Level Security policies, private storage, and server-side data operations. Do not expose a service-role key in the frontend.

## AI advisor

The advisor has a clearly disclosed rule-based fallback. A real AI integration is not included in this client-only starter because private API keys must never be exposed to the browser. Add a server-side `/api/advisor` endpoint on a backend host, configure the provider key as a server secret, and add authentication, rate limits, validation, and logging before enabling real AI responses.

## Important tax notice

ITR recommendations and tax calculators in this starter are preliminary educational aids. GST and TDS calculators use user-entered rates. The salary tax estimate is simplified and does not fully implement all current-year slabs, rebates, cess, surcharge, deductions, or special-rate income. Do not use it for filing or payment decisions until the tax engine is implemented and tested against official current-year rules and reviewed by a qualified CA.

## Deploy

For a static frontend, deploy the Vite build to Netlify or Vercel. GitHub Pages can host the static frontend but cannot host a server-side AI API or secure backend by itself. Configure backend hosting and environment secrets separately.


## Added in the AI-CA upgrade
- Rebranded interface and account entry point.
- Tax document hub covering Form 16, Form 16A, Form 26AS/AIS, ITR, GST challans/returns, e-invoice/e-way bill, TDS statements and MCA/Udyam links.
- Login/sign-up uses Supabase Auth when configured; without credentials, the app remains a local demo and cannot create real accounts.

## Production-readiness checklist
This remains a frontend starter, not a country-wide live tax filing service. Before public launch, configure Supabase Auth, database tables and row-level security; build server-side APIs; add audited current-year tax rules, secure document storage, tenant isolation, backups, monitoring, privacy/consent flows, and professional legal/CA review. The document hub links to official portals and does not submit filings.

## Recent UI additions
- A welcome / sign-in screen appears first. Users can sign in, create an account, or continue in demo mode.
- The PAN / Aadhaar / GST checks section links to official portals and provides a local checklist only. It does not verify identity or call government APIs, and it intentionally does not collect sensitive ID numbers or OTPs.
- The “Which tax applies to me?” guide gives separate general checklists for business owners/freelancers and salaried employees. It is educational guidance, not a personalised tax determination.
