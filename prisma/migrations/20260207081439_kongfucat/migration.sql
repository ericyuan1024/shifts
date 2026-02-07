-- CreateTable
CREATE TABLE "AvailabilityTemplate" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "roleTypeId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "hours" DOUBLE PRECISION NOT NULL,
    "choice" "PreferenceChoice" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AvailabilityTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AvailabilityTemplate_roleTypeId_idx" ON "AvailabilityTemplate"("roleTypeId");

-- CreateIndex
CREATE UNIQUE INDEX "AvailabilityTemplate_userId_roleTypeId_dayOfWeek_startTime__key" ON "AvailabilityTemplate"("userId", "roleTypeId", "dayOfWeek", "startTime", "endTime");

-- AddForeignKey
ALTER TABLE "AvailabilityTemplate" ADD CONSTRAINT "AvailabilityTemplate_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AvailabilityTemplate" ADD CONSTRAINT "AvailabilityTemplate_roleTypeId_fkey" FOREIGN KEY ("roleTypeId") REFERENCES "RoleType"("id") ON DELETE CASCADE ON UPDATE CASCADE;
