# Supabase Database Migrations

This directory contains the database migrations for the Prioris project.

## Migration Files

- `001_initial_schema.sql` - Initial database schema with profiles, custom_lists, and list_items tables
- `002_schema_fixes.sql` - RLS policy fixes and data consistency improvements

## Running Migrations

### Using Supabase CLI (Recommended)

1. Install Supabase CLI: `npm install -g supabase`
2. Login: `supabase login`
3. Link project: `supabase link --project-ref your-project-id`
4. Apply migrations: `supabase db push`

### Manual Application

If you need to apply migrations manually:

1. Go to your Supabase Dashboard → SQL Editor
2. Run each migration file in order (001, 002, etc.)
3. Verify the changes in the Table Editor

## Migration Naming Convention

- Use 3-digit prefix: `001_`, `002_`, `003_`
- Use descriptive names: `001_initial_schema.sql`
- One major change per migration
- Always include rollback instructions in comments

## RLS Security

All tables have Row Level Security (RLS) enabled with appropriate policies:

- Users can only access their own data
- Admin functions require service role
- Public data is clearly marked

## Backup

Always backup your database before applying migrations:

```bash
supabase db dump --local > backup_$(date +%Y%m%d_%H%M%S).sql
```