-- CreateEnum
CREATE TYPE "ClockAction" AS ENUM ('IN', 'OUT');

-- CreateTable
CREATE TABLE "TimeClock" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "action" "ClockAction" NOT NULL,
    "shiftTime" TIMESTAMP(3) NOT NULL,
    "punchedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ip" TEXT,
    "userAgent" TEXT,

    CONSTRAINT "TimeClock_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TimeClock_userId_shiftTime_idx" ON "TimeClock"("userId", "shiftTime");

-- CreateIndex
CREATE INDEX "TimeClock_shiftTime_idx" ON "TimeClock"("shiftTime");

-- AddForeignKey
ALTER TABLE "TimeClock" ADD CONSTRAINT "TimeClock_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
