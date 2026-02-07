-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('EMPLOYEE', 'ADMIN');

-- CreateEnum
CREATE TYPE "PreferenceChoice" AS ENUM ('WANT', 'CAN', 'CANT');

-- CreateEnum
CREATE TYPE "ScheduleStatus" AS ENUM ('DRAFT', 'FINALIZED');

-- CreateEnum
CREATE TYPE "AssignmentSource" AS ENUM ('AUTO', 'MANUAL');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'EMPLOYEE',
    "passcodeHash" TEXT NOT NULL,
    "weight" INTEGER NOT NULL DEFAULT 1,
    "maxHoursWeek" INTEGER NOT NULL DEFAULT 24,
    "roleTypeId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RoleType" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RoleType_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShiftTemplate" (
    "id" TEXT NOT NULL,
    "roleTypeId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "hours" DOUBLE PRECISION NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ShiftTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Week" (
    "id" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Week_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ShiftSlot" (
    "id" TEXT NOT NULL,
    "weekId" TEXT NOT NULL,
    "roleTypeId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "startAt" TIMESTAMP(3) NOT NULL,
    "endAt" TIMESTAMP(3) NOT NULL,
    "hours" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ShiftSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Preference" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "shiftSlotId" TEXT NOT NULL,
    "choice" "PreferenceChoice" NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Preference_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Schedule" (
    "id" TEXT NOT NULL,
    "weekId" TEXT NOT NULL,
    "status" "ScheduleStatus" NOT NULL DEFAULT 'DRAFT',
    "version" INTEGER NOT NULL DEFAULT 1,
    "generatedAt" TIMESTAMP(3),
    "finalizedAt" TIMESTAMP(3),

    CONSTRAINT "Schedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Assignment" (
    "id" TEXT NOT NULL,
    "scheduleId" TEXT NOT NULL,
    "shiftSlotId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "source" "AssignmentSource" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Assignment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_passcodeHash_key" ON "User"("passcodeHash");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "RoleType_name_key" ON "RoleType"("name");

-- CreateIndex
CREATE INDEX "ShiftTemplate_dayOfWeek_idx" ON "ShiftTemplate"("dayOfWeek");

-- CreateIndex
CREATE UNIQUE INDEX "Week_startDate_key" ON "Week"("startDate");

-- CreateIndex
CREATE INDEX "ShiftSlot_weekId_idx" ON "ShiftSlot"("weekId");

-- CreateIndex
CREATE INDEX "ShiftSlot_roleTypeId_idx" ON "ShiftSlot"("roleTypeId");

-- CreateIndex
CREATE INDEX "Preference_shiftSlotId_idx" ON "Preference"("shiftSlotId");

-- CreateIndex
CREATE UNIQUE INDEX "Preference_userId_shiftSlotId_key" ON "Preference"("userId", "shiftSlotId");

-- CreateIndex
CREATE UNIQUE INDEX "Schedule_weekId_key" ON "Schedule"("weekId");

-- CreateIndex
CREATE UNIQUE INDEX "Assignment_shiftSlotId_key" ON "Assignment"("shiftSlotId");

-- CreateIndex
CREATE INDEX "Assignment_scheduleId_idx" ON "Assignment"("scheduleId");

-- CreateIndex
CREATE INDEX "Assignment_userId_idx" ON "Assignment"("userId");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES "RoleType"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShiftTemplate" ADD CONSTRAINT "ShiftTemplate_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES "RoleType"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShiftSlot" ADD CONSTRAINT "ShiftSlot_weekId_fkey" FOREIGN KEY ("weekId") REFERENCES "Week"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ShiftSlot" ADD CONSTRAINT "ShiftSlot_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES "RoleType"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Preference" ADD CONSTRAINT "Preference_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Preference" ADD CONSTRAINT "Preference_shiftSlotId_fkey" FOREIGN KEY ("shiftSlotId") REFERENCES "ShiftSlot"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Schedule" ADD CONSTRAINT "Schedule_weekId_fkey" FOREIGN KEY ("weekId") REFERENCES "Week"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "Schedule"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_shiftSlotId_fkey" FOREIGN KEY ("shiftSlotId") REFERENCES "ShiftSlot"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assignment" ADD CONSTRAINT "Assignment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
