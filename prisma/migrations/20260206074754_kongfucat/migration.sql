/*
  Warnings:

  - A unique constraint covering the columns `[weekId,roleTypeId,startAt,endAt]` on the table `ShiftSlot` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "ShiftSlot_weekId_roleTypeId_startAt_endAt_key" ON "ShiftSlot"("weekId", "roleTypeId", "startAt", "endAt");
