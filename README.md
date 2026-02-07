# Scheduling MVP

Mobile-first scheduling for small teams. Employees sign in with a 4-digit passcode and can only edit their own availability. Admins can generate schedules, manually adjust, and finalize.

## Features
- 4-digit passcode login (unique per user)
- Open next 2 weeks automatically
- Employee availability: Want / Can / Can't
- Auto scheduling (preferences + weights + weekly hour cap)
- Admin manual adjustments
- Finalized schedules for employees
- Sync availability from last finalized week

## Default Roles
- Server
- Kitchen
- Manager (can cover any shift)

## Local Setup

1. Install dependencies
```bash
npm install
```

2. Configure the database
```bash
cp .env.example .env
```
Edit `.env` and set `DATABASE_URL` for your local PostgreSQL.

3. Generate Prisma client and migrate
```bash
npm run prisma:generate
npm run prisma:migrate
```

4. Start dev server
```bash
npm run dev
```

Open `http://localhost:3000`.

## First-time bootstrap
If no admin exists, visit:
```
http://localhost:3000/bootstrap
```

## Sign in
- Employee sign-in: `/login`
- Admin sign-in: `/admin/login`

## Recommended Flow
1. Admin creates shift templates
2. Admin creates employees and assigns roles
3. Employees set availability
4. Admin generates or adjusts schedule
5. Admin finalizes
6. Employees view final shifts
