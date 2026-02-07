import { prisma } from "@/lib/db";
import { redirect } from "next/navigation";
import BootstrapForm from "./BootstrapForm";

export default async function BootstrapPage() {
  const existing = await prisma.user.findFirst({ where: { role: "ADMIN" } });
  if (existing) redirect("/login");

  return (
    <main className="page-center">
      <BootstrapForm />
    </main>
  );
}
